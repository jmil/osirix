//
//  OSIROIManager.h
//  OsiriX
//
//  Created by Joël Spaltenstein on 1/25/11.
//  Copyright 2011 OsiriX Team. All rights reserved.
//

#import <Cocoa/Cocoa.h>

// anyone who is interested in dealing with ROIs can create one of these and learn about what is going on with ROIs

// and OSIROIManager is meant to act as a filter, it will return ROIs

// what I want is an object that will give me a list of volume ROIs

extern const NSString *OSILineROIType;
extern const NSString *OSI;

@class OSIStudy;
@class OSIROI;
@class OSIVolumeWindow;

extern NSString* const OSIROIManagerROIsDidUpdateNotification; 

@protocol OSIROIManagerDelegate;


@interface OSIROIManager : NSObject {
	id <OSIROIManagerDelegate> _delegate;
	
	OSIVolumeWindow *_volumeWindow;
	BOOL _coalesceROIs;
	
	BOOL _rebuildingROIs;
	
	NSMutableArray *_OSIROIs;
}

@property (nonatomic, readwrite, assign) id <OSIROIManagerDelegate> delegate;

- (id)initWithVolumeWindow:(OSIVolumeWindow *)volumeWindow;
- (id)initWithVolumeWindow:(OSIVolumeWindow *)volumeWindow coalesceROIs:(BOOL)coalesceROIs; // if coalesceROIs is YES, ROIs with the same name will 

- (NSArray *)ROIs; // return OSIROIs observable

- (OSIROI *)firstROIWithName:(NSString *)name; // convenience method to get the first ROI with a given name
- (NSArray *)ROIsWithName:(NSString *)name;
- (NSArray *)ROINames; // returns all the unique ROI names

// not done
//- (id)init; // look at all ROIS
//
//- (id)initWithStudy:(OSIStudy *)study; // if a study is specifed, only ROIs the manager will only look at ROIs in this study
//
//- (NSArray *)ROIsOfType:(NSString *)type;



@end

@protocol OSIROIManagerDelegate <NSObject>
@optional
//- (void)ROIManager:(OSIROIManager *)ROIManager didAddROI:(OSIROI *)ROI;
//- (void)ROIManager:(OSIROIManager *)ROIManager didRemoveROI:(OSIROI *)ROI;
//- (void)ROIManager:(OSIROIManager *)ROIManager didModifyROI:(OSIROI *)ROI;

@end

