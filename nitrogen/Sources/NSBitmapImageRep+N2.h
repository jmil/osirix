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

-(void)ATMask:(float)level;
-(NSBitmapImageRep*)smoothen:(NSUInteger)margin;
//-(NSBitmapImageRep*)convolveWithFilter:(const boost::numeric::ublas::matrix<float>&)filter fillPixel:(NSUInteger[])fillPixel;
//-(NSBitmapImageRep*)fftConvolveWithFilter:(const boost::numeric::ublas::matrix<float>&)filter fillPixel:(NSUInteger[])fillPixel;

@end
