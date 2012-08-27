//
//  iLiveViewViewController.h
//  iLiveView
//
//  Created by Ari on 3/28/11.
//  Copyright 2011 Squish Software. All rights reserved.
//

#import "LVController.h"

@interface iLiveViewViewController : UIViewController <LiveViewDelegate> {
    LVController *liveView;
    
	IBOutlet UILabel *versionHeading;
	IBOutlet UILabel *versionLabel;
    IBOutlet UILabel *screenHeading;
    IBOutlet UILabel *screenLabel;
	IBOutlet UILabel *statusLabel;
	IBOutlet UIButton *exitButton;
	IBOutlet UIImageView *initializedView;
	IBOutlet UIImageView *connectedView;
}

- (void)setScreenStatus:(NSString *)tatus;
- (void)setVersion:(NSString *)version;
- (void)setStatus:(NSString *)statusString withExit:(BOOL)exitVisible;
- (void)setInitialized:(BOOL)initialized;
- (void)setConnected:(BOOL)connected;

- (IBAction)clearDisplay;
- (IBAction)vibrate;
- (IBAction)exit;
- (IBAction)resetMenu;
- (IBAction)setMenuZero;
- (IBAction)test1;
- (IBAction)test2;
- (IBAction)test3;
- (IBAction)test4;

@end
