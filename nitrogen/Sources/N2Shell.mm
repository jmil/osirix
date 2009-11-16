//
//  N2Shell.m
//  Nitrogen
//
//  Created by Alessandro Volz on 7/28/09.
//  Copyright 2009 OsiriX Team. All rights reserved.
//

#import "N2Shell.h"


@implementation N2Shell

+(NSString*)execute:(NSString*)path {
	return [N2Shell execute:path arguments:NULL];
}

+(NSString*)execute:(NSString*)path arguments:(NSArray*)arguments {
	return [N2Shell execute:path arguments:arguments expectedStatus:0];
}

+(NSString*)execute:(NSString*)path arguments:(NSArray*)arguments expectedStatus:(int)expectedStatus {
	if (!arguments) arguments = [NSArray array];
	
	NSTask* task = [[[NSTask alloc] init] autorelease];
	[task setLaunchPath:path];
	[task setArguments:arguments];
	[task setStandardOutput:[NSPipe pipe]];
	
	[task launch];
	[task waitUntilExit];
	
//	int status = [task terminationStatus];
	NSString* stdout = [[[[NSString alloc] initWithData:[[[task standardOutput] fileHandleForReading] readDataToEndOfFile] encoding:NSUTF8StringEncoding] autorelease] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
	
//	if (status != expectedStatus)
//		[NSException raise:NSGenericException format:@"Task %@ exited with status %d\n%@", path, status, stdout];
	
	return stdout;
}

+(NSString*)hostname {
	NSString* host = [[NSHost currentHost] name];
	NSRange r = [host rangeOfString:@"."];
	host = r.location!=NSNotFound? [host substringToIndex:r.location] : host;
	return host;
	// [N2Shell execute:@"/bin/hostname" arguments:[NSArray arrayWithObject:@"-s"]];
}

+(NSString*)mac {
	NSString* temp = [N2Shell execute:@"/usr/sbin/ipconfig" arguments:[NSArray arrayWithObjects:@"getpacket", @"en0", NULL] expectedStatus:1];
	NSArray* lines = [temp componentsSeparatedByCharactersInSet:[NSCharacterSet newlineCharacterSet]];
	
	NSString* chaddrPrefix = @"chaddr = ";
	for (NSString* line in lines) {
		if ([line hasPrefix:chaddrPrefix]) {
			NSMutableArray* pieces = [[[line substringFromIndex:[chaddrPrefix length]] componentsSeparatedByString:@":"] mutableCopy];
			for (NSUInteger i = 0; i < [pieces count]; ++i)
				if ([[pieces objectAtIndex:i] length] < 2)
					[pieces replaceObjectAtIndex:i withObject:[NSString stringWithFormat:@"0%@", [pieces objectAtIndex:i]]];
			return [pieces componentsJoinedByString:@":"];
		}
	}
	
	return @"00:00:00:00:00:00";
}

+(int)userId {
	return [[N2Shell execute:@"/usr/bin/id" arguments:[NSArray arrayWithObject:@"-u"]] intValue];
}

@end
