//
//  N2Panel.h
//  Nitrogen Framework
//
//  Created by Alessandro Volz on 8/24/09.
//  Copyright 2009 OsiriX Team. All rights reserved.
//

#import <Cocoa/Cocoa.h>
@class N2View;

@interface N2Panel : NSPanel {
	BOOL _canBecomeKeyWindow;
}

@property BOOL canBecomeKeyWindow;

@end
