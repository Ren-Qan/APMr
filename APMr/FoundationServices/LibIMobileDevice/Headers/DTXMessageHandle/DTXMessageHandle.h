//
//  DTXMessageHandle.h
//  TestAPP
//
//  Created by 任玉乾 on 2022/11/21.
//

#import <Foundation/Foundation.h>
#import <DTXMessageHandle/DTXArguments.h>
#import <DTXMessageHandle/DTXReceiveObject.h>

#import <libimobiledevice/libimobiledevice.h>

NS_ASSUME_NONNULL_BEGIN

@class DTXMessageHandle;

typedef NS_ENUM(NSUInteger, DTXMessageErrorCode) {
    DTXMessageErrorCodeMounterStartFailed = 1,
    DTXMessageErrorCodeMounterLookupImageFailed,
    DTXMessageErrorCodeNotFoundSignature,
    DTXMessageErrorCodeUploadImageFailed,
    DTXMessageErrorCodeNotFoundImagePath,
    DTXMessageErrorCodeMonterMountImageFailed,
    DTXMessageErrorCodeStartInstrumentsServiceFailed,
    DTXMessageErrorCodeInstrumentsHandShakeFailed,
    DTXMessageErrorCodeReadMessageHeaderFailed,
    DTXMessageErrorCodeBadHeaderMagic,
    DTXMessageErrorCodeInvalidConversationIndex,
    DTXMessageErrorCodeReadingFromSocketFailed,
};

typedef NS_ENUM(NSUInteger, DTXMessageProgressState) {
    DTXMessageProgressStateMonterStartService = 1,
    DTXMessageProgressStateMonterLookupImage,
    DTXMessageProgressStateFindSignature,
    DTXMessageProgressStateMonterUploadImage,
    DTXMessageProgressStateFindImagePath,
    DTXMessageProgressStateMonterMountImage,
    DTXMessageProgressStateStartInstrumentsService,
    DTXMessageProgressStateInstrumentsHandShake,
};

@protocol DTXMessageHandleDelegate <NSObject>

@optional

- (void)error:(DTXMessageErrorCode)error
      message:(NSString * _Nullable)message
       handle:(DTXMessageHandle *)handle;

- (void)progress:(DTXMessageProgressState)progress
         message:(NSString * _Nullable)message
          handle:(DTXMessageHandle *)handle;

@end

@interface DTXMessageHandle : NSObject

@property (nonatomic, weak) id<DTXMessageHandleDelegate> delegate;

- (void)stopService;

- (BOOL)connectInstrumentsServiceWithDevice:(idevice_t)device;

- (BOOL)isVaildServer:(NSString *)server;

- (BOOL)sendWithChannel:(uint32_t)channel
             identifier:(uint32_t)identifier
               selector:(NSString *)selector
                   args:(DTXArguments * _Nullable)args
           expectsReply:(BOOL)expectsReply;

- (DTXReceiveObject * _Nullable)receive;

@end

NS_ASSUME_NONNULL_END
