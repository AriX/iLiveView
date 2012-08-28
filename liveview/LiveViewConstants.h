//
//  LiveViewConstants.h
//  iLiveView
//
//  Created by Ari on 3/30/11.
//  Copyright 2011 Squish Software. All rights reserved.
//

#import <UIKit/UIKit.h>

#pragma mark - Variables

int channel_mtu;

#pragma mark - Protocols

@protocol LiveViewDelegate <NSObject>
- (void)setScreenStatus:(NSString *)status;
- (void)setVersion:(NSString *)version;
- (void)setStatus:(NSString *)statusString withExit:(BOOL)exitVisible;
- (void)setInitialized:(BOOL)initialized;
- (void)setConnected:(BOOL)connected;
@end

# pragma mark - Messages

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

# pragma mark - Structures

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

struct LVMessageGetCaps_Resp {
    LVMessageHeader header;
    uint8_t width;
    uint8_t height;
    uint8_t statusBarWidth;
    uint8_t statusBarHeight;
    uint8_t viewWidth;
    uint8_t viewHeight;
    uint8_t announceWidth;
    uint8_t announceHeight;
    uint8_t textChunkSize;
    uint8_t idleTimer;
    uint8_t versionLength;
    char softwareVersion;
} __attribute__((__packed__));
typedef struct LVMessageGetCaps_Resp LVMessageGetCaps_Resp;

struct LVMessageGetTime_Resp {
    LVMessageHeader header;
    uint32_t currentTime;
    uint8_t use24HourClock;
} __attribute__((__packed__));
typedef struct LVMessageGetTime_Resp LVMessageGetTime_Resp;

struct LVMessageDeviceStatus {
    LVMessageHeader header;
    uint8_t screenStatus;
} __attribute__((__packed__));
typedef struct LVMessageDeviceStatus LVMessageDeviceStatus;

struct LVMessageGetMenuItem {
    LVMessageHeader header;
    uint8_t index;
} __attribute__((__packed__));
typedef struct LVMessageGetMenuItem LVMessageGetMenuItem;

struct LVMessageSetMenuSettings {
    LVMessageHeader header;
    uint8_t vibrationTime;
    uint8_t fontSize;
    uint8_t itemID;
} __attribute__((__packed__));
typedef struct LVMessageSetMenuSettings LVMessageSetMenuSettings;

struct LVMessageSetVibrate {
    LVMessageHeader header;
    uint16_t delayTime;
    uint16_t vibrationTime;
} __attribute__((__packed__));
typedef struct LVMessageSetVibrate LVMessageSetVibrate;

struct LVMessageSetStatusBar {
    LVMessageHeader header;
    uint8_t unknown1;
    uint16_t unknown2;
    uint16_t unreadAlerts;
    uint16_t unknown4;
    uint8_t menuItemID;
    uint8_t unknown6;
    uint16_t unknown7;
    uint16_t unknown8;
    uint16_t unknown9;
    uint8_t imageData;
} __attribute__((__packed__));
typedef struct LVMessageSetStatusBar LVMessageSetStatusBar;

# pragma mark - Enums

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
