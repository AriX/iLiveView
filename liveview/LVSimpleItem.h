//
//  LVSimpleItem.h
//  iLiveView
//
//  Created by Ari Weinstein on 6/13/11.
//  Copyright 2011 Squish Software. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LVItemProtocol.h"

@interface LVSimpleItem : NSObject <LVItemProtocol> {
    BOOL isUnread;
    NSString *time;
    NSString *header;
    NSString *body;
}

@property (nonatomic, assign) BOOL isUnread;
@property (nonatomic, assign) NSString *time;
@property (nonatomic, assign) NSString *header;
@property (nonatomic, assign) NSString *body;
@property (nonatomic, readonly) NSString *image;

@end
