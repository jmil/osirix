//
//  ROIEnhancementFilter.h
//  ROIEnhancementFilter
//
//  Created by rossetantoine on Wed Jun 09 2004.
//  Copyright (c) 2004 Antoine Rosset. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PluginFilter.h"
#import "ResultsController.h"

@interface ROIEnhancementFilter : PluginFilter {

}

- (long) filterImage:(NSString*) menuName;

@end
