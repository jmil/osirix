//
//   DCMPDFImportFilter
//  
//

#import "DCMPDFImportFilter.h"
#import <OsiriX/DCM.h>

#import "browserController.h"

@implementation DCMPDFImportFilter

- (long) filterImage:(NSString*) menuName
{
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	
	self.addtoCurrentStudy = [[NSUserDefaults standardUserDefaults] boolForKey: @"PDFtoDICOMaddToCurrentStudy"];
	
	if (_addtoCurrentStudy)
		[self studyInfo];
	
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
	
	if([openPanel runModalForTypes:[NSArray arrayWithObject:@"pdf"]] == NSOKButton)
	{
		self.docTitle = [studyDesciptionID stringValue];
		
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
		while(fpath = [enumerator nextObject])
		{
			[[NSFileManager defaultManager] fileExistsAtPath:fpath isDirectory:&isDir];
			//loop through directory if true
			if (isDir)
			{
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
	
	[self setPatientName:@"No Name"];
	[self setPatientID:@""];
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
	
	
	[[NSUserDefaults standardUserDefaults] setBool: _addtoCurrentStudy forKey: @"PDFtoDICOMaddToCurrentStudy"];
	
	[pool release];
	
	return 0;
}

- (void)convertImageToDICOM:(NSString *)path
{
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	
	NSMutableData *pdf = nil;
	if ([[path pathExtension] isEqualToString:@"pdf"])
		pdf = [NSMutableData dataWithContentsOfFile:path];	
	
	//if we have an image  get the info we need from the imageRep.
	if (pdf )
	{		
		// pad data
		if ([pdf length] % 2 != 0)
			[pdf increaseLengthBy:1];
		// create DICOM OBJECT
		DCMObject *dcmObject = [DCMObject encapsulatedPDF:pdf];
		if (_studyInstanceUID)
			[dcmObject setAttributeValues:[NSArray arrayWithObject:_studyInstanceUID] forName:@"StudyInstanceUID"];
		if (_seriesInstanceUID)
			[dcmObject setAttributeValues:[NSArray arrayWithObject:_seriesInstanceUID] forName:@"SeriesInstanceUID"];
		[dcmObject setAttributeValues:[NSArray arrayWithObject:@"DICOM PDF"] forName:@"SeriesDescription"];
		if (_patientName)
			[dcmObject setAttributeValues:[NSMutableArray arrayWithObject:_patientName] forName:@"PatientsName"];
		else
			[dcmObject setAttributeValues:[NSMutableArray arrayWithObject:@""] forName:@"PatientsName"];
		if (_patientID)
			[dcmObject setAttributeValues:[NSMutableArray arrayWithObject:_patientID] forName:@"PatientID"];
		else
			[dcmObject setAttributeValues:[NSMutableArray arrayWithObject:@"0"] forName:@"PatientID"];
		
		if (_patientSex)
			[dcmObject setAttributeValues:[NSMutableArray arrayWithObject:_patientSex] forName:@"PatientsSex"];
		else
			[dcmObject setAttributeValues:[NSMutableArray arrayWithObject:@""] forName:@"PatientsSex"];
			
		if (_patientDOB)
			[dcmObject setAttributeValues:[NSMutableArray arrayWithObject:_patientDOB] forName:@"PatientsBirthDate"];
			
		if (_docTitle)
			[dcmObject setAttributeValues:[NSMutableArray arrayWithObject:_docTitle] forName:@"DocumentTitle"];
		else
			[dcmObject setAttributeValues:[NSMutableArray arrayWithObject:@"DICOM PDF"] forName:@"DocumentTitle"];
			
		[dcmObject setAttributeValues:[NSMutableArray arrayWithObject:[NSString stringWithFormat:@"%d", _imageNumber++]] forName:@"InstanceNumber"];
		if (_studyID)
			[dcmObject setAttributeValues:[NSMutableArray arrayWithObject:[NSString stringWithFormat:@"%d", _studyID]] forName:@"StudyID"];
		else
			[dcmObject setAttributeValues:[NSMutableArray arrayWithObject:[NSString stringWithFormat:@"%d", 0001]] forName:@"StudyID"];
			
		if (_studyDate)
			[dcmObject setAttributeValues:[NSMutableArray arrayWithObject:_studyDate] forName:@"StudyDate"];	
		else
			[dcmObject setAttributeValues:[NSMutableArray arrayWithObject:[DCMCalendarDate dicomDateWithDate:[NSDate date]]] forName:@"StudyDate"];
		if (_studyTime)	
			[dcmObject setAttributeValues:[NSMutableArray arrayWithObject:_studyTime] forName:@"StudyTime"];
		else
			[dcmObject setAttributeValues:[NSMutableArray arrayWithObject:[DCMCalendarDate dicomTimeWithDate:[NSDate date]]] forName:@"StudyTime"];

		if (_seriesDate)
			[dcmObject setAttributeValues:[NSMutableArray arrayWithObject:_seriesDate] forName:@"SeriesDate"];
		else
		
			[dcmObject setAttributeValues:[NSMutableArray arrayWithObject:_studyDate] forName:@"SeriesDate"];
		
		if (_seriesTime) 
			[dcmObject setAttributeValues:[NSMutableArray arrayWithObject:_seriesTime] forName:@"SeriesTime"];
		
		else			
			[dcmObject setAttributeValues:[NSMutableArray arrayWithObject:_studyTime] forName:@"SeriesTime"];
		
		//get Incoming Folder Path;
		NSString *destination = [NSString stringWithFormat: @"%@/INCOMING.noindex/PDF%d%d.dcm", [[BrowserController currentBrowser] documentsDirectory], _studyID, _imageNumber];
		
		if ([dcmObject writeToFile:destination withTransferSyntax:[DCMTransferSyntax ExplicitVRLittleEndianTransferSyntax] quality:DCMLosslessQuality atomically:YES])
			NSLog(@"Wrote PDF to %@", destination);
	}
	
	[pool release];
}

- (void)dealloc
{
	[_patientName release];
	[_patientID release];
	[_docTitle release];
	[super dealloc];
}

-(BOOL) addtoCurrentStudy
{
	return _addtoCurrentStudy;
}

-(void) setAddtoCurrentStudy:(BOOL)value
{
	_addtoCurrentStudy = value;
	[self studyInfo];
}

-(NSString *)patientName
{
	return _patientName;
}

-(NSString *)patientID
{
	return _patientID;
}

-(void)setPatientName:(NSString *)name
{
	[_patientName release];
	_patientName = [name retain];
}
	
-(void)setPatientID:(NSString *)pid
{
	[_patientID release];
	_patientID = [pid retain];
}

- (void)studyInfo
{
	if (_addtoCurrentStudy)
	{
		NSArray *currentSelection = [[BrowserController currentBrowser] databaseSelection];
		if ([currentSelection count] > 0)
		{
			id selection = [currentSelection objectAtIndex:0];
			id study;
			if ([[[selection entity] name] isEqualToString:@"Study"]) 
				study = selection;				
			else
				study = [selection valueForKey:@"study"];
			
			_studyInstanceUID = [study valueForKeyPath:@"studyInstanceUID"];
			NSString *name = [study valueForKeyPath:@"name"];
			
			if (!name)
				name = @"No Name";
			[self setPatientName:name];
			NSString *pid = [study valueForKeyPath:@"patientID"];
			
			if (!pid)
				pid = @"0";
			[self setPatientID:pid];
			_patientDOB = [DCMCalendarDate dicomDateWithDate:[study valueForKeyPath:@"dateOfBirth"]];
			_patientSex = [study valueForKeyPath:@"patientSex"];
			
			_studyID = [[selection valueForKeyPath:@"id"] intValue];
			_studyDate  = [DCMCalendarDate dicomDateWithDate:[selection valueForKeyPath:@"date"]];
			_studyTime  = [DCMCalendarDate dicomTimeWithDate:[selection valueForKeyPath:@"date"]];
			
			id series = nil;

			NSEnumerator *enumerator = [[study valueForKey:@"series"] objectEnumerator];
			while (series = [enumerator nextObject]) {
				if ([[series valueForKey:@"name"] isEqualToString:@"PDF"])
				{
					_seriesInstanceUID = [series valueForKey:@"seriesDICOMUID"];
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

- (NSString *)docTitle
{
	return _docTitle;
}

- (void)setDocTitle:(NSString *)docTitle
{
	[_docTitle release];
	_docTitle = [docTitle retain];
}
@end
