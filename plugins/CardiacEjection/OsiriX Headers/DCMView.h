//
//  DCMView.h
//  OsiriX
//
//  Created by rossetantoine on Wed Jan 21 2004.
//  Copyright (c) 2004 ROSSET Antoine. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Cocoa/Cocoa.h>

#include <OpenGL/gl.h>
#include <OpenGL/glext.h>
#include <OpenGL/glu.h>


#define STAT_UPDATE                0.6f
#define IMAGE_COUNT                1
#define IMAGE_DEPTH                32


enum
{
    tWL = 0,
    tTranslate =1,
    tZoom =2,
    tRotate =3,
    tNext =4,
    tMesure =5,
    tROI =6,
	t3DRotate =7,
	tCross = 8,
	
	// ROIs
	tOval = 9,
	tOPolygon = 10,
	tCPolygon = 11,
	tAngle = 12,
	tText = 13,
	tArrow = 14,
	tPencil = 15
};

@class DCMPix;
@class DCMView;
@class ROI;

@interface DCMView: NSOpenGLView
{
	ROI				*curROI;
	BOOL			drawingROI;
	DCMView			*blendingView;
	float			blendingFactor;
	
	BOOL			colorTransfer;
	unsigned char   *colorBuff;
	unsigned char   alphaTable[256], redTable[256], greenTable[256], blueTable[256];
	float			redFactor, greenFactor, blueFactor;
	long			blendingMode;
	float			sliceVector[ 3], slicePoint[ 3], slicePointO[ 3], slicePointI[ 3];

	float			mprVector[ 3], mprPoint[ 3];
	
    NSImage         *myImage;
	
    NSMutableArray  *dcmPixList;
    NSMutableArray  *dcmFilesList;
	NSMutableArray  *dcmRoiList, *curRoiList;
    DCMPix			*curDCM;
	
    
    char            listType;
    
    short           curImage, startImage;
    
    short           currentTool;
    
    NSPoint         start, originStart, previous;
    long            startWW, curWW;
    long            startWL, curWL;
    NSSize          scaleStart, scaleInit;
    
	BOOL			convolution;
	short			kernelsize, normalization;
	short			kernel[ 25];
	
    float           scaleValue,startScaleValue;
    float           rotation, rotationStart;
    NSPoint			origin;
	NSPoint			cross;
	float			angle;
	short			crossMove;
    
    NSMatrix        *matrix;
    
    long            speedometer, count;
	
    BOOL            QuartzExtreme;
	
    BOOL            xFlipped, yFlipped;

	long			fontListGLSize[256];
	long			labelFontListGLSize[ 256];
	NSSize			stringSize;
	NSFont			*labelFont;
	NSFont			*fontGL;
    GLuint          fontListGL;
	GLuint          labelFontListGL;
    
    NSPoint         mesureA, mesureB;
    NSRect          roiRect;
	NSString		*stringID;
	NSSize			previousViewSize;
    
    long imageWidth; // height of orginal image
    long imageHeight; // width of orginal image
    float imageAspect; // width / height or aspect ratio of orginal image
    long imageDepth; // depth of image (after loading into gworld, will be either 32 or 16 bits)
    long textureX; // number of horizontal textures
    long textureY; // number of vertical textures
    GLuint * pTextureName; // array for texture names (# = textureX * textureY)
	GLuint * blendingTextureName; // array for texture names (# = textureX * textureY)
	GLuint * subtractedTextureName; // array for texture names (# = textureX * textureY)
    long textureWidth; // total width of texels with cover image (including any border on image, but not internal texture overlaps)
    long textureHeight; // total height of texels with cover image (including any border on image, but not internal texture overlaps)
    
	BOOL f_ext_texture_rectangle; // is texture rectangle extension supported
	BOOL f_ext_client_storage; // is client storage extension supported
	BOOL f_ext_packed_pixel; // is packed pixel extension supported
	BOOL f_ext_texture_edge_clamp; // is SGI texture edge clamp extension supported
	BOOL f_gl_texture_edge_clamp; // is OpenGL texture edge clamp support (1.2+)
	unsigned long edgeClampParam; // the param that is passed to the texturing parmeteres
	long maxTextureSize; // the minimum max texture size across all GPUs
	long maxNOPTDTextureSize; // the minimum max texture size across all GPUs that support non-power of two texture dimensions
	long TEXTRECTMODE;
}
-(void) subtract:(DCMView*) bV;
-(void) multiply:(DCMView*) bV;
-(void) setBlendingMode:(long) f;
-(GLuint *) loadTextureIn:(GLuint *) texture :(BOOL) blending;
- (void) setSubtraction:(long) imID :(NSPoint) offset;
- (void) setYFlipped:(BOOL) v;
- (BOOL) roiTool:(long) tool;
- (void) sliderAction2DMPR:(id) sender;
- (void) setStringID:(NSString*) str;
- (float) angle;
- (void) setCrossCoordinatesPer:(float) val;
- (void) setCrossCoordinates:(float) x :(float) y :(BOOL) update;
- (void) setCross:(long) x :(long)y :(BOOL) update;
- (void) setMPRAngle: (float) vectorMPR;
- (NSPoint) ConvertFromView2GL:(NSPoint) a;
- (void) cross3D:(float*) x :(float*) y :(float*) z;
- (void) setWLWW:(long) wl :(long) ww;
- (void) getWLWW:(long*) wl :(long*) ww;
- (void) setConv:(short*) matrix :(short) size :(short) norm;
- (void) setCLUT:( unsigned char*) r :(unsigned char*) g :(unsigned char*) b;
- (void) setCurrentTool:(short)i;
- (void) dealloc;
- (long) speedometer;
- (NSImage*) nsimage:(BOOL) originalSize;
- (void) setTheMatrix:(NSMatrix*)m;
- (void) setIndex:(short) index;
- (void) setIndexWithReset:(short) index :(BOOL)sizeToFit;
- (void) setDCM:(NSMutableArray*) c :(NSMutableArray*)d :(NSMutableArray*)e :(short) firstImage :(char) type :(BOOL) reset;
- (short) curImage;
- (void) sendSyncMessage:(short) inc;
- (void) setQuartzExtreme:(BOOL) set;
- (void) loadTextures;
- (void) flipVertical:(id) sender;
- (void) flipHorizontal:(id) sender;
- (void) setFusion:(short) mode :(short) stacks;
- (void) FindMinimumOpenGLCapabilities;
- (float) scaleValue;
- (void) setScaleValue:(float) x;
- (float) rotation;
- (void) setRotation:(float) x;
- (NSPoint) origin;
- (void) setOrigin:(NSPoint) x;
- (void) setBlending:(DCMView*) bV;
- (float) pixelSpacing;
- (void) scaleToFit;
- (void) setBlendingFactor:(float) f;
- (void) sliderAction:(id) sender;
- (DCMPix*)curDCM;
- (void) roiSet;
- (void) colorTables:(unsigned char **) a :(unsigned char **) r :(unsigned char **)g :(unsigned char **) b;
- (void )changeFont:(id)sender;
- (NSSize)sizeOfString:(NSString *)string forFont:(NSFont *)font;
- (long) lengthOfString:( char *) cstr forFont:(long *)fontSizeArray;
- (void) getCrossCoordinates:(float*) x: (float*) y;
- (IBAction) sliderRGBFactor:(id) sender;
- (IBAction) alwaysSyncMenu:(id) sender;
@end