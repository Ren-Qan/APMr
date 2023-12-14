//
//  DTXDiskMountConnection.m
//  APMr
//
//  Created by 任玉乾 on 2023/12/14.
//

#import <DTXConnection/DTXDiskMountConnection.h>

#import <libimobiledevice/mobile_image_mounter.h>
#import <libimobiledevice/service.h>

#define REMOTESERVER_SERVICE_NAME "com.apple.instruments.remoteserver.DVTSecureSocketProxy"

@implementation DTXDiskMountConnection {
    idevice_connection_t _connection;
    mobile_image_mounter_client_t _mounter_client;
}

- (void)stop {
    if (_connection) {
        idevice_disconnect(_connection);
    }
    
    if (_mounter_client) {
        mobile_image_mounter_free(_mounter_client);
    }
    
    _connection = NULL;
    _mounter_client = NULL;
}

- (NSData * _Nullable)receiveWithSize:(uint32)size {
    if (!_connection) { return NULL; }
    
    NSData *data = NULL;
    uint32_t recv_len = 0;
    uint8_t * stream = (uint8_t *)malloc(sizeof(uint8_t) * size);
    idevice_error_t state = idevice_connection_receive(_connection, (char *)stream, (uint32_t)size, &recv_len);

    if (state == 0 && recv_len > 0) {
        data = [NSData dataWithBytes:stream length:recv_len];
    }
    
    free(stream);
    return data;
}

- (BOOL)sendData:(nonnull NSData *)data {
    if (!_connection) { return FALSE; }
    
    uint32_t nsent = 0;
    size_t msglen = data.length;
    
    idevice_connection_send(_connection, [data bytes], (uint32_t)msglen, &nsent);
    
    return nsent == msglen;
}

- (BOOL)connectionWithDevice:(idevice_t)device
                   osVersion:(NSString *)osVersion
                    progress:(void (^)(NSString * message))progress
                    complete:(void (^)(NSString * message, BOOL success))complete {
    [self stop];
    if (!device) { return NO; }
    
    BOOL state = YES;
    BOOL isNeedMountImage = NO;
    
    uint64_t signture_length = 0;
    char *signature_string = NULL;

    plist_t mounter_lookup_result = NULL;
    plist_t mount_image_result = NULL;

    const char *image_path = [[self getDeviceSupportURLWithOSVersion:osVersion] cStringUsingEncoding:NSUTF8StringEncoding];
    
    void (^progressBlock)(NSString *) = ^(NSString *message) {
        if (progress) {
            progress(message);
        }
    };
    
    void (^completeBlock)(NSString *, BOOL) = ^(NSString *message, BOOL success) {
        if (complete) {
            complete(message, success);
        }
    };
    
    progressBlock(@"mobile_image_mounter_start_service");
    if (mobile_image_mounter_start_service(device, &_mounter_client, "INSTRUMENTS") != 0) {
        completeBlock(@"mobile_image_mounter_start_service_falied", NO);
        state = NO;
    }
    
    if (state) {
        progressBlock(@"mobile_image_mounter_lookup_image");
        if (mobile_image_mounter_lookup_image(_mounter_client, "Developer", &mounter_lookup_result) != 0) {
            completeBlock(@"mobile_image_mounter_lookup_image_falied", NO);
            state = NO;
        }
    }
    
    if (state) {
        plist_t signature_map = plist_dict_get_item(mounter_lookup_result, "ImageSignature");
        plist_t signature_arr = plist_array_get_item(signature_map, 0);
                
        progressBlock(@"finding_signature");
        plist_get_data_val(signature_arr, &signature_string, &signture_length);
        
        if (signture_length <= 0 || signature_string == NULL) {
            isNeedMountImage = YES;
        }
    }
    
    if (isNeedMountImage) {
        if (state) {
            progressBlock(@"mobile_image_mounter_upload_image");
            if (mobile_image_mounter_upload_image(_mounter_client, "Developer", 9, signature_string, (uint16_t)signture_length, upload_mounter_callback, NULL) != 0) {
                completeBlock(@"mobile_image_mounter_upload_image_falied", NO);
                state = NO;
            }
        }
                
        if (state) {
            progressBlock(@"mobile_image_mounter_mount_diskimage");
            if (mobile_image_mounter_mount_image(_mounter_client, image_path, signature_string, signture_length, "Developer", &mount_image_result) != 0) {
                completeBlock(@"mobile_image_mounter_mount_image_falied", NO);
                state = NO;
            }
        }
    }
    
    if (state) {
        progressBlock(@"service_client_factory_start_service");
        if (service_client_factory_start_service(device, REMOTESERVER_SERVICE_NAME, (void **)(&_connection), "Remote", SERVICE_CONSTRUCTOR(constructor_remote_service), NULL) != 0) {
            completeBlock(@"service_client_factory_start_service_falied", NO);
            state = NO;
        }
    }
    

    if (signature_string) free(signature_string);
    if (mount_image_result) plist_free(mount_image_result);
    if (mounter_lookup_result) plist_free(mounter_lookup_result);
    
    if (state) {
        completeBlock(@"diskMount_connection_success", YES);
    }
    
    return state;
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

- (NSString *)getDeviceSupportURLWithOSVersion:(NSString *)version {
    NSString *prePath = @"/Applications/Xcode.app/Contents/Developer/Platforms/iPhoneOS.platform/DeviceSupport/";
    NSString *name = @"/DeveloperDiskImage.dmg";
    return [NSString stringWithFormat:@"%@%@%@", prePath, version, name];
}

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

@end
