//
//  SpineCounterFilter.h
//  SpineCounter
//
//  Created by rossetantoine on Wed Jun 09 2004.
//  Copyright (c) 2004 Antoine Rosset. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PluginFilter.h"
#import "ROI.h"

@interface SpineCounterFilter : PluginFilter {

}

- (long) filterImage:(NSString*) menuName;

- (void) setMenus;

- (void) switchTypes;
- (void) incrementDefaultName;
- (void) exportSpines;

- (NSString*) outputString:(NSString*) prevType: (NSString*) newType;


- (void) rotateType:(ROI*) roi;

- (void) endSavePanel: (NSSavePanel *) sheet returnCode: (int) retCode contextInfo: (void *) contextInfo;

@end
