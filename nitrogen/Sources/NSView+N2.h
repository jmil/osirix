//
//  NSView+N2.h
//  Nitrogen
//
//  Created by Alessandro Volz on 11.11.09.
//  Copyright 2009 OsiriX Team. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface NSView (N2)

// Shortcut to [NSView initWithFrame:NSMakeRect(NSZeroPoint, size)]
-(id)initWithSize:(NSSize)size;

@end

@protocol OptimalSize

-(NSSize)optimalSize;
-(NSSize)optimalSizeForWidth:(CGFloat)width;

@end
