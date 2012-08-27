//
//  iLiveViewViewController.m
//  iLiveView
//
//  Created by Ari on 3/28/11.
//  Copyright 2011 Squish Software. All rights reserved.
//

#import "iLiveViewViewController.h"

@implementation iLiveViewViewController

- (void)setScreenStatus:(NSString *)status {
    screenLabel.text = status;
}

- (void)setVersion:(NSString *)version {
	[versionLabel performSelectorOnMainThread:@selector(setText:) withObject:[NSString stringWithString:version] waitUntilDone:NO];
}

- (void)setConnected:(BOOL)connected {
	[connectedView performSelectorOnMainThread:@selector(setImage:) withObject:[UIImage imageNamed:(connected)?@"success.png":@"fail.png"] waitUntilDone:NO];
	[self performSelectorOnMainThread:@selector(_setVersionVisible:) withObject:connected?@"YES":@"" waitUntilDone:NO];
	if (!connected) {
        [self setVersion:@""];
        [screenLabel performSelectorOnMainThread:@selector(setText:) withObject:@"" waitUntilDone:NO];
    }
}

- (void)setInitialized:(BOOL)initialized {
	[initializedView performSelectorOnMainThread:@selector(setImage:) withObject:[UIImage imageNamed:(initialized)?@"success.png":@"fail.png"] waitUntilDone:NO];
}

- (void)setStatus:(NSString *)statusString withExit:(BOOL)exitVisible {
	[statusLabel performSelectorOnMainThread:@selector(setText:) withObject:[NSString stringWithFormat:@"Status: %@", statusString] waitUntilDone:NO];
	[self performSelectorOnMainThread:@selector(_setExitVisible:) withObject:exitVisible?@"YES":@"" waitUntilDone:NO];
}

- (void)_setVersionVisible:(NSString *)versionVisibleString {
	versionHeading.hidden = ![versionVisibleString isEqualToString:@"YES"];
    screenHeading.hidden = ![versionVisibleString isEqualToString:@"YES"];
}

- (void)_setExitVisible:(NSString *)exitVisibleString {
	exitButton.hidden = ![exitVisibleString isEqualToString:@"YES"];
}

- (IBAction)exit {
    exit(0);
}

- (IBAction)vibrate {
	/*NSMutableData *output = [[[NSMutableData alloc] init] autorelease];
	[output serializeWithFormat:@">HH", 1, 1000];
	[liveView sendMessage:kMessageSetVibrate withData:output];*/
    /*NSMutableData *output = [[[NSMutableData alloc] init] autorelease];
	[output serializeWithFormat:@">B", kDeviceStatusMenu];
	[liveView sendMessage:kMessageDeviceStatus withData:output];*/
    [liveView displayBitmapWithX:0 andY:0 andBitmap:[[[NSData alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"music" ofType:@"png"]] autorelease]];
    
    //[liveView setMenuSettingsWithVibration:8 fontSize:12 menuID:3];
}

- (IBAction)test1 {
    [liveView setStatusBarWithItem:0 andAlerts:2 andImage:@"logprevu"];
}

- (IBAction)test2 {
    /*int msgid = 80;
	NSMutableData *output = [[[NSMutableData alloc] init] autorelease];
	[output serializeWithFormat:@">BHHHBBB", 0, 0, 0, 0, msgid, 0, 0]; // final 0 is for plaintext vs bitmapimage (1) strings
	[output appendString:topText];
	[output serializeWithFormat:@">H", 0];
	[output serializeWithFormat:@">B", 0];
	[output appendString:bottomText];
	if (bitmapName) [output appendData:[[[NSData alloc] initWithContentsOfFile:[self pathForImage:bitmapName]] autorelease]];
	[liveView sendMessage:kMessageDisplayPanel withData:output];*/
    NSMutableData *output = [[[NSMutableData alloc] init] autorelease];
	[output serializeWithFormat:@">B", kDeviceStatusOn];
	[liveView sendMessage:kMessageDeviceStatus withData:output];
}

- (IBAction)test3 {
    [liveView setScreenModeWithBrightness:kBrightnessMax andAuto:0];
}

- (IBAction)test4 {
    [liveView notifyWithItem:0 andAlerts:0 andImage:nil];
}

- (IBAction)resetMenu {
	[liveView enableMenu];
}

- (IBAction)setMenuZero {
	[liveView disableMenu];
}

- (IBAction)clearDisplay {
	NSMutableData *output = [[[NSMutableData alloc] init] autorelease];
	[output appendString:@""];
	[liveView sendMessage:kMessageClearDisplay withData:output];
}

- (void)viewDidLoad {
    [super viewDidLoad];
	
	liveView = [[LVController alloc] initWithDelegate:self];
    
    LVMenuItem *messagesItem = [[LVMenuItem alloc] init];
    messagesItem.name = @"Messages";
    messagesItem.icon = @"Messages";
    [liveView.menuItems addObject:messagesItem];
    [messagesItem release];
    LVMenuItem *successItem = [[LVMenuItem alloc] init];
    successItem.name = @"Prevue Online";
    successItem.icon = @"vue";
    [liveView.menuItems addObject:successItem];
    LVSimpleItem *simpleItem1 = [[LVSimpleItem alloc] init];
    simpleItem1.time = @"6:00PM";
    simpleItem1.header = @"Prevue Guide";
    simpleItem1.body = @"Welcome to the party!";
    [successItem addItem:simpleItem1];
    [simpleItem1 release];
    [successItem release];
    LVMenuItem *failItem = [[LVMenuItem alloc] init];
    failItem.name = @"Vue";
    failItem.icon = @"vue_sw";
    [liveView.menuItems addObject:failItem];
    [failItem release];
}

- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

- (void)dealloc {
    [super dealloc];
}

@end