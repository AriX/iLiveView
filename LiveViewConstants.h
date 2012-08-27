//
//  LiveViewConstants.h
//  iLiveView
//
//  Created by Ari on 3/30/11.
//  Copyright 2011 Squish Software. All rights reserved.
//

// Control field values      bit no.       1 2 3 4 5   6 7 8
#define BT_RFCOMM_SABM       0x3F       // 1 1 1 1 P/F 1 0 0
#define BT_RFCOMM_UA         0x73       // 1 1 0 0 P/F 1 1 0
#define BT_RFCOMM_DM         0x0F       // 1 1 1 1 P/F 0 0 0
#define BT_RFCOMM_DM_PF      0x1F
#define BT_RFCOMM_DISC       0x53       // 1 1 0 0 P/F 0 1 1
#define BT_RFCOMM_UIH        0xEF       // 1 1 1 1 P/F 1 1 1
#define BT_RFCOMM_UIH_PF     0xFF

// Multiplexer message types 
#define BT_RFCOMM_PN_CMD     0x83
#define BT_RFCOMM_PN_RSP     0x81
#define BT_RFCOMM_TEST_CMD   0x23
#define BT_RFCOMM_TEST_RSP   0x21
#define BT_RFCOMM_FCON_CMD   0xA3
#define BT_RFCOMM_FCON_RSP   0xA1
#define BT_RFCOMM_FCOFF_CMD  0x63
#define BT_RFCOMM_FCOFF_RSP  0x61
#define BT_RFCOMM_MSC_CMD    0xE3
#define BT_RFCOMM_MSC_RSP    0xE1
#define BT_RFCOMM_RPN_CMD    0x93
#define BT_RFCOMM_RPN_RSP    0x91
#define BT_RFCOMM_RLS_CMD    0x53
#define BT_RFCOMM_RLS_RSP    0x51
#define BT_RFCOMM_NSC_RSP    0x11

// FCS calc 
#define BT_RFCOMM_CODE_WORD         0xE0 // pol = x8+x2+x1+1
#define BT_RFCOMM_CRC_CHECK_LEN     3
#define BT_RFCOMM_UIHCRC_CHECK_LEN  2

#define NR_CREDITS 0x30
#define CHANNEL_MTU 99

typedef enum {
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
} LiveViewMessage_t;

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
