//
//  DTXConnection.m
//  APMr
//
//  Created by 任玉乾 on 2023/12/14.
//

#import <DTXConnection/DTXConnection.h>

@implementation DTXConnection

- (void)dealloc {
    [self stop];
}

- (void)stop {
    
}

- (BOOL)connectionWithDevice:(idevice_t)device
                   osVersion:(NSString *)osVersion
                    progress:(void (^)(NSString * message))progress
                    complete:(void (^)(NSString * message, BOOL success))complete {
    [self stop];
    
    return NO;
}

- (BOOL)sendData:(NSData *)data {
    return NO;
}

- (NSData * _Nullable)receiveWithSize:(uint32)size {
    return NULL;
}

- (NSNumber * _Nullable)fd {
    return NULL;
}

@end
