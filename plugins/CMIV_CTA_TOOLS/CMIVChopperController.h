
/*=========================================================================
CMIVChopperController

Reduce the dimension of original dataset by a box defined by users

Author: Chunliang Wang (chunliang.wang@imv.liu.se)


Program:  CMIV CTA image processing Plugin for OsiriX

This file is part of CMIV CTA image processing Plugin for OsiriX.

Copyright (c) 2007,
Center for Medical Image Science and Visualization (CMIV),
Linkšping University, Sweden, http://www.cmiv.liu.se/

CMIV CTA image processing Plugin for OsiriX is free software;
you can redistribute it and/or modify it under the terms of the
GNU General Public License as published by the Free Software 
Foundation, either version 3 of the License, or (at your option)
any later version.

CMIV CTA image processing Plugin for OsiriX is distributed in
the hope that it will be useful, but WITHOUT ANY WARRANTY; 
without even the implied warranty of MERCHANTABILITY or FITNESS
FOR A PARTICULAR PURPOSE.  See the GNU General Public License
for more details.

You should have received a copy of the GNU General Public License
along with this program.  If not, see <http://www.gnu.org/licenses/>.

=========================================================================*/
#import <Cocoa/Cocoa.h>
#import "PluginFilter.h"
#import "CMIV_CTA_TOOLS.h"
#define id Id
#include <vtkImageImport.h>
#include <vtkTransform.h>
#include <vtkImageReslice.h>
#undef id
@interface CMIVChopperController : NSObject
{
	IBOutlet NSWindow	*window;
    IBOutlet NSTextField *imageFrom;
    IBOutlet NSSlider *imageFromSlider;
    IBOutlet NSTextField *imageTo;
    IBOutlet NSSlider *imageToSlider;
    IBOutlet NSTextField *leftTopX;
    IBOutlet NSTextField *leftTopY;
    IBOutlet DCMView *originalView;
    IBOutlet NSSlider *originalViewSlider;
    IBOutlet DCMView *reformView;
    IBOutlet NSSlider *reformViewSlider;
    IBOutlet NSSegmentedControl *reformViewState;
    IBOutlet NSTextField *rightBottomX;
    IBOutlet NSTextField *rightBottomY;
	IBOutlet NSButton *nextStep;
    IBOutlet NSTextField *wizardTips;	
	NSRect   roiRect;
	NSRect   coronalROIRect;
	NSRect   sagittalROIRect;
	long      imageWidth,imageHeight,imageAmount;
	int      iImageFrom,iImageTo; 
	float    ratioXtoThick,ratioYtoThick,ratioXtoY;
	float    *outputVolumeData;
	ROI      *curAxialROI,*curReformROI;
	NSMutableArray *roiListAxial,*roiListReform;
	NSMutableArray *reformPixList;
	NSArray         *reformFileList;
	DCMPix			*curPix;
	
	ViewerController     *originalViewController;
	
	double				vtkOriginalX,vtkOriginalY,vtkOriginalZ;
	double				sliceThickness;
	
	vtkImageReslice		*rotate;
	vtkImageImport		*reader;
	vtkTransform		*sliceTransform;	
	NSMutableArray      *toolbarList;	
	CMIV_CTA_TOOLS* parent;
	BOOL isInWizardMode;
	BOOL isSelectAll;
	
}
- (IBAction)changeReformView:(id)sender;
- (IBAction)setImageFromTo:(id)sender;
- (IBAction)setImageFromToSlider:(id)sender;
- (IBAction)setROIRect:(id)sender;
- (IBAction)endPanel:(id)sender;
- (IBAction)setCurrentToImageFromTo:(id)sender;
- (IBAction)setReformViewIndex:(id)sender;
- (IBAction)selectAll:(id)sender;
- (int) showChopperPanel:(ViewerController *) vc:(CMIV_CTA_TOOLS*) owner;
- (void)showPanelAsWizard:(ViewerController *) vc:(CMIV_CTA_TOOLS*) owner;
- (void) updateAllTextField;
- (void) updateImageFromToSliders;
- (void) updateALLROIs;
- (void) roiChanged: (NSNotification*) note;
- (void) defaultToolModified: (NSNotification*) note;
- (void) changeWLWW: (NSNotification*) note;
- (int)  initReformView;
- (void) reHideToolbar;
@end
