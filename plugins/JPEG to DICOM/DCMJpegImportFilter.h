//
//   DCMJpegImportFilter
//  
//

//  Copyright (c) 2005 Macrad, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PluginFilter.h"

@class DCMCalendarDate;

@interface DCMJpegImportFilter : PluginFilter
{
	NSString *patientName;
	DCMCalendarDate *patientDOB;
	NSString *patientID, *patientSex;
	NSString *studyDescription;
	NSDate *datePicker;
	
	DCMCalendarDate *studyDate;
	DCMCalendarDate *studyTime;
	
	NSString *studyInstanceUID;
	NSString *seriesInstanceUID;

	int studyID;
	int imageNumber;

	BOOL addtoCurrentStudy;
}

@property BOOL addtoCurrentStudy;
@property (retain) NSString *patientName, *patientID, *studyDescription;
@property (retain) NSDate *datePicker;

- (long) filterImage:(NSString*) menuName;
- (void)convertImageToDICOM:(NSString *)path;
- (void)studyInfo;

@end
