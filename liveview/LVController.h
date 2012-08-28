//
//  LVController.h
//  
//
//  Created by Ari on 3/31/11.
//  Copyright 2011 Squish Software. All rights reserved.
//

#include <unistd.h>
#include <stdio.h>
#include <stdlib.h>
#include <strings.h>
#include <errno.h>
#include <string.h>
#include <fcntl.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <btstack/btstack.h>
#include <btstack/utils.h>

//#import <BTstack/BTDiscoveryViewController.h>
//#import <BTstack/BTstackManager.h>
#import <MediaPlayer/MediaPlayer.h>
#import "NSMutableData+endian.h"
#import "LiveViewConstants.h"
#import "LVMenuItem.h"
#import "LVSimpleItem.h"
#import "LVMessageItem.h"

@interface LVController : NSObject {
	int width, height, statusBarWidth, statusBarHeight, viewWidth, viewHeight, announceWidth, announceHeight, textChunkSize, idleTimer, menuItemId, navAction, navType, alertAction, maxBodySize, currentMenuId;
	BOOL wasInAlert, inMusicMode;
	LiveViewStatus_t screenStatus;
    
    //BTDiscoveryViewController *discoveryView;
}

+ (LVController *)sharedInstance;

- (void)processData:(void *)dataPointer length:(size_t)dataLength;

- (void)sendMessage:(void *)message;
- (void)sendMessage:(LiveViewMessageType)type withData:(const void *)data length:(NSUInteger)length;
- (void)sendMessage:(LiveViewMessageType)type withNSData:(NSData *)data;
- (void)sendMessage:(LiveViewMessageType)type withString:(NSString *)string;
- (void)sendMessage:(LiveViewMessageType)type withInteger:(uint8_t)integer;

- (void)sendGetCaps;
- (void)sendVibrateFor:(int)miliseconds afterDelay:(int)delayTime;
- (void)sendSetMenuSettingsWithVibration:(int)vibrationTime fontSize:(int)fontSize menuID:(int)itemID;
- (void)sendSetStatusBarWithItem:(int)itemID andAlerts:(int)unreadAlerts andImage:(NSString *)imageTitle;

- (void)sendDisplayPanelWithTopText:(NSString *)topText bottomText:(NSString *)bottomText imageName:(NSString *)bitmapName alertUser:(int)alertUser;
- (void)sendMusicDisplayPanel;
- (void)sendMenuItem:(int)item;
- (void)setScreenModeWithBrightness:(int)brightness andAuto:(int)autoTrue;
- (void)setStatus:(NSString *)statusString withExit:(BOOL)exitVisible;
- (void)setInitialized:(BOOL)initialized;
- (void)setConnected:(BOOL)connected;
- (void)displayBitmapWithX:(int)x andY:(int)y andBitmap:(NSData *)bitmapData;
- (void)notifyWithItem:(int)itemID andAlerts:(int)unreadAlerts andImage:(NSString *)imageTitle;

- (id)init;
- (id)initWithDelegate:(id<LiveViewDelegate>)theDelegate;
- (NSString *)relativeDate:(NSDate *)date;

@property (nonatomic, assign) BOOL menuDisabled;
@property (nonatomic, assign) id<LiveViewDelegate> delegate;
@property (nonatomic, readonly) NSMutableArray *menuItems;

@end

LVController *LVControllerInstance;
void LVSendRawData(uint8_t *data, uint16_t len);
void initializeBluetooth(char *MACAddr);
