//
//  ArthroplastyTemplatingWindowController.h
//  Arthroplasty Templating II
//  Created by Joris Heuberger on 04/04/07.
//  Copyright (c) 2007-2009 OsiriX Foundation. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <Quartz/Quartz.h>
#import "ArthroplastyTemplate.h"

@class ArthroplastyTemplatingTableView;

@interface ArthroplastyTemplatingWindowController : NSWindowController {
	NSMutableArray* _templates; // every file is a template
	NSMutableArray* _families;
	
	IBOutlet NSArrayController* _templatesArrayController;
	IBOutlet ArthroplastyTemplatingTableView* _templatesTableView;
	IBOutlet PDFView* _pdfView;
	
	ArthroplastyTemplateViewDirection _viewDirection;
	
	BOOL _flipTemplatesHorizontally;
}

@property(readonly) BOOL flipTemplatesHorizontally;

-(void)loadTemplates;
-(ArthroplastyTemplate*)templateAtPath:(NSString*)path;
-(ArthroplastyTemplate*)templateAtIndex:(int)index;
-(ArthroplastyTemplate*)selectedTemplate;
-(NSString*)pdfPathForTemplateAtIndex:(int)index;

-(void)setPDFDocument:(id)sender;

-(IBAction)setViewDirection:(id)sender;
-(IBAction)flipLeftRight:(id)sender;

-(void)templateDragged:(NSNotification *)notification;
-(void)draggedOperation:(id<NSDraggingInfo>)operation onDestination:(id)destination;

-(NSRect)boundingBoxOfImage:(NSImage*)image withBackgroundColor:(NSColor*)backgroundColor;
-(NSRect)addMargin:(int)pixels toRect:(NSRect)rect;

-(NSString*)nameForTemplateAtIndex:(int)index;
-(NSArray*)textualDataForTemplateAtIndex:(int)index;

@end
