//
//  DTXMessageHandle.h
//  TestAPP
//
//  Created by 任玉乾 on 2022/11/21.
//

#import <Foundation/Foundation.h>
#import <DTXMessageHandle/DTXPayload.h>
#import <DTXMessageHandle/DTXArguments.h>
#import <DTXMessageHandle/DTXReceiveObject.h>

#import <libimobiledevice/libimobiledevice.h>

NS_ASSUME_NONNULL_BEGIN

@class DTXMessageHandle;

@protocol DTXMessageHandleDelegate <NSObject>

@optional

- (void)log:(nonnull NSString *)message
     handle:(DTXMessageHandle *)handle;

- (void)complete:(nonnull NSString *)message
         success:(BOOL)success
          handle:(DTXMessageHandle *)handle;

- (void)progress:(nonnull NSString *)message
          handle:(DTXMessageHandle *)handle;

@end

@interface DTXMessageHandle : NSObject

@property (nonatomic, weak) id<DTXMessageHandleDelegate> delegate;

- (void)stopService;

- (BOOL)isVaildServer:(NSString *)server;

- (BOOL)connectInstrumentsServiceWithDevice:(idevice_t)device
                                  osVersion:(NSString *)osVersion;

- (BOOL)sendWithChannel:(uint32_t)channel
             identifier:(uint32_t)identifier
               selector:(NSString *)selector
                   args:(DTXArguments * _Nullable)args
           expectsReply:(BOOL)expectsReply;

- (DTXReceiveObject * _Nullable)receive;

- (NSNumber * _Nullable)fd;

@end

NS_ASSUME_NONNULL_END
