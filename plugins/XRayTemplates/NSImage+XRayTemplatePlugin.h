//
//  NSImage+XRayTemplatePlugin.h
//  XRayTemplatesPlugin
//
//  Created by Joris Heuberger on 10/25/07.
//  Copyright 2007 OsiriX Team. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface NSImage (XRayTemplatePlugin)

- (NSImage*)croppedImageInRectangle:(NSRect)rect;
- (void)flipImageHorizontally;

@end