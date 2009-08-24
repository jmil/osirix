//
//  NSTextView+N2.h
//  Nitrogen Framework
//
//  Created by Alessandro Volz on 07/08/09.
//  Copyright 2009 OsiriX Team. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface NSTextView (N2)

-(NSSize)adaptToContent;
-(NSSize)adaptToContent:(CGFloat)maxWidth;

@end
