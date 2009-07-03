//
//  ArthroplastyTemplatingPlugin.h
//  Arthroplasty Templating II
//  Created by Joris Heuberger on 04/04/07.
//  Copyright (c) 2007-2009 OsiriX Foundation. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PluginFilter.h"
@class ArthroplastyTemplatingWindowController, ArthroplastyTemplatingStepByStepController;

@interface ArthroplastyTemplatingPlugin : PluginFilter {
	ArthroplastyTemplatingWindowController *_templatesWindowController;
	NSMutableArray* _windows;
	BOOL _initialized;
}

@property(readonly) ArthroplastyTemplatingWindowController* templatesWindowController;

-(ArthroplastyTemplatingStepByStepController*)windowControllerForViewer:(ViewerController*)viewer;

@end
