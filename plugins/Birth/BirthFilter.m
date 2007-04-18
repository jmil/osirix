//
//  BirthFilter.m
//  Birth
//
//  Created by Philippe Thevenaz on Fri Apr 13 2007.
//  Copyright (c) 2007 __MyCompanyName__. All rights reserved.
//

#import "BirthFilter.h"
#import "DCMPix.h"
#import "ViewerController.h"
#import "DicomFile.h"

/*==============================================================================
|	BirthFilter
\=============================================================================*/
@implementation BirthFilter

/*----------------------------------------------------------------------------*/
- (void) initPlugin
{ /* begin initPlugin */
} /* end initPlugin */

/*----------------------------------------------------------------------------*/
- (long) filterImage
	: (NSString*) menuName
{ /* begin filterImage */

/*..............................................................................
	variables
..............................................................................*/
	DCMPix*
		currentPixels;
	NSMutableArray
		*pixelsList = [NSMutableArray array];
	float
		xOrigin = 0.0F,
		xSpace = 1.0F,
		yOrigin = 0.0F,
		ySpace = 1.0F,
		zOrigin = 0.0F;
	float*
		volume = (float*)NULL;
	long
		depth = 30L,
		height = 20L,
		width = 10L,
		x = 0L,
		y = 0L,
		z = 0L;
	short
		pixelSize = (short)32;

/*..............................................................................
	statements
..............................................................................*/
	volume = (float*)malloc(sizeof(float) * (size_t)(width * height * depth));
	if (volume == (float*)NULL) {
		return -1;
	}
	
	float *copyvolume = volume;
	
	for (z = 0L; (z < depth); z++) {
		for (y = 0L; (y < height); y++) {
			for (x = 0L; (x < width); x++) {
				*copyvolume++ = (float)(rand() - RAND_MAX / 2) / 1000.0F;
			}
		}
	}
	
	for (z = 0L; (z < depth); z++)
	{
		currentPixels = [[DCMPix alloc] initwithdata
			: volume + z * width * height
			: pixelSize
			: width
			: height
			: xSpace
			: ySpace
			: xOrigin
			: yOrigin
			: zOrigin + z // increase the slice position, to allow 3D reconstruction - Axial plane
			: YES
		];
		
		// Orientation to allow 3D reconstructions - X & Y vectors of the plane - Axial plane
		
		float o[ 6];
		
		o[ 0] = 1;		o[ 1] = 0;		o[ 2] = 0; 
		o[ 3] = 0;		o[ 4] = 1;		o[ 5] = 0; 
		[currentPixels setOrientation: o];
		
		[pixelsList addObject: currentPixels];
		
		[currentPixels release];
	}
	
	NSData	*newData = [NSData dataWithBytesNoCopy:volume length: sizeof(float) * (width * height * depth) freeWhenDone:YES];
	
	[ViewerController newWindow
		: pixelsList
		: 0L
		: newData
	];

	return 0;
} /* end filterImage */

@end