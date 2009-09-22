//
//  NSInvocation+N2.h
//  HUGE Administration Tool
//
//  Created by Alessandro Volz on 21.09.09.
//  Copyright 2009 HUG. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface NSInvocation (N2)

+(NSInvocation*)invocationWithSelector:(SEL)sel target:(id)target argument:(id)arg;

@end
