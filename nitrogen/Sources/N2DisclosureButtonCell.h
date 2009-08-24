//
//  N2DisclosureButtonCell.h
//  Nitrogen Framework
//
//  Created by Joris Heuberger on 30/03/07.
//  Edited by Alessandro Volz since 21/05/09.
//  Copyright 2009 OsiriX Team. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface N2DisclosureButtonCell : NSButtonCell {
	NSMutableDictionary* _attributes;
}

@property(readonly) NSMutableDictionary* attributes;

@end
