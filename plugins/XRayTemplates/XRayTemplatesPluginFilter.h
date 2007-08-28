//
//  XRayTemplatesPluginFilter.h
//  XRayTemplatesPlugin
//
//  Copyright (c) 2007 Joris. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PluginFilter.h"
#import "XRayTemplateWindowController.h"
#import "XRayTemplateStepByStepController.h"

@interface XRayTemplatesPluginFilter : PluginFilter {
	XRayTemplateWindowController *windowController;
	XRayTemplateStepByStepController *stepByStepController;
}

- (long)filterImage:(NSString*)menuName;
- (BOOL)findTemplatePanel;
- (BOOL)findStepByStepPanel;

@end
