//
//  NSMutableData+endian.m
//  LiveView
//
//  Created by Faye Pearson on 09/01/2011.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "NSMutableData+endian.h"

@implementation NSData (endian)
/* deserializeWithFormat:...
	You may want to change this to return pos at the end.
	You may want to add another field that takes the initial pos
 */
- (NSData *)deserializeWithFormat:(const NSString *)format, ... {
	int c;
	int pos = 0;
	va_list argumentList;
	id *arg;
	int l;
	
	va_start(argumentList, format);
	for (c=0;c<[format length];c++) {
		switch ([format characterAtIndex:c]) {
			case '>':
				// it's all big endian here. You want something else?
				break;
			case '<':
				// ah, you do.  Sorry.
				break;
			case 'B':
				arg = va_arg(argumentList, id*);
				[self getBytes:arg range:NSMakeRange(pos,1)];
				pos++;
				break;
			case 'H':
				arg = va_arg(argumentList, id*);
				[self getBytes:arg range:NSMakeRange(pos,2)];
				*(uint16_t*)arg=ntohs(*(uint16_t*)arg);
				pos+=2;
				break;
			case 'L':
				arg = va_arg(argumentList, id*);
				[self getBytes:arg range:NSMakeRange(pos,4)];
				*(uint32_t*)arg=ntohl(*(uint32_t*)arg);
				pos+=4;
				break;
			case 's':
				arg = va_arg(argumentList, id*);
				l=0;
				[self getBytes:&l range:NSMakeRange(pos,1)];
				pos++;
				*arg = [[NSString alloc] initWithBytes:[[self subdataWithRange:NSMakeRange(pos,l)] bytes] length:l encoding:NSUTF8StringEncoding];
				break;
			case 'S':
				arg = va_arg(argumentList, id*);
				l=0;
				[self getBytes:&l range:NSMakeRange(pos,2)];
				l=ntohs(l);
				pos+=2;
				*arg = [[NSString alloc] initWithBytes:[[self subdataWithRange:NSMakeRange(pos,l)] bytes] length:l encoding:NSUTF8StringEncoding];
				break;
			default:
				break;
		}
	}
	va_end(argumentList);
	return self;
}

@end

@implementation NSMutableData (endian)

- (void)appendint8:(int8_t)i8 {
	[self appendBytes:&i8 length:sizeof(int8_t)];
}

- (void)appendBEint16:(int16_t)i16 {
	i16=ntohs(i16);
	[self appendBytes:&i16 length:sizeof(int16_t)];
}

- (void)appendBEint32:(int32_t)i32 {
	i32=ntohl(i32);
	[self appendBytes:&i32 length:sizeof(int32_t)];
}

- (void)appendString:(NSString *)s {
	NSData *str = [s dataUsingEncoding:NSUTF8StringEncoding];
	if ([str length]>255) {
		str = [str subdataWithRange:NSMakeRange(0, 255)];
	}
	[self appendint8:[str length]];
	if ([str length]) [self appendData:str];
}

- (void)appendBigString:(NSString *)s {
	NSData *str = [s dataUsingEncoding:NSUTF8StringEncoding];
	[self appendBEint16:[str length]];
	if ([str length]) [self appendData:str];
}

- (NSMutableData *)serializeWithFormat:(const NSString *)format, ... {
	int c;
	va_list argumentList;
	
	va_start(argumentList, format);
	for (c=0;c<[format length];c++) {
		switch ([format characterAtIndex:c]) {
			case '>':
				// it's all big endian here. You want something else?
				break;
			case '<':
				// ah, you do.  Sorry.
				break;
			case 'B':
				[self appendint8:va_arg(argumentList,int)];
				break;
			case 'H':
				[self appendBEint16:va_arg(argumentList,int)];
				break;
			case 'L':
				[self appendBEint32:va_arg(argumentList,int32_t)];
				break;
			case 's':
				[self appendString:va_arg(argumentList,id)];
				break;
			case 'S':
				[self appendBigString:va_arg(argumentList,id)];
				break;
			default:
				break;
		}
	}
	va_end(argumentList);
	return self;
}

- (NSMutableData *)deserializeWithFormat:(const NSString *)format, ... {
	int c;
	int pos = 0;
	va_list argumentList;
	id *arg;
	int l;
	
	va_start(argumentList, format);
	for (c=0;c<[format length];c++) {
		switch ([format characterAtIndex:c]) {
			case '>':
				// it's all big endian here. You want something else?
				break;
			case '<':
				// ah, you do.  Sorry.
				break;
			case 'B':
				arg = va_arg(argumentList, id*);
				[self getBytes:arg range:NSMakeRange(pos,1)];
				pos++;
				break;
			case 'H':
				arg = va_arg(argumentList, id*);
				[self getBytes:arg range:NSMakeRange(pos,2)];
				*(uint16_t*)arg=ntohs(*(uint16_t*)arg);
				pos+=2;
				break;
			case 'L':
				arg = va_arg(argumentList, id*);
				[self getBytes:arg range:NSMakeRange(pos,4)];
				*(uint32_t*)arg=ntohl(*(uint32_t*)arg);
				pos+=4;
				break;
			case 's':
				arg = va_arg(argumentList, id*);
				l=0;
				[self getBytes:&l range:NSMakeRange(pos,1)];
				pos++;
				*arg = [[NSString alloc] initWithBytes:[[self subdataWithRange:NSMakeRange(pos,l)] bytes] length:l encoding:NSUTF8StringEncoding];
				break;
			case 'S':
				arg = va_arg(argumentList, id*);
				l=0;
				[self getBytes:&l range:NSMakeRange(pos,2)];
				l=ntohs(l);
				pos+=2;
				*arg = [[NSString alloc] initWithBytes:[[self subdataWithRange:NSMakeRange(pos,l)] bytes] length:l encoding:NSUTF8StringEncoding];
				break;
			default:
				break;
		}
	}
	va_end(argumentList);
	return self;
}


@end
