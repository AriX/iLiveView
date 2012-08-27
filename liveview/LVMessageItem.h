//
//  LVSimpleItem.h
//  iLiveView
//
//  Created by Ari Weinstein on 6/13/11.
//  Copyright 2011 Squish Software. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LVItemProtocol.h"

@interface LVMessageItem : NSObject <LVItemProtocol> {
    BOOL isUnread;
    NSString *time;
    NSString *header;
    NSString *body;
}

@property (nonatomic, assign) BOOL isUnread;
@property (nonatomic, copy) NSString *time;
@property (nonatomic, copy) NSString *header;
@property (nonatomic, copy) NSString *body;
@property (nonatomic, readonly) NSString *image;

@end
