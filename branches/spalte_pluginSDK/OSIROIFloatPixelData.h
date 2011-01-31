//
//  ROIPixelData.h
//  OsiriX
//
//  Created by Joël Spaltenstein on 1/25/11.
//  Copyright 2011 OsiriX Team. All rights reserved.
//

#import <Cocoa/Cocoa.h>

// this is the representation of the data within the generic ROI


@class OSIFloatVolumeData;
@class OSIROIMask;
@class OSIStudy;

@interface OSIROIFloatPixelData : NSObject {

}

- (id)initWithROIMask:(OSIROIMask *) floatVolumeData:(OSIFloatVolumeData *)volumeData;

- (OSIROIMask *)ROIMask;
- (OSIFloatVolumeData *)floatVolumeData;

- (float)meanIntensity;
- (float)maxIntensity;
- (float)minIntensity;

- (NSUInteger)floatCount;
- (void)getFloatData:(float *)buffer floatCount:(NSUInteger)count;

- (OSIStudy *)study; // really just a shortcut to get the volume's study


@end
