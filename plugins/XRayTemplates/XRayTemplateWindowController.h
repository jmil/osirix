//
//  XRayTemplateWindowController.h
//  XRayTemplatesPlugin
//
//  Created by joris on 05/03/07.
//  Copyright 2007 OsiriX Team. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <Quartz/Quartz.h>

#import "XRayTemplate.h"
#import "ZimmerTemplate.h"

@class XRayTemplateTableView;

@interface XRayTemplateWindowController : NSWindowController {
	NSString *embededTemplateDirectoryPath;
	
	NSMutableArray *templates;
	IBOutlet NSArrayController *templatesArrayController;
	IBOutlet XRayTemplateTableView *templatesTableView;
	
	XRayTemplateViewDirection viewDirection;
	
	IBOutlet PDFView *pdfView;
	
	BOOL flipTemplatesHorizontally;
}

- (void)viewerWillClose:(NSNotification*)notification;

- (NSMutableArray*)templates;
- (NSMutableArray*)templatesForManufacturer:(XRayTemplateManufacturer)manufacturer;
- (NSMutableArray*)templatesForManufacturer:(XRayTemplateManufacturer)manufacturer withName:(NSString*)name;
- (void)findTemplates;
- (NSMutableArray*)templatesInDirectoryAtPath:(NSString*)path;
- (XRayTemplate*)templateAtPath:(NSString*)path;
- (XRayTemplate*)templateAtIndex:(int)index;
- (XRayTemplate*)selectedTemplate;
- (XRayTemplate*)nextSizeForTemplate:(XRayTemplate*)aTemplate;
- (XRayTemplate*)previousSizeForTemplate:(XRayTemplate*)aTemplate;

- (NSString*)PDFPathForTemplateAtIndex:(int)index;
- (void)setPDFDocument:(id)sender;

- (IBAction)setViewDirection:(id)sender;

- (BOOL)flipTemplatesHorizontally;
- (IBAction)flipLeftRight:(id)sender;

- (void)templateDragged:(NSNotification *)notification;
- (void)draggedOperation:(id <NSDraggingInfo>)operation onDestination:(id)destination;
- (NSImage*)imageForTemplate:(XRayTemplate*)template pixelSpacing:(float*)pixelSpacing;

- (NSRect)boundingBoxOfImage:(NSImage*)image withBackgroundColor:(NSColor*)backgroundColor;
- (NSRect)boundingBoxOfImage:(NSImage*)image;
- (NSRect)addMargin:(int)pixels toRect:(NSRect)rect;

- (NSString*)nameForTemplateAtIndex:(int)index;
- (NSArray*)textualDataForTemplateAtIndex:(int)index;

@end
