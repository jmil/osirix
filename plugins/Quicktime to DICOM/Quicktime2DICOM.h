//
//   DCMJpegImportFilter
//  
//

#import <Foundation/Foundation.h>
#import "OsiriX Headers/PluginFilter.h"

@class DCMCalendarDate;

@interface Quicktime2DICOM : PluginFilter
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

- (void)convertMovieToDICOM:(NSString *)path;
- (long) filterImage:(NSString*) menuName;
- (void) studyInfo;

@end
