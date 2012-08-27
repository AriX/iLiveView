//
//  NSMutableData+endian.h
//  LiveView
//
//  Created by Faye Pearson on 09/01/2011.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSData (endian)
- (NSMutableData *)deserializeWithFormat:(const NSString *)format, ...;
@end

@interface NSMutableData (endian)

- (void)appendint8:(int8_t)i8;
- (void)appendBEint16:(int16_t)i16;
- (void)appendBEint32:(int32_t)i32;
- (void)appendString:(NSString *)s;
- (void)appendBigString:(NSString *)s;
- (NSMutableData *)serializeWithFormat:(const NSString *)format, ...;
- (NSMutableData *)deserializeWithFormat:(const NSString *)format, ...;

@end
