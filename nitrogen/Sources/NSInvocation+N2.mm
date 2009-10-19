//
//  NSInvocation+N2.m
//  HUGE Administration Tool
//
//  Created by Alessandro Volz on 21.09.09.
//  Copyright 2009 HUG. All rights reserved.
//

#import "NSInvocation+N2.h"
#include <sstream>

@implementation NSInvocation (N2)

+(NSInvocation*)invocationWithSelector:(SEL)sel target:(id)target argument:(id)arg {
	NSMethodSignature* signature = [target methodSignatureForSelector:sel];
	NSInvocation* invocation = [NSInvocation invocationWithMethodSignature:signature];
	[invocation setTarget:target];
	[invocation setSelector:sel];
	
	const char* firstArgumentType = [signature getArgumentTypeAtIndex:2];
//	DLog(@"Creating invocation for [%@ %@(%c)%@]", [target className], NSStringFromSelector(sel), firstArgumentType[0], arg);
	switch (firstArgumentType[0]) {
		case '@': {
			[invocation setArgument:&arg atIndex:2];
		} break;
			
		case 'i':
		case 'I':
		case 'f':
		case 'c':
		case 'd': {
			if ([arg isKindOfClass:[NSString class]]) {
				switch (firstArgumentType[0]) {
					case 'i': {
						NSInteger i = [arg integerValue];
						[invocation setArgument:&i atIndex:2];
					} break;
					case 'I': {
						NSUInteger I = [arg integerValue];
						[invocation setArgument:&I atIndex:2];
					} break;
					case 'f': {
						CGFloat f = [arg floatValue];
						[invocation setArgument:&f atIndex:2];
					} break;
					case 'd': {
						double d = [arg doubleValue];
						[invocation setArgument:&d atIndex:2];
					} break;
					case 'c': {
						char c = [arg intValue];
						[invocation setArgument:&c atIndex:2];
					} break;
				}
			} else if ([arg isKindOfClass:[NSNumber class]]) {
				switch (firstArgumentType[0]) {
					case 'i': {
						NSInteger i = [arg integerValue];
						[invocation setArgument:&i atIndex:2];
					} break;
					case 'I': {
						NSUInteger I = [arg unsignedIntegerValue];
						[invocation setArgument:&I atIndex:2];
					} break;
					case 'f': {
						CGFloat f = [arg floatValue];
						[invocation setArgument:&f atIndex:2];
					} break;
					case 'd': {
						double d = [arg doubleValue];
						[invocation setArgument:&d atIndex:2];
					} break;				
					case 'c': {
						char c = [arg intValue];
						[invocation setArgument:&c atIndex:2];
					} break;				
				}
			} else {
				NSLog(@"Warning: unhandled argument class %@", [arg className]);
				return NULL;
			}
		} break;
			
		default: {
			NSLog(@"Warning: unhandled first argument type '%c'", firstArgumentType[0]);
			return NULL;
		} break;
	}
	
	return invocation;
}

@end
