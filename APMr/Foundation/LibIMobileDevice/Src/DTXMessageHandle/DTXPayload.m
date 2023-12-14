//
//  DTXPayload.m
//  APMr
//
//  Created by 任玉乾 on 2023/12/14.
//

#import "DTXPayload.h"

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
        _totalLen = pheader -> totalLength + 16;
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
