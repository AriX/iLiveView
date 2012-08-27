#import "LVPreferenceManager.h"

@implementation LVPreferenceManager

@synthesize preferences;

-(id)init
{
	self = [super init];
	if(self)
	{
		preferences = [[NSDictionary dictionaryWithContentsOfFile:@"/var/mobile/Library/Preferences/com.ariweinstein.liveview.plist"] retain];
	}
	return self;
}

-(void)reloadPreferences
{
	if(preferences)
	{
		[preferences release];
	}
	preferences = [[NSDictionary dictionaryWithContentsOfFile:@"/var/mobile/Library/Preferences/com.ariweinstein.liveview.plist"] retain];
}

@end