//
//  NSUtils.h
//  Arthroplasty Templating II
//
//  Created by Alessandro Volz on 6/25/09.
//  Copyright 2009 HUG. All rights reserved.
//

#import <Cocoa/Cocoa.h>

extern NSString* NoInterceptionException;


CGFloat NSSign(CGFloat f);


NSPoint operator-(const NSPoint& p);						// -[x,y] = [-x,-y]
NSPoint operator+(const NSPoint& p1, const NSPoint& p2);	// [x,y]+[X,Y] = [x+X,y+Y]
NSPoint operator-(const NSPoint& p1, const NSPoint& p2);	// [x,y]-[X,Y] = -[X,Y]+[x,y] = [x-X,y-Y]
NSPoint operator/(const NSPoint& p, const CGFloat f);		// [x,y]/d = [x/d,y/d]
BOOL operator==(const NSPoint& p1, const NSPoint& p2);
BOOL operator!=(const NSPoint& p1, const NSPoint& p2);

CGFloat NSDistance(const NSPoint& p1, const NSPoint& p2);
CGFloat NSAngle(const NSPoint& p1, const NSPoint& p2);
#define NSMiddle(p1,p2) ((p1+p2)/2)


typedef struct _NSVector : _NSPoint {
} NSVector;

NSVector NSMakeVector(CGFloat x, CGFloat y);
NSVector NSMakeVector(const NSPoint& from, const NSPoint& to);
NSVector NSMakeVector(const NSPoint& p);
NSPoint NSMakePoint(const NSVector& p);

NSVector operator!(const NSVector& v);

CGFloat NSLength(const NSVector& v);
CGFloat NSAngle(const NSVector& v);

typedef struct _NSLine {
    NSPoint origin;
	NSVector direction;
} NSLine;

NSLine NSMakeLine(const NSPoint& origin, const NSVector& direction);
NSLine NSMakeLine(const NSPoint& p1, const NSPoint& p2);

CGFloat NSAngle(const NSLine& l);
BOOL NSParallel(const NSLine& l1, const NSLine& l2);
NSPoint operator*(const NSLine& l1, const NSLine& l2);		// intersection of lines
