//
//  LVMenuItem.h
//  iLiveView
//
//  Created by Ari Weinstein on 6/13/11.
//  Copyright 2011 Squish Software. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LVItemProtocol.h"

@interface LVMenuItem : NSObject {
    BOOL isAlertItem;
    int currentIndex;
    
    NSString *name;
    NSString *icon;
    NSMutableArray *items;
}

- (void)addItem:(id<LVItemProtocol>)item;
- (id<LVItemProtocol>)itemAtIndex:(int)index;
- (id<LVItemProtocol>)itemAtCurrentIndex;
- (int)unread;
- (int)total;

@property (nonatomic, assign) BOOL isAlertItem;
@property (nonatomic, assign) int currentIndex;
@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *icon;

@end
