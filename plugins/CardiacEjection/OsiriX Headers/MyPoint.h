//
//  MyPoint.h
//  OsiriX
//
//  Created by rossetantoine on Mon Mar 29 2004.
//  Copyright (c) 2004 ROSSET Antoine. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface MyPoint : NSObject  <NSCoding>
{
	NSPoint pt;
}

+ (MyPoint*) point: (NSPoint) a;

- (id) initWithPoint:(NSPoint) a;
- (void) setPoint:(NSPoint) a;
- (float) y;
- (float) x;
- (NSPoint) point;
- (BOOL) isEqualToPoint:(NSPoint) a;
- (BOOL) isNearToPoint:(NSPoint) a :(float) scale;
- (void) move:(float) x :(float) y;

@end
