//
//  CaseImageArrayController.m
//  TeachingFile
//
//  Created by Lance Pysher on 2/14/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import "CaseImageArrayController.h"
#import "DCMView.h"
#import "DCMPix.h"
#import <QuartzCore/QuartzCore.h>
#import "ViewerController.h"
#import "WindowLayoutManager.h"
#import <OsiriX/DCM.h>
NSString *pasteBoardOsiriX = @"OsiriX pasteboard";


@implementation CaseImageArrayController

- (void)awakeFromNib{
	[tableView registerForDraggedTypes:[NSArray arrayWithObjects: pasteBoardOsiriX, nil]];
}

- (NSDragOperation)tableView:(NSTableView *)aTableView validateDrop:(id <NSDraggingInfo>)info proposedRow:(int)row proposedDropOperation:(NSTableViewDropOperation)operation
{
    // Add code here to validate the drop
  
	
    return NSDragOperationEvery;    
}


- (BOOL)tableView:(NSTableView *)aTableView acceptDrop:(id <NSDraggingInfo>)info row:(int)row dropOperation:(NSTableViewDropOperation)operation{
	[self insertImageAtRow:row FromViewer:[info draggingSource]];	
	return YES;
}

- (void)insertImageAtRow:(int)row FromViewer:(DCMView *)vi{
	id newImage = [self newObject];

	// JPEG Image

	NSImage *originalSizeImage = [vi nsimage:YES];
	NSBitmapImageRep *rep = (NSBitmapImageRep *)[originalSizeImage bestRepresentationForDevice:nil];
	NSData *jpegData = [rep representationUsingType:NSJPEGFileType properties:[NSDictionary dictionaryWithObject:[NSNumber numberWithFloat:0.9] forKey:NSImageCompressionFactor]];
	
	[newImage setValue:jpegData forKey: @"originalDimension"];
	[newImage setValue:@"jpg" forKey:@"originalDimensionExtension"];

	//NSImage *thumbnail;
	NSData *tiff = [originalSizeImage TIFFRepresentation];
	// Convert to a CIImage
	CIImage  *ciImage    = [[CIImage alloc] initWithData:tiff];
	float width = [originalSizeImage size].width;
	float scale = 256.0/width;
	
	//create filter
	CIFilter *myFilter = [CIFilter filterWithName:@"CILanczosScaleTransform"];
	[myFilter setDefaults];
	[myFilter setValue: ciImage forKey: @"inputImage"];  
	[myFilter setValue: [NSNumber numberWithFloat: scale]  
					forKey: @"inputScale"];
					
	//get scaled image
	CIImage *result = [myFilter valueForKey:@"outputImage"];
	NSCIImageRep *ciRep = [NSCIImageRep imageRepWithCIImage:result];
	NSImage *image = [[[NSImage alloc] init] autorelease];
	[image addRepresentation:ciRep];
	//convert to Tiff to get Bipmap and convert to jpeg
	NSImage *tn = [[[NSImage alloc] initWithData:[image TIFFRepresentation]] autorelease];
	rep = (NSBitmapImageRep *)[tn bestRepresentationForDevice:nil];
	jpegData = [rep representationUsingType:NSJPEGFileType properties:[NSDictionary dictionaryWithObject:[NSNumber numberWithFloat:0.9] forKey:NSImageCompressionFactor]];
	[newImage setValue:jpegData forKey: @"thumbnail"];

	// Original Format
	// need to anonymize
	NSString *originalImagePath = [[vi imageObj] valueForKey:@"completePath"];	
	[newImage setValue:[originalImagePath pathExtension] forKey:@"originalFormatExtension"];
	if ([[originalImagePath pathExtension] isEqualToString:@"dcm"]) {
			
			NSMutableArray *tags = [NSMutableArray array];
			[tags addObject:[NSArray arrayWithObject:[DCMAttributeTag tagWithName:@"PatientsName"]]];
			[tags addObject:[NSArray arrayWithObject:[DCMAttributeTag tagWithName:@"PatientsBirthDate"]]];
			[tags addObject:[NSArray arrayWithObject:[DCMAttributeTag tagWithName:@"InstitutionName"]]];
			[tags addObject:[NSArray arrayWithObject:[DCMAttributeTag tagWithName:@"StudyDate"]]];
			[tags addObject:[NSArray arrayWithObject:[DCMAttributeTag tagWithName:@"SeriesDate"]]];
			[tags addObject:[NSArray arrayWithObject:[DCMAttributeTag tagWithName:@"InstanceDate"]]];
			[tags addObject:[NSArray arrayWithObject:[DCMAttributeTag tagWithName:@"ContentDate"]]];
			[tags addObject:[NSArray arrayWithObject:[DCMAttributeTag tagWithName:@"AcquisitionDate"]]];
			DCMObject *dcmObject = [DCMObject objectWithContentsOfFile:originalImagePath decodingPixelData:NO];
			NSEnumerator *enumerator = [tags objectEnumerator];
			DCMAttributeTag *tag;
			while (tag = [enumerator nextObject])
				[dcmObject anonyimizeAttributeForTag:(DCMAttributeTag *)tag replacingWith:nil];
			DCMDataContainer *container = [DCMDataContainer dataContainer];
			[dcmObject writeToDataContainer:(DCMDataContainer *)container 
			withTransferSyntax:[DCMTransferSyntax ExplicitVRLittleEndianTransferSyntax]
			quality:1.0 
			asDICOM3:YES
			strippingGroupLengthLength:YES];
			//[DCMObject anonymizeContentsOfFile:path  tags:(NSArray *)tags  writingToFile:newJpegPath];
			[newImage setValue:[container dicomData]  forKey: @"originalFormat"];	
			
		}
		else {	
			NSData *originalFormatData = [NSData dataWithContentsOfFile:originalImagePath];
			[newImage setValue:originalFormatData forKey: @"originalFormat"];
		}

	//Annotation
	NSImage *annotationImage = [vi nsimage:NO];
	rep = [annotationImage bestRepresentationForDevice:nil];
	jpegData = [rep representationUsingType:NSJPEGFileType properties:[NSDictionary dictionaryWithObject:[NSNumber numberWithFloat:0.9] forKey:NSImageCompressionFactor]];
	[newImage setValue:jpegData forKey: @"annotation"];
	if (row < 0)
		row = 0;
	[self insertObject:newImage atArrangedObjectIndex:row];
}

- (IBAction)addOrDelete:(id)sender{
	if ([sender selectedSegment] == 0) 
		[self selectCurrentImage:sender];
	else
		[self remove:sender];

}

- (IBAction)selectCurrentImage:(id)sender{
	// need to get current DCMView;
	NSWindowController  *viewer = [[WindowLayoutManager sharedWindowLayoutManager] currentViewer];
	[self insertImageAtRow:[[self arrangedObjects] count] FromViewer:[(ViewerController *)viewer imageView]];
}





@end
