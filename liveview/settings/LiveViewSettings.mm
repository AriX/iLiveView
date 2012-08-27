#import <Preferences/Preferences.h>

@interface LiveViewSettingsListController: PSListController {
}
@end

@implementation LiveViewSettingsListController
- (id)specifiers {
	if(_specifiers == nil) {
		_specifiers = [[self loadSpecifiersFromPlistName:@"LiveViewSettings" target:self] retain];
	}
	return _specifiers;
}
@end

// vim:ft=objc
