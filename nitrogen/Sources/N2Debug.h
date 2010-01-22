//
//  N2Debug.h
//  Nitrogen Framework
//
//  Created by Alessandro Volz on 6/25/09.
//  Copyright 2009 OsiriX Team. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface N2Debug : NSObject {
}

+(BOOL)isActive;
+(void)setActive:(BOOL)active;

@end


#ifdef DEBUG
#define DLog NSLog
#else
#define DLog(args...) { if ([N2Debug isActive]) NSLog(args); }
#endif
