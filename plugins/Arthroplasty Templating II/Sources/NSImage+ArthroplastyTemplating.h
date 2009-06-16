//
//  NSImage+Extras.h
//  Arthroplasty Templating II
//  Created by Alessandro Volz on 5/27/09.
//  Copyright (c) 2009 OsiriX Foundation. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface NSBitmapImageRep (ArthroplastyTemplating)

-(void)ATMask:(float)level;

@end


@interface NSImage (ArthroplastyTemplating)

-(void)flipImageHorizontally;
-(NSRect)boundingBoxSkippingColor:(NSColor*)color inRect:(NSRect)box;
-(NSRect)boundingBoxSkippingColor:(NSColor*)color;

@end

@interface ATImage : NSImage {
	NSSize _inchSize;
}

@property NSSize inchSize;

-(id)initWithSize:(NSSize)size inches:(NSSize)inches;
-(ATImage*)crop:(NSRect)rect;
-(float)resolution;

@end