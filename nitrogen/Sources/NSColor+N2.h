//
//  NSColor+N2.h
//  Nitrogen
//
//  Created by Alessandro Volz on 14.09.09.
//  Copyright 2009 OsiriX Team. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface NSColor (N2)

-(BOOL)isEqualToColor:(NSColor*)color;
-(BOOL)isEqualToColor:(NSColor*)color alphaThreshold:(CGFloat)alphaThreshold;

@end
