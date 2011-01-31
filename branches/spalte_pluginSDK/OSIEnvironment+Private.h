//
//  OSIEnvironment+Private.h
//  OsiriX
//
//  Created by Joël Spaltenstein on 1/26/11.
//  Copyright 2011 OsiriX Team. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "OSIEnvironment.h";

@class ViewerController;

@interface OSIEnvironment (Private)

- (void)addViewerController:(ViewerController *)viewerController;
- (void)removeViewerController:(ViewerController *)viewerController;

@end
