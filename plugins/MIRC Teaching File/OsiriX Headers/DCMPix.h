#import <Foundation/Foundation.h>
#import <Cocoa/Cocoa.h>

#define USEVIMAGE

@class xNSImage;
@class ROI;
@class ThickSlabController;

@interface DCMPix: NSObject <NSCopying>
{
	BOOL				nonDICOM;
    NSString            *srcFile;
    xNSImage			*image;
    short               *oImage;
	float				*fImage, *fVolImage;
	
	NSPoint				subOffset;
	float				*subtractedfImage;
	
    char                *wImage;
	long				frameNo;
	long				serieNo;
    
    char                *baseAddr;
    
    long                height, width, rowBytes;
    long                ww, wl, imID, imTot;
	long				fullww, fullwl;
    float               sliceInterval, pixelSpacingX, pixelSpacingY, sliceLocation, sliceThickness, pixelRatio;
    
	float				originX, originY, originZ;
	float				orientation[ 9];
	
	BOOL				thickSlabMode;
	BOOL				isRGB;
	BOOL				inverseVal;
	long				fPlanarConf;
	BOOL				fIsSigned;
	
	BOOL				fixed8bitsWLWW;
	
    float               slope, offset;
	
	float				cineRate;
	
	BOOL				convolution, updateToBeApplied;
	short				kernelsize;
	short				normalization;
	short				kernel[25];
	
	long				savedWL, savedWW;
	
	short				stack;
	short				stackMode, pixPos;
	NSArray				*pixArray;
	
	volatile BOOL		checking;
	
	NSString			*echotime, *repetitiontime, *convertedDICOM;
	
	// ThickSlab
	
	ThickSlabController *thickSlab;
}

// Is it an RGB image (ARGB) or float image?
- (BOOL) isRGB;

// Pointer to image data
- (float*) fImage;

// Dimensions in pixels
-(long) pwidth;
-(long) pheight;

// WL & WW
-(long) ww;
-(long) wl;

// Compute ROI data
- (void) computeROI:(ROI*) roi :(float *)mean :(float *)total :(float *)dev :(float *)min :(float *)max;

// Fill a ROI with a value!
- (void) fillROI:(ROI*) roi :(float) newVal :(float) minValue :(float) maxValue :(BOOL) outside;

// Is this Point (pt) in this ROI ?
- (BOOL) isInROI:(ROI*) roi :(NSPoint) pt;

// Return a pointer with all pixels values contained in the current ROI
// Free the pointer with the free() function
- (float*) getROIValue :(long*) numberOfValues :(ROI*) roi;
- (float*) getLineROIValue :(long*) numberOfValues :(ROI*) roi;


- (BOOL) thickSlabMode;
- (void) ConvertToBW:(long) mode;
- (void) ConvertToRGB:(long) mode :(long) cwl :(long) cww;
- (void) imageArithmeticSubtraction:(DCMPix*) sub;
- (float) cineRate;
- (void) setSubtractionOffset:(NSPoint) o;
- (void) setSubtractedfImage :(float*) s;
-(float*) subtractImages :(float*) input :(float*) subfImage;
-(void) imageArithmeticMultiplication:(DCMPix*) sub;
- (NSString*) repetitiontime;
- (NSString*) echotime;
- (void) setRGB : (BOOL) val;
- (void) setConvolutionKernel:(short*)val :(short) size :(short) norm;
- (void) setArrayPix :(NSArray*) array :(short) i;
- (BOOL) updateToApply;
- (id) myinitEmpty;
- (id) myinit:(NSString*) s :(long) pos :(long) tot :(float*) ptr :(long) f :(long) ss;
- (id) initwithdata :(float*) im :(short) pixelSize :(long) xDim :(long) yDim :(float) xSpace :(float) ySpace :(float) oX :(float) oY :(float) oZ;
- (xNSImage*) computeWImage:(BOOL)icon :(long)ww :(long)wl;
- (void) changeWLWW:(long)newWL :(long)newWW;
- (xNSImage*) getImage;
- (char*) baseAddr;
- (void) setBaseAddr :( char*) ptr;
- (void) dealloc;
- (short*) oImage;
//- (void) killImage;
- (void) checkImageAvailble:(long)newWW :(long)newWL;
-(long) rowBytes;
-(void) setRowBytes:(long) rb;
-(long) fullww;
-(long) fullwl;
-(float) slope;
-(float) offset;
-(long) ID;
-(long) frameNo;
-(void) setFrameNo:(long) f;
-(long) serieNo;
-(long) Tot;
-(void) setTot: (long) tot;
-(float) originX;
-(float) originY;
-(float) originZ;
-(float) pixelRatio;
-(void) setPixelRatio:(float)r;
-(float) pixelSpacingX;
-(float) pixelSpacingY;
-(void) setPixelSpacingX :(float) s;
-(void) setPixelSpacingY :(float) s;
-(float) sliceLocation;
-(void) setSliceLocation:(float) l;
-(float) sliceThickness;
-(float) sliceInterval;
-(void) setSliceInterval:(float) s;
-(void) CheckLoad;
-(void) setFusion:(short) mode :(short) stacks;
-(short) stack;
-(NSString*) sourceFile;
-(void) setUpdateToApply;
-(void) orientation:(float*) c;
-(void) setOrientation:(float*) c;
-(void) computePixMinPixMax;
- (long) savedWL;
- (long) savedWW;
-(void) setfImage:(float*) ptr;
- (void) setThickSlabController:( ThickSlabController*) ts;
-(void) setFixed8bitsWLWW:(BOOL) f;
@end