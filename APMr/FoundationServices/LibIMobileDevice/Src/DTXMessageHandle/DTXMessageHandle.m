//
//  DTXMessageHandle.m
//  TestAPP
//
//  Created by 任玉乾 on 2022/11/21.
//

#import <DTXMessageHandle/DTXMessageHandle.h>

#import <stdio.h>
#import <stdint.h>
#import <stdlib.h>

#import <libimobiledevice/lockdown.h>
#import <libimobiledevice/mobile_image_mounter.h>
#import <libimobiledevice/service.h>

#define REMOTESERVER_SERVICE_NAME "com.apple.instruments.remoteserver.DVTSecureSocketProxy"

struct DTXMessageHeader {
    uint32_t magic;
    uint32_t cb;
    uint16_t fragmentId;
    uint16_t fragmentCount;
    uint32_t length;
    uint32_t identifier;
    uint32_t conversationIndex;
    uint32_t channelCode;
    uint32_t expectsReply;
};

struct DTXMessagePayloadHeader {
    uint32_t flags;
    uint32_t auxiliaryLength;
    uint64_t totalLength;
};

@interface DTXPayload : NSObject

@property (nonatomic, assign) uint32_t identifier;

@property (nonatomic, assign) uint32_t channel;

@property (nonatomic, strong, readonly) NSMutableArray<NSData *> *payloads;

- (instancetype)initWithCapacity:(NSInteger)capacity;

- (void)addData:(NSData *)data index:(NSInteger)index;

- (NSData *)data;

- (BOOL)readComplete;

@end

@interface DTXMessageHandle()

@end

@implementation DTXMessageHandle {
    idevice_connection_t _connection;
    mobile_image_mounter_client_t _mounter_client;
        
    NSDictionary *_server_dic;
    NSMutableDictionary <NSString *, DTXPayload *> *_receive_map;
}

- (void)dealloc {
    [self stopService];
}

// MARK: - Private -

- (void)error:(DTXMessageErrorCode)error message:(NSString *)message {
    if ([self.delegate respondsToSelector:@selector(error:message:handle:)]) {
        [self.delegate error:error message:message handle:self];
    }
}

- (void)progress:(DTXMessageProgressState)progress message:(NSString *)message {
    if ([self.delegate respondsToSelector:@selector(progress:message:handle:)]) {
        [self.delegate progress:progress message:message handle:self];
    }
}

// MARK: - Setup -

- (BOOL)setupWithDevice:(idevice_t)device {
    if (!device) { return NO; }
    
    BOOL state = YES;
    BOOL isNeedMountImage = NO;
    
    uint64_t signture_length = 0;
    char *signature_string = NULL;
    char * image_path = NULL;

    plist_t mounter_lookup_result = NULL;
    plist_t mount_image_result = NULL;
    
    [self progress:DTXMessageProgressStateMonterStartService message:@"mobile_image_mounter_start_service"];
    if (mobile_image_mounter_start_service(device, &_mounter_client, "INSTRUMENTS") != 0) {
        [self error:DTXMessageErrorCodeMounterStartFailed message:@"mounter_start_service_failed"];
        state = NO;
    }
    
    if (state) {
        [self progress:DTXMessageProgressStateMonterLookupImage message:@"mobile_image_mounter_lookup_image"];
        if (mobile_image_mounter_lookup_image(_mounter_client, "Developer", &mounter_lookup_result) != 0) {
            [self error:DTXMessageErrorCodeMounterLookupImageFailed message:@"mounter_lookup_image_failed"];
            state = NO;
        }
    }
    
    if (state) {
        [self progress:DTXMessageProgressStateFindSignature message:@"finding ImageSignature"];
        plist_t signature_map = plist_dict_get_item(mounter_lookup_result, "ImageSignature");
        plist_t signature_arr = plist_array_get_item(signature_map, 0);
                
        plist_get_data_val(signature_arr, &signature_string, &signture_length);
        
        if (signture_length <= 0 || signature_string == NULL) {
            isNeedMountImage = YES;
        }
    }
    
    if (isNeedMountImage) {
        if (state) {
            [self progress:DTXMessageProgressStateMonterUploadImage message:@"mobile_image_mounter_upload_image"];
            if (mobile_image_mounter_upload_image(_mounter_client, "Developer", 9, signature_string, (uint16_t)signture_length, upload_mounter_callback, NULL) != 0) {
                [self error:DTXMessageErrorCodeUploadImageFailed message:@"upload image error"];
                state = NO;
            }
        }
        
        if (state) {
            [self progress:DTXMessageProgressStateFindImagePath message:@"find_image_path"];
            image_path = find_image_path(device);
            if (image_path == NULL) {
                [self error:DTXMessageErrorCodeNotFoundImagePath message:@"not found imagePath"];
                state = NO;
            }
        }
        
        if (state) {
            [self progress:DTXMessageProgressStateMonterMountImage message:@"mobile_image_mounter_mount_image"];
            mobile_image_mounter_mount_image(_mounter_client, image_path, signature_string, signture_length, "Developer", &mount_image_result);
        }
    }
    
    if (state) {
        [self progress:DTXMessageProgressStateStartInstrumentsService message:@"service_client_factory_start_service"];
        if (service_client_factory_start_service(device, REMOTESERVER_SERVICE_NAME, (void **)(&_connection), "Remote", SERVICE_CONSTRUCTOR(constructor_remote_service), NULL) != 0) {
            [self error:DTXMessageErrorCodeStartInstrumentsServiceFailed message:@"strat instruments service failed"];
            state = NO;
        }
    }
    
    if (state) {
        if (_connection) {
            state = [self instrumentsShakeHand];
        }
    }
        
    if (image_path) free(image_path);
    if (signature_string) free(signature_string);
    if (mount_image_result) plist_free(mount_image_result);
    if (mounter_lookup_result) plist_free(mounter_lookup_result);
    
    return state;
}

- (BOOL)instrumentsShakeHand {
    [self progress:DTXMessageProgressStateInstrumentsHandShake message:@"instruments_shake_and"];
    
    NSDictionary * par = @{
        @"com.apple.private.DTXBlockCompression" : [NSNumber numberWithLongLong:2],
        @"com.apple.private.DTXConnection" : [NSNumber numberWithLongLong:1]
    };
    
    DTXArguments *args = [[DTXArguments alloc] init];
    [args appendObject:par];
    
    [self sendWithChannel:9
               identifier:10000
                 selector:@"_notifyOfPublishedCapabilities:"
                     args:args
             expectsReply:NO];
    
    DTXReceiveObject *result= [self receive];
    
    NSString *string = (NSString *)[result object];
    NSDictionary *serverDic = (NSDictionary *)[result.array firstObject];
    BOOL success = NO;
    
    if (string && serverDic) {
        if ([string isKindOfClass:[NSString class]] && [string isEqualToString:@"_notifyOfPublishedCapabilities:"] && [serverDic isKindOfClass:[NSDictionary class]]) {
            _server_dic = serverDic;
            _receive_map = [NSMutableDictionary dictionary];
            success = YES;
        }
    }
    
    if (!success) {
        [self error:DTXMessageErrorCodeInstrumentsHandShakeFailed message:@"instruments hand shake failed"];
    } else {
        [self progress:DTXMessageProgressStateSuccess message:@"success"];
    }
    
    return success;
}

- (NSData *)getByteWithObj:(id)obj {
    return [NSKeyedArchiver archivedDataWithRootObject:obj requiringSecureCoding:NO error:NULL];
}

// MARK: - Public -

- (void)stopService {
    if (_connection) {
        idevice_disconnect(_connection);
    }
    
    if (_mounter_client) {
        mobile_image_mounter_free(_mounter_client);
    }
    
    _connection = NULL;
    _mounter_client = NULL;
    _server_dic = NULL;
    _receive_map = NULL;
}

- (BOOL)connectInstrumentsServiceWithDevice:(idevice_t)device {
    [self stopService];
    return [self setupWithDevice:device];
}

- (BOOL)isVaildServer:(NSString *)server {
    if ([_server_dic objectForKey:server]) {
        return YES;
    }
    return NO;
}

// MARK: Send Message / Receive Message

- (BOOL)sendWithChannel:(uint32_t)channel
             identifier:(uint32_t)identifier
               selector:(NSString *)selector
                   args:(DTXArguments *)args
           expectsReply:(BOOL)expectsReply {
    
    NSData *selData = [self getByteWithObj:selector];
    NSData *argData = [args getArgBytes];
    
    struct DTXMessagePayloadHeader pheader;
    pheader.flags = 0x2 | (expectsReply ? 0x1000 : 0);
    pheader.auxiliaryLength = (uint32)(argData.length);
    pheader.totalLength = argData.length + selData.length;
    
    struct DTXMessageHeader mheader;
    mheader.magic = 0x1F3D5B79;
    mheader.cb = sizeof(struct DTXMessageHeader);
    mheader.fragmentId = 0;
    mheader.fragmentCount = 1;
    mheader.length = (uint32_t)(sizeof(pheader) + pheader.totalLength);
    mheader.identifier = (uint32_t)identifier;
    mheader.conversationIndex = 0;
    mheader.channelCode = channel;
    mheader.expectsReply = (expectsReply ? 1 : 0);
    
    DTXArguments *argument = [[DTXArguments alloc] init];
    [argument append_v:&mheader len:sizeof(mheader)];
    [argument append_v:&pheader len:sizeof(pheader)];
    [argument append_b:argData];
    [argument append_b:selData];
    
    uint32_t nsent;
    NSData *datas = [argument bytes];
    size_t msglen = datas.length;
    
    idevice_connection_send(_connection, [datas bytes], (uint32_t)msglen, &nsent);
    
    return nsent == msglen;
}

- (DTXReceiveObject * _Nullable)receive {
    uint32_t channelCode = 0;
    uint32_t identifier = 0;
    NSData *payload = NULL;
    
    while (true) {
        struct DTXMessageHeader mheader;
        uint32_t nrecv = 0;
        idevice_connection_receive(_connection, (char *)(&mheader), sizeof(mheader), &nrecv);
        
        if (nrecv != sizeof(mheader)) {
            [self error:DTXMessageErrorCodeReadMessageHeaderFailed
                message:[NSString stringWithFormat:@"failed to read message header: %s, nrecv = %x", strerror(errno), nrecv]];
            return NULL;
        }
        
        if (mheader.magic != 0x1F3D5B79) {
            [self error:DTXMessageErrorCodeBadHeaderMagic
                message:[NSString stringWithFormat:@"bad header magic: %x", mheader.magic]];
            return NULL;
        }
        
        if (mheader.conversationIndex != 0 && mheader.conversationIndex != 1) {
            [self error:DTXMessageErrorCodeInvalidConversationIndex
                message:[NSString stringWithFormat:@"invalid conversation index: %d", mheader.conversationIndex]];
            return NULL;
        }
        
        if (mheader.fragmentId == 0) {
            identifier = mheader.identifier;
            channelCode = mheader.channelCode;
            if (mheader.fragmentCount > 1) continue;
        }
        
        NSMutableData *frag = [NSMutableData data];
        uint32_t nbytes = 0;
        uint8_t *fragData = (uint8_t *)malloc(sizeof(uint8_t) * mheader.length);
                
        while (nbytes < mheader.length) {
            uint8_t *curptr = fragData + nbytes;
            size_t curlen = mheader.length - nbytes;
            idevice_connection_receive(_connection, (char *)curptr, (uint32_t)curlen, &nrecv);
                                
            if (nrecv > 0) {
                NSData *temData = [NSData dataWithBytes:curptr length:nrecv];
                [frag appendData:temData];
                nbytes += nrecv;
            }
        }
        
        free(fragData);

        NSString *key = [NSString stringWithFormat:@"%@-%@", @(mheader.channelCode), @(mheader.identifier)];
        BOOL loadFinish = NO;

        if (mheader.fragmentCount == 1) {
            payload = frag;
            loadFinish = YES;
        } else {
            DTXPayload *localPayload = _receive_map[key];
            if (!localPayload) {
                localPayload = [DTXPayload.alloc initWithCapacity:mheader.fragmentCount];
                localPayload.identifier = mheader.identifier;
                localPayload.channel = mheader.channelCode;
                _receive_map[key] = localPayload;
            }
            
            [localPayload addData:frag index:mheader.fragmentId];
            if (mheader.fragmentId == mheader.fragmentCount - 1 && localPayload.readComplete) {
                payload = [localPayload data];
                channelCode = localPayload.channel;
                identifier = localPayload.identifier;
                [localPayload.payloads removeAllObjects];
                loadFinish = YES;
            }
        }
        
        if (loadFinish) {
            _receive_map[key] = NULL;
            break;
        }
    }
        
    struct DTXMessagePayloadHeader *pheader = (struct DTXMessagePayloadHeader *)(payload.bytes);
    const uint8_t *auxptr = payload.bytes + sizeof(struct DTXMessagePayloadHeader);
    uint32_t auxlen = pheader->auxiliaryLength;
    
    const uint8_t *objptr = auxptr + auxlen;
    uint64_t objlen = 0;
    objlen = pheader->totalLength - auxlen;
            
    DTXReceiveObject *result = [[DTXReceiveObject alloc] init];
    
    [result setChannel:channelCode];
    [result setIdentifier:identifier];
    [result setFlag:pheader -> flags];
    
    if (auxlen != 0) {
        NSData *data = [NSData dataWithBytesNoCopy:(void *)auxptr length:auxlen freeWhenDone:NO];
        [result deserializeWithData:data];
    }
    
    if (objlen != 0) {
        NSData *data = [NSData dataWithBytesNoCopy:(void *)objptr length:objlen freeWhenDone:NO];
        [result unarchiverWithData:data];
    }
    return result;
}

- (NSNumber * _Nullable)fd {
    if (!_connection) {
        return NULL;
    }
    
    int fd = -1;
    if (idevice_connection_get_fd(_connection, &fd) == IDEVICE_E_SUCCESS && fd != -1) {
        return [NSNumber.alloc initWithInt:fd];
    }
    return NULL;
}

// MARK: - C Func -

ssize_t upload_mounter_callback(void* buffer, size_t length, void *user_data) {
    return 0;
}

int32_t constructor_remote_service(idevice_t device,
                                   lockdownd_service_descriptor_t service,
                                   idevice_connection_t * conn) {
    if (!device || !service || service -> port == 0) {
        return SERVICE_E_INVALID_ARG;
    }
    
    // connect
    idevice_connection_t connection;
    idevice_error_t error = idevice_connect(device, service -> port, &connection);
    if (error != IDEVICE_E_SUCCESS) {
        return error;
    };
    
    int fd;
    error = idevice_connection_get_fd(connection, &fd);
    if (error != IDEVICE_E_SUCCESS) {
        return error;
    }
    
    if (service -> ssl_enabled) {
        idevice_connection_enable_ssl(connection);
    }
        
    (*conn) = connection;
    return SERVICE_E_SUCCESS;
}

char * idevice_get_version(idevice_t device) {
    if (device == NULL) {
        return NULL;
    }
    
    char *s_version = NULL;
    lockdownd_client_t client_loc = NULL;
    plist_t p_version = NULL;
    
    lockdownd_client_new(device, &client_loc, "getVersion");
    
    if (lockdownd_get_value(client_loc, NULL, "ProductVersion", &p_version) == 0) {
        plist_get_string_val(p_version, &s_version);
    }
    
    lockdownd_client_free(client_loc);
    plist_free(p_version);
    return s_version;
}

char * find_image_path(idevice_t device) {
    char * version = idevice_get_version(device);
    if (version == NULL) {
        return NULL;
    }
    
    const char *path = "/Applications/Xcode.app/Contents/Developer/Platforms/iPhoneOS.platform/DeviceSupport/";
    const char *fileName = "/DeveloperDiskImage.dmg";
    
    int len = (int)(strlen(version) + strlen(path) + strlen(fileName) + 1);
    char * result = (char *)malloc(sizeof(char) * len);
    
    strcat(result, path);
    strcat(result, version);
    strcat(result, fileName);
    
    return result;
}

@end


@implementation DTXPayload {
    NSInteger _count;
    NSInteger _capacity;
    
    NSInteger _currentLen;
    NSInteger _totalLen;
}

- (instancetype)initWithCapacity:(NSInteger)capacity {
    if (self = [super init]) {
        _payloads = [NSMutableArray arrayWithCapacity:capacity];
        for (int i = 0; i < capacity; i++) {
            [_payloads addObject:[NSData data]];
        }
        _capacity = capacity;
        _count = 0;
        _totalLen = -1;
        _currentLen = 0;
    }
    return self;
}

- (void)addData:(NSData *)data index:(NSInteger)index {
    if (index == 1 && data.length > 16) {
        struct DTXMessagePayloadHeader *pheader = (struct DTXMessagePayloadHeader *)(data.bytes);
        _totalLen = pheader->totalLength + 16;
    }
    
    if (index < _capacity) {
        _payloads[index] = data;
        _count += 1;
        _currentLen += data.length;
    }
}

- (NSData *)data {
    NSMutableData *data = [NSMutableData data];
    [_payloads enumerateObjectsUsingBlock:^(NSData * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [data appendData:obj];
    }];
    return data;
}

- (BOOL)readComplete {
    return _currentLen >= _totalLen;
}

@end
