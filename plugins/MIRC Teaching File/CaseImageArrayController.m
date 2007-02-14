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
NSString *pasteBoardOsiriX = @"OsiriX pasteboard";


@implementation CaseImageArrayController

- (void)awakeFromNib{
	[tableView registerForDraggedTypes:[NSArray arrayWithObjects: pasteBoardOsiriX, nil]];
}

- (NSDragOperation)tableView:(NSTableView *)aTableView validateDrop:(id <NSDraggingInfo>)info proposedRow:(int)row proposedDropOperation:(NSTableViewDropOperation)operation
{
    // Add code here to validate the drop
    NSLog(@"validate Drop");
	
    return NSDragOperationEvery;    
}


- (BOOL)tableView:(NSTableView *)aTableView acceptDrop:(id <NSDraggingInfo>)info row:(int)row dropOperation:(NSTableViewDropOperation)operation{
	id newImage = [self newObject];
	DCMView	*vi = (DCMView *)[info draggingSource];
	// JPEG Image
	NSLog(@"Add originalSize");
	NSImage *originalSizeImage = [vi nsimage:YES];
	NSBitmapImageRep *rep = [originalSizeImage bestRepresentationForDevice:nil];
	NSData *jpegData = [rep representationUsingType:NSJPEGFileType properties:[NSDictionary dictionaryWithObject:[NSNumber numberWithFloat:0.9] forKey:NSImageCompressionFactor]];
	
	[newImage setValue:jpegData forKey: @"originalDimension"];
	[newImage setValue:@"jpg" forKey:@"originalDimensionExtension"];
	NSLog(@"Add Thumbnail");
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
	NSLog(@"original Format");
	// Original Format
	NSString *originalImagePath = [[vi imageObj] valueForKey:@"completePath"];	
	NSData *originalFormatData = [NSData dataWithContentsOfFile:originalImagePath];
	[newImage setValue:originalFormatData forKey: @"originalFormat"];
	[newImage setValue:[originalImagePath pathExtension] forKey:@"originalFormatExtension"];
	NSLog(@"Annotation");
	//Annotation
	NSImage *annotationImage = [vi nsimage:NO];
	rep = [annotationImage bestRepresentationForDevice:nil];
	jpegData = [rep representationUsingType:NSJPEGFileType properties:[NSDictionary dictionaryWithObject:[NSNumber numberWithFloat:0.9] forKey:NSImageCompressionFactor]];
	[newImage setValue:jpegData forKey: @"annotation"];
	if (row < 0)
		row = 0;
	[self insertObject:newImage atArrangedObjectIndex:row];
	
	return YES;
}

@end
