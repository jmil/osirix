//
//  XRayTemplateTableView.h
//  XRayTemplatesPlugin
//
//  Created by Joris Heuberger on 07/03/07.
//  Copyright 2007 OsiriX Team. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "XRayTemplateWindowController.h"

@interface XRayTemplateTableView : NSTableView {
	IBOutlet XRayTemplateWindowController *windowController;
	IBOutlet NSArrayController *templatesArrayController;
}

@end
