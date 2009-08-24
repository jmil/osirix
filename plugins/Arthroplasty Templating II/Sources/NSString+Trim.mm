//
//  NSString+Trim.mm
//  Arthroplasty Templating II
//  Created by Alessandro Volz on 5/27/09.
//  Copyright (c) 2007-2009 OsiriX Team. All rights reserved.
//

#import "NSString+Trim.h"


@implementation NSString(Trim)

-(NSString*)stringByTrimmingStartAndEnd {
	NSCharacterSet* whitespaceAndNewline = [NSCharacterSet whitespaceAndNewlineCharacterSet];
	unsigned i;
	for (i = 0; i < [self length] && [whitespaceAndNewline characterIsMember:[self characterAtIndex:i]]; ++i);
	if (i == [self length]) return @"";
	unsigned start = i;
	for (i = [self length]-1; i > start && [whitespaceAndNewline characterIsMember:[self characterAtIndex:i]]; --i);
	if (i == start) return @"";
	return [self substringWithRange:NSMakeRange(start, i-start+1)];
}



@end
