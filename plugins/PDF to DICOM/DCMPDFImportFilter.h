//
//   DCMPDFImportFilter
//  
//

#import <Foundation/Foundation.h>
#import "PluginFilter.h"

@class DCMCalendarDate;

@interface DCMPDFImportFilter : PluginFilter
{
	IBOutlet NSView *accessoryView;
	IBOutlet id patientNameField;
	IBOutlet id patientIDField;
	IBOutlet id studyDesciptionID;
	IBOutlet NSDatePicker *datePicker;
	
	NSString *_patientName;
	NSString *_patientID;
	NSString *_patientDOB;
	NSString *_patientSex;
		
	NSString *_docTitle;
	DCMCalendarDate *_studyDate;
	DCMCalendarDate *_studyTime;
	DCMCalendarDate *_seriesDate;
	DCMCalendarDate *_seriesTime;
	
	NSString *_studyInstanceUID;
	NSString *_seriesInstanceUID;
	int _studyID;
	int _imageNumber;
	
	BOOL _addtoCurrentStudy;
}

- (long) filterImage:(NSString*) menuName;
- (void)convertImageToDICOM:(NSString *)path;

-(BOOL) addtoCurrentStudy;
-(void) setAddtoCurrentStudy:(BOOL)value;
-(NSString *)patientName;
-(NSString *)patientID;
-(void)setPatientName:(NSString *)name;
-(void)setPatientID:(NSString *)pid;
- (void)studyInfo;
- (NSString *)docTitle;
- (void)setDocTitle:(NSString *)docTitle;

@end
