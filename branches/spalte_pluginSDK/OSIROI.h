//
//  OSIROI.h
//  OsiriX
//
//  Created by Joël Spaltenstein on 1/25/11.
//  Copyright 2011 OsiriX Team. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "OSIGeometry.h"

// abstract 

//@class OSIROIFloatPixelData;
//@class OSIFloatVolumeData;
@class OSIStudy;
@class ROI;

// this is an abstract class
// how do you identify an ROI? Does an ROI have an ID and that is how you know what an ROI is, or is the ROI the actual object...
// polygon compilation ROI

@interface OSIROI : NSObject {

}

//@property (nonatomic, readwrite, assign) void *context;

//- (id)initWithDictionaryRepresentation:(NSDictionary *)dict;

- (NSString *)name;
//- (NSString *)label;

//- (NSString *)metricNames;
//- (NSString *)labelForMetric:(NSString *)metric;
//- (NSString *)unitForMetric:(NSString *)metric;
//- (id)valueForMetric:(NSString *)metric;

//- (OSIStudy *)study;
//- (OSIROIFloatPixelData *)ROIFloatPixelDataForFloatVolumeData:(OSIFloatVolumeData *)floatVolume; // resamples the ROI onto the other volume data
//- (OSIROIMask *)ROIMaskForFloatVolumeData:(OSIFloatVolumeData *)floatVolume;
//- (BOOL)containsVector:(OSIVector)vector;

- (NSArray *)convexHull; // OSIVectors stored in NSValue objects. The ROI promises to live inside of these points
						 // all concrete implementation MUST implement this!

//- (NSDictionary *)dictionaryRepresentation; // make sure this is a plist serializable dictionary;

// at some point I would love to support drawing new ROI types...

@end
