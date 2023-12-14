//
//  DTXMessageHandle.m
//  TestAPP
//
//  Created by 任玉乾 on 2022/11/21.
//

#import <DTXMessageHandle/DTXMessageHandle.h>
#import <DTXConnection/DTXDiskMountConnection.h>
#import <DTXConnection/DTXRSDConnection.h>

@interface DTXMessageHandle()

@property (nonatomic, strong) DTXDiskMountConnection *diskMount;

@property (nonatomic, strong) DTXRSDConnection *rsd;

@end

@implementation DTXMessageHandle {
    DTXConnection *_connection;
    
    NSDictionary *_server_dic;
    NSMutableDictionary <NSString *, DTXPayload *> *_receive_map;
}

- (DTXDiskMountConnection *)diskMount {
    if (!_diskMount) {
        _diskMount = [DTXDiskMountConnection.alloc init];
    }
    return _diskMount;
}

- (DTXRSDConnection *)rsd {
    if (!_rsd) {
        _rsd = [DTXRSDConnection.alloc init];
    }
    return  _rsd;
}

- (void)dealloc {
    [self stopService];
}

// MARK: - Private -

- (void)log:(NSString *)message {
    if ([self.delegate respondsToSelector:@selector(log:handle:)]) {
        [self.delegate log:message handle:self];
    }
}

- (void)complete:(NSString *)message success:(BOOL)success {
    if ([self.delegate respondsToSelector:@selector(complete:success:handle:)]) {
        [self.delegate complete:message success:success handle:self];
    }
}

- (void)progress:(NSString *)message {
    if ([self.delegate respondsToSelector:@selector(progress:handle:)]) {
        [self.delegate progress:message handle:self];
    }
}

// MARK: - Setup -

- (BOOL)instrumentsHandshake {
    [self progress: @"instruments_shake_hand_begin"];
    
    NSDictionary * par = @{
        @"com.apple.private.DTXBlockCompression" : @2,
        @"com.apple.private.DTXConnection" : @1,
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
    
    [self complete:@"instrument" success:success];
    return success;
}

- (NSData *)getByteWithObj:(id)obj {
    return [NSKeyedArchiver archivedDataWithRootObject:obj requiringSecureCoding:NO error:NULL];
}

// MARK: - Public -

- (void)stopService {
    if (_connection) {
        [_connection stop];
    }
    
    _connection = NULL;
    _server_dic = NULL;
    _receive_map = NULL;
}

- (BOOL)connectInstrumentsServiceWithDevice:(idevice_t)device
                                  osVersion:(NSString *)osVersion {
    [self stopService];
    NSInteger version = [osVersion componentsSeparatedByString:@"."].firstObject.intValue;
    
    if (version >= 14 && version < 17) {
        _connection = self.diskMount;
    } else if (version >= 17) {
        _connection = self.rsd;
    }
    
    BOOL connectionIsSuccess = NO;
    if (_connection) {
        __weak typeof(self) _self = self;
        connectionIsSuccess = [_connection connectionWithDevice:device
                                                      osVersion:osVersion
                                                       progress:^(NSString * _Nonnull message) {
            [_self progress:message];
        } complete:^(NSString * _Nonnull message, BOOL success) {
            [_self complete:message success:success];
        }];
    }
    
    if (connectionIsSuccess) {
        return [self instrumentsHandshake];
    }
    
    return NO;
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
    if (!_connection) { return NO; }
    
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
    
    NSData *datas = [argument bytes];

    return [_connection sendData:datas];
}

- (DTXReceiveObject * _Nullable)receive {
    if (!_connection) { return NULL; }
    
    uint32_t channelCode = 0;
    uint32_t identifier = 0;
    NSData *payload = NULL;
    
    while (true) {
        if (!_connection) { return NULL; }

        NSData *receiveData = [_connection receiveWithSize:sizeof(struct DTXMessageHeader)];
        struct DTXMessageHeader mheader = *(struct DTXMessageHeader *)receiveData.bytes;
        
        if (receiveData.length != sizeof(mheader)) {
            NSString *error = [NSString stringWithFormat:@"failed to read message header: %s, nrecv = %lx", strerror(errno), (unsigned long)receiveData.length];
            [self log:error];
            return NULL;
        }
        
        if (mheader.magic != 0x1F3D5B79) {
            [self log:[NSString stringWithFormat:@"bad header magic: %x", mheader.magic]];
            return NULL;
        }
        
        if (mheader.conversationIndex != 0 && mheader.conversationIndex != 1) {
            [self log:[NSString stringWithFormat:@"invalid conversation index: %d", mheader.conversationIndex]];
            return NULL;
        }
        
        if (mheader.fragmentId == 0) {
            identifier = mheader.identifier;
            channelCode = mheader.channelCode;
            if (mheader.fragmentCount > 1) continue;
        }
        
        NSMutableData *frag = [NSMutableData data];
        uint32_t nbytes = 0;
                
        while (nbytes < mheader.length) {
            uint32_t curlen = mheader.length - nbytes;
            NSData *curptr = [_connection receiveWithSize:curlen];
                                            
            if (curptr.length > 0) {
                [frag appendData:curptr];
                nbytes += curptr.length;
            }
        }
        
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
    return [_connection fd];
}

@end
