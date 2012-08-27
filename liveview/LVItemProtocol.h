//
//  LVItemProtocol.h
//  iLiveView
//
//  Created by Ari Weinstein on 6/13/11.
//  Copyright 2011 Squish Software. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol LVItemProtocol <NSObject>

- (BOOL)isUnread;
- (NSString *)time;
- (NSString *)header;
- (NSString *)body;
- (NSString *)image;
- (void)sendToPhone;

@end
