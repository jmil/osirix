//
//   DCMJpegImportFilter
//  
//

//  Copyright (c) 2005 Macrad, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PluginFilter.h"

@class DCMCalendarDate;

@interface DCMJpegImportFilter : PluginFilter {
	IBOutlet NSView *accessoryView;
	IBOutlet id patientNameField;
	IBOutlet id patientIDField;
	IBOutlet id studyDesciptionID;
	IBOutlet NSDatePicker *datePicker;
	
	NSString *patientName;
	NSString *patientID;
	NSString *studyDescription;
	DCMCalendarDate *studyDate;
	DCMCalendarDate *studyTime;
	
	NSString *studyInstanceUID;
	NSString *seriesInstanceUID;
	int studyID;
	int imageNumber;

}

- (long) filterImage:(NSString*) menuName;
- (void)convertImageToDICOM:(NSString *)path;

@end
