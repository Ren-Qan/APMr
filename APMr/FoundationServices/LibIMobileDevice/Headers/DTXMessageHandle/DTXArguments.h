//
//  DTXArguments.h
//  TestAPP
//
//  Created by 任玉乾 on 2022/11/21.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface DTXArguments : NSObject

+ (instancetype)args;

- (NSMutableData *)bytes;

- (NSData *)getArgBytes;

- (void)appendObject:(id)object;

- (void)appendData:(NSData *)data;

- (void)appendInt32Num:(int32_t)num;

- (void)appendUInt32Num:(uint32_t)num;

- (void)appendInt64Num:(int64_t)num;

- (void)appendUInt64Num:(uint64_t)num;

- (void)append_b:(NSData *)data;

- (void)append_v:(const void *)v len:(NSUInteger)len;

@end

NS_ASSUME_NONNULL_END
