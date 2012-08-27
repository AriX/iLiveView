//
//  LVSimpleItem.m
//  iLiveView
//
//  Created by Ari Weinstein on 6/13/11.
//  Copyright 2011 Squish Software. All rights reserved.
//

#import "LVMessageItem.h"

@implementation LVMessageItem

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
    return @"MessagesSmall";
}

- (void)setBody:(NSString *)newBody {
    [body release];
    body = [newBody copy];
}

- (void)sendToPhone {
    NSLog(@"%@ sent to phone!", header);
}

- (void)dealloc {
    [body release];
    [time release];
    [header release];
    
    [super dealloc];
}

@end
