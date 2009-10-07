//
//  N2XMLRPC.h
//  Nitrogen
//
//  Created by Alessandro Volz on 28.09.09.
//  Copyright 2009 HUG. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface N2XMLRPC : NSObject {
}

+(NSObject*)ParseElement:(NSXMLNode*)n;
+(NSString*)FormatElement:(NSObject*)o;
+(NSString*)ReturnElement:(NSInvocation*)invocation;

@end
