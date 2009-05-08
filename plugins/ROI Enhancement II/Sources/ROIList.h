#pragma once

//
//  ROIList.h
//  ROI Enhancement II
//
//  Created by Alessandro Volz on 4/20/09.
//  Copyright 2009 HUG. All rights reserved.
//

enum ROISel {
	ROIMin, ROIMean, ROIMax
};

#import <Cocoa/Cocoa.h>
@class Interface, ROIList;
@class ROI;
@class GRDataSet, GRLineDataSet, AreaDataSet;

@interface ROIRec : NSObject {
	ROIList* _roiList;
	ROI* _roi;
	NSMenuItem* _menuItem;
	GRLineDataSet *_minDataSet, *_meanDataSet, *_maxDataSet;
	AreaDataSet *_minmaxDataSet;
	BOOL _displayed;
}

@property(readonly) ROI* roi;
@property(readonly) NSMenuItem* menuItem;
@property(readonly) GRLineDataSet *minDataSet, *meanDataSet, *maxDataSet;
@property(readonly) AreaDataSet *minmaxDataSet;
@property BOOL displayed;

-(id)init:(ROI*)roi forList:(ROIList*)_roiList;
-(void)updateDisplayed;

@end;


@interface ROIList : NSObject {
	IBOutlet Interface* _interface;
	IBOutlet NSButton* _button;
	IBOutlet NSMenu* _menu;
	IBOutlet NSMenuItem* _all;
	IBOutlet NSMenuItem* _selected;
	IBOutlet NSMenuItem* _checked;
	IBOutlet NSMenuItem* _separator;
	NSMutableArray* _records;
	BOOL _display_all, _display_selected, _display_checked;
}

@property(readonly, retain) Interface* interface;

-(void)awakeFromNib;
-(void)loadViewerROIs;

-(unsigned)countOfDisplayedROIs;
-(ROIRec*)displayedROIRec:(unsigned)index;
-(ROIRec*)findRecordByROI:(ROI*)roi;
-(ROIRec*)findRecordByMenuItem:(NSMenuItem*)menuItem;
-(ROIRec*)findRecordByDataSet:(GRDataSet*)dataSet sel:(ROISel*)sel;
-(ROIRec*)findRecordByDataSet:(GRDataSet*)dataSet;

-(void)roiChange:(NSNotification*)notification;
-(void)removeROI:(NSNotification*)notification;

-(void)displayAllROIs;
-(void)displayAllROIs:(id)sender;
-(void)displaySelectedROIs;
-(void)displaySelectedROIs:(id)sender;
-(void)displayCheckedROIs:(id)sender;

-(void)changedMin:(BOOL)min mean:(BOOL)mean max:(BOOL)max fill:(BOOL)fill;

@end

