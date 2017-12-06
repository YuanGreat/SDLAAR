//
//  ProxyManager.h
//  SmartDeviceLink-iOS

#import <Foundation/Foundation.h>

@class SDLManager;

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

@property (assign, nonatomic, readonly) ProxyState state;
@property (strong, nonatomic) SDLManager *sdlManager;

+ (instancetype)sharedManager;
- (void)startIAP;
- (void)startTCP;
- (void)reset;




@end

