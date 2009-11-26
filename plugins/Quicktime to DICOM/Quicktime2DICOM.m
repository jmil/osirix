//
//   Quicktime2DICOM
//  
//

#import "Quicktime2DICOM.h"
#import <OsiriX/DCM.h>
#import "QTKit/QTMovie.h"
#import "OsiriX Headers/browserController.h"
#import "OsiriX Headers/WaitRendering.h"

@implementation Quicktime2DICOM

@synthesize addtoCurrentStudy, patientName, patientID, studyDescription, datePicker;

-(void) setAddtoCurrentStudy:(BOOL) v
{
	addtoCurrentStudy = v;
	[self studyInfo];
}

- (long) filterImage:(NSString*) menuName
{
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	
	self.addtoCurrentStudy = YES;
	
	if( addtoCurrentStudy)
		[self studyInfo];
	
	self.datePicker = [NSDate date];
	
	NSOpenPanel *openPanel = [NSOpenPanel openPanel];
	[openPanel setCanChooseDirectories: NO];
	[openPanel setAllowsMultipleSelection: YES];
	[openPanel setTitle:NSLocalizedString( @"Import", nil)];
	[openPanel setMessage:NSLocalizedString( @"Select a movie to convert to DICOM", nil)];
	if([openPanel runModalForTypes: [QTMovie movieFileTypes: 0]] == NSOKButton)
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
		
		imageNumber = 0;
		NSEnumerator *enumerator = [[openPanel filenames] objectEnumerator];
		NSString *fpath;
		BOOL isDir;
		while(fpath = [enumerator nextObject])
		{
			[[NSFileManager defaultManager] fileExistsAtPath:fpath isDirectory:&isDir];
			
			[self convertMovieToDICOM: fpath];
		}
	}
	
	[pool release];
	
	return -1;
}

- (float*) getDataFromNSImage:(NSImage*) otherImage w: (int*) width h: (int*) height rgb: (BOOL*) isRGB
{
	int x, y;
	
	NSBitmapImageRep *rep = [NSBitmapImageRep imageRepWithData: [otherImage TIFFRepresentation]];
	
	NSImage *r = [[[NSImage alloc] initWithSize: NSMakeSize( [rep pixelsWide], [rep pixelsHigh])] autorelease];
	
	[r lockFocus];
	[[NSColor whiteColor] set];
	NSRectFill( NSMakeRect( 0, 0, [r size].width, [r size].height));
	[otherImage drawInRect: NSMakeRect(0,0,[r size].width, [r size].height) fromRect:NSMakeRect(0,0,[otherImage size].width, [otherImage size].height) operation: NSCompositeSourceOver fraction: 1.0];
	[r unlockFocus];
	
	NSBitmapImageRep *TIFFRep = [[NSBitmapImageRep alloc] initWithData: [r TIFFRepresentation]];
	
	*height = [TIFFRep pixelsHigh];
	*width = [TIFFRep pixelsWide];
	
	unsigned char *srcImage = [TIFFRep bitmapData];
	unsigned char *rgbImage = nil, *srcPtr = nil, *tmpPtr = nil;
	
	int totSize = *height * *width * 3;

	rgbImage = malloc( totSize);
	
	switch( [TIFFRep bitsPerPixel])
	{
		case 8:
			tmpPtr = rgbImage;
			for( y = 0 ; y < *height; y++)
			{
				srcPtr = srcImage + y*[TIFFRep bytesPerRow];
				
				x = *width;
				while( x-->0)
				{
					*tmpPtr++ = *srcPtr;
					*tmpPtr++ = *srcPtr;
					*tmpPtr++ = *srcPtr;
					srcPtr++;
				}
			}
		break;
			
		case 32:
			tmpPtr = rgbImage;
			for( y = 0 ; y < *height; y++)
			{
				srcPtr = srcImage + y*[TIFFRep bytesPerRow];
				
				x = *width;
				while( x-->0)
				{
					*tmpPtr++ = *srcPtr++;
					*tmpPtr++ = *srcPtr++;
					*tmpPtr++ = *srcPtr++;
					srcPtr++;
				}
			}
		break;
			
		case 24:
			tmpPtr = rgbImage;
			for( y = 0 ; y < *height; y++)
			{
				srcPtr = srcImage + y*[TIFFRep bytesPerRow];
				
				x = *width;
				while( x-->0)
				{
					*((short*)tmpPtr) = *((short*)srcPtr);
					tmpPtr+=2;
					srcPtr+=2;
					
					*tmpPtr++ = *srcPtr++;
				}
			}
		break;
			
		case 48:
			tmpPtr = rgbImage;
			for( y = 0 ; y < *height; y++)
			{
				srcPtr = srcImage + y*[TIFFRep bytesPerRow];
				
				x = *width;
				while( x-->0)
				{
					*tmpPtr++ = *srcPtr;	srcPtr += 2;
					*tmpPtr++ = *srcPtr;	srcPtr += 2;
					*tmpPtr++ = *srcPtr;	srcPtr += 2;
				}
			}
		break;
			
		default:
			NSLog(@"Error - Unknow bitsPerPixel ...");
		break;
	}
	
	float *fImage = (float*) rgbImage;
	*isRGB = YES;
	
	[TIFFRep release];
	
	return fImage;
}

- (void)convertMovieToDICOM:(NSString *)path
{
	//create image
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	
	[QTMovie enterQTKitOnThreadDisablingThreadSafetyProtection];
	
	NSError	*error = nil;
	
	QTMovie *movie = [[[QTMovie alloc] initWithFile: path error: &error] autorelease];
	WaitRendering *wait = [[[WaitRendering alloc] init: @"OsiriX is pure energy..."] autorelease];
	[wait showWindow:self];
	
	if( movie)
	{
		[movie attachToCurrentThread];
		
		int curFrame = 0;
		[movie gotoBeginning];
		
		QTTime previousTime = [movie currentTime];
		
		curFrame = 0;
		
		BOOL stop = NO;
		do
		{
			{
				int width, height;
				BOOL isRGB;
				float *data = [self getDataFromNSImage: [movie currentFrameImage] w: &width h: &height rgb: &isRGB];
				int numberBytes = width * height;
				int spp = 1;
				
				if( isRGB)
					spp = 3;
				
				numberBytes *= spp;
				
				// create DICOM OBJECT
				DCMObject *dcmObject = [DCMObject secondaryCaptureObjectWithBitDepth:8 samplesPerPixel:spp numberOfFrames:1];
				
				if( studyInstanceUID)
					[dcmObject setAttributeValues:[NSArray arrayWithObject:studyInstanceUID] forName:@"StudyInstanceUID"];
				
				if( seriesInstanceUID)
					[dcmObject setAttributeValues:[NSArray arrayWithObject:seriesInstanceUID] forName:@"SeriesInstanceUID"];
				
				if( patientName)
					[dcmObject setAttributeValues:[NSMutableArray arrayWithObject:patientName] forName:@"PatientsName"];
				
				if( patientDOB)
					[dcmObject setAttributeValues:[NSMutableArray arrayWithObject:patientDOB] forName:@"PatientsBirthDate"];
				
				if( patientSex)
					[dcmObject setAttributeValues:[NSMutableArray arrayWithObject:patientSex] forName:@"PatientsSex"];
				
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
				[dcmObject setAttributeValues:[NSMutableArray arrayWithObject:@"9999"] forName:@"SeriesNumber"];
								
				[dcmObject setAttributeValues:[NSMutableArray arrayWithObject:[NSNumber numberWithInt: height]] forName:@"Rows"];
				[dcmObject setAttributeValues:[NSMutableArray arrayWithObject:[NSNumber numberWithInt: width]] forName:@"Columns"];
				[dcmObject setAttributeValues:[NSMutableArray arrayWithObject:[NSNumber numberWithInt: spp]] forName:@"SamplesperPixel"];
				
				if( isRGB)
					[dcmObject setAttributeValues:[NSMutableArray arrayWithObject: @"RGB"] forName:@"PhotometricInterpretation"];
				else
					[dcmObject setAttributeValues:[NSMutableArray arrayWithObject: @"MONOCHROME2"] forName:@"PhotometricInterpretation"];
				
				[dcmObject setAttributeValues:[NSMutableArray arrayWithObject:[NSNumber numberWithBool:0]] forName:@"PixelRepresentation"];					
				[dcmObject setAttributeValues:[NSMutableArray arrayWithObject:[NSNumber numberWithBool:7]] forName:@"HighBit"];
				[dcmObject setAttributeValues:[NSMutableArray arrayWithObject:[NSNumber numberWithInt:8]] forName:@"BitsAllocated"];
				[dcmObject setAttributeValues:[NSMutableArray arrayWithObject:[NSNumber numberWithInt:8]] forName:@"BitsStored"];
				
				NSString *vr = 	@"OB";
				DCMTransferSyntax *ts = [DCMTransferSyntax ExplicitVRLittleEndianTransferSyntax];
				DCMAttributeTag *tag = [DCMAttributeTag tagWithName:@"PixelData"];
				DCMPixelDataAttribute *attr = [[[DCMPixelDataAttribute alloc] initWithAttributeTag:tag 
														vr:vr 
														length: numberBytes
														data:nil 
														specificCharacterSet:nil
														transferSyntax: ts 
														dcmObject:dcmObject
														decodeData:NO] autorelease];
														
				[attr addFrame: [NSMutableData dataWithBytes: data length: numberBytes]];
				[dcmObject setAttribute:attr];
				
				NSString *destination = [NSString stringWithFormat: @"%@/INCOMING.noindex/JTD%d%d.dcm", [[BrowserController currentBrowser] documentsDirectory], studyID, imageNumber];
				[dcmObject writeToFile:destination withTransferSyntax:ts quality:DCMLosslessQuality atomically:YES];
			}
			
			previousTime = [movie currentTime];
			curFrame++;
			[movie stepForward];
			
			if( QTTimeCompare( previousTime, [movie currentTime]) != NSOrderedAscending) stop = YES;
		}
		while( stop == NO);
	}
	
	[wait close];
	
	[QTMovie exitQTKitOnThread];
	
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
			patientDOB = [DCMCalendarDate dicomDateWithDate: [study valueForKeyPath:@"dateOfBirth"]];
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
