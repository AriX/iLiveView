//
//  LiveView.m
//  
//
//  Created by Ari on 3/31/11.
//  Copyright 2011 Squish Software. All rights reserved.
//

#import "LVController.h"

static LVController *LVControllerInstance;

@interface LVController (Private)

- (void)sendData:(void *)data length:(NSUInteger)remainingData;
- (void)handleScreenStatus;
- (void)handleMusicAction;

#pragma mark - Internal messages
- (void)sendAckMessage:(LiveViewMessageType)type;
- (void)sendSetMenuSize:(NSUInteger)size;
- (void)sendGetTimeResponse;
- (void)sendResult:(LiveViewResult_t)result message:(LiveViewMessageType)type;

- (NSString *)pathForImage:(NSString *)image;

@end

@implementation LVController

@synthesize delegate = _delegate;
@synthesize menuItems = _menuItems;

#pragma mark - Message receiving and responding

- (void)handleLiveViewMessage:(LVMessage *)message legacyNSData:(NSData *)legacyData {
    LiveViewMessageType type = message->header.type;
    
	NSMutableData *output = [[NSMutableData alloc] init];
	int i = 0, navigation = 0, menuId = 0;
	NSString *sa, *sb, *sc;
	[self sendAckMessage:type];
	switch (type) {
		case kMessageGetCaps_Resp: {
            LVMessageGetCaps_Resp *getCaps = (LVMessageGetCaps_Resp *)message;
            width = getCaps->width;
            height = getCaps->height;
            statusBarWidth = getCaps->statusBarWidth;
            statusBarHeight = getCaps->statusBarHeight;
            viewWidth = getCaps->viewWidth;
            viewHeight = getCaps->viewHeight;
            announceWidth = getCaps->announceWidth;
            announceHeight = getCaps->announceWidth;
            textChunkSize = getCaps->textChunkSize;
            idleTimer = getCaps->idleTimer;
            
            NSString *softwareVersion = [[NSString alloc] initWithBytes:&getCaps->softwareVersion length:getCaps->versionLength encoding:NSUTF8StringEncoding];
            [self.delegate setVersion:softwareVersion];
            [softwareVersion release];
            
			[self sendSetMenuSize:(self.menuDisabled ? 0 : self.menuItems.count)];
			_menuDisabled = FALSE;
			break;
            
		} case kMessageGetTime:
			[self sendGetTimeResponse];
			break;
            
		case kMessageDeviceStatus: {
            LVMessageDeviceStatus *deviceStatus = (LVMessageDeviceStatus *)message;
            screenStatus = deviceStatus->screenStatus;
            
			[self sendResult:kResultOK message:kMessageDeviceStatus_Resp];
            [self performSelectorOnMainThread:@selector(handleScreenStatus) withObject:nil waitUntilDone:NO];
			break;
        }
            
		case kMessageNavigation:
			i = navigation = menuItemId = menuId = 0;
			[legacyData deserializeWithFormat:@">HBBB", &i, &navigation, &menuItemId, &menuId];
			if (i != 3) NSLog(@"Unexpected navigation message length: %d [%@]", i, legacyData);
			else if (menuId != 10 && menuId != 20) NSLog(@"Unexpected navigation menu ID: %d", menuId);
			else if (navigation != 32 && (navigation < 1 || navigation > 15)) NSLog(@"Navigation type out of range: %d", navigation);
			else {
				wasInAlert = (menuId == 20);
				if (navigation != 32) {
					navAction = (navigation-1)%3;
					navType = (navigation-1)/3;
				} else {
					navAction = kActionPress;
					navType = kNavMenuSelect;
				}
			}
			[output setLength:0];
            if (inMusicMode) [self handleMusicAction];
            else {
                if (navAction == kActionLongPress && navType == kNavSelect) {
                    inMusicMode = TRUE;
                    [output appendint8:kResultOK];
                    [self sendMessage:kMessageNavigation_Resp withNSData:output];
                    [self sendMusicDisplayPanel];
                    [[MPMusicPlayerController iPodMusicPlayer] beginGeneratingPlaybackNotifications];
                } else if (navAction == kActionPress && navType == kNavMenuSelect) {
                    [output appendint8:kResultExit];
                    [self sendMessage:kMessageNavigation_Resp withNSData:output];
                    [[[self.menuItems objectAtIndex:currentMenuId] itemAtCurrentIndex] sendToPhone];
                } else {
                    [output appendint8:kResultExit];
                    [self sendMessage:kMessageNavigation_Resp withNSData:output];
                }
            }
			
			break;
            
		case kMessageGetMenuItem: {
            LVMessageGetMenuItem *getMenuItem = (LVMessageGetMenuItem *)message;
            [self sendMenuItem:getMenuItem->index];
            break;
            
		} case kMessageGetMenuItems:
            for (i=0; i<[self.menuItems count]; i++) {
                [self sendMenuItem:i];
            }
			break;
            
		case kMessageGetAlert:
			[legacyData deserializeWithFormat:@">BBHsss", &menuItemId, &alertAction, &maxBodySize, &sa, &sb, &sc];
			if ([sa length] || [sb length] || [sc length]) {
				NSLog(@"GetAlert with non-zero text: %@, %@, %@",sa,sb,sc);
			}
			[output setLength:0];
            currentMenuId = menuItemId;
            LVMenuItem *menuItem = [self.menuItems objectAtIndex:menuItemId];
            switch (alertAction) {
                case kAlertFirst:
                    menuItem.currentIndex = 0;;
                    break;
                case kAlertPrev:
                    if (menuItem.currentIndex == 0) menuItem.currentIndex = menuItem.total-1;
                    else menuItem.currentIndex--;
                    break;
                case kAlertNext:
                    if (menuItem.currentIndex == menuItem.total-1) menuItem.currentIndex = 0;
                    else menuItem.currentIndex++;
                    break;
                case kAlertLast:
                    menuItem.currentIndex = menuItem.total-1;
                    break;
                case kAlertCurrent:
                default:
                    break;
            }
            id<LVItemProtocol> alertItem = [menuItem itemAtCurrentIndex];
			NSData *image = [[[NSData alloc] initWithContentsOfFile:[self pathForImage:alertItem.image]] autorelease];
			[output serializeWithFormat:@">BHHHBB", 0, [menuItem total], menuItem.unread, menuItem.currentIndex, 0, 0];
			[output serializeWithFormat:@">SSSBL",  alertItem.time, alertItem.header, alertItem.body, 0, [image length]];
			[output appendData:image];
			[self sendMessage:kMessageGetAlert_Resp withNSData:output];
			break;
            
		/*case kMessageSetStatusBar_Resp:
            [self sendSetMenuSettingsWithVibration:5 fontSize:12 menuID:0];
			break;*/
            
		default:
			NSLog(@"Message %d with legacyData [%@]\n", type, legacyData);
			break;
	}
    [output release];
}

#pragma mark - Raw data I/O

- (void)processData:(void *)dataPointer length:(size_t)dataLength {
    while (dataLength >= sizeof(LVMessageHeader)) {
        LVMessage *message = (LVMessage *)dataPointer;
        LVMessageHeader *header = &message->header;
        
        header->length = OSSwapInt32(header->length); // Reverse endianness
        if (header->length > dataLength)
            header->length = dataLength-sizeof(LVMessageHeader); // Prevent possible buffer underflow
        
        if (header->headerlength == 4) {
            NSUInteger receivedLength = header->length;
            NSLog(@"Received message %d with data ", header->type);
            hexdump(&message->data, receivedLength);
            
            @try {
                [self handleLiveViewMessage:message legacyNSData:[NSData dataWithBytes:&message->data length:receivedLength]];
            }
            @catch (NSException *exception) {
                NSLog(@"Message handler exception! %@", exception);
            }
            dataPointer += receivedLength+sizeof(LVMessageHeader);
            dataLength -= receivedLength+sizeof(LVMessageHeader);
        } else {
            NSLog(@"Received data with malformed header!");
            break;
        }
    }
    if (dataLength > 0) {
        NSLog(@"Recieved unanticipated extra data in packet: ");
        hexdump(dataPointer, dataLength);
    }
}

- (void)sendData:(void *)data length:(NSUInteger)remainingData {
    int packetLength;
    
    if (channel_mtu) {
        while(remainingData) {
            packetLength = (remainingData > channel_mtu) ? channel_mtu : remainingData;
            
            LVSendRawData(data, packetLength);
            NSLog(@"Wrote %d bytes.", packetLength);
            
            remainingData -= packetLength;
            data += packetLength;
        }
    }
}

#pragma mark - Message generation

- (void)sendMessage:(void *)message {
    LVMessageHeader *header = &((LVMessage *)message)->header;
    NSLog(@"Sending message %d with data ", header->type);
    hexdump(&((LVMessage *)message)->data, header->length);
    
    uint32_t messageLength = header->length;
    header->headerlength = 4;
    header->length = OSSwapInt32(messageLength);
    
    [self sendData:message length:sizeof(LVMessageHeader)+messageLength];
}

- (void)sendMessage:(LiveViewMessageType)type withData:(const void *)data length:(NSUInteger)length { 
    LVMessage *message = malloc(sizeof(LVMessageHeader)+length);
    LVMessageHeader *header = &message->header;
    
    header->type = type;
    header->length = length;
    memcpy(&message->data, data, length);
    
    [self sendMessage:message];
    
    free(message);
}

- (void)sendMessage:(LiveViewMessageType)type withNSData:(NSData *)data {
	[self sendMessage:type withData:[data bytes] length:[data length]];
}

- (void)sendMessage:(LiveViewMessageType)type withString:(NSString *)string {
    [self sendMessage:type withNSData:[string dataUsingEncoding:NSUTF8StringEncoding]];
}

- (void)sendMessage:(LiveViewMessageType)type withInteger:(uint8_t)integer {
    [self sendMessage:type withData:&integer length:1];
}

- (void)sendResult:(LiveViewResult_t)result message:(LiveViewMessageType)type {
    [self sendMessage:type withInteger:result];
}

#pragma mark - Messages

- (void)sendAckMessage:(LiveViewMessageType)type {
	[self sendMessage:kMessageAck withInteger:type];
}

- (void)sendGetCaps {
    [self sendMessage:kMessageGetCaps withString:@"0.0.6"];
}

- (void)sendSetMenuSize:(NSUInteger)size {
    [self sendMessage:kMessageSetMenuSize withInteger:size];
}

- (void)sendGetTimeResponse {
    NSDate *date = [NSDate date];

    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateStyle:NSDateFormatterNoStyle];
    [dateFormatter setTimeStyle:NSDateFormatterLongStyle];
    BOOL use24HourClock = [[dateFormatter dateFormat] rangeOfString:@"a"].location != NSNotFound;
    [dateFormatter release];  
    
    LVMessageGetTime_Resp message;
    message.header.type = kMessageGetTime_Resp;
    message.header.length = sizeof(message);
    message.currentTime = OSSwapInt32([date timeIntervalSince1970] + [[NSTimeZone localTimeZone] secondsFromGMTForDate:date]);
    message.use24HourClock = use24HourClock ? 1 : 0;
        
    [self sendMessage:&message];
}

- (void)sendVibrateFor:(int)miliseconds afterDelay:(int)delayTime {
    LVMessageSetVibrate message;
    message.header.type = kMessageSetVibrate;
    message.header.length = sizeof(message);
    message.delayTime = OSSwapInt16(delayTime);
    message.vibrationTime = OSSwapInt16(miliseconds);
    
	[self sendMessage:&message];
}

- (void)sendSetMenuSettingsWithVibration:(int)vibrationTime fontSize:(int)fontSize menuID:(int)itemID {
    LVMessageSetMenuSettings message;
    message.header.type = kMessageSetMenuSettings;
    message.header.length = sizeof(message);
    message.vibrationTime = vibrationTime;
    message.fontSize = fontSize;
    message.itemID = itemID;
    
	[self sendMessage:&message];
}

- (void)sendMenuItem:(int)item {
    LVMenuItem *menuItem = [self.menuItems objectAtIndex:item];
    NSMutableData *output = [[NSMutableData alloc] init];
    [output setLength:0];
    [output serializeWithFormat:@">BHHHBBSSS", ([menuItem isAlertItem])?0:1, 0, [menuItem unread], 0, item+3, 0, @"", @"", menuItem.name];
    // is alert item, ?, unread count, ?, menu item id + 3 for some reason, plaintext v bitmapimage string, unused field, unused field, title
    [output appendData:[[[NSData alloc] initWithContentsOfFile:[self pathForImage:menuItem.icon]] autorelease]];
    [self sendMessage:kMessageGetMenuItem_Resp withNSData:output];
    [output release];
}

- (void)notifyWithItem:(int)itemID andAlerts:(int)unreadAlerts andImage:(NSString *)imageTitle {
    inMusicMode = TRUE;
    [self sendMusicDisplayPanel];
}

- (void)sendSetStatusBarWithItem:(int)itemID andAlerts:(int)unreadAlerts andImage:(NSString *)imageTitle {
    NSData *imageData;
    NSInteger imageLength = -1; // If there is no image, remove the placeholder imageData byte.
    if (imageTitle) {
        imageData = [[NSData alloc] initWithContentsOfFile:[self pathForImage:imageTitle]];
        imageLength = [imageData length];
    }
    
    NSInteger messageLength = sizeof(LVMessageSetStatusBar)+imageLength;
    
    LVMessageSetStatusBar *message = malloc(messageLength);
    message->header.type = kMessageSetStatusBar;
    message->header.length = messageLength;
    message->unknown1 = 0;
    message->unknown2 = OSSwapInt16(0);
    message->unreadAlerts = OSSwapInt16(unreadAlerts);
    message->unknown4 = OSSwapInt16(0);
    message->menuItemID = itemID+3;
    message->unknown6 = 0;
    message->unknown7 = OSSwapInt16(0);
    message->unknown8 = OSSwapInt16(0);
    message->unknown9 = OSSwapInt16(0);
    
    if (imageLength) {
        memcpy(&message->imageData, [imageData bytes], imageLength);
        [imageData release];
    }
    
    [self sendMessage:message];
    
    free(message);
}

- (void)displayBitmapWithX:(int)x andY:(int)y andBitmap:(NSData *)bitmapData {
	NSMutableData *output = [[[NSMutableData alloc] init] autorelease];
	[output serializeWithFormat:@">BBB", x, y, 1];
	[output appendData:bitmapData];
	[self sendMessage:kMessageDisplayBitmap withNSData:output];
}

- (void)setScreenModeWithBrightness:(int)brightness andAuto:(int)autoTrue {
	int v = brightness << 1;
	if (autoTrue) v |= 1;
	[self sendMessage:kMessageSetScreenMode withInteger:v];
}

- (void)sendDisplayPanelWithTopText:(NSString *)topText bottomText:(NSString *)bottomText imageName:(NSString *)bitmapName alertUser:(int)alertUser {
	int msgid = 80;
	if (!alertUser) msgid |= 1;
	NSMutableData *output = [[[NSMutableData alloc] init] autorelease];
	[output serializeWithFormat:@">BHHHBBB", 0, 0, 0, 0, msgid, 0, 0]; // final 0 is for plaintext vs bitmapimage (1) strings
	[output appendString:topText];
	[output serializeWithFormat:@">H", 0];
	[output serializeWithFormat:@">B", 0];
	[output appendString:bottomText];
	if (bitmapName) [output appendData:[[[NSData alloc] initWithContentsOfFile:[self pathForImage:bitmapName]] autorelease]];
	[self sendMessage:kMessageDisplayPanel withNSData:output];
}

- (void)setMenuDisabled:(BOOL)menuDisabled {
    _menuDisabled = menuDisabled;
    [self sendGetCaps];
}

#pragma Support methods

- (void)handleScreenStatus {
    switch (screenStatus) {
        case kDeviceStatusOff:
            if (inMusicMode) {
                inMusicMode = FALSE;
                [[MPMusicPlayerController iPodMusicPlayer] endGeneratingPlaybackNotifications];
            }
            [self.delegate setScreenStatus:@"Off"];
            break;
        case kDeviceStatusOn:
            [self.delegate setScreenStatus:@"On"];
            break;
        case kDeviceStatusMenu:
            [self.delegate setScreenStatus:@"Menu"];
            break;
        default:
            [self.delegate setScreenStatus:[NSString stringWithFormat:@"%d", screenStatus]];
            break;
    }
}

- (void)handleMusicAction {
    NSMutableData *output = [[NSMutableData alloc] init];
    if (navAction == kActionLongPress && navType == kNavSelect) {
        inMusicMode = FALSE;
        [output appendint8:kResultExit];
        [self sendMessage:kMessageNavigation_Resp withNSData:output];
        [[MPMusicPlayerController iPodMusicPlayer] endGeneratingPlaybackNotifications];
    } else {
        [output appendint8:kResultOK];
        [self sendMessage:kMessageNavigation_Resp withNSData:output];
        switch (navType) {
            case kNavUp:
                [[MPMusicPlayerController iPodMusicPlayer] setVolume:[[MPMusicPlayerController iPodMusicPlayer] volume]+0.0625];
                break;
            case kNavDown:
                [[MPMusicPlayerController iPodMusicPlayer] setVolume:[[MPMusicPlayerController iPodMusicPlayer] volume]-0.0625];
                break;
            case kNavRight:
                [[MPMusicPlayerController iPodMusicPlayer] skipToNextItem];
                break;
            case kNavLeft:
                if ((int)[[MPMusicPlayerController iPodMusicPlayer] currentPlaybackTime] < 4.0) [[MPMusicPlayerController iPodMusicPlayer] skipToPreviousItem];
                else [[MPMusicPlayerController iPodMusicPlayer] skipToBeginning];
                break;
            case kNavSelect:
                if ([[MPMusicPlayerController iPodMusicPlayer] playbackState] == MPMusicPlaybackStateStopped) {
                    [[MPMusicPlayerController iPodMusicPlayer] setQueueWithQuery:[MPMediaQuery songsQuery]];
                    [[MPMusicPlayerController iPodMusicPlayer] setShuffleMode:MPMusicShuffleModeDefault];
                }
                if ([[MPMusicPlayerController iPodMusicPlayer] playbackState] == MPMusicPlaybackStatePlaying) [[MPMusicPlayerController iPodMusicPlayer] pause];
                else [[MPMusicPlayerController iPodMusicPlayer] play];
                break;
            default:
                break;
        }
    }
    [output release];
}

- (void)sendMusicDisplayPanel {
	MPMusicPlayerController *musicPlayer = [MPMusicPlayerController iPodMusicPlayer];
	MPMediaItem *nowPlayingItem = [musicPlayer nowPlayingItem];
	NSString *imageName = nil, *titleString, *artist;
	switch (musicPlayer.playbackState) {
		case MPMusicPlaybackStatePaused:
			imageName = @"MusicPlay";
		case MPMusicPlaybackStatePlaying:
			artist = [nowPlayingItem valueForProperty:@"artist"];
			titleString = [nowPlayingItem valueForProperty:@"title"];
			if (!imageName) imageName = @"MusicPause";
			break;
		default:
			imageName = @"MusicPlay";
			titleString = @"";
			artist = @"";
			break;
	}
	[self sendDisplayPanelWithTopText:artist bottomText:titleString imageName:imageName alertUser:0];
}

- (void)handlePlaybackChange:(id)notification {
	if (inMusicMode)
        [self sendMusicDisplayPanel];
}

- (void)setConnected:(BOOL)connected {
    [self.delegate setConnected:connected];
}

- (void)setInitialized:(BOOL)initialized {
    [self.delegate setInitialized:initialized];
}

- (void)setStatus:(NSString *)statusString withExit:(BOOL)exitVisible {
    [self.delegate setStatus:statusString withExit:exitVisible];
}

- (NSString *)pathForImage:(NSString *)image {
    return [@"/Library/Application Support/LiveView" stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.png", image]];
}

- (NSString *)relativeDate:(NSDate *)date {
    double timeInterval = [date timeIntervalSinceDate:[NSDate date]] * -1;
    if (timeInterval < 1) {
        return @"never";
    } else if (timeInterval < 60) {
        return @"less than a minute ago";
    } else if (timeInterval < 3600) {
        int diff = round(timeInterval / 60);
        NSString *s = (diff == 1)?@"":@"s";
        return [NSString stringWithFormat:@"%d minute%@ ago", diff, s];
    } else if (timeInterval < 86400) {
        int diff = round(timeInterval / 60 / 60);
        NSString *s = (diff == 1)?@"":@"s";
        return [NSString stringWithFormat:@"%d hour%@ ago", diff, s];
    } else if (timeInterval < 2629743) {
        int diff = round(timeInterval / 60 / 60 / 24);
        NSString *s = (diff == 1)?@"":@"s";
        return [NSString stringWithFormat:@"%d day%@ ago", diff, s];
    } else {
        return @"never";
    }
}

#pragma Initialization methods

- (id)init {
    self = [self initWithDelegate:nil];
    
    return self;
}

- (id)initWithDelegate:(id<LiveViewDelegate>)delegate {
    self = [super init];
    if (!self)
        return nil;
    
    LVControllerInstance = self;
    _delegate = delegate;
    _menuItems = [[NSMutableArray alloc] init];
    [NSThread detachNewThreadSelector:@selector(runBluetooth) toTarget:self withObject:nil];
    MPMusicPlayerController *musicPlayer = [MPMusicPlayerController iPodMusicPlayer];
    NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
    [notificationCenter addObserver:self selector:@selector(handlePlaybackChange:) name:@"MPMusicPlayerControllerNowPlayingItemDidChangeNotification" object:musicPlayer];
    [notificationCenter addObserver:self selector:@selector(handlePlaybackChange:) name:@"MPMusicPlayerControllerPlaybackStateDidChangeNotification" object:musicPlayer];
    
	return self;
}

- (void)runBluetooth {
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    runBluetooth("6c:23:b9:9b:47:10");
	[pool drain];
}

- (void)dealloc {
    MPMusicPlayerController *musicPlayer = [MPMusicPlayerController iPodMusicPlayer];
    NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
    [notificationCenter removeObserver:self name:@"MPMusicPlayerControllerNowPlayingItemDidChangeNotification" object:musicPlayer];
    [notificationCenter removeObserver:self name:@"MPMusicPlayerControllerPlaybackStateDidChangeNotification" object:musicPlayer];
    
    [super dealloc];
}

+ (LVController *)sharedInstance {
	return LVControllerInstance;
}

@end
