//
//  N2Debug.h
//  Nitrogen Framework
//
//  Created by Alessandro Volz on 6/25/09.
//  Copyright 2009 OsiriX Team. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#ifdef DEBUG
#define DLog NSLog
#else
#define DLog(...) //
#endif
