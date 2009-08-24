//
//  N2Pair.h
//  Nitrogen Framework
//
//  Created by Alessandro Volz on 8/11/09.
//  Copyright 2009 OsiriX Team. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface N2Pair : NSObject {
	id _first, _second;
}

@property(retain) id first, second;

-(id)initWith:(id)first and:(id)second;

@end
