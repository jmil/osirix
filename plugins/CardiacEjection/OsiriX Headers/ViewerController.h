//
//  ViewerController.h
//  OsiriX
//
//  Created by rossetantoine.
//  Copyright (c) 2004 ROSSET Antoine. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <AppKit/AppKit.h>

@class DCMView;
@class ColorTransferView;
@class MyPoint;
@class ROI;

@interface ViewerController : NSWindowController {

    IBOutlet NSWindow       *quicktimeWindow;
	IBOutlet NSMatrix		*quicktimeMode;
	
    IBOutlet DCMView        *imageView;
    IBOutlet NSSlider       *slider, *speedSlider;
    IBOutlet NSView         *speedView;
    IBOutlet NSView         *toolsView;
    IBOutlet NSView         *WLWWView;
    IBOutlet NSView         *ReconstructionView;
	IBOutlet NSView         *ConvView;
	IBOutlet NSView         *FusionView;
	IBOutlet NSView			*BlendingView;
	IBOutlet NSView			*movieView, *serieView;
	IBOutlet NSView         *RGBFactorsView;
	IBOutlet NSTextField    *speedText;
    IBOutlet NSPopUpButton  *wlwwPopup;
    IBOutlet NSPopUpButton  *convPopup;
    IBOutlet NSPopUpButton  *clutPopup;
	IBOutlet NSPopUpButton  *seriePopup;
	
			 NSPoint		subOffset;
			 long			subtractedImage, wlBeforeSubtract;
	
	IBOutlet NSButton		*subtractOnOff;
	IBOutlet NSView         *subtractView;
	IBOutlet NSTextField	*XOffset, *YOffset, *subtractIm;
	
	IBOutlet NSWindow		*ThickIntervalWindow;
    IBOutlet NSTextField    *customInterval;
    IBOutlet NSTextField    *customXSpacing;
	IBOutlet NSTextField    *customYSpacing;
			
    IBOutlet NSWindow       *addWLWWWindow;
    IBOutlet NSTextField    *newName;
    IBOutlet NSTextField    *wl;
    IBOutlet NSTextField    *ww;
	IBOutlet NSMatrix		*toolsMatrix;
    
	IBOutlet NSWindow       *roiSetPixWindow;
	IBOutlet NSTextField    *maxValueText, *minValueText, *newValueText;
	IBOutlet NSMatrix		*InOutROI;
	IBOutlet NSButton		*checkMaxValue, *checkMinValue;
	
	IBOutlet NSWindow       *blendingTypeWindow;
	IBOutlet NSButton		*blendingTypeMultiply, *blendingTypeSubtract;
	IBOutlet NSButton		*blendingTypeRed, *blendingTypeGreen, *blendingTypeBlue, *blendingTypeRGB;
	IBOutlet NSPopUpButton  *blendingPlugins;
	
	IBOutlet NSWindow       *roiPropaWindow;
	IBOutlet NSMatrix		*roiPropaMode;
	IBOutlet NSTextField	*roiPropaDest;
	
	IBOutlet NSWindow       *addConvWindow;
	IBOutlet NSMatrix		*convMatrix, *sizeMatrix;
	IBOutlet NSTextField    *matrixName, *matrixNorm;
	
	IBOutlet NSWindow       *addCLUTWindow;
	IBOutlet NSTextField    *clutName;
	IBOutlet ColorTransferView  *clutView;
	
	IBOutlet NSTextField    *movieTextSlide;
	IBOutlet NSButton		*moviePlayStop;
	IBOutlet NSSlider       *movieRateSlider;
	IBOutlet NSSlider       *moviePosSlider;
	
	IBOutlet NSTextField    *blendingPercentage;
	IBOutlet NSSlider       *blendingSlider;
	ViewerController		*blendingController;
	
	NSString				*curConvMenu, *curWLWWMenu, *curCLUTMenu;
	
	IBOutlet NSTextField    *stacksFusion;
	IBOutlet NSSlider       *sliderFusion;
	IBOutlet NSPopUpButton  *popFusion, *popupRoi, *ReconstructionRoi;
	
    NSMutableArray          *fileList[50], *pixList[50], *roiList[50];
	NSData					*volumeData[50];
	short					curMovieIndex, maxMovieIndex;
    NSToolbar               *toolbar;
	
	float					direction;
    
	volatile BOOL			ThreadLoadImage, stopThreadLoadImage;
    BOOL                    FullScreenOn;
    NSWindow                *FullScreenWindow;
    NSWindow                *StartingWindow;
    NSView                  *contentView;
    
    NSTimer					*timer, *movieTimer;
    NSTimeInterval			lastTime, lastTimeFrame;
	NSTimeInterval			lastMovieTime;
	
	NSDate					*popupStartDate, *popupLastDate;
	
	NSSound					*tickSound;
}

// Create a new 2D Viewer
- (ViewerController *) newWindow:(NSMutableArray*)pixList :(NSMutableArray*)fileList :(NSData*) volumeData;

// Return the 'dragged' window, the destination window is contained in the 'viewerController' object of the 'PluginFilter' object
-(ViewerController*) blendedWindow;

// Display a waiting window
- (id) startWaitWindow :(NSString*) message;
- (void) endWaitWindow:(id) waitWindow;

// OsiriX have to refresh the current displayed image
- (void) needsDisplayUpdate;

// Return the memory pointer that contains the ENTIRE series (a unique memory block for all images)
- (float*) volumePtr;

// Return the image pane object
- (DCMView*) imageView;

// Return the array of DCMPix objects
- (NSMutableArray*) pixList;

// Return the array of DicomFile objects
- (NSMutableArray*) fileList;

// Return the array of ROI objects
- (NSMutableArray*) roiList;

// Create a new Point object
- (MyPoint*) newPoint: (float) x :(float) y;

// Create a new ROI object
- (ROI*) newROI: (long) type;

// UNDOCUMENTED FUNCTIONS
// For more informations: rossetantoine@bluewin.ch

- (IBAction) ConvertToRGBMenu:(id) sender;
- (IBAction) ConvertToBWMenu:(id) sender;
- (IBAction) export2PACS:(id) sender;
- (IBAction) subtractCurrent:(id) sender;
- (IBAction) subtractStepper:(id) sender;
- (IBAction) subtractSwitch:(id) sender;
- (void) loadROI:(long) mIndex;
- (void) saveROI:(long) mIndex;
- (id) findPlayStopButton;
- (BOOL) FullScreenON;
- (void) setROITool:(id) sender;
- (void) changeImageData:(NSMutableArray*)f :(NSMutableArray*)d :(NSData*) v;
- (IBAction) loadSerie:(id) sender;
- (void) offFullscren;
- (float) frame4DRate;
- (long) maxMovieIndex;
- (NSSlider*) moviePosSlider;
- (NSSlider*) sliderFusion;
- (IBAction) convMatrixAction:(id)sender;
- (IBAction) changeMatrixSize:(id) sender;
- (IBAction) computeSum:(id) sender;
- (IBAction) endNameWLWW:(id) sender;
- (IBAction) endConv:(id) sender;
- (IBAction) endCLUT:(id) sender;
- (IBAction) endBlendingType:(id) sender;
- (IBAction) endQuicktime:(id) sender;
- (void) setDefaultTool:(id) sender;
- (OSErr)getFSRefAtPath:(NSString*)sourceItem ref:(FSRef*)sourceRef;
- (id) viewCinit:(NSMutableArray*)f :(NSMutableArray*)d :(NSData*) v;
- (void) speedSliderAction:(id) sender;
- (void) setupToolbar;
- (void) PlayStop:(id) sender;
- (short) getNumberOfImages;
- (float) frameRate;
- (void) adjustSlider;
- (void) sliderFusionAction:(id) sender;
- (void) popFusionAction:(id) sender;
- (void) propagateSettings;
- (void) setCurWLWWMenu:(NSString*)s ;
- (BOOL) is2DViewer;
- (NSString*) curCLUTMenu;
- (void) ApplyCLUTString:(NSString*) str;
- (NSSlider*) blendingSlider;
- (void) blendingSlider:(id) sender;
- (void) blendingMode:(id) sender;
- (ViewerController*) blendingController;
- (NSString*) modality;
- (void) addMovieSerie:(NSMutableArray*)f :(NSMutableArray*)d :(NSData*) v;
- (void) startLoadImageThread;
- (void) moviePosSliderAction:(id) sender;
- (void) movieRateSliderAction:(id) sender;
- (void) MoviePlayStop:(id) sender;
- (void) checkEverythingLoaded;
- (IBAction) roiSetPixelsSetup:(id) sender;
- (IBAction) roiSetPixels:(id) sender;
- (IBAction) roiPropagateSetup: (id) sender;
- (IBAction) roiPropagate:(id) sender;
- (void) showWindowTransition;
- (float) computeInterval;
- (IBAction) endThicknessInterval:(id) sender;
- (void) SetThicknessInterval:(long) constructionType;
- (IBAction) MPRViewer:(id) sender;
- (IBAction) VRViewer:(id) sender;
- (IBAction) MPR2DViewer:(id) sender;
- (IBAction) MIPViewer:(id) sender;
- (IBAction) SRViewer:(id) sender;
- (void)createDCMViewMenu;
- (void) exportJPEG:(id) sender;
- (void)closeAllWindows:(NSNotification *)note;
@end
