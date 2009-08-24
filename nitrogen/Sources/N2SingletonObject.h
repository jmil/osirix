//
//  N2SingletonObject.h
//  Nitrogen Framework
//
//  Created by Alessandro Volz on 8/11/09.
//  Copyright 2009 OsiriX Team. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface N2SingletonObject : NSObject {
	@protected
	BOOL _hasInited;
}

@end
