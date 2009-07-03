//
//  NSButtonCell+ArthroplastyTemplating.m
//  Arthroplasty Templating II
//
//  Created by Alessandro Volz on 6/17/09.
//  Copyright 2009 HUG. All rights reserved.
//

#import "NSButton+ArthroplastyTemplating.h"


@implementation ATButtonCell

-(void)awakeFromNib {
	[self setShowsBorderOnlyWhileMouseInside:NO];
}

@end

@implementation ATPanel
@synthesize canBecomeKeyWindow = _canBecomeKeyWindow;
@end
