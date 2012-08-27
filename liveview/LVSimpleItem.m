//
//  LVSimpleItem.m
//  iLiveView
//
//  Created by Ari Weinstein on 6/13/11.
//  Copyright 2011 Squish Software. All rights reserved.
//

#import "LVSimpleItem.h"

@implementation LVSimpleItem

@synthesize isUnread, time, header;

- (id)init {
    self = [super init];
    if (self) {
        isUnread = YES;
    }
    
    return self;
}

- (NSString *)body {
    isUnread = NO;
    return body;
}

- (NSString *)image {
    return @"logprevu";
}

- (void)setBody:(NSString *)newBody {
    body = newBody;
}

- (void)sendToPhone {
    NSLog(@"%@ sent to phone!", header);
}

@end
