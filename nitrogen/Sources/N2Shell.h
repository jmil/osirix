//
//  Shell.h
//  HUGE Administration Tool
//
//  Created by Alessandro Volz on 7/28/09.
//  Copyright 2009 HUG. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface N2Shell : NSObject

+(NSString*)execute:(NSString*)path;
+(NSString*)execute:(NSString*)path arguments:(NSArray*)arguments;
+(NSString*)execute:(NSString*)path arguments:(NSArray*)arguments expectedStatus:(int)expectedStatus;
+(NSString*)hostname;
+(NSString*)mac;
+(int)userId;

@end
