#import <SpringBoard/SpringBoard.h>
#import <ChatKit/ChatKit.h>

#import <dlfcn.h>
#import <objc/runtime.h>

#import "LVController.h"
%class SBUIController;
%class SBIconModel;
%class SBIcon;
%class SBAppSwitcherController;
%class SBAwayController;

@interface SBUIController (peterhajas)
-(void)activateApplicationFromSwitcher:(SBApplication *) app;
-(void)dismissSwitcher;
-(BOOL)activateSwitcher;
@end

@interface SBIconModel (peterhajas)
+(id)sharedInstance;
-(id)applicationIconForDisplayIdentifier:(id)displayIdentifier;
@end

@interface SBIcon (peterhajas)
-(id)iconImageView;
@end

@interface SBRemoteLocalNotificationAlert : SBAlertItem
-(id)alertItemNotificationSender;
@end

/*-(void)launchBundleID:(NSString *)bundleID {
	//TODO: switch to URL for this
    SBUIController *uicontroller = (SBUIController *)[%c(SBUIController) sharedInstance];
    SBApplicationController *appcontroller = (SBApplicationController *)[%c(SBApplicationController) sharedInstance];
    if([[appcontroller applicationsWithBundleIdentifier:bundleID] count] == 0)
    {
        //We can't do anything!
        //Inform the user, then return out
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Can't find application"
                                                  message:[NSString stringWithFormat:@"MobileNotifier can't find the application with bundle ID of %@. Has it been uninstalled or removed?", bundleID]
                                                  delegate:nil
                                                  cancelButtonTitle:@"Ok"
                                                  otherButtonTitles:nil];
        [alert show];
        [alert release];
        
        return;
    }
	if([[UIDevice currentDevice] respondsToSelector:@selector(isMultitaskingSupported)])
	{
		//Do the awesome, animated switch to the new app
		[uicontroller activateApplicationFromSwitcher:[[appcontroller applicationsWithBundleIdentifier:bundleID] objectAtIndex:0]];
	}
	else
	{
		//Boring old way (which still doesn't work outside of Springboard)
		[uicontroller activateApplicationAnimated:[[appcontroller applicationsWithBundleIdentifier:bundleID] objectAtIndex:0]];
	}
}

-(void)launchAppInSpringBoardWithBundleID:(NSString *)bundleID
{
    [self launchBundleID:bundleID];
}

-(UIImage*)iconForBundleID:(NSString *)bundleID;
{
	if([bundleID isEqualToString:@"com.apple.MobileSMS"])
	{
		return [[UIImage imageWithContentsOfFile:@"/Applications/MobileSMS.app/icon.png"] retain];
	}
	if([bundleID isEqualToString:@"com.apple.mobilephone"])
	{
		return [[UIImage imageWithContentsOfFile:@"/Applications/MobilePhone.app/icon.png"] retain];
	}
	
	SBApplicationController* sbac = (SBApplicationController *)[%c(SBApplicationController) sharedInstance];
	//Let's grab the application's icon using some awesome NSBundle stuff!
	
	//If we can't grab the app from the SBApplicationController, then bummer. We can't launch.
    if([[sbac applicationsWithBundleIdentifier:bundleID] count] < 1)
    {
        //Just return nothing. It's better than something!
        return nil;
    }
	
	//Next, grab the app's bundle:
	NSBundle *appBundle = (NSBundle*)[[[sbac applicationsWithBundleIdentifier:bundleID] objectAtIndex:0] bundle];
	//Next, ask the dictionary for the IconFile name
	NSString *iconName = [[appBundle infoDictionary] objectForKey:@"CFBundleIconFile"];
	NSString *iconPath = @"";
	
	if(iconName != nil)
	{
		//Finally, query the bundle for the path of the icon minus its path extension (usually .png)
		iconPath = [appBundle pathForResource:[iconName stringByDeletingPathExtension] 
												 ofType:[iconName pathExtension]];
	}
	else
	{
		//Some apps, like Boxcar, prefer an array of icons. We need to deal with that appropriately.
		NSArray *iconArray = [[appBundle infoDictionary] objectForKey:@"CFBundleIconFiles"];
		//Interate through the array first
		int count = [iconArray count];
		if(count != 0)
		{
			int i;
			for(i = 0; i < count; i++)
			{
				//With some preliminary testing, the highest-up item in the iconArray is the highest resolution image
				iconPath = [appBundle pathForResource:[[iconArray objectAtIndex:i] stringByDeletingPathExtension] 
														 ofType:[[iconArray objectAtIndex:i] pathExtension]];
			}
		}
	}
	
	//Prefer retina images over non retina images
	
	if([UIImage imageWithContentsOfFile:iconPath] == nil)
	{
		iconPath = [appBundle pathForResource:@"Icon@2x" ofType:@"png"];
	}
	
	if([UIImage imageWithContentsOfFile:iconPath] == nil)
	{
		iconPath = [appBundle pathForResource:@"icon@2x" ofType:@"png"];
	}
	
	if([UIImage imageWithContentsOfFile:iconPath] == nil)
	{
		iconPath = [appBundle pathForResource:@"Icon" ofType:@"png"];
	}
	
	if([UIImage imageWithContentsOfFile:iconPath] == nil)
	{
		iconPath = [appBundle pathForResource:@"icon" ofType:@"png"];
	}
	
	//Return our UIImage!
	if(iconPath != nil)
	{
		return [[UIImage imageWithContentsOfFile:iconPath] retain];
	}
	else
	{
		//We don't have an image. Let's return one with the MobileNotifier logo.
		return [[UIImage imageWithContentsOfFile:@"/Library/Application Support/MobileNotifier/lockscreen-logo.png"] retain];
	}
}

-(void)dismissSwitcher
{
    SBUIController *uicontroller = (SBUIController *)[%c(SBUIController) sharedInstance];
    [uicontroller dismissSwitcher];
}

-(void)wakeDeviceScreen
{
    SBAwayController* awayController = (SBAwayController *)[%c(SBAwayController) sharedAwayController];
    [awayController undimScreen];
    [awayController restartDimTimer:5.0];
}*/

//Mail class declaration for fetched messages

@interface AutoFetchRequestPrivate

-(BOOL)gotNewMessages;
-(int)messageCount;

@end

LVController *liveView;

NSMutableArray *smsArray;
NSMutableArray *pushArray;

%hook SpringBoard

- (void)applicationDidFinishLaunching:(id)application {    
    %orig;
   
    dlopen("/usr/local/lib/BTstack.dylib", RTLD_NOW);
    liveView = [[LVController alloc] init];
    
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

%end;

%hook BBServer

- (void)_addBulletin:(id)bulletin {
    %orig;
    
    if ([(id)[bulletin section] isEqualToString:@"com.apple.MobileSMS"]) {
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        LVMenuItem *messagesItem = [liveView.menuItems objectAtIndex:0];
        LVMessageItem *newMessage = [[LVMessageItem alloc] init];
        newMessage.time = [liveView relativeDate:[bulletin date]];
        newMessage.header = [bulletin title];
        newMessage.body = [bulletin message];
        [messagesItem addItem:newMessage];
        [newMessage release];
        [dateFormatter release];
        [liveView setStatusBarWithItem:0 andAlerts:[messagesItem unread] andImage:@"MessagesSmall"];
    }
    if ([(id)[bulletin section] isEqualToString:@"com.apple.mobilemail"]) {
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        LVMenuItem *messagesItem = [liveView.menuItems objectAtIndex:1];
        LVMessageItem *newMessage = [[LVMessageItem alloc] init];
        newMessage.time = [liveView relativeDate:[bulletin date]];
        newMessage.header = [bulletin title];
        newMessage.body = [bulletin message];
        [messagesItem addItem:newMessage];
        [newMessage release];
        [dateFormatter release];
        [liveView setStatusBarWithItem:0 andAlerts:[messagesItem unread] andImage:@"MessagesSmall"];
    }
}

%end;

//Experimental: Hook SBAlertItemsController for skipping the alert grabbing and going right for the built-in manager

%hook SBAlertItemsController

- (void)activateAlertItem:(id)item {
    //Build the alert data part of the way
    //MNAlertData *data;
    
    NSLog(@"SHNARK SHNARK SHNARK");

	if ([item isKindOfClass:%c(SBSMSAlertItem)]) {
	    NSLog(@"EE OWWHHH");
        //It's an SMS/MMS!
        [liveView vibrate];
        /*[liveView setMenuZero];
        [liveView setScreenModeWithBrightness:kBrightnessMax andAuto:1];
        [liveView setStatusBarWithItem:0 andAlerts:1 andImage:@"logprevu"];*/
        /*[liveView setMenuZero];
        [liveView resetMenu];*/
        //[liveView notifyWithItem:0 andAlerts:0 andImage:@"logprevu"];
       // [liveView sendDisplayPanelWithTopText:@"Hi" bottomText:@"Text msg" imageName:@"logprevu" alertUser:1];
       /* data = [[MNAlertData alloc] init];
        data.type = kSMSAlert;
        data.time = [[NSDate date] retain];
    	data.status = kNewAlertForeground;
		data.bundleID = [[NSString alloc] initWithString:@"com.apple.MobileSMS"];
		if ([item alertImageData] == NULL) {
			data.header = [[NSString alloc] initWithFormat:@"%@", [item name]];
			data.text = [[NSString alloc] initWithFormat:@"%@", [item messageText]];
		} else {
			data.header = [[NSString alloc] initWithFormat:@"%@", [item name]];
			data.text = [[NSString alloc] initWithFormat:@"%@", [item messageText]];
	    }
		[manager newAlertWithData:data];*/
		%orig;
	} else if(([item isKindOfClass:%c(SBRemoteNotificationAlert)]) || ([item isKindOfClass:%c(SBRemoteLocalNotificationAlert)])) {
        //It's a push notification!
        
		//Get the SBApplication object, we need its bundle identifier
		/*SBApplication *app(MSHookIvar<SBApplication *>(item, "_app"));
		//Filter out clock alerts
		if (![phacinterface isApplicationIgnored:[app bundleIdentifier]]) {
			NSString* _body = MSHookIvar<NSString*>(item, "_body");
			data = [[MNAlertData alloc] init];
			data.time = [[NSDate date] retain];
        	data.status = kNewAlertForeground;
			data.type = kPushAlert;
			data.bundleID = [app bundleIdentifier];
			data.header = [app displayName];
			data.text = _body;
			[manager newAlertWithData:data];
		} else {
			//We do not want to intercept ignored application events.
			%orig;
		}*/
		%orig;
    } else if([item isKindOfClass:%c(SBVoiceMailAlertItem)]) {
        //It's a voicemail alert!
       /* data = [[MNAlertData alloc] init];
        data.time = [[NSDate date] retain];
    	data.status = kNewAlertForeground;
        data.type = kPhoneAlert;
        data.bundleID = @"com.apple.mobilephone";
        data.header = [item title];
        data.text = [item bodyText];
		[manager newAlertWithData:data];*/
		%orig;
    }
    
    else
    {
        //It's a different alert (power/app store, for example)
		
		//Let's run the original function for now
		%orig;
    }
}

-(void)deactivateAlertItem:(id)item
{
    %log;
    %orig;
}

%end

//Hook AutoFetchRequestPrivate for getting new mail
/*
%hook AutoFetchRequestPrivate

-(void)run //This works! This is an appropriate way for us to display a new mail notification to the user
{
	%orig;
    %log;
	if([self gotNewMessages])
	{
		//Build the alert data part of the way
		MNAlertData* data = [[MNAlertData alloc] init];
		//Current date + time
        data.time = [[NSDate date] retain];
		data.status = kNewAlertForeground;

	    data.type = kSMSAlert;
		data.bundleID = [[NSString alloc] initWithString:@"com.apple.MobileMail"];
		
		data.header = [[NSString alloc] initWithFormat:@"Mail"];
		data.text = [[NSString alloc] initWithFormat:@"%d new messages", [self messageCount]];
		
		[manager newAlertWithData:data];
	}
}

%end
*/
static void reloadPrefsNotification(CFNotificationCenterRef center,
									void *observer,
									CFStringRef name,
									const void *object,
									CFDictionaryRef userInfo) {
	//[manager reloadPreferences];
}

%ctor
{
	//Register for the preferences-did-change notification
	CFNotificationCenterRef r = CFNotificationCenterGetDarwinNotifyCenter();
	CFNotificationCenterAddObserver(r, NULL, &reloadPrefsNotification, CFSTR("com.ariweinstein.liveview/reloadPrefs"), NULL, 0);
}

//Information about Logos for future reference:

/* How to Hook with Logos
Hooks are written with syntax similar to that of an Objective-C @implementation.
You don't need to #include <substrate.h>, it will be done automatically, as will
the generation of a class list and an automatic constructor.

%hook ClassName

// Hooking a class method
+ (id)sharedInstance {
	return %orig;
}

// Hooking an instance method with an argument.
- (void)messageName:(int)argument {
	%log; // Write a message about this call, including its class, name and arguments, to the system log.

	%orig; // Call through to the original function with its original arguments.
	%orig(nil); // Call through to the original function with a custom argument.

	// If you use %orig(), you MUST supply all arguments (except for self and _cmd, the automatically generated ones.)
}

// Hooking an instance method with no arguments.
- (id)noArguments {
	%log;
	id awesome = %orig;
	[awesome doSomethingElse];

	return awesome;
}

// Always make sure you clean up after yourself; Not doing so could have grave conseqeuences!
%end
*/

	//How to hook ivars!
	//MSHookIvar<ObjectType *>(self, "OBJECTNAME");



// vim:ft=objc
