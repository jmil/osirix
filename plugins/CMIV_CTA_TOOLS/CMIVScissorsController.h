
/*=========================================================================
CMIVScissorsController

Handle most common 2d image processing task, such as MPR, CPR.
Another important job is to create the seeds marker for the 
segmentation.

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
#import "CMIVSlider.h"
#define id Id
#include <vtkImageImport.h>
#include <vtkTransform.h>
#include <vtkImageReslice.h>
#include <vtkImageData.h>
//#include <vtkProbeFilter.h>
#include <vtkRuledSurfaceFilter.h>
#include <vtkPoints.h>
#include <vtkTransformFilter.h>
#include <vtkCellArray.h>
//#include <vtkDataSet.h>
#include <vtkPointData.h>
#include <vtkTransformPolyDataFilter.h>
#include <vtkSplineFilter.h>
#include <vtkKochanekSpline.h>
#include <vtkRibbonFilter.h>
#include <vtkAppendPolyData.h>
#include "spline.h"
#undef id

@interface CMIVScissorsController : NSObject
{
	IBOutlet NSWindow	*window;
	IBOutlet NSWindow	*loadPathWindow;
	IBOutlet NSWindow	*exportCPRWindow;
	IBOutlet NSWindow	*savePathWindow;
    IBOutlet NSTextField *resampleText;
	IBOutlet NSPopUpButton *pathListButton;
    IBOutlet NSSlider *axImageSlider;
    IBOutlet NSSlider *cImageSlider;
    IBOutlet DCMView *cPRView;
    IBOutlet DCMView *crossAxiasView;
    IBOutlet CMIVSlider *cYRotateSlider;
    IBOutlet NSSlider *oImageSlider;
    IBOutlet DCMView *originalView;
    IBOutlet CMIVSlider *oXRotateSlider;
    IBOutlet CMIVSlider *oYRotateSlider;
    IBOutlet NSColorWell *seedColor;
    IBOutlet NSTextField *seedName;
    IBOutlet NSTableView *seedsList;
	IBOutlet NSButton *centerLock;
    IBOutlet NSSlider *brushWidthSlider;
    IBOutlet NSSegmentedControl *brushStatSegment;
    IBOutlet NSTextField *brushWidthText;
	IBOutlet NSButton *crossShowButton;	
	IBOutlet NSPopUpButton *pathModifyButton;
	IBOutlet NSButton *nextButton;
	IBOutlet NSButton *previousButton;
	IBOutlet NSButton *convertToSeedButton;
	IBOutlet NSButton *continuePlantingButton;
	IBOutlet NSButton *cancelButton;
	IBOutlet NSButton *saveButton;
    IBOutlet NSTableView *centerlinesList;
	IBOutlet NSMenuItem *straightenedCPRSwitchMenu;
	IBOutlet NSButton *straightenedCPRButton;	
	IBOutlet NSButton *exportOrthogonalImagesButton;
	
	IBOutlet NSTextField *currentTips;
	IBOutlet NSTabView *seedToolTipsTabView;
    IBOutlet NSSlider *resampleRatioSlider;
    IBOutlet NSTextField *resampleRatioText;
	
	IBOutlet NSMatrix *howManyAngleToExport;
	IBOutlet NSTextField *howManyImageToExport;
	IBOutlet NSTextField *pathName;	
	IBOutlet NSTextField *oViewRotateXText;
	IBOutlet NSTextField *oViewRotateYText;
	IBOutlet NSTextField *cViewRotateYText;
	IBOutlet NSButton *ifExportCrossSectionButton;	
	
	int      imageWidth,imageHeight,imageAmount,imageSize;
	float    sliceThickness;
	float	 vtkOriginalX,vtkOriginalY,vtkOriginalZ;
	float    xSpacing,ySpacing,zSpacing,minSpacing;
	float    centerX,centerY,centerZ; //for lock center , not useful now
	float    preOViewXAngle,PreOViewYAngle,preOViewPosition;
	float    oViewRotateAngleX,oViewRotateAngleY,cViewRotateAngleY;
	NSArray             *fileList;	
	ViewerController     *originalViewController;
	DCMPix* curPix;

	BOOL     roiShowNameOnly, roiShowTextOnlyWhenSeleted;
	BOOL     isInWizardMode;
	BOOL     isInCPROnlyMode;
	BOOL     isStraightenedCPR;
	float               *volumeData;
	unsigned short int  *contrastVolumeData;
	vtkImageReslice		*oViewSlice;
	vtkImageImport		*reader,*roiReader;
	vtkTransform		*oViewBasicTransform,*oViewUserTransform;
	vtkTransform		*inverseTransform;
	vtkTransform		*cViewTransform;
	vtkTransform        *axViewTransform,*axViewTransformForStraightenCPR, *avViewinverseTransform;
	vtkImageReslice     *cViewSlice;
	vtkImageReslice     *axViewSlice;
	vtkImageReslice     *oViewROISlice;
	///////////////
	vtkTransform        *surfaceLeftTransform;
	vtkTransform        *surfaceRightTransform;	
//	vtkProbeFilter      *curvedProber;
	vtkRuledSurfaceFilter *curvedSurface;
	vtkPoints           *pathKeyPoints;
	vtkCellArray        *centerLinePath;
	vtkPolyData			*centerLinePolyData;
	vtkTransformPolyDataFilter *leftTransformFilter;
	vtkTransformPolyDataFilter *rightTransformFilter;
	vtkAppendPolyData	*appenedPolyData;
	vtkSplineFilter     *splineFilter;
	vtkKochanekSpline   *kSpline;
	vtkPoints           *smoothedCenterlinePoints;
	vtkCellArray        *smoothedCenterlineCells;
	vtkPolyData			*smoothedCenterlinePD;
	vtkRibbonFilter     *narrowRibbonofCenterline;
	vtkPolyData         *ribbonPolydata;	
	ROI                 *curvedMPR2DPath;
	NSMutableArray      *curvedMPR3DPath;
	NSMutableArray      *curvedMPRProjectedPaths;
	ROI                 *curvedMPRReferenceLineOfAxis;	
	float				*cprImageBuffer;
	float               defaultROIThickness;

	
	float                minValueInSeries;
	
	NSMutableArray      *oViewPixList,*oViewROIList;
	NSMutableArray      *cViewPixList,*cViewROIList;
	NSMutableArray      *axViewPixList,*axViewROIList;	
	
	NSMutableArray      *contrastList;	
	NSMutableArray      *totalROIList;
	NSMutableArray      *toolbarList;	
	NSMutableArray      *cpr3DPaths;
	NSMutableArray      *centerlinesNameArrays;
	int                  uniIndex;
	int                  isRemoveROIBySelf;
	long		annotations	;
	
	int      currentTool;
	int      currentPathMode;
	NSRect   cPRROIRect;
	NSRect   axCircleRect;
	int      centerIsLocked;
	float    lastOViewXAngle,lastOViewYAngle,lastOViewTranslate;
	float    lastCViewTranslate;
	double	 oViewSpace[3], oViewOrigin[3];
	double	 cViewSpace[3], cViewOrigin[3];
	double   axViewSpace[3],axViewOrigin[3];
	NSPoint  cPRViewCenter,cViewArrowStartPoint;
	float    oViewToCViewZAngle,cViewToAxViewZAngle;
	BOOL     IsVersion2_6;
	CMIV_CTA_TOOLS* parent;
	NSColor* currentSeedColor;
	NSString *currentSeedName;
	int currentStep;
	int totalSteps;
	NSString* howToContinueTip;
	BOOL isNeedShowReferenceLine;
	
	int       soomthedpathlen;
	double*   soomthedpath;
	int interpolationMode;
	
	
	
}
- (IBAction)addSeed:(id)sender;
- (IBAction)changeDefaultTool:(id)sender;
- (IBAction)changeSeedColor:(id)sender;
- (IBAction)changeSeedName:(id)sender;
- (IBAction)changOriginalViewDirection:(id)sender;
- (IBAction)onCancel:(id)sender;
- (IBAction)onOK:(id)sender;
- (IBAction)pageAxView:(id)sender;
- (IBAction)pageCView:(id)sender;
- (IBAction)pageOView:(id)sender;
- (IBAction)removeSeed:(id)sender;
- (IBAction)rotateXCView:(id)sender;
- (IBAction)rotateXOView:(id)sender;
- (IBAction)rotateYOView:(id)sender;
- (void)    rotateZOView:(float)angle;
- (IBAction)resetOriginalView:(id)sender;
- (IBAction)lockCenter:(id)sender;
- (IBAction)selectAContrast:(id)sender;
- (IBAction)setBrushWidth:(id)sender;
- (IBAction)setBrushMode:(id)sender;
- (IBAction)crossShow:(id)sender;
- (IBAction)covertRegoinToSeeds:(id)sender;
- (IBAction)setPathMode:(id)sender;
- (IBAction)showLoadPathDialog:(id)sender;
- (IBAction)endLoadPathDialog:(id)sender;
- (IBAction)goNextStep:(id)sender;
- (IBAction)goPreviousStep:(id)sender;
- (IBAction)continuePlanting:(id)sender;
- (IBAction)selectANewCenterline:(id)sender;
- (IBAction)showCPRImageDialog:(id)sender;
- (IBAction)endCPRImageDialog:(id)sender;
- (IBAction)setResampleRatio:(id)sender;
- (IBAction)exportCenterlines:(id)sender;
- (IBAction)showCenterlinesDialog:(id)sender;
- (IBAction)endCenterlinesDialog:(id)sender;
- (IBAction)removeCenterline:(id)sender;
- (IBAction)switchStraightenedCPR:(id)sender;
- (IBAction)exportOrthogonalDataset:(id)sender;
- (int) showScissorsPanel:(ViewerController *) vc: (CMIV_CTA_TOOLS*) owner;
- (void)showPanelAsWizard:(ViewerController *) vc: (CMIV_CTA_TOOLS*) owner;
- (void)showPanelAsCPROnly:(ViewerController *) vc: (CMIV_CTA_TOOLS*) owner;
- (int) initViews;
- (int) initSeedsList;
- (int) reloadSeedsFromExportedROI;
- (void) updateOView;
- (void) updateCView;
- (void) updateCViewAsCurvedMPR;
- (void) updateCViewAsMPR;
- (void) updateAxView;
- (void) recaculateAxViewForCPR;
- (void) recaculateAxViewForStraightenedCPR;
- (void) updatePageSliders;
- (void) resetSliders;
- (void) roiChanged: (NSNotification*) note;
- (void) roiAdded: (NSNotification*) note;
- (void) roiRemoved: (NSNotification*) note;
- (void) defaultToolModified: (NSNotification*) note;
- (void) changeWLWW: (NSNotification*) note;
- (void) crossMove:(NSNotification*) note;
- (void) cAndAxViewReset;
- (void) defaultToolModified: (NSNotification*) note;
- (void) creatROIListFromSlices:(NSMutableArray*) roiList :(int) width:(int)height:(short unsigned int*)im :(float)spaceX:(float)spaceY:(float)originX:(float)originY;
- (void) reCaculateCPRPath:(NSMutableArray*) roiList :(int) width :(int)height :(float)spaceX: (float)spaceY : (float)spaceZ :(float)originX :(float)originY:(float)originZ;
- (void) changeCurrentTool:(int) tag;
- (void) fixHolesInBarrier:(int)minx :(int)maxx :(int)miny :(int)maxy :(int)minz :(int)maxz :(short unsigned int) marker;
- (void) create3DPathFromROIs:(NSString*) roiName;
- (void) resample3DPath:(float)step;
	//for tableview
- (int)numberOfRowsInTableView:(NSTableView *)tableView;
- (id)tableView:(NSTableView *)tableView
    objectValueForTableColumn:(NSTableColumn *)tableColumn
            row:(int)row;
- (void)tableView:(NSTableView *)aTableView
 setObjectValue:(id)anObject
 forTableColumn:(NSTableColumn *)aTableColumn
			row:(int)rowIndex;

- (float*) caculateCurvedMPRImage :(int*)pwidth :(int*)pheight ;
- (float*) caculateStraightCPRImage :(int*)pwidth :(int*)pheight ;
- (void) checkRootSeeds:(NSArray*)roiList;
- (void) runSegmentation;
- (int) plantSeeds:(float*)inData:(float*)outData:(unsigned char *)directData;
- (void) showPreviewResult:(float*)inData:(float*)outData:(unsigned char *)directData :(unsigned char *)colorData;
- (void) goSubStep:(int)step:(bool)needResetViews;
- (void) setCurrentCPRPathWithPath:(NSArray*)path:(float)resampelrate;
- (void) convertCenterlinesToVTKCoordinate:(NSArray*)centerlines;
- (void) creatROIfrom3DPath:(NSArray*)path:(NSString*)name:(NSMutableArray*)newViewerROIList;
- (void)reHideToolbar;
- (void)relocateAxViewSlider;
- (float)TriCubic : (float*) p :(float *)volume : (int) xDim : (int) yDim :(int) zDim;
- (ViewerController *) exportCrossSectionImages;
- (ViewerController *) exportCViewImages;
- (ViewerController *) exportOViewImages;
@end
