//
//  ArthroplastyTemplatingPlugin.h
//  Arthroplasty Templating II
//  Created by Joris Heuberger on 04/04/07.
//  Copyright (c) 2007-2009 OsiriX Foundation. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PluginFilter.h"
@class ArthroplastyTemplatingWindowController;
@class ArthroplastyTemplatingStepByStepController;

@interface ArthroplastyTemplatingPlugin : PluginFilter {
	ArthroplastyTemplatingWindowController *windowController;
	ArthroplastyTemplatingStepByStepController *stepByStepController;
}

- (long) filterImage:(NSString*) menuName;

@end
