//
//  ROIList.mm
//  ROI Enhancement II
//
//  Created by Alessandro Volz on 4/20/09.
//  Copyright 2009 HUG. All rights reserved.
//
 
#import "ROIList.h"
#import <ROI.h>
#import "Interface.h"
#import "Chart.h"
#import <ViewerController.h>
#import <GRLineDataSet.h>
#import <GRAreaDataSet.h>
#import "Options.h"


@implementation ROIRec
@synthesize roi = _roi;
@synthesize menuItem = _menuItem;
@synthesize minDataSet = _minDataSet, meanDataSet = _meanDataSet, maxDataSet = _maxDataSet, minmaxDataSet = _minmaxDataSet;

-(id)init:(ROI*)roi forList:(ROIList*)roiList {
	self = [super init];
	
	_roiList = roiList;
	_roi = [roi retain];
	
	_menuItem = [[NSMenuItem alloc] initWithTitle:[roi name] action:@selector(roiMenuItemSelected:) keyEquivalent:@""];
	[_menuItem setTarget:roiList];
	
	_minDataSet = [[[[_roiList interface] chart] createOwnedLineDataSet] retain];
	[[[_roiList interface] chart] addDataSet:_minDataSet loadData:NO];
	_meanDataSet = [[[[_roiList interface] chart] createOwnedLineDataSet] retain];
	[[[_roiList interface] chart] addDataSet:_meanDataSet loadData:NO];
	_maxDataSet = [[[[_roiList interface] chart] createOwnedLineDataSet] retain];
	[[[_roiList interface] chart] addDataSet:_maxDataSet loadData:NO];
	_minmaxDataSet = [[[[_roiList interface] chart] createOwnedAreaDataSetFrom:_minDataSet to:_maxDataSet] retain];
	[[[_roiList interface] chart] addAreaDataSet:_minmaxDataSet];
	
	[_minDataSet setProperty:[NSNumber numberWithFloat:1] forKey:GRDataSetPlotLineWidth];
	[_maxDataSet setProperty:[NSNumber numberWithFloat:1] forKey:GRDataSetPlotLineWidth];
	
	_displayed = NO; [self setDisplayed:NO];

	return self;
}

-(void)updateDisplayed {
	[_minmaxDataSet setDisplayed: (_displayed && [[[_roiList interface] options] fill])];
	[_minDataSet setProperty:[NSNumber numberWithBool:!(_displayed && [[[_roiList interface] options] min])] forKey:GRDataSetHidden];
	[_meanDataSet setProperty:[NSNumber numberWithBool:!(_displayed && [[[_roiList interface] options] mean])] forKey:GRDataSetHidden];
	[_maxDataSet setProperty:[NSNumber numberWithBool:!(_displayed && [[[_roiList interface] options] max])] forKey:GRDataSetHidden];
}

-(void)setDisplayed:(BOOL)displayed {
	_displayed = displayed;
	[self updateDisplayed];
	[_menuItem setState:displayed? NSOnState : NSOffState];
}

-(BOOL)displayed {
	return _displayed;
}

-(void)dealloc {
	[[[_roiList interface] chart] removeDataSet:_minDataSet];
//	[_minDataSet release];
	[[[_roiList interface] chart] removeDataSet:_meanDataSet];
//	[_meanDataSet release];
	[[[_roiList interface] chart] removeDataSet:_maxDataSet];
//	[_maxDataSet release];
	[[[_roiList interface] chart] removeAreaDataSet:_minmaxDataSet];
	//[_menuItem release];
	//[_roi release];
	[super dealloc];
}

@end


@implementation ROIList
@synthesize interface = _interface;

-(void)awakeFromNib {
	_records = [[NSMutableArray alloc] init];
	
	[self displaySelectedROIs];

	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(roiChange:) name:@"roiChange" object:NULL];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(removeROI:) name:@"removeROI" object:NULL];
}

-(void)loadViewerROIs {
	NSArray* roiSeriesList = [[_interface viewer] roiList];
	for (unsigned i = 0; i < [roiSeriesList count]; ++i) {
		NSArray* roiImageList = [roiSeriesList objectAtIndex:i];
		for (unsigned i = 0; i < [roiImageList count]; ++i)
			[[NSNotificationCenter defaultCenter] postNotificationName:@"roiChange" object:[roiImageList objectAtIndex:i]];
	}
	
	unsigned displayedCount = [self countOfDisplayedROIs];
	if (!displayedCount || displayedCount == [_records count])
		[self displayAllROIs];
}

-(void)dealloc
{
//	[_records release];
	
	[[NSNotificationCenter defaultCenter] removeObserver:self];

	[super dealloc];
}

-(unsigned)countOfDisplayedROIs {
	unsigned count = 0;
	for (unsigned i = 0; i < [_records count]; ++i)
		if ([(ROIRec*)[_records objectAtIndex:i] displayed])
			++count;
	return count;
}

-(ROIRec*)displayedROIRec:(unsigned)index {
	unsigned count = 0;
	for (unsigned i = 0; i < [_records count]; ++i) {
		ROIRec* roiRec = [_records objectAtIndex:i];
		if ([roiRec displayed])
			if (++count == index)
				return roiRec;
	}
	
	return NULL;
}

-(ROIRec*)findRecordByROI:(ROI*)roi {
	for (unsigned i = 0; i < [_records count]; ++i) {
		ROIRec* roiRec = [_records objectAtIndex:i];
		if ([roiRec roi] == roi)
			return roiRec;
	}
	
	return NULL;
}

-(ROIRec*)findRecordByMenuItem:(NSMenuItem*)menuItem {
	for (unsigned i = 0; i < [_records count]; ++i) {
		ROIRec* roiRec = [_records objectAtIndex:i];
		if ([roiRec menuItem] == menuItem)
			return roiRec;
	}
	
	return NULL;
}

-(ROIRec*)findRecordByDataSet:(GRDataSet*)dataSet sel:(ROISel*)sel {
	for (unsigned i = 0; i < [_records count]; ++i) {
		ROIRec* roiRec = [_records objectAtIndex:i];
		if ([roiRec minDataSet] == dataSet)
			{ *sel = ROIMin; return roiRec; }
		if ([roiRec meanDataSet] == dataSet)
			{ *sel = ROIMean; return roiRec; }
		if ([roiRec maxDataSet] == dataSet)
			{ *sel = ROIMax; return roiRec; }
	}
	
	*sel = (ROISel)-1;
	return NULL;
}

-(ROIRec*)findRecordByDataSet:(GRDataSet*)dataSet {
	ROISel sel;
	return [self findRecordByDataSet:dataSet sel:&sel];
}

// check whether the parameter ROI is in this graph's associated viewer
-(BOOL)isInViewer:(ROI*)roi {
	// TODO: check avec Antoine Rosset, est-ce la meilleure methode?
	NSArray* roiSeriesList = [[_interface viewer] roiList];
	for (unsigned i = 0; i < [roiSeriesList count]; ++i) {
		NSArray* roiImageList = [roiSeriesList objectAtIndex:i];
		if ([roiImageList containsObject:roi])
			return YES;
	}
	
	return NO;
}

-(void)roiChange:(NSNotification*)notification
{
	ROI* roi = [notification object];
	// if not in our viewer, ignore
	if (![self isInViewer:roi])
		return;
	
	// if it doesn't have a surface, then we're not interested in it // TODO: a better way to distinguish between interesting ROIs?
	if (![roi roiArea])
		return;
	
	ROIRec* roiRec = [self findRecordByROI:roi];
	if (!roiRec) { // not in list
		// create record, store it in the list, add its menu item to the menu
		roiRec = [[ROIRec alloc] init:roi forList:self];
		[_menu addItem:[roiRec menuItem]];
		[_records addObject:roiRec];
		// display if in mode "display all" - mode "display selected" is handled later
		[roiRec setDisplayed:_display_all];
//		[roiRec release];
		// the separator between menus must be shown, as there are ROIs in the list
		[_separator setHidden:NO];
	}
	
	// update name if necessary
	if (![[[roiRec menuItem] title] isEqualToString:[roi name]]) // if name has changed, update menu
		[[roiRec menuItem] setTitle:[roi name]];
	
	// handle selection changes
	if (_display_selected) {
		BOOL should_display = roi.ROImode == ROI_selected;
		if (should_display != [roiRec displayed])
			[roiRec setDisplayed:should_display];
	}
	
	[[_interface chart] refresh:roiRec];
}

-(void)removeROI:(NSNotification*)notification {
	ROI* roi = [notification object];

	ROIRec* roiRec = [self findRecordByROI:roi];
	// if it's not in our list, ignore it
	if (!roiRec)
		return;

	// it is in our list, remove the menu item
	[_menu removeItem:[roiRec menuItem]];
	
	// if it is displayed, hide it
	if ([roiRec displayed])
		[roiRec setDisplayed:NO];

	// remove from list
	[_records removeObject:roiRec];
	
	// might need to hide the separator between menus
	[_separator setHidden:[_records count] == 0];

	[[_interface chart] setNeedsDisplay:YES];
}

-(void)setButtonTitle:(NSString*)title {
	[_button setTitle:[NSString stringWithFormat:@"Display: %@", title]];
}

-(void)displayAllROIs {
	[_all setState:_display_all = YES];
	[_selected setState:_display_selected = NO];
	[_checked setState:_display_checked = NO];
	[self setButtonTitle:[_all title]];
	
	for (unsigned i = 0; i < [_records count]; ++i) {
		ROIRec* roiRec = [_records objectAtIndex:i];
		[roiRec setDisplayed:YES];
	}
}

-(void)displayAllROIs:(id)sender {
	[self displayAllROIs];
}

-(void)displaySelectedROIs {
	[_all setState:_display_all = NO];
	[_selected setState:_display_selected = YES];
	[_checked setState:_display_checked = NO];
	[self setButtonTitle:[_selected title]];
	
	for (unsigned i = 0; i < [_records count]; ++i) {
		ROIRec* roiRec = [_records objectAtIndex:i];
		[roiRec setDisplayed:[roiRec roi].ROImode == ROI_selected];
	}
}

-(void)displaySelectedROIs:(id)sender {
	[self displaySelectedROIs];
}

-(void)displayCheckedROIs {
	[_all setState:_display_all = NO];
	[_selected setState:_display_selected = NO];
	[_checked setState:_display_checked = YES];
	
	unsigned displayedCount = 0;
	ROIRec* firstDisplayed = NULL;
	for (unsigned i = 0; i < [_records count]; ++i){
		ROIRec* roiRec = [_records objectAtIndex:i];
		
		BOOL displayed = [roiRec displayed];
		[roiRec setDisplayed:displayed];
		
		if (displayed) {
			++displayedCount;
			if (!firstDisplayed)
				firstDisplayed = roiRec;
		}
	}
	
	[self setButtonTitle:displayedCount == 1 ? [[firstDisplayed menuItem] title] : [_checked title]];
}

-(void)displayCheckedROIs:(id)sender {
	[self displayCheckedROIs];
}

-(void)roiMenuItemSelected:(id)sender {
	ROIRec* roiRec = [self findRecordByMenuItem:sender];
	[roiRec setDisplayed:![roiRec displayed]];
	[self displayCheckedROIs];
}

-(void)changedMin:(BOOL)min mean:(BOOL)mean max:(BOOL)max fill:(BOOL)fill {
	for (unsigned i = 0; i < [_records count]; ++i){
		ROIRec* roiRec = [_records objectAtIndex:i];
		[roiRec updateDisplayed];
	}
}

@end
	
	
	
