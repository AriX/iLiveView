//
//  LiveView.m
//  
//
//  Created by Ari on 3/31/11.
//  Copyright 2011 Squish Software. All rights reserved.
//

#import "LVController.h"

@interface LVController (Private)

- (void)sendData:(NSData *)data;
- (void)sendMessage:(LiveViewMessageType)msg withInteger:(int)integer;
- (void)handleScreenStatus;
- (void)handleMusicAction;

- (NSString *)pathForImage:(NSString *)image;

@end

@implementation LVController

@synthesize delegate, menuItems;

#pragma Message receiving and responding

- (void)handleLiveViewMessage:(LiveViewMessageType)msg withData:(NSData *)data {
	NSMutableData *output = [[NSMutableData alloc] init];
	int i = 0, navigation = 0, menuId = 0;
	NSString *sa, *sb, *sc, *softwareVersion;
	[output appendint8:msg];
	[self sendMessage:kMessageAck withData:output];
	switch (msg) {
		case kMessageGetCaps_Resp:
			width = height = statusBarWidth = statusBarHeight = viewWidth = viewHeight= announceWidth = announceHeight = textChunkSize = idleTimer = 0;
			[data deserializeWithFormat:@">BBBBBBBBBBs", &width, &height, &statusBarWidth, &statusBarHeight, &viewWidth, &viewHeight, &announceWidth, &announceHeight, &textChunkSize, &idleTimer, &softwareVersion];
			[delegate setVersion:softwareVersion];
			[output setLength:0];
			[output appendint8:(disableMenu)?0:[menuItems count]];
			[self sendMessage:kMessageSetMenuSize withData:output];
			disableMenu = FALSE;
			break;
            
		case kMessageGetTime:
			[output setLength:0];
			NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
			[dateFormatter setDateStyle:NSDateFormatterNoStyle];
			[dateFormatter setTimeStyle:NSDateFormatterLongStyle];
			int use24HourClock = ([[dateFormatter dateFormat] rangeOfString:@"a"].location != NSNotFound)? 1 : 0;
			[dateFormatter release];
			NSDate *currentDate = [[NSDate alloc] init];
			int currentTime = [currentDate timeIntervalSince1970] + [[NSTimeZone localTimeZone] secondsFromGMTForDate:currentDate];
            [currentDate release];
			[output serializeWithFormat:@"LB", currentTime, use24HourClock];
			[self sendMessage:kMessageGetTime_Resp withData:output];
			break;
            
		case kMessageDeviceStatus:
			[data deserializeWithFormat:@">B", &screenStatus];
			[output setLength:0];
			[output appendint8:kResultOK];
			[self sendMessage:kMessageDeviceStatus_Resp withData:output];
            [self performSelectorOnMainThread:@selector(handleScreenStatus) withObject:nil waitUntilDone:NO];
			break;
            
		case kMessageNavigation:
			i = navigation = menuItemId = menuId = 0;
			[data deserializeWithFormat:@">HBBB", &i, &navigation, &menuItemId, &menuId];
			if (i != 3) NSLog(@"Unexpected navigation message length: %d [%@]", i, data);
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
                    [self sendMessage:kMessageNavigation_Resp withData:output];
                    [self sendMusicDisplayPanel];
                    [[MPMusicPlayerController iPodMusicPlayer] beginGeneratingPlaybackNotifications];
                } else if (navAction == kActionPress && navType == kNavMenuSelect) {
                    [output appendint8:kResultExit];
                    [self sendMessage:kMessageNavigation_Resp withData:output];
                    [[[menuItems objectAtIndex:currentMenuId] itemAtCurrentIndex] sendToPhone];
                } else {
                    [output appendint8:kResultExit];
                    [self sendMessage:kMessageNavigation_Resp withData:output];
                }
            }
			
			break;
            
		case kMessageGetMenuItem:
            [data deserializeWithFormat:@">B", &i];
            [self sendMenuItem:i];
             break;
            
		case kMessageGetMenuItems:
            for (i=0; i<[menuItems count]; i++) {
                [self sendMenuItem:i];
            }
			break;
            
		case kMessageGetAlert:
			[data deserializeWithFormat:@">BBHsss", &menuItemId, &alertAction, &maxBodySize, &sa, &sb, &sc];
			if ([sa length] || [sb length] || [sc length]) {
				NSLog(@"GetAlert with non-zero text: %@, %@, %@",sa,sb,sc);
			}
			[output setLength:0];
            currentMenuId = menuItemId;
            LVMenuItem *menuItem = [menuItems objectAtIndex:menuItemId];
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
			[self sendMessage:kMessageGetAlert_Resp withData:output];
			break;
            
		case kMessageSetStatusBar_Resp:
			[output setLength:0];
			[output appendint8:5];
			[output appendint8:12];
			[output appendint8:0];
			[self sendMessage:kMessageSetMenuSettings withData:output];
			break;
            
		default:
			NSLog(@"Message %d with data [%@]\n", msg, data);
			break;
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

- (void)handleScreenStatus {
    switch (screenStatus) {
        case kDeviceStatusOff:
            if (inMusicMode) {
                inMusicMode = FALSE;
                [[MPMusicPlayerController iPodMusicPlayer] endGeneratingPlaybackNotifications];
            }
            [delegate setScreenStatus:@"Off"];
            break;
        case kDeviceStatusOn:
            [delegate setScreenStatus:@"On"];
            break;
        case kDeviceStatusMenu:
            [delegate setScreenStatus:@"Menu"];
            break;
        default:
            [delegate setScreenStatus:[NSString stringWithFormat:@"%d", screenStatus]];
            break;
    }
}

- (void)processData:(void *)dataPointer length:(size_t)dataLength {
    while (dataLength >= sizeof(LVMessageHeader)) {
        LVMessage *message = (LVMessage *)dataPointer;
        LVMessageHeader *header = &message->header;
        uint32_t receivedLength = OSSwapInt32(header->length); // Reverse endianness
        if (receivedLength > dataLength) receivedLength = dataLength-sizeof(LVMessageHeader); // Prevent possible buffer underflow
        
        if (header->headerlength == 4) {
            NSLog(@"Received message %d with data ", header->type);
            hexdump(&message->data, receivedLength);
            @try {
                [self handleLiveViewMessage:header->type withData:[NSData dataWithBytes:&message->data length:receivedLength]];
            }
            @catch (NSException *exception) {
                NSLog(@"Message handler exception! Ignoring...");
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

    /*// Consider rewriting this to parse data as C structures instead of reading from NSData
	NSData *data = [NSData dataWithBytes:dataPointer length:dataLength];
	uint8_t msg, headlen;
	uint32_t datalen;
	
	while ([data length] >= 6) {
		[data getBytes:&msg range:NSMakeRange(0,1)];
		[data getBytes:&headlen range:NSMakeRange(1,1)];
		if (headlen == 4) {
			[data getBytes:&datalen range:NSMakeRange(2,4)];
			datalen = ntohl(datalen);
            if (datalen > [data length]) datalen = [data length]; // Prevent possible buffer overflow
			NSLog(@"Received message %d with data [%@] on channel id %d", msg, data, 1);
            @try {
                [self handleLiveViewMessage:msg withData:[data subdataWithRange:NSMakeRange(6, datalen)]];
            }
            @catch (NSException *exception) {
                NSLog(@"Data length exception! Ignoring.");
            }
			data = [data subdataWithRange:NSMakeRange(6+datalen, [data length]-6-datalen)];
		} else {
			NSLog(@"Received data [%@] on channel id %d", data, 1);
			data = [data subdataWithRange:NSMakeRange(0, 0)];
		}
	}
	if ([data length] > 0) {
		NSLog(@"Received data [%@] on channel id %d", data, 1);
	}*/
}

#pragma Data sending

- (void)sendData:(NSData *)data {
	NSData *packet;
    int packetLength;
    
    int channelMTU = channel_mtu;
	int remainingData = [data length];
    
    if (channelMTU) {
        while(remainingData) {
            packetLength = (remainingData > channelMTU) ? channelMTU : remainingData;
            
            packet = [data subdataWithRange:NSMakeRange(0, packetLength)];
            if (remainingData -= packetLength)
                data = [data subdataWithRange:NSMakeRange(packetLength, remainingData)];
            
            LVSendRawData((uint8_t *)[packet bytes], [packet length]);
            NSLog(@"Wrote %d bytes.",[packet length]);
        }
    }
}

- (void)sendMessage:(LiveViewMessageType)msg withData:(NSData *)data {
	//NSLog(@"Sending message %d with data %@.", msg, data);
	NSMutableData *output = [[NSMutableData alloc] init];
	[output appendint8:msg];
	[output appendint8:4];
	[output appendBEint32:[data length]];
	[output appendData:data];
	[self sendData:output];
    NSLog(@"Sending message %d with data %@.", msg, output);
    [output release];
}

- (void)sendMessage:(LiveViewMessageType)msg withInteger:(int)integer {
	NSMutableData *output = [[NSMutableData alloc] init];
	[output serializeWithFormat:@">B", integer];
	[self sendMessage:msg withData:output];
    [output release];
}

#pragma Messages

- (void)sendMenuItem:(int)item {
    LVMenuItem *menuItem = [menuItems objectAtIndex:item];
    NSMutableData *output = [[NSMutableData alloc] init];
    [output setLength:0];
    [output serializeWithFormat:@">BHHHBBSSS", ([menuItem isAlertItem])?0:1, 0, [menuItem unread], 0, item+3, 0, @"", @"", menuItem.name];
    // is alert item, ?, unread count, ?, menu item id + 3 for some reason, plaintext v bitmapimage string, unused field, unused field, title
    [output appendData:[[[NSData alloc] initWithContentsOfFile:[self pathForImage:menuItem.icon]] autorelease]];
    [self sendMessage:kMessageGetMenuItem_Resp withData:output];
    [output release];
}

- (void)notifyWithItem:(int)itemID andAlerts:(int)unreadAlerts andImage:(NSString *)imageTitle {
    inMusicMode = TRUE;
    [self sendMusicDisplayPanel];
}

- (void)setStatusBarWithItem:(int)itemID andAlerts:(int)unreadAlerts andImage:(NSString *)imageTitle {
	NSMutableData *output = [[NSMutableData alloc] init];
	[output serializeWithFormat:@">BHHHBB", 0, 0, unreadAlerts, 0, itemID+3, 0];
	[output serializeWithFormat:@">H", 0];
	[output serializeWithFormat:@">H", 0];
	[output serializeWithFormat:@">H", 0];
    if (imageTitle) {
        NSData *imageData = [[NSData alloc] initWithContentsOfFile:[self pathForImage:imageTitle]];
        [output appendData:imageData];
        [imageData release];
    }
	[self sendMessage:kMessageSetStatusBar withData:output];
    [output release];
}

- (void)setMenuSettingsWithVibration:(int)vibrationTime fontSize:(int)fontSize menuID:(int)itemID {
	NSMutableData *output = [[[NSMutableData alloc] init] autorelease];
	[output serializeWithFormat:@">BBB", vibrationTime, fontSize, itemID];
	[self sendMessage:kMessageSetMenuSettings withData:nil];
}

- (void)displayBitmapWithX:(int)x andY:(int)y andBitmap:(NSData *)bitmapData {
	NSMutableData *output = [[[NSMutableData alloc] init] autorelease];
	[output serializeWithFormat:@">BBB", x, y, 1];
	[output appendData:bitmapData];
	[self sendMessage:kMessageDisplayBitmap withData:output];
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
	[self sendMessage:kMessageDisplayPanel withData:output];
}

- (void)sendGetCaps {
	NSMutableData *output = [[NSMutableData alloc] init];
	[output appendString:@"0.0.6"];
	[self sendMessage:kMessageGetCaps withData:output];
    [output release];
}

- (IBAction)vibrate {
	NSMutableData *output = [[NSMutableData alloc] init];
	[output serializeWithFormat:@">HH", 1, 1000];
	[self sendMessage:kMessageSetVibrate withData:output];
    [output release];
}

- (void)enableMenu {
    disableMenu = FALSE;
	[self sendGetCaps];
}

- (void)disableMenu {
	disableMenu = TRUE;
	[self sendGetCaps];
}

#pragma Support methods

- (void)handleMusicAction {
    NSMutableData *output = [[NSMutableData alloc] init];
    if (navAction == kActionLongPress && navType == kNavSelect) {
        inMusicMode = FALSE;
        [output appendint8:kResultExit];
        [self sendMessage:kMessageNavigation_Resp withData:output];
        [[MPMusicPlayerController iPodMusicPlayer] endGeneratingPlaybackNotifications];
    } else {
        [output appendint8:kResultOK];
        [self sendMessage:kMessageNavigation_Resp withData:output];
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

- (void)handlePlaybackChange:(id)notification {
	if (inMusicMode) {
        [self sendMusicDisplayPanel];
	}
}

- (void)setConnected:(BOOL)connected {
    [delegate setConnected:connected];
}

- (void)setInitialized:(BOOL)initialized {
    [delegate setInitialized:initialized];
}

- (void)setStatus:(NSString *)statusString withExit:(BOOL)exitVisible {
    [delegate setStatus:statusString withExit:exitVisible];
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

- (id)initWithDelegate:(id<LiveViewDelegate>)theDelegate {
    self = [super init];
    
    if (self != nil) {
        LVControllerInstance = self;
        self.delegate = theDelegate;
        [NSThread detachNewThreadSelector:@selector(startBluetooth) toTarget:self withObject:nil];
        MPMusicPlayerController *musicPlayer = [MPMusicPlayerController iPodMusicPlayer];
        NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
        [notificationCenter addObserver:self selector:@selector(handlePlaybackChange:) name:@"MPMusicPlayerControllerNowPlayingItemDidChangeNotification" object:musicPlayer];
        [notificationCenter addObserver:self selector:@selector(handlePlaybackChange:) name:@"MPMusicPlayerControllerPlaybackStateDidChangeNotification" object:musicPlayer];
        menuItems = [[NSMutableArray alloc] init];
    }
    
	return self;
}

- (void)startBluetooth {
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    
    initializeBluetooth("6c:23:b9:9b:47:10");
    
    /*discoveryView = [[BTDiscoveryViewController alloc] init];
	[discoveryView setDelegate:self];
    [[self delegate] presentModalViewController:discoveryView animated:YES];
	
    BTstackManager * bt = [BTstackManager sharedInstance];
	[bt setDelegate:self];
	[bt addListener:self];
	[bt addListener:discoveryView];
    
	BTstackError err = [bt activate];
	if (err) NSLog(@"activate err 0x%02x!", err);*/
    	
	[pool drain];
}
/*
-(void) btstackManager:(BTstackManager*) manager
  handlePacketWithType:(uint8_t) packet_type
			forChannel:(uint16_t) channel
			   andData:(uint8_t *)packet
			   withLen:(uint16_t) size
{
	//bd_addr_t event_addr;
    NSLog(@"HANDLE PACKET");
	
	switch (packet_type) {
			
		case L2CAP_DATA_PACKET:
			if (packet[0] == 0xa1 && packet[1] == 0x31){
				[self handleBtDataWithX:packet[4] andY:packet[5] andZ:packet[6]];
			}
			break;
			
            
		case HCI_EVENT_PACKET:
			
			switch (packet[0]){
                    
				case HCI_EVENT_COMMAND_COMPLETE:
					if ( COMMAND_COMPLETE_EVENT(packet, hci_write_authentication_enable) ) {
                        // connect to device
                        bt_send_cmd(&l2cap_create_channel, [device address], PSM_HID_CONTROL);
					}
					break;
                    
				case HCI_EVENT_PIN_CODE_REQUEST:
					bt_flip_addr(event_addr, &packet[2]);
					if (BD_ADDR_CMP([device address], event_addr)) break;
                    
					// inform about pin code request
					NSLog(@"HCI_EVENT_PIN_CODE_REQUEST\n");
					bt_send_cmd(&hci_pin_code_request_reply, event_addr, 6,  &packet[2]); // use inverse bd_addr as PIN
					break;
                    
				case L2CAP_EVENT_CHANNEL_OPENED:
					if (packet[2] == 0) {
						// inform about new l2cap connection
						bt_flip_addr(event_addr, &packet[3]);
						uint16_t psm = READ_BT_16(packet, 11); 
						uint16_t source_cid = READ_BT_16(packet, 13); 
                        uint16_t dest_cid   = READ_BT_16(packet, 15);
						wiiMoteConHandle = READ_BT_16(packet, 9);
						NSLog(@"Channel successfully opened: handle 0x%02x, psm 0x%02x, source cid 0x%02x, dest cid 0x%02x",
							  wiiMoteConHandle, psm, source_cid, dest_cid);
						if (psm == PSM_HID_CONTROL) {
							// control channel openedn succesfully, now open interrupt channel, too.
                            hidControl = source_cid;
							bt_send_cmd(&l2cap_create_channel, event_addr, PSM_HID_INTERRUPT);
						} else {
							// request acceleration data.. 
                            hidInterrupt = source_cid;
							uint8_t setMode31[] = { 0xa2, 0x12, 0x00, 0x31 };
							bt_send_l2cap( hidInterrupt, setMode31, sizeof(setMode31));
							uint8_t setLEDs[] = { 0xa2, 0x11, 0x10 };
							bt_send_l2cap( hidInterrupt, setLEDs, sizeof(setLEDs));
							// start demo
							[self startDemo];
						}
					}
					break;
					
				default:
					break;
			}
			break;
			
		default:
			break;
	}
}
	
-(void) activatedBTstackManager:(BTstackManager*) manager {
	NSLog(@"activated!");
	[[BTstackManager sharedInstance] startDiscovery];
}

-(void) btstackManager:(BTstackManager*)manager deviceInfo:(BTDevice*)newDevice {
	NSLog(@"Device Info: addr %@ name %@ COD 0x%06x", [newDevice addressString], [newDevice name], [newDevice classOfDevice] ); 
	if ([newDevice name] && [[newDevice name] hasPrefix:@"Nintendo RVL-CNT-01"]){
		NSLog(@"WiiMote found with address %@", [newDevice addressString]);
		//device = newDevice;
		[[BTstackManager sharedInstance] stopDiscovery];
	}
}

-(void) discoveryStoppedBTstackManager:(BTstackManager*) manager {
	NSLog(@"discoveryStopped!");
	bt_send_cmd(&hci_write_authentication_enable, 0);
}*/

+ (LVController *)sharedInstance {
	return LVControllerInstance;
}

- (void)dealloc {
    [super dealloc];
}

@end
