//
//  DTXPayload.h
//  APMr
//
//  Created by 任玉乾 on 2023/12/14.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

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

NS_ASSUME_NONNULL_END
