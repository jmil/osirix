//
//  NSString+N2.mm
//  Nitrogen Framework
//
//  Created by Alessandro Volz on 07/22/09.
//  Copyright 2009 OsiriX Team. All rights reserved.
//

#import <Nitrogen/NSString+N2.h>


@implementation NSString (N2)

+(NSString*)sizeString:(unsigned long long)size { // From http://snippets.dzone.com/posts/show/3038 with slight modifications
    if (size<1023)
        return [NSString stringWithFormat:@"%i octets", size];
    float floatSize = float(size) / 1024;
    if (floatSize<1023)
        return [NSString stringWithFormat:@"%1.1f KO", floatSize];
    floatSize = floatSize / 1024;
    if (floatSize<1023)
        return [NSString stringWithFormat:@"%1.1f MO", floatSize];
    floatSize = floatSize / 1024;
    return [NSString stringWithFormat:@"%1.1f GO", floatSize];
}

+(NSString*)timeString:(NSTimeInterval)time {
	NSString* unit; unsigned value;
	if (time < 60-1) {
		unit = @"seconde"; value = ceil(time);
	} else if (time < 3600-1) {
		unit = @"minute"; value = ceil(time/60);
	} else {
		unit = @"heure"; value = ceil(time/3600);
	}
	
	return [NSString stringWithFormat:@"%d %@%@", value, unit, value==1? @"" : @"s"];
}

+(NSString*)dateString:(NSTimeInterval)date {
	return [[NSDate dateWithTimeIntervalSinceReferenceDate:date] descriptionWithCalendarFormat:@"'le' dd.MM.yyyy 'à' HH'h'mm" timeZone:NULL locale:[[NSUserDefaults standardUserDefaults] dictionaryRepresentation]];
}

-(NSString*)stringByTrimmingStartAndEnd {
	NSCharacterSet* whitespaceAndNewline = [NSCharacterSet whitespaceAndNewlineCharacterSet];
	unsigned i;
	for (i = 0; i < [self length] && [whitespaceAndNewline characterIsMember:[self characterAtIndex:i]]; ++i);
	if (i == [self length]) return @"";
	unsigned start = i;
	for (i = [self length]-1; i > start && [whitespaceAndNewline characterIsMember:[self characterAtIndex:i]]; --i);
	return [self substringWithRange:NSMakeRange(start, i-start+1)];
}

@end
