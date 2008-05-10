//
//  VolumeGeneratorFilter.m
//  VolumeGenerator
//
//  Created by Philippe Thevenaz on Tue May 6 2008.
//

#import <stdlib.h>
#import "VolumeGeneratorFilter.h"
#import "DCMPix.h"
#import "DicomFile.h"
#import "DicomSeries.h"
#import "BrowserController.h"
#import "ViewerController.h"
#import <OsiriX/DCMObject.h>
#import <OsiriX/DCMPixelDataAttribute.h>
#import <OsiriX/DCMTransferSyntax.h>
#import <OsiriX/DCMAttributeTag.h>
#import <OsiriX/DCMCalendarDate.h>

/*==============================================================================
|	VolumeGeneratorFilter
\=============================================================================*/
@implementation VolumeGeneratorFilter

/*----------------------------------------------------------------------------*/
- (void)initPlugin
{ /* begin initPlugin */
} /* end initPlugin */

/*----------------------------------------------------------------------------*/
- (long)filterImage
	: (NSString*) menuName
{ /* begin filterImage */

	@try
	{
		/* variables */
		double
			voxelDimensionX = 0.0,
			voxelDimensionY = 0.0,
			voxelDimensionZ = 0.0;
		
		unsigned short
			*p = (unsigned short*)NULL,
			*volume = (unsigned short*)NULL;
		
		float
			orientation[] = {0.0F, 0.0F, 0.0F, 0.0F, 0.0F, 0.0F},
			position[] = {0.0F, 0.0F, 0.0F},
			xOrigin = 0.0F,
			yOrigin = 0.0F,
			zOrigin = 0.0F;
			
		int
			depth = 0L,
			evenDepth = 0L,
			evenHeight = 0L,
			evenWidth = 0L,
			height = 0L,
			width = 0L,
			x = 0L,
			y = 0L,
			z = 0L;

		/* settings */
		depth = 10L,
		height = 90L,
		width = 160L,
		voxelDimensionX = 1.0,
		voxelDimensionY = 1.0,
		voxelDimensionZ = 3.0;
		xOrigin = 25.0F,
		yOrigin = 125.0F,
		zOrigin = -75.0F;
		orientation[0] = 1.0F;
		orientation[1] = 0.0F;
		orientation[2] = 0.0F;
		orientation[3] = 0.0F;
		orientation[4] = 1.0F;
		orientation[5] = 0.0F; 
		
		/* created volume MUST have even dimensions */
		evenWidth = ((width + 1L) / 2L) * 2L;
		evenHeight = ((height + 1L) / 2L) * 2L;
		evenDepth = ((depth + 1L) / 2L) * 2L;

		volume = (unsigned short*)malloc(sizeof(unsigned short)
			* (size_t)(evenWidth * evenHeight * evenDepth));
		if (volume == (unsigned short*)NULL) {
			return -1L;
		}
		p = volume;
		for (z = 0L; (z < evenDepth); z++) {
			for (y = 0L; (y < evenHeight); y++) {
				for (x = 0L; (x < evenWidth); x++) {
					*p++ = 2.0F * (unsigned short)((x + y + z) % 2L);
				}
			}
		}
		
		NSMutableArray *files = [NSMutableArray array];
		
		/* first we create some files for the DB */
		for (z = 0L; (z < evenDepth); z++)
		{
			DCMObject *dcmDst = [DCMObject secondaryCaptureObjectWithBitDepth: 32  samplesPerPixel: 1 numberOfFrames: depth];
			[dcmDst setAttributeValues:[NSMutableArray arrayWithObject: @"123456"] forName:@"StudyInstanceUID"];
			[dcmDst setAttributeValues:[NSMutableArray arrayWithObject: @"1"] forName:@"SeriesInstanceUID"];
			[dcmDst setAttributeValues:[NSMutableArray arrayWithObject: @"series created from void"] forName:@"SeriesDescription"];
			[dcmDst setAttributeValues:[NSMutableArray arrayWithObject: @"frog 1"] forName:@"PatientsName"];
			[dcmDst setAttributeValues:[NSMutableArray arrayWithObject: @"FUID-192"] forName:@"PatientID"];
			[dcmDst setAttributeValues:[NSMutableArray arrayWithObject: @"study created from void"] forName:@"StudyDescription"];
			[dcmDst setAttributeValues:[NSMutableArray arrayWithObject: @"1"] forName:@"SeriesNumber"];
			[dcmDst setAttributeValues:[NSMutableArray arrayWithObject: @"STUDY1"] forName:@"StudyID"];
			[dcmDst setAttributeValues:[NSMutableArray arrayWithObject: @"M"] forName:@"PatientsSex"];
			[dcmDst setAttributeValues:[NSMutableArray arrayWithObject: [DCMCalendarDate dicomDate: @"20061212"]] forName:@"PatientsBirthDate"];
			[dcmDst setAttributeValues:[NSMutableArray arrayWithObject: @""] forName:@"AccessionNumber"];
			[dcmDst setAttributeValues:[NSMutableArray arrayWithObject: @""] forName:@"ReferringPhysiciansName"];
			[dcmDst setAttributeValues:[NSMutableArray arrayWithObject: @"OsiriX"] forName:@"Manufacturer"];
			[dcmDst setAttributeValues:[NSMutableArray arrayWithObject: @"OsiriX"] forName:@"ManufacturersModelName"];
			[dcmDst setAttributeValues:[NSMutableArray arrayWithObject: [DCMCalendarDate dicomDate: @"20071212"]] forName:@"StudyDate"];
			[dcmDst setAttributeValues:[NSMutableArray arrayWithObject: [DCMCalendarDate dicomTime: @"120000.000000"]] forName:@"StudyTime"];
			[dcmDst setAttributeValues:[NSMutableArray arrayWithObject: [DCMCalendarDate dicomDate: @"20071212"]] forName:@"SeriesDate"];
			[dcmDst setAttributeValues:[NSMutableArray arrayWithObject: [DCMCalendarDate dicomTime: @"120000.000000"]] forName:@"SeriesTime"];
			[dcmDst setAttributeValues:[NSMutableArray arrayWithObject: [DCMCalendarDate dicomDate: @"20071212"]] forName:@"AcquisitionDate"];
			[dcmDst setAttributeValues:[NSMutableArray arrayWithObject: [DCMCalendarDate dicomTime: @"120000.000000"]] forName:@"AcquisitionTime"];
			
			[dcmDst setAttributeValues:[NSMutableArray arrayWithObject: [NSNumber numberWithInt: z]] forName:@"InstanceNumber"];
			
			[dcmDst setAttributeValues:[NSMutableArray arrayWithObject: [NSNumber numberWithInt: evenHeight]] forName:@"Rows"];
			[dcmDst setAttributeValues:[NSMutableArray arrayWithObject: [NSNumber numberWithInt: evenWidth]] forName:@"Columns"];
			[dcmDst setAttributeValues:[NSMutableArray arrayWithObject: [NSNumber numberWithInt: 1]] forName:@"SamplesperPixel"];
			
			[dcmDst setAttributeValues:[NSMutableArray arrayWithObjects:[NSNumber numberWithFloat: voxelDimensionX], [NSNumber numberWithFloat: voxelDimensionY], nil] forName:@"PixelSpacing"];
			
			[dcmDst setAttributeValues:[NSMutableArray arrayWithObjects:[NSNumber numberWithFloat:orientation[ 0]], [NSNumber numberWithFloat:orientation[ 1]], [NSNumber numberWithFloat:orientation[ 2]], [NSNumber numberWithFloat:orientation[ 3]], [NSNumber numberWithFloat:orientation[ 4]], [NSNumber numberWithFloat:orientation[ 5]], nil] forName:@"ImageOrientationPatient"];
			
			[dcmDst setAttributeValues:[NSMutableArray arrayWithObjects:[NSNumber numberWithFloat:position[ 0]], [NSNumber numberWithFloat:position[ 1]], [NSNumber numberWithFloat:position[ 2] + voxelDimensionZ*z], nil] forName:@"ImagePositionPatient"];
			
			[dcmDst setAttributeValues:[NSMutableArray arrayWithObject:[NSNumber numberWithFloat:voxelDimensionZ]] forName:@"SliceThickness"];
			[dcmDst setAttributeValues:[NSMutableArray arrayWithObject:[NSNumber numberWithFloat:position[ 2] + voxelDimensionZ*z]] forName:@"SliceLocation"];
			
			[dcmDst setAttributeValues:[NSMutableArray arrayWithObject: @"MONOCHROME2"] forName:@"PhotometricInterpretation"];
			[dcmDst setAttributeValues:[NSMutableArray arrayWithObject: [NSNumber numberWithInt:15]] forName:@"HighBit"];
			[dcmDst setAttributeValues:[NSMutableArray arrayWithObject: [NSNumber numberWithInt:16]] forName:@"BitsAllocated"];
			[dcmDst setAttributeValues:[NSMutableArray arrayWithObject: [NSNumber numberWithInt:16]] forName:@"BitsStored"];

			[dcmDst setAttributeValues:[NSMutableArray arrayWithObject: [NSNumber numberWithFloat:0]] forName:@"RescaleIntercept"];
			[dcmDst setAttributeValues:[NSMutableArray arrayWithObject: [NSNumber numberWithFloat:1]] forName:@"RescaleSlope"];

			DCMTransferSyntax *ts = [DCMTransferSyntax ImplicitVRLittleEndianTransferSyntax];
					
			DCMAttributeTag *tag = [DCMAttributeTag tagWithName:@"PixelData"];
			DCMPixelDataAttribute *attr = [[[DCMPixelDataAttribute alloc] initWithAttributeTag:tag 
											vr: @"OW"
											length: evenHeight * evenWidth
											data: nil
											specificCharacterSet: nil
											transferSyntax: ts
											dcmObject: dcmDst
											decodeData: NO] autorelease];
			[attr addFrame: [NSMutableData dataWithBytes: volume + evenHeight * evenWidth * z length: evenHeight * evenWidth * sizeof( unsigned short)]];
			[dcmDst setAttribute:attr];
			
			NSString *dstPath = [NSString stringWithFormat: @"/tmp/%d.dcm", z];
			[[NSFileManager defaultManager] removeFileAtPath: dstPath handler: 0L];
			
			[files addObject: dstPath];
			
			[dcmDst writeToFile:dstPath withTransferSyntax:[DCMTransferSyntax ImplicitVRLittleEndianTransferSyntax] quality:0 atomically:YES];
		}
		
		/* add this series to the db : files are copied or linked to the DB, depending on the Database Preferences*/
		
		NSArray *imagesDB = [[BrowserController currentBrowser] addFilesAndFolderToDatabase: files];
		
		/* OPTIONAL: open this new series */
		[[BrowserController currentBrowser] findAndSelectFile: 0L image: [imagesDB lastObject] shouldExpand: NO];
		[[BrowserController currentBrowser] newViewerDICOM: self];
	}
	
	@catch (NSException *e)
	{
		NSLog( @"Exception in our VolumeGenerator plugin: %@", e);
	}
	return 0L;
} /* end filterImage */

@end