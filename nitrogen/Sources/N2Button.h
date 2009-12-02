//
//  N2Button.h
//  Nitrogen
//
//  Created by Alessandro Volz on 18.11.09.
//  Copyright 2009 OsiriX Team. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface N2Button : NSButton {
	id _representedObject;
}

@property(retain) id representedObject;

@end
