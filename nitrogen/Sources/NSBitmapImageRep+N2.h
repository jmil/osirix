//
//  NSBitmapImageRep+N2.h
//  Nitrogen Framework
//
//  Created by Alessandro Volz on 07/08/09.
//  Copyright 2009 OsiriX Team. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface NSBitmapImageRep (N2)

-(void)setColor:(NSColor*)color;
-(NSImage*)image;
-(NSBitmapImageRep*)repUsingColorSpaceName:(NSString*)colorSpaceName;

@end
