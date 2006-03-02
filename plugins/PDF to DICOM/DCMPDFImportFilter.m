//
//   DCMPDFImportFilter
//  
//

//  Copyright (c) 2005 Macrad, LL. All rights reserved.
//

#import "DCMPDFImportFilter.h"
#import <OsiriX/DCM.h>
//#import <OsiriX/DCMEncapsulatedPDF.h>

#import "browserController.h"

@implementation DCMPDFImportFilter

- (long) filterImage:(NSString*) menuName
{
	if (_addtoCurrentStudy)
		[self studyInfo];
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	NSDate *date = [datePicker dateValue];
	_studyDate = [DCMCalendarDate dicomDateWithDate:date];
	_studyTime = [DCMCalendarDate dicomTimeWithDate:date];
	_seriesTime = nil;
	_seriesDate= nil;
	[self setDocTitle:@"PDF"];
	NSArray *topLevelObjects;
	NSBundle *thisBundle = [NSBundle bundleForClass:[self class]];
	NSNib *nib = [[NSNib alloc] initWithNibNamed:@"ConversionInfo" bundle:thisBundle];
	[nib instantiateNibWithOwner:self topLevelObjects:&topLevelObjects];
	[datePicker setDateValue:[NSDate date]];
	NSOpenPanel *openPanel = [NSOpenPanel openPanel];
	[openPanel setAccessoryView:accessoryView];
	[openPanel setCanChooseDirectories:YES];
	[openPanel setAllowsMultipleSelection:YES];
	[openPanel setTitle:NSLocalizedString(@"Import", nil)];
	[openPanel setMessage:NSLocalizedString(@"Select PDF or folder of PDFs to convert to DICOM", nil)];
	
	if([openPanel runModalForTypes:[NSArray arrayWithObject:@"pdf"]] == NSOKButton){
		_docTitle = [studyDesciptionID stringValue];
		
		DCMObject *dcmObject = [DCMObject dcmObject];
		[dcmObject newStudyInstanceUID];
		[dcmObject newSeriesInstanceUID];
		
		if (_addtoCurrentStudy)
			[self studyInfo];
		else 
			_imageNumber = 0;
		
		if (!_studyInstanceUID)
			_studyInstanceUID = [dcmObject attributeValueWithName:@"StudyInstanceUID"];	
		if (!_seriesInstanceUID)
		_seriesInstanceUID = [dcmObject attributeValueWithName:@"SeriesInstanceUID"];
			
		
		NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
		_studyID = [defaults  integerForKey:@"JTDStudyID"];
		if (_studyID = 0)
			_studyID = 10001;
		[defaults setInteger:_studyID++ forKey:@"JTDStudyID"];
		
		NSEnumerator *enumerator = [[openPanel filenames] objectEnumerator];
		NSString *fpath;
		BOOL isDir;
		while(fpath = [enumerator nextObject]){
			[[NSFileManager defaultManager] fileExistsAtPath:fpath isDirectory:&isDir];
			//loop through directory if true
			if (isDir){
				NSDirectoryEnumerator *dirEnumerator = [[NSFileManager defaultManager] enumeratorAtPath:fpath];
				NSString *path;
				while (path = [dirEnumerator nextObject])
					if  ([[NSImage imageFileTypes] containsObject:[path pathExtension]] 
					|| [[NSImage imageFileTypes] containsObject:NSFileTypeForHFSTypeCode([[[[NSFileManager defaultManager] fileSystemAttributesAtPath:path] objectForKey:NSFileHFSTypeCode] longValue])])
						[self convertImageToDICOM:[fpath stringByAppendingPathComponent:path]];
			}
			else
				[self convertImageToDICOM:fpath];
		}
	}
	
	[nib release];
	
	[self setPatientName:nil];
	[self setPatientID:nil];
	[self setDocTitle:nil];

	_patientID = nil;
	_patientDOB = nil;
	_patientSex = nil;;
		

	_studyDate = nil;
	_studyTime = nil;
	_seriesDate = nil;
	_seriesTime = nil;
	
	_studyInstanceUID = nil;
	_seriesInstanceUID = nil;

	[pool release];
	return -1;
}

- (void)convertImageToDICOM:(NSString *)path{
	
	//create image
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	NSData *pdf = nil;
	if ([[path pathExtension] isEqualToString:@"pdf"])
		pdf = [NSData dataWithContentsOfFile:path];	
	//if we have an image  get the info we need from the imageRep.
	if (pdf ){
			
			// create DICOM OBJECT
			DCMObject *dcmObject = [DCMObject newEncapsulatedPDF:pdf];
			[dcmObject setAttributeValues:[NSArray arrayWithObject:_studyInstanceUID] forName:@"StudyInstanceUID"];
			[dcmObject setAttributeValues:[NSArray arrayWithObject:_seriesInstanceUID] forName:@"SeriesInstanceUID"];
			[dcmObject setAttributeValues:[NSArray arrayWithObject:@"PDF"] forName:@"SeriesDescription"];
			[dcmObject setAttributeValues:[NSMutableArray arrayWithObject:_patientName] forName:@"PatientsName"];
			[dcmObject setAttributeValues:[NSMutableArray arrayWithObject:_patientID] forName:@"PatientID"];
			[dcmObject setAttributeValues:[NSMutableArray arrayWithObject:_patientSex] forName:@"PatientsSex"];
			[dcmObject setAttributeValues:[NSMutableArray arrayWithObject:_patientDOB] forName:@"PatientsBirthDate"];
			
			[dcmObject setAttributeValues:[NSMutableArray arrayWithObject:_docTitle] forName:@"DocumentTitle"];
			
			[dcmObject setAttributeValues:[NSMutableArray arrayWithObject:[NSString stringWithFormat:@"%d", _imageNumber++]] forName:@"InstanceNumber"];
			[dcmObject setAttributeValues:[NSMutableArray arrayWithObject:[NSString stringWithFormat:@"%d", _studyID]] forName:@"StudyID"];
			
			[dcmObject setAttributeValues:[NSMutableArray arrayWithObject:_studyDate] forName:@"StudyDate"];			
			[dcmObject setAttributeValues:[NSMutableArray arrayWithObject:_studyTime] forName:@"StudyTime"];
						
			if (_seriesDate)
				[dcmObject setAttributeValues:[NSMutableArray arrayWithObject:_seriesDate] forName:@"SeriesDate"];
			else
			
				[dcmObject setAttributeValues:[NSMutableArray arrayWithObject:_studyDate] forName:@"SeriesDate"];
			
			if (_seriesTime) 
				[dcmObject setAttributeValues:[NSMutableArray arrayWithObject:_seriesTime] forName:@"SeriesTime"];
			
			else			
				[dcmObject setAttributeValues:[NSMutableArray arrayWithObject:_studyTime] forName:@"SeriesTime"];

					
			//NSLog(@"pdf: %@", [dcmObject description]);
			
			//get Incoming Folder Path;
			NSString *destination = [NSString stringWithFormat: @"%@/INCOMING/PDF%d%d.dcm", [[BrowserController currentBrowser] documentsDirectory], _studyID, _imageNumber];
			//destination = [NSString stringWithFormat: @"%@/Desktop/%@.dcm", NSHomeDirectory(), _docTitle]; 
		
			if ([dcmObject writeToFile:destination withTransferSyntax:[DCMTransferSyntax ExplicitVRLittleEndianTransferSyntax] quality:DCMLosslessQuality atomically:YES])
				NSLog(@"Wrote PDF: %@", destination);
			//NSLog(@"Exit PDF import");

	}

	
	
	[pool release];
}

- (void)dealloc{
	[_patientName release];
	[_patientID release];
	[_docTitle release];
	[super dealloc];
}


-(BOOL) addtoCurrentStudy{
	return _addtoCurrentStudy;
}

-(void) setAddtoCurrentStudy:(BOOL)value{
	_addtoCurrentStudy = value;
	[self studyInfo];
}

-(NSString *)patientName{
	return _patientName;
}
-(NSString *)patientID{
	return _patientID;
}
-(void)setPatientName:(NSString *)name{
	[_patientName release];
	_patientName = [name retain];
}
	
-(void)setPatientID:(NSString *)pid{
	[_patientID release];
	_patientID = [pid retain];
}

- (void)studyInfo{
	if (_addtoCurrentStudy){
		NSArray *currentSelection = [[BrowserController currentBrowser] databaseSelection];
		if ([currentSelection count] > 0) {
			id selection = [currentSelection objectAtIndex:0];
			id study;
			if ([[[selection entity] name] isEqualToString:@"Study"]) 
				study = selection;				
			else
				study = [selection valueForKey:@"study"];
			
			_studyInstanceUID = [study valueForKeyPath:@"studyInstanceUID"];
			[self setPatientName:[study valueForKeyPath:@"name"]];
			[self setPatientID:[study valueForKeyPath:@"patientID"]];
			_patientDOB = [DCMCalendarDate dicomDateWithDate:[study valueForKeyPath:@"dateOfBirth"]];
			_patientSex = [study valueForKeyPath:@"patientSex"];
			
			_studyID = [[selection valueForKeyPath:@"id"] intValue];
			_studyDate  = [DCMCalendarDate dicomDateWithDate:[selection valueForKeyPath:@"date"]];
			_studyTime  = [DCMCalendarDate dicomTimeWithDate:[selection valueForKeyPath:@"date"]];
			
			id series = nil;

			NSEnumerator *enumerator = [[study valueForKey:@"series"] objectEnumerator];
			while (series = [enumerator nextObject]) {
				if ([[series valueForKey:@"name"] isEqualToString:@"PDF"]) {
					NSArray *arrayUID = [[series valueForKey:@"seriesInstanceUID"] componentsSeparatedByString:@" "];
					// the core data DB stores the seriesUID in an unusual fashion. The true UID needs to be removed out of the string
					if ([arrayUID count] >= 2)
						_seriesInstanceUID = [arrayUID objectAtIndex:1];

					_seriesDate  = [DCMCalendarDate dicomDateWithDate:[series valueForKeyPath:@"date"]];
					_seriesTime  = [DCMCalendarDate dicomTimeWithDate:[series valueForKeyPath:@"date"]];
					_imageNumber = [[series valueForKey:@"images"] count] + 1;
				}
			}
		}
		else
			_studyInstanceUID = nil;
	}

}

- (NSString *)docTitle{
	return _docTitle;
}
- (void)setDocTitle:(NSString *)docTitle{
	[_docTitle release];
	_docTitle = [docTitle retain];
}


@end
