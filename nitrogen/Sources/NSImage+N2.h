//
//  NSImage+Extras.h
//  Arthroplasty Templating II
//  Created by Alessandro Volz on 5/27/09.
//  Copyright (c) 2009 OsiriX Team. All rights reserved.
//

#import <Cocoa/Cocoa.h>
//#include <boost/numeric/ublas/matrix.hpp>

@interface NSImage (N2)

-(void)flipImageHorizontally;
-(NSRect)boundingBoxSkippingColor:(NSColor*)color inRect:(NSRect)box;
-(NSRect)boundingBoxSkippingColor:(NSColor*)color;

-(BOOL)isLogicallyResizable;

@end

@interface N2Image : NSImage {
	NSRect _portion;
	NSSize _inchSize;
}

@property NSSize inchSize;
@property NSRect portion;

-(id)initWithSize:(NSSize)size inches:(NSSize)inches;
-(id)initWithSize:(NSSize)size inches:(NSSize)inches portion:(NSRect)portion;
-(N2Image*)crop:(NSRect)rect;
-(NSPoint)convertPointFromPageInches:(NSPoint)p;
-(NSSize)originalInchSize;
-(float)resolution;

@end