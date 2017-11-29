//
//  ProxyManager.h
//  SmartDeviceLink-iOS

#import <Foundation/Foundation.h>

@class SDLManager;
@class SDLStreamingMediaManager;
@class SDLOnSystemRequest;
@class SDLRegisterAppInterfaceResponse;

@protocol AASDLDelegate <NSObject>

@optional
- (void)aaOnOnSystemRequest:(SDLOnSystemRequest *)notification;
- (void)aaOnRegisterAppInterfaceResponse:(SDLRegisterAppInterfaceResponse *)response;
- (void)aaManagerDidDisconnect;
@end


typedef NS_ENUM(NSUInteger, ProxyTransportType) {
    ProxyTransportTypeUnknown,
    ProxyTransportTypeTCP,
    ProxyTransportTypeIAP
};

typedef NS_ENUM(NSUInteger, ProxyState) {
    ProxyStateStopped,
    ProxyStateSearchingForConnection,
    ProxyStateConnected
};

extern NSString *const ASDLLockScreenStatusNotification;
extern NSString *const ASDLNotificationUserInfoObject;
extern NSString *const ASDLOnSystemRequestNotification;

@interface ProxyManager : NSObject

@property (nonatomic,weak) id<AASDLDelegate> aaSDLDelegate;
@property (assign, nonatomic, readonly) ProxyState state;
@property (strong, nonatomic) SDLManager *sdlManager;

+ (instancetype)sharedManager;
- (void)startIAP;
- (void)startTCP;
- (void)reset;




@end

