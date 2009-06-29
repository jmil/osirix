//
//  NSUtils.mm
//  Arthroplasty Templating II
//
//  Created by Alessandro Volz on 6/25/09.
//  Copyright 2009 HUG. All rights reserved.
//

#import "NSUtils.h"
#include <cmath>


NSString* NoInterceptionException = @"NoInterceptionException";


// CGFloat

CGFloat NSSign(CGFloat f) {
	return f<0? -1 : 1;
}


/// NSPoint

NSPoint operator+(const NSPoint& p1, const NSPoint& p2) {
	return NSMakePoint(p2.x+p1.x, p2.y+p1.y);
}

NSPoint operator-(const NSPoint& p1) {
	return NSMakePoint(-p1.x, -p1.y);
}

NSPoint operator-(const NSPoint& p1, const NSPoint& p2) {
	return -p2+p1;
}

NSPoint operator/(const NSPoint& p, const CGFloat f) {
	return NSMakePoint(p.x/f, p.y/f);
}

BOOL operator==(const NSPoint& p1, const NSPoint& p2) {
	return (p1.x==p2.x) && (p1.y==p2.y);
}

BOOL operator!=(const NSPoint& p1, const NSPoint& p2) {
	return !(p1==p2);
}

CGFloat NSDistance(const NSPoint& p1, const NSPoint& p2) {
	return NSLength(NSMakeVector(p1, p2));
}

CGFloat NSAngle(const NSPoint& p1, const NSPoint& p2) {
	return NSAngle(NSMakeVector(p1, p2));
}


/// NSVector

NSVector NSMakeVector(CGFloat x, CGFloat y) {
	NSVector vector;
	vector.x = x;
	vector.y = y;
	return vector;
}

NSVector NSMakeVector(const NSPoint& p1, const NSPoint& p2) {
	return NSMakeVector(p2.x-p1.x, p2.y-p1.y);
}

NSVector NSMakeVector(const NSPoint& p) {
	return NSMakeVector(p.x, p.y);
}

NSPoint NSMakePoint(const NSVector& v) {
	return NSMakePoint(v.x, v.y);
}

NSVector operator!(const NSVector& v) {
	return NSMakeVector(-v.y, v.x);
}

CGFloat NSAngle(const NSVector& v) {
	if (v.y == 0)
		return pi/2 * NSSign(v.y);
	return atan(v.y/v.x);
}

CGFloat NSLength(const NSVector& v) {
	return std::sqrt(std::pow(v.x, 2)+std::pow(v.y, 2));
}


/// NSLine

NSLine NSMakeLine(const NSPoint& origin, const NSVector& direction) {
	NSLine line;
	line.origin = origin;
	line.direction = direction;
	return line;
}

NSLine NSMakeLine(const NSPoint& p1, const NSPoint& p2) {
	return NSMakeLine(p1, NSMakeVector(p1, p2));
}

CGFloat NSAngle(const NSLine& l) {
	return NSAngle(l.direction);
}

BOOL NSParallel(const NSLine& l1, const NSLine& l2) {
	return NSAngle(l1) == NSAngle(l2);
}

NSPoint operator*(const NSLine& l1, const NSLine& l2) {
	if (NSParallel(l1, l2))
		[NSException raise:NoInterceptionException format:@"The two lines are parallel and therefore have no interception."];
	CGFloat u = (l2.direction.x*(l1.origin.y-l2.origin.y)-l2.direction.y*(l1.origin.x-l2.origin.x))/(l2.direction.y*l1.direction.x-l2.direction.x*l1.direction.y);
	return NSMakePoint(l1.origin.x+u*l1.direction.x, l1.origin.y+u*l1.direction.y);
}
