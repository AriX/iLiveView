//
//  iLiveViewAppDelegate.h
//  iLiveView
//
//  Created by Ari on 3/28/11.
//  Copyright 2011 Squish Software. All rights reserved.
//

#import <UIKit/UIKit.h>

@class iLiveViewViewController;

@interface iLiveViewAppDelegate : NSObject <UIApplicationDelegate> {
    UIWindow *window;
    iLiveViewViewController *viewController;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet iLiveViewViewController *viewController;

@end

