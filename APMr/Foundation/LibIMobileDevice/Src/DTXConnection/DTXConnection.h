//
//  DTXConnection.h
//  APMr
//
//  Created by 任玉乾 on 2023/12/14.
//

#import <Foundation/Foundation.h>
#import <libimobiledevice/libimobiledevice.h>

NS_ASSUME_NONNULL_BEGIN

@interface DTXConnection : NSObject

- (void)stop;

- (BOOL)connectionWithDevice:(idevice_t)device 
                   osVersion:(NSString *)osVersion
                    progress:(void (^)(NSString * message))progress
                    complete:(void (^)(NSString * message, BOOL success))complete;

- (BOOL)sendData:(NSData *)data;

- (NSData * _Nullable)receiveWithSize:(uint32)size;

- (NSNumber * _Nullable)fd;

@end

NS_ASSUME_NONNULL_END
