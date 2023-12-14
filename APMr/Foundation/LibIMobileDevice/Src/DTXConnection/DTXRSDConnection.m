//
//  DTXRSDConnection.m
//  APMr
//
//  Created by 任玉乾 on 2023/12/14.
//

#import <DTXConnection/DTXRSDConnection.h>

@implementation DTXRSDConnection

- (void)stop { }

- (NSData * _Nullable)receiveWithSize:(uint32)size {
    return NULL;
}

- (BOOL)sendData:(nonnull NSData *)data {
    return NO;
}

- (BOOL)connectionWithDevice:(idevice_t)device
                   osVersion:(NSString *)osVersion
                    progress:(void (^)(NSString * message))progress
                    complete:(void (^)(NSString * message, BOOL success))complete {
    return NO;
}

@end
