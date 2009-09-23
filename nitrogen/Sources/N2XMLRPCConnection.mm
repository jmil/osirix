//
//  N2XMLRPCConnection.mm
//  HUGE Administration Tool
//
//  Created by Alessandro Volz on 21.09.09.
//  Copyright 2009 HUG. All rights reserved.
//

#import "N2XMLRPCConnection.h"
#import "ISO8601DateFormatter.h"
#import <Nitrogen/NSData+N2.h>
#import <Nitrogen/NSString+N2.h>

@implementation N2XMLRPCConnection
@synthesize delegate = _delegate;

-(void)dealloc {
	[self setDelegate:NULL];
	[super dealloc];
}

-(void)reconnect {
	_timeout = [NSTimer scheduledTimerWithTimeInterval:5 target:self selector:@selector(timeout:) userInfo:NULL repeats:NO];
	[super reconnect];
}

-(void)open {
	_timeout = [NSTimer scheduledTimerWithTimeInterval:5 target:self selector:@selector(timeout:) userInfo:NULL repeats:NO];
	[super open];
}

-(void)close {
	if (_timeout) [_timeout invalidate]; _timeout = NULL;
	[super close];
}

-(void)timeout:(NSTimer*)timer {
	_timeout = NULL;
	[self close];
}

-(void)handleData:(NSMutableData*)data {
	if (_executed) return;
	
	CFHTTPMessageRef request = CFHTTPMessageCreateEmpty(kCFAllocatorDefault, TRUE);
	CFHTTPMessageAppendBytes(request, (uint8*)[data bytes], [data length]);

	if (!CFHTTPMessageIsHeaderComplete(request))
		return;
	
	NSString* contentLength = (NSString*)CFHTTPMessageCopyHeaderFieldValue(request, (CFStringRef)@"Content-Length");
	if (contentLength) [contentLength autorelease];
	NSData* content = [(NSData*)CFHTTPMessageCopyBody(request) autorelease];
	
	if (contentLength && [content length] < [contentLength intValue])
		return;
	
	NSString* version = [(NSString*)CFHTTPMessageCopyVersion(request) autorelease];
    if (!version) {
        [self writeAndReleaseResponse:CFHTTPMessageCreateResponse(kCFAllocatorDefault, 505, NULL, kCFHTTPVersion1_0)];
        return;
    }
	
    NSString* method = [(NSString*)CFHTTPMessageCopyRequestMethod(request) autorelease];
    if (!method) {
        [self writeAndReleaseResponse:CFHTTPMessageCreateResponse(kCFAllocatorDefault, 400, NULL, (CFStringRef)version)];
        return;
    }
	
	if (![method isEqualToString:@"POST"]) {
		[self writeAndReleaseResponse:CFHTTPMessageCreateResponse(kCFAllocatorDefault, 405, NULL, (CFStringRef)version)];
		return;
	}
	
	_executed = YES;
	[self handleRequest:request];
	
	CFRelease(request);
}

+(NSObject*)ParseElement:(NSXMLNode*)n {
	if ([n kind] == NSXMLTextKind)
		return [n stringValue];
	
	NSXMLElement* e = (NSXMLElement*)n;
		
	if ([[e name] isEqualToString:@"array"]) {
		NSArray* values = [e nodesForXPath:@"data/value/*" error:NULL];
		NSMutableArray* returnValues = [NSMutableArray arrayWithCapacity:[values count]];
		for (NSXMLElement* v in values)
			[returnValues addObject:[N2XMLRPCConnection ParseElement:v]];
		return [NSArray arrayWithArray:returnValues];
	}
	
	if ([[e name] isEqualToString:@"base64"]) {
		return [NSData dataWithBase64:[[e childAtIndex:0] stringValue]];
	}
	
	if ([[e name] isEqualToString:@"boolean"]) {
		return [NSNumber numberWithBool:[[e stringValue] boolValue]];
	}
	
	if ([[e name] isEqualToString:@"dateTime.iso8601"]) {
		return [[[[ISO8601DateFormatter alloc] init] autorelease] dateFromString:[e stringValue]];
	}
	
	if ([[e name] isEqualToString:@"double"]) {
		return [NSNumber numberWithDouble:[[e stringValue] doubleValue]];
	}
	
	if ([[e name] isEqualToString:@"i4"] || [[e name] isEqualToString:@"int"]) {
		return [NSNumber numberWithInt:[[e stringValue] intValue]];
	}
	
	if ([[e name] isEqualToString:@"string"]) {
		return [[e stringValue] xmlUnescapedString];
	}
	
	if ([[e name] isEqualToString:@"struct"]) {
		NSArray* members = [e nodesForXPath:@"member" error:NULL];
		NSMutableDictionary* returnMembers = [NSMutableDictionary dictionaryWithCapacity:[members count]];
		for (NSXMLElement* m in members)
			[returnMembers setObject:[N2XMLRPCConnection ParseElement:[[m nodesForXPath:@"value/*" error:NULL] objectAtIndex:0]] forKey:[[[m nodesForXPath:@"name" error:NULL] objectAtIndex:0] stringValue]];
		return [NSDictionary dictionaryWithDictionary:returnMembers];
	}
	
	if ([[e name] isEqualToString:@"nil"]) {
		return NULL;
	}
	
	[NSException raise:NSGenericException format:@"unhandled XMLRPC data type: %@", [e name]]; return NULL;
}

+(NSString*)FormatElement:(NSObject*)o {
	if (!o)
		return @"<nil/>";
	
	if ([o isKindOfClass:[NSDictionary class]]) {
		NSMutableString* s = [NSMutableString stringWithCapacity:512];
		[s appendString:@"<struct>"];
		for (NSString* k in (NSDictionary*)o)
			[s appendFormat:@"<member><name>%@</name><value>%@</value></member>", k, [N2XMLRPCConnection FormatElement:[(NSDictionary*)o objectForKey:k]]];
		[s appendString:@"</struct>"];
		return [NSString stringWithString:s];
	}
	
	if ([o isKindOfClass:[NSString class]]) {
		return [NSString stringWithFormat:@"<string>%@</string>", [(NSString*)o xmlEscapedString]];
	}
	
	if ([o isKindOfClass:[NSArray class]]) {
		NSMutableString* s = [NSMutableString stringWithCapacity:512];
		[s appendString:@"<array><data>"];
		for (NSObject* o2 in (NSArray*)o)
			[s appendFormat:@"<value>%@</value>", [N2XMLRPCConnection FormatElement:o2]];
		[s appendString:@"</data></array>"];
		return [NSString stringWithString:s];
	}
	
	if ([o isKindOfClass:[NSDate class]]) {
		return [NSString stringWithFormat:@"<dateTime.iso8601>%@</dateTime.iso8601>", [[[[ISO8601DateFormatter alloc] init] autorelease] stringFromDate:(NSDate*)o]];
	}
	
	if ([o isKindOfClass:[NSData class]]) {
		return [NSString stringWithFormat:@"<base64>%@</base64>", [(NSData*)o base64]];
	}

	[NSException raise:NSGenericException format:@"execution succeeded but return class %@ unsupported", [o className]]; return NULL;
}

+(NSString*)ReturnElement:(NSInvocation*)invocation {
	const char* returnType = [[invocation methodSignature] methodReturnType];
	switch (returnType[0]) {
		case '@': {
			NSObject* o; [invocation getReturnValue:&o];
			return [N2XMLRPCConnection FormatElement:o];
		} break;
		case 'i': {
			NSInteger i; [invocation getReturnValue:&i];
			return [NSString stringWithFormat:@"<int>%d</int>", i];
		} break;
		case 'f': {
			CGFloat f; [invocation getReturnValue:&f];
			return [NSString stringWithFormat:@"<double>%f</double>", f];
		} break;
	}
	
	[NSException raise:NSGenericException format:@"execution succeeded but return type %c unsupported", returnType[0]]; return NULL;
}

-(void)handleRequest:(CFHTTPMessageRef)request {
	NSString* contentLengthString = (NSString*)CFHTTPMessageCopyHeaderFieldValue(request, (CFStringRef)@"Content-Length");
	if (contentLengthString) [contentLengthString autorelease];
	NSInteger contentLength = contentLengthString? [contentLengthString intValue] : 0;
	NSData* content = [(NSData*)CFHTTPMessageCopyBody(request) autorelease];
	
	if (contentLengthString && contentLength < [content length])
		content = [content subdataWithRange:NSMakeRange(0, contentLength)];
	
	NSLog(@"ssssss");
	
	@try {
		NSXMLDocument* doc = [[[NSXMLDocument alloc] initWithData:content options:NSXMLNodeOptionsNone error:NULL] autorelease];

		NSArray* methodCalls = [doc nodesForXPath:@"methodCall" error:NULL];
		if ([methodCalls count] != 1)
			[NSException raise:NSGenericException format:@"request contains %d method calls", [methodCalls count]];
		NSXMLElement* methodCall = [methodCalls objectAtIndex:0];
		
		NSArray* methodNames = [methodCall nodesForXPath:@"methodName" error:NULL];
		if ([methodNames count] != 1)
			[NSException raise:NSGenericException format:@"method call contains %d method names", [methodNames count]];
		NSString* methodName = [[methodNames objectAtIndex:0] stringValue];
		
//		NSArray* methodParameterNames = [doc nodesForXPath:@"methodCall/params//member/name" error:NULL];
//		NSMutableArray* methodParameterValues = [[doc nodesForXPath:@"methodCall/params//member/value" error:NULL] mutableArray];
//		if ([methodParameterNames count] != [methodParameterValues count])
//			[NSException raise:NSGenericException format:@"request parameters inconsistent", [methodNames count]];
		NSArray* params = [methodCall nodesForXPath:@"params/param/value/*" error:NULL];
		
//		NSMutableDictionary* methodParameters = [NSMutableDictionary dictionaryWithCapacity:[methodParameterNames count]];
//		for (int i = 0; i < [methodParameterNames count]; ++i)
//			[methodParameters setObject:[[methodParameterValues objectAtIndex:i] objectValue] forKey:[[methodParameterNames objectAtIndex:i] objectValue]];
		
		NSMutableString* methodSignatureString = [NSMutableString stringWithCapacity:128];
		[methodSignatureString appendString:methodName];
		for (NSXMLNode* n in params)
			[methodSignatureString appendString:@":"];
		
		SEL methodSelector = NSSelectorFromString(methodSignatureString);
		if (![_delegate respondsToSelector:methodSelector] || ![_delegate respondsToSelector:@selector(isMethodAvailableToXMLRPC:)] || ![_delegate performSelector:@selector(isMethodAvailableToXMLRPC:) withObject:methodSignatureString])
			[NSException raise:NSGenericException format:@"invalid method/parameters", [methodNames count]];
		
		NSMethodSignature* methodSignature = [_delegate methodSignatureForSelector:methodSelector];
		NSInvocation* invocation = [NSInvocation invocationWithMethodSignature:methodSignature];
		[invocation setTarget:_delegate];
		[invocation setSelector:methodSelector];
		
		for (int i = 0; i < [params count]; ++i) {
			const char* argType = [methodSignature getArgumentTypeAtIndex:2+i];
			NSXMLNode* n = [params objectAtIndex:i];
			NSObject* o = [N2XMLRPCConnection ParseElement:n];
			
			switch (argType[0]) {
				case '@': {
					[invocation setArgument:&o atIndex:2+i];
				} break;
				case 'i':
				case 'f': {
					NSAssert([o isKindOfClass:[NSNumber class]], @"Expecting a numeric parameter");
					NSNumber* n = (NSNumber*)o;
					switch (argType[0]) {
						case 'i': {
							NSInteger i = [n intValue];
							[invocation setArgument:&i atIndex:2+i];
						} break;
						case 'f': {
							CGFloat f = [n floatValue];
							[invocation setArgument:&f atIndex:2+i];
						} break;
						default: {
							[NSException raise:NSGenericException format:@"client side unsupported argument type %c in %@", argType[0], methodSignature];
						} break;
					}
				} break;
				default: {
					[NSException raise:NSGenericException format:@"client side unsupported argument type %c in %@", argType[0], methodSignature];
				} break;
			}
		}
		
		NSLog(@"ssssss2");
		[invocation invoke];
		NSLog(@"ssssss3");

		NSString* returnValue = [N2XMLRPCConnection ReturnElement:invocation];
		NSString* responseXml = [NSString stringWithFormat:@"<?xml version=\"1.0\" encoding=\"UTF-8\"?><methodResponse><params><param><value>%@</value></param></params></methodResponse>", returnValue];
		NSData* responseData = [responseXml dataUsingEncoding:NSUTF8StringEncoding];
		
		CFHTTPMessageRef response = CFHTTPMessageCreateResponse(kCFAllocatorDefault, 200, NULL, kCFHTTPVersion1_0);
		CFHTTPMessageSetHeaderFieldValue(response, (CFStringRef)@"Content-Length", (CFStringRef)[NSString stringWithFormat:@"%d", [responseData length]]);
		CFHTTPMessageSetBody(response, (CFDataRef)responseData);
		[self writeAndReleaseResponse:response];
	} @catch (NSException* e) {
		NSLog(@"Warning: [N2XMLRPCConnection handleRequest:] %@", [e description]);
		[self writeAndReleaseResponse:CFHTTPMessageCreateResponse(kCFAllocatorDefault, 500, (CFStringRef)[e description], kCFHTTPVersion1_0)];
	}
}

-(void)writeAndReleaseResponse:(CFHTTPMessageRef)response {
	[self writeData:[(NSData*)CFHTTPMessageCopySerializedMessage(response) autorelease]];
	_waitingToClose = YES;
	CFRelease(response);
}

-(void)lifecycle {
	[super lifecycle];
	if (_waitingToClose && _hasSpaceAvailable)
		[self close];
}

@end
