//
//  LVMenuItem.m
//  iLiveView
//
//  Created by Ari Weinstein on 6/13/11.
//  Copyright 2011 Squish Software. All rights reserved.
//

#import "LVMenuItem.h"

@implementation LVMenuItem

@synthesize isAlertItem, currentIndex, name, icon;

- (id)init {
    self = [super init];
    if (self) {
        isAlertItem = TRUE;
        items = [[NSMutableArray alloc] initWithCapacity:50];
        currentIndex = 0;
    }
    
    return self;
}

- (void)addItem:(id<LVItemProtocol>)item {
    [items insertObject:item atIndex:0];
}

- (id<LVItemProtocol>)itemAtCurrentIndex {
    return [self itemAtIndex:currentIndex];
}

- (id<LVItemProtocol>)itemAtIndex:(int)index {
    if (index+1 > [items count]) return nil;
    return [items objectAtIndex:index];
}

- (int)unread {
    int i, j = 0;
    for (i=0; i<[items count]; i++) {
        if ([[items objectAtIndex:i] isUnread]) j++;
    }
    return j;
}

- (int)total {
    return [items count];
}

- (void)dealloc {
    [name release];
    [icon release];
    [super dealloc];
}

@end
