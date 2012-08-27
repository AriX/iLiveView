//
//  LiveViewConstants.h
//  iLiveView
//
//  Created by Ari on 3/30/11.
//  Copyright 2011 Squish Software. All rights reserved.
//

#import <UIKit/UIKit.h>

int channel_mtu;

@protocol LiveViewDelegate <NSObject>
- (void)setScreenStatus:(NSString *)status;
- (void)setVersion:(NSString *)version;
- (void)setStatus:(NSString *)statusString withExit:(BOOL)exitVisible;
- (void)setInitialized:(BOOL)initialized;
- (void)setConnected:(BOOL)connected;
@end

enum {
	kMessageGetCaps             = 1,
	kMessageGetCaps_Resp        = 2, // Received
	
	kMessageDisplayText         = 3,
	kMessageDisplayText_Resp    = 4,
	
	kMessageDisplayPanel        = 5,
	kMessageDisplayPanel_Resp   = 6,
	
	kMessageDeviceStatus        = 7,
	kMessageDeviceStatus_Resp   = 8, // Received
	
	kMessageDisplayBitmap       = 19,
	kMessageDisplayBitmap_Resp  = 20,
	
	kMessageClearDisplay        = 21,
	kMessageClearDisplay_Resp   = 22,
	
	kMessageSetMenuSize         = 23,
	kMessageSetMenuSize_Resp    = 24,
	
	kMessageGetMenuItem         = 25, // Received?
	kMessageGetMenuItem_Resp    = 26,
	
	kMessageGetAlert            = 27,
	kMessageGetAlert_Resp       = 28,
	
	kMessageNavigation          = 29,
	kMessageNavigation_Resp     = 30,
	
	kMessageSetStatusBar        = 33,
	kMessageSetStatusBar_Resp   = 34,
	
	kMessageGetMenuItems        = 35, // Received
	
	kMessageSetMenuSettings     = 36,
	kMessageSetMenuSettings_Resp= 37,
	
	kMessageGetTime             = 38,
	kMessageGetTime_Resp        = 39,
	
	kMessageSetLED              = 40,
	kMessageSetLED_Resp         = 41, // Received
	
	kMessageSetVibrate          = 42,
	kMessageSetVibrate_Resp     = 43, // Received
	
	kMessageAck                 = 44,
	
	kMessageSetScreenMode       = 64,
	kMessageSetScreenMode_Resp  = 65, // Received
	
	kMessageGetScreenMode       = 66,
	kMessageGetScreenMode_Resp  = 67
};
typedef uint8_t LiveViewMessageType;

struct LVMessageHeader {
    uint8_t type;                 
    uint8_t headerlength;
    uint32_t length;
} __attribute__((__packed__));
typedef struct LVMessageHeader LVMessageHeader;

struct LVMessage {
    LVMessageHeader header;
    uint8_t data;
} __attribute__((__packed__));
typedef struct LVMessage LVMessage;

typedef enum {
	kDeviceStatusOff,
	kDeviceStatusOn,
	kDeviceStatusMenu
} LiveViewStatus_t;

typedef enum {
	kResultOK,
	kResultError,
	kResultOOM,
	kResultExit,
	kResultCancel
} LiveViewResult_t;

typedef enum {
	kActionPress,
	kActionLongPress,
	kActionDoublePress,
} LiveViewNavAction_t;

typedef enum {
	kNavUp,
	kNavDown,
	kNavLeft,
	kNavRight,
	kNavSelect,
	kNavMenuSelect
} LiveViewNavType_t;

typedef enum {
	kAlertCurrent,
	kAlertFirst,
	kAlertLast,
	kAlertNext,
	kAlertPrev
} LiveViewAlert_t;

typedef enum {
	kBrightnessOff = 48,
	kBrightnessDim,
	kBrightnessMax
} LiveViewBrightness_t;
