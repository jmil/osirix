//
//  NSData+N2.mm
//  Nitrogen Framework
//
//  Created by Alessandro Volz on 07/08/09.
//  Copyright 2009 OsiriX Team. All rights reserved.
//

#import <Nitrogen/NSData+N2.h>

char hexchar2dec(char hex) {
	if (hex >= '0' && hex <= '9')
		return hex-'0';
	if (hex >= 'A' && hex <= 'F')
		return hex-'A'+10;
	if (hex >= 'a' && hex <= 'f')
		return hex-'a'+10;
	return -1;
}

char hex2char(const char* hex) {
	return (hexchar2dec(hex[0])<<4)+hexchar2dec(hex[1]);
}


@implementation NSData (N2)

+(NSData*)dataWithHex:(NSString*)hex {
	if (!hex) return NULL;
	return [[[NSData alloc] initWithHex:hex] autorelease];
}

-(NSData*)initWithHex:(NSString*)hex {
	NSUInteger length = [hex length]/2;
	char* buffer = (char*)malloc(length);
	const char* utf8 = [hex UTF8String];
	
	#pragma omp parallel for
	for (int i = 0; i < (int)length; ++i)
		buffer[i] = hex2char(&utf8[i*2]);
	
	return [self initWithBytesNoCopy:buffer length:length];
}

@end
