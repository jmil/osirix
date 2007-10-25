//
//  XRayTemplate.h
//  XRayTemplatesPlugin
//
//  Created by Joris Heuberger on 19/03/07.
//  Copyright 2007 OsiriX Team. All rights reserved.
//

#import <Cocoa/Cocoa.h>

typedef enum
{
	UnknownManufacturer = -1,
	Zimmer
} XRayTemplateManufacturer;

typedef enum
{
	XRayTemplateAnteriorPosteriorDirection,
	XRayTemplateLateralDirection
} XRayTemplateViewDirection;

@interface XRayTemplate : NSObject {
	NSString *directoryName;
	NSMutableDictionary* properties;
	NSString *PDFPreviewPath;
	NSImage *image;
	NSString *name;
	NSArray *textualData;

	NSString *referenceFilePath;
	
	XRayTemplateViewDirection viewDirection;
}

- (id)initFromFileAtPath:(NSString*)path;
- (NSString*)directoryName;
- (void)setViewDirection:(XRayTemplateViewDirection)direction;
- (XRayTemplateManufacturer)manufacturer;
- (NSString*)manufacturerName;
- (NSMutableDictionary*)properties;
- (NSString*)PDFPreviewPath;
- (NSImage*)image;
- (NSString*)name;
- (NSArray*)textualData;
- (NSString*)referenceFilePath;
- (NSString*)size;
- (float)sizeValue;
- (NSString*)reference;

@end
