//
//  ROIPixelData.h
//  OsiriX
//
//  Created by Joël Spaltenstein on 1/25/11.
//  Copyright 2011 OsiriX Team. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "OSIROIMask.h"
// this is the representation of the data within the generic ROI


@class OSIFloatVolumeData;
@class OSIStudy;

@interface OSIROIFloatPixelData : NSObject {
	OSIROIMask *_ROIMask;
	OSIFloatVolumeData *_volumeData;
}

- (id)initWithROIMask:(OSIROIMask *)roiMask floatVolumeData:(OSIFloatVolumeData *)volumeData;

@property (nonatomic, readonly, retain) OSIROIMask *ROIMask;
@property (nonatomic, readonly, retain) OSIFloatVolumeData *floatVolumeData;

- (float)meanIntensity;
- (float)maxIntensity;
- (float)minIntensity;

- (NSUInteger)floatCount;
- (NSUInteger)getFloatData:(float *)buffer floatCount:(NSUInteger)count;

- (NSRange)volumeRangeForROIMaskRun:(OSIROIMaskRun)maskRun;
- (NSRange)volumeRangeForROIMaskIndex:(OSIROIMaskIndex)maskIndex;

@end
