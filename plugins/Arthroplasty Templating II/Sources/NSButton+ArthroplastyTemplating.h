//
//  NSButtonCell+ArthroplastyTemplating.h
//  Arthroplasty Templating II
//
//  Created by Alessandro Volz on 6/17/09.
//  Copyright 2009 HUG. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface ATButtonCell	: NSButtonCell
@end;

@interface ATPanel : NSPanel {
	BOOL _canBecomeKeyWindow;
}

@property BOOL canBecomeKeyWindow;

@end;