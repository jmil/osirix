//
//  ArthroplastyTemplatingTableView.h
//  Arthroplasty Templating II
//  Copyright (c) 2007-2009 OsiriX Foundation. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "ArthroplastyTemplatingWindowController.h"

@interface ArthroplastyTemplatingTableView : NSTableView {
	IBOutlet ArthroplastyTemplatingWindowController *windowController;
	IBOutlet NSArrayController *templatesArrayController;
}

@end
