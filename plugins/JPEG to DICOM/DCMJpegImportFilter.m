//
//   DCMJpegImportFilter
//  
//

//  Copyright (c) 2005 Macrad, LL. All rights reserved.
//

#import "DCMJpegImportFilter.h"
#import <OsiriX/DCM.h>

#import "browserController.h"

@implementation DCMJpegImportFilter

@synthesize addtoCurrentStudy, patientName, patientID, studyDescription, datePicker;

-(void) setAddtoCurrentStudy:(BOOL) v
{
	addtoCurrentStudy = v;
	[self studyInfo];
}

- (long) filterImage:(NSString*) menuName
{
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	
	self.addtoCurrentStudy = [[NSUserDefaults standardUserDefaults] boolForKey: @"JPEGtoDICOMaddToCurrentStudy"];
	
	if( addtoCurrentStudy)
		[self studyInfo];
		
	NSArray *topLevelObjects;
	NSBundle *thisBundle = [NSBundle bundleForClass:[self class]];
	NSNib *nib = [[[NSNib alloc] initWithNibNamed:@"ConversionInfo" bundle:thisBundle] autorelease];
	[nib instantiateNibWithOwner:self topLevelObjects:&topLevelObjects];
	self.datePicker = [NSDate date];
	NSOpenPanel *openPanel = [NSOpenPanel openPanel];
	[openPanel setAccessoryView:accessoryView];
	[openPanel setCanChooseDirectories:YES];
	[openPanel setAllowsMultipleSelection:YES];
	[openPanel setTitle:NSLocalizedString(@"Import", nil)];
	[openPanel setMessage:NSLocalizedString(@"Select image or folder of images to convert to DICOM", nil)];
	if([openPanel runModalForTypes:[NSImage imageFileTypes]] == NSOKButton)
	{
		studyDate = [DCMCalendarDate dicomDateWithDate: self.datePicker];
		studyTime = [DCMCalendarDate dicomTimeWithDate: self.datePicker];
		DCMObject *dcmObject = [DCMObject dcmObject];
		[dcmObject newStudyInstanceUID];
		[dcmObject newSeriesInstanceUID];
		
		if( addtoCurrentStudy)
			[self studyInfo];
		
		if (!studyInstanceUID)
			studyInstanceUID = [[dcmObject attributeValueWithName:@"StudyInstanceUID"] copy];
		
		if (!seriesInstanceUID)
			seriesInstanceUID = [[dcmObject attributeValueWithName:@"SeriesInstanceUID"] copy];
		
		NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
		studyID = [defaults integerForKey:@"JTDStudyID"];
		if (studyID = 0)
			studyID = 10001;
		[defaults setInteger:studyID++ forKey:@"JTDStudyID"];
		imageNumber = 0;
		NSEnumerator *enumerator = [[openPanel filenames] objectEnumerator];
		NSString *fpath;
		BOOL isDir;
		while(fpath = [enumerator nextObject])
		{
			[[NSFileManager defaultManager] fileExistsAtPath:fpath isDirectory:&isDir];
			
			if (isDir)
			{
				NSDirectoryEnumerator *dirEnumerator = [[NSFileManager defaultManager] enumeratorAtPath:fpath];
				NSString *path;
				while( path = [dirEnumerator nextObject])
					if( [[NSImage imageFileTypes] containsObject:[path pathExtension]] 
					|| [[NSImage imageFileTypes] containsObject:NSFileTypeForHFSTypeCode([[[[NSFileManager defaultManager] fileSystemAttributesAtPath:path] objectForKey:NSFileHFSTypeCode] longValue])])
						[self convertImageToDICOM:[fpath stringByAppendingPathComponent:path]];
			}
			else
				[self convertImageToDICOM:fpath];
		}
	}
	
	[[NSUserDefaults standardUserDefaults] setBool: addtoCurrentStudy forKey: @"JPEGtoDICOMaddToCurrentStudy"];
	
	[pool release];
	
	return -1;
}

- (void)convertImageToDICOM:(NSString *)path
{
	//create image
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	NSImage *image = [[[NSImage alloc] initWithContentsOfFile:path] autorelease];
	
	//if we have an image  get the info we need from the imageRep.
	if (image)
	{
		NSImageRep *rep = [image bestRepresentationForDevice:nil];
		//we only want bitmaps.  May use PDFs later
		if ([rep isMemberOfClass:[NSBitmapImageRep class]])
		{
			int rows = [rep pixelsHigh];
			int columns = [rep pixelsWide];
			int spp = [(NSBitmapImageRep*)rep samplesPerPixel];
			//get rid of alpha channel in present

			int numberBytes = rows * columns * spp;
			int rowLength = columns * spp;
			int bytesPerRow = [(NSBitmapImageRep*)rep bytesPerRow];
			int bpp = [(NSBitmapImageRep*)rep bitsPerPixel];
			BOOL isPlanar = [(NSBitmapImageRep*)rep isPlanar];
			if (isPlanar)
			{
				//if planar and has alpha discard the last plane
				if ([rep hasAlpha])
				{
					spp--;
					numberBytes = rows * columns * spp;
				}
				rowLength = columns;
			}
			//isPlanar = NO;
			NSLog(@"rep: %@", [rep description]);
			//NSLog(@"rows %d  columns %d, spp: %d, planar; %d bpr: %d", rows, columns, spp, isPlanar, bytesPerRow);
			NSString *photometricInterpretation = @"MONOCHROME2";
			if (spp > 1)
				photometricInterpretation = @"RGB";
				
			// create DICOM OBJECT
			DCMObject *dcmObject = [DCMObject secondaryCaptureObjectWithBitDepth:8  samplesPerPixel:spp numberOfFrames:1];
			
			if( studyInstanceUID)
				[dcmObject setAttributeValues:[NSArray arrayWithObject:studyInstanceUID] forName:@"StudyInstanceUID"];
			
			if( seriesInstanceUID)
				[dcmObject setAttributeValues:[NSArray arrayWithObject:seriesInstanceUID] forName:@"SeriesInstanceUID"];
			
			[dcmObject setAttributeValues:[NSArray arrayWithObject:[NSNumber numberWithBool:isPlanar]] forName:@"PlanarConfiguration"];
			
			if( patientName)
				[dcmObject setAttributeValues:[NSMutableArray arrayWithObject:patientName] forName:@"PatientsName"];
			
			if( patientID)
				[dcmObject setAttributeValues:[NSMutableArray arrayWithObject:patientID] forName:@"PatientID"];
			
			if( studyDescription)
				[dcmObject setAttributeValues:[NSMutableArray arrayWithObject:studyDescription] forName:@"StudyDescription"];
				
			[dcmObject setAttributeValues: [NSMutableArray arrayWithObject:[path lastPathComponent]] forName:@"SeriesDescription"];
			
			[dcmObject setAttributeValues:[NSMutableArray arrayWithObject:[NSString stringWithFormat:@"%d", imageNumber++]] forName:@"InstanceNumber"];
			
			[dcmObject setAttributeValues:[NSMutableArray arrayWithObject:[NSString stringWithFormat:@"%d", studyID]] forName:@"StudyID"];
					
			[dcmObject setAttributeValues:[NSMutableArray arrayWithObject:studyDate] forName:@"StudyDate"];
			[dcmObject setAttributeValues:[NSMutableArray arrayWithObject:studyTime] forName:@"StudyTime"];
			[dcmObject setAttributeValues:[NSMutableArray arrayWithObject:studyDate] forName:@"SeriesDate"];
			[dcmObject setAttributeValues:[NSMutableArray arrayWithObject:studyTime] forName:@"SeriesTime"];
					
			[dcmObject setAttributeValues:[NSMutableArray arrayWithObject:[NSNumber numberWithInt:rows]] forName:@"Rows"];
			[dcmObject setAttributeValues:[NSMutableArray arrayWithObject:[NSNumber numberWithInt:columns]] forName:@"Columns"];
			[dcmObject setAttributeValues:[NSMutableArray arrayWithObject:[NSNumber numberWithInt:spp]] forName:@"SamplesperPixel"];

			[dcmObject setAttributeValues:[NSMutableArray arrayWithObject:photometricInterpretation] forName:@"PhotometricInterpretation"];

					
			[dcmObject setAttributeValues:[NSMutableArray arrayWithObject:[NSNumber numberWithBool:0]] forName:@"PixelRepresentation"];					
			[dcmObject setAttributeValues:[NSMutableArray arrayWithObject:[NSNumber numberWithBool:7]] forName:@"HighBit"];
			[dcmObject setAttributeValues:[NSMutableArray arrayWithObject:[NSNumber numberWithInt:8]] forName:@"BitsAllocated"];
			[dcmObject setAttributeValues:[NSMutableArray arrayWithObject:[NSNumber numberWithInt:8]] forName:@"BitsStored"];
			
			NSString *vr = 	@"OB";
			DCMTransferSyntax *ts = [DCMTransferSyntax ExplicitVRLittleEndianTransferSyntax];
			DCMAttributeTag *tag = [DCMAttributeTag tagWithName:@"PixelData"];
			DCMPixelDataAttribute *attr = [[[DCMPixelDataAttribute alloc] initWithAttributeTag:tag 
													vr:vr 
													length:numberBytes
													data:nil 
													specificCharacterSet:nil
													transferSyntax:ts 
													dcmObject:dcmObject
													decodeData:NO] autorelease];
			NSData *data = [NSData dataWithBytes:[(NSBitmapImageRep *)rep bitmapData] length:bytesPerRow * rows];
			NSMutableData *subdata = [NSMutableData data];
			if (bpp == spp * 8 || (!isPlanar  && [rep hasAlpha]))
			{
				int i = 0;
				int offset = 0;
				
				if ([rep hasAlpha])
					offset = 1;
					
				int rowCount = rows + offset;
				
				if (isPlanar)
					rowCount = rows * spp;
				for (i = offset ;  i < rowCount; i++)
				{
					NSRange range = NSMakeRange(bytesPerRow * i,  rowLength);
					NSData *dataRow = [data subdataWithRange:range];
					[subdata appendData:dataRow];
				}
			}
			else {
				/*
					bits per pixel does not match spp * 8 bits. There is extra space in every pixel or we have a alpha channel to remove
					We will need to loop throug each row and remove the excess bytes.  Making sure there is no paddin at the end of the row
				*/
				int i = 0;
				int j = 0;
				if ([rep hasAlpha])
				{
					spp--;
					[dcmObject setAttributeValues:[NSMutableArray arrayWithObject:[NSNumber numberWithInt:spp]] forName:@"SamplesperPixel"];
				}
				for ( i = 0; i < rows; i++)
				{
					for (j = 0; j < columns; j++)
					{
						NSRange range = NSMakeRange((bytesPerRow * i) + (j * (bpp / 8)), spp);
						
						if (range.location + range.length <= [data length])
						{
							NSData *pixel = [data subdataWithRange:range];
							[subdata appendData:pixel];
						}
					}
				}

				
			}
			
			[attr addFrame:subdata];
			[dcmObject setAttribute:attr];
			
			NSString *destination = [NSString stringWithFormat: @"%@/INCOMING.noindex/JTD%d%d.dcm", [[BrowserController currentBrowser] documentsDirectory], studyID, imageNumber];
			[dcmObject writeToFile:destination withTransferSyntax:ts quality:DCMLosslessQuality atomically:YES];

		}
	}
	[pool release];
}

- (void)studyInfo
{
	if( addtoCurrentStudy)
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
			
			[studyInstanceUID release];
			studyInstanceUID = [[study valueForKeyPath:@"studyInstanceUID"] copy];
			NSString *name = [study valueForKeyPath:@"name"];
			
			if (!name)
				name = @"No Name";
				
			self.patientName = name;
			NSString *pid = [study valueForKeyPath:@"patientID"];
			
			if (!pid)
				pid = @"0";
			self.patientID = pid;
			patientDOB = [DCMCalendarDate dicomDateWithDate:[study valueForKeyPath:@"dateOfBirth"]];
			patientSex = [study valueForKeyPath:@"patientSex"];
			
			studyID = [[selection valueForKeyPath:@"id"] intValue];
			studyDate  = [DCMCalendarDate dicomDateWithDate:[selection valueForKeyPath:@"date"]];
			studyTime  = [DCMCalendarDate dicomTimeWithDate:[selection valueForKeyPath:@"date"]];
		}
		else
			studyInstanceUID = nil;
	}
}

- (void)dealloc
{
	[studyInstanceUID release];
	[seriesInstanceUID release];
	[patientName release];
	[patientID release];
	[studyDescription release];
	[datePicker release];
	
	[super dealloc];
}

@end
