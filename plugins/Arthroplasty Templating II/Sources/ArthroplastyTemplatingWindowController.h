//
//  ArthroplastyTemplatingWindowController.h
//  Arthroplasty Templating II
//  Created by Joris Heuberger on 04/04/07.
//  Copyright (c) 2007-2009 OsiriX Team. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "SelectablePDFView.h"
#import "ArthroplastyTemplate.h"

@class ArthroplastyTemplatingTableView, ATImage, ROI, ViewerController;
@class ArthroplastyTemplateFamily, ArthroplastyTemplatingPlugin;
#import "ArthroplastyTemplatingUserDefaults.h"

@interface ArthroplastyTemplatingWindowController : NSWindowController {
	NSMutableArray* _templates;
	ArthroplastyTemplatingPlugin* _plugin;

	NSArrayController* _familiesArrayController;
	IBOutlet ArthroplastyTemplatingTableView* _familiesTableView;
	
	IBOutlet SelectablePDFView* _pdfView;
	IBOutlet NSPopUpButton* _sizes;
	IBOutlet NSButton* _shouldTransformColor;
	IBOutlet NSColorWell* _transformColor;
	IBOutlet NSSearchField* _searchField;
	ArthroplastyTemplateViewDirection _viewDirection;
	BOOL _flipTemplatesHorizontally;
	IBOutlet NSButton* _flipTemplatesHorizontallyButton;
	
	ArthroplastyTemplatingUserDefaults* _userDefaults;
	NSDictionary* _presets;
}

@property(readonly) BOOL flipTemplatesHorizontally;
@property(readonly) ArthroplastyTemplatingUserDefaults* userDefaults;
@property(readonly) ArthroplastyTemplatingPlugin* plugin;

-(id)initWithPlugin:(ArthroplastyTemplatingPlugin*)plugin;
-(void)loadTemplates;
-(ArthroplastyTemplate*)templateAtPath:(NSString*)path;
-(ArthroplastyTemplate*)currentTemplate;
-(ArthroplastyTemplateFamily*)familyAtIndex:(int)index;
-(ArthroplastyTemplateFamily*)selectedFamily;
-(NSString*)pdfPathForFamilyAtIndex:(int)index;
-(ATImage*)dragImageForTemplate:(ArthroplastyTemplate*)templat;
-(IBAction)searchFilterChanged:(id)sender;
-(BOOL)setFilter:(NSString*)string;

-(void)setFamily:(id)sender;

-(IBAction)setViewDirection:(id)sender;
-(IBAction)flipLeftRight:(id)sender;

-(ROI*)createROIFromTemplate:(ArthroplastyTemplate*)templat inViewer:(ViewerController*)destination centeredAt:(NSPoint)p;
-(void)dragTemplate:(ArthroplastyTemplate*)templat startedByEvent:(NSEvent*)event onView:(NSView*)view;

-(NSRect)addMargin:(int)pixels toRect:(NSRect)rect;

-(BOOL)selectionForCurrentTemplate:(NSRect*)rect;
-(void)setSelectionForCurrentTemplate:(NSRect)rect;

@end
