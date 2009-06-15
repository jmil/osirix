//
//  NSImage+Extras.h
//  Arthroplasty Templating II
//  Created by Alessandro Volz on 5/27/09.
//  Copyright (c) 2009 OsiriX Foundation. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface NSImage (ArthroplastyTemplating)

-(NSImage*)croppedImageInRectangle:(NSRect)rect;
-(void)flipImageHorizontally;
-(NSRect)boundingBoxSkippingColor:(NSColor*)color;

@end