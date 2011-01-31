//
//  OSICoalescedROI.h
//  OsiriX
//
//  Created by Joël Spaltenstein on 1/27/11.
//  Copyright 2011 OsiriX Team. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "OSIROI.h"

@interface OSICoalescedROI : OSIROI {

}

- (id)initWithOSIROIs:(NSArray *)rois;

@end
