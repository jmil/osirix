/*=========================================================================
Author: Chunliang Wang (chunliang.wang@imv.liu.se)


Program:  CMIV CTA image processing Plugin for OsiriX

This file is part of CMIV CTA image processing Plugin for OsiriX.

Copyright (c) 2007,
Center for Medical Image Science and Visualization (CMIV),
Linköping University, Sweden, http://www.cmiv.liu.se/

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

#import "CMIVSaveResult.h"
#import "CMIVExport.h"
#define VERBOSEMODE


@implementation CMIVSaveResult

- (IBAction)onCancel:(id)sender
{
	[window setReleasedWhenClosed:YES];
	[window close];
	if(waitWindow)
		[originalViewController endWaitWindow: waitWindow];
	if(databaseUpdateTimer)
	{
		[databaseUpdateTimer invalidate];
		[databaseUpdateTimer release];
		databaseUpdateTimer=nil;
	}
    [NSApp endSheet:window returnCode:[sender tag]];
	[parent exitCurrentDialog];
}

- (IBAction)onSave:(id)sender
{
#ifdef VERBOSEMODE
	NSLog( @"**********Start Exporting Data************");
#endif
	
	[self findPreviewMatrix];
	CMIVExport *exporter=[[CMIVExport alloc] init];
	[exporter setSeriesDescription: [seriesName stringValue]];
	if([seriesNumber intValue]<=0)
		[exporter setSeriesNumber:6600 + [[NSCalendarDate date] minuteOfHour] + [[NSCalendarDate date] secondOfMinute]];
	else
		[exporter setSeriesNumber:[seriesNumber intValue]];
	[exporter exportCurrentSeries: originalViewController];
	exportSeriesUID=[[exporter exportSeriesUID] retain];
	[exporter release];	
#ifdef VERBOSEMODE
	NSString* strwarning=[NSString stringWithString: @"**********Waiting OsiriX read Data************"];
	strwarning=[strwarning stringByAppendingString:exportSeriesUID];
	NSLog(strwarning);
#endif
	waitWindow = [originalViewController startWaitWindow:@"database updating..."];
	databaseUpdateTimer = [[NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(openNewCreatedSeries:) userInfo:self repeats:YES] retain];
	[okButton setEnabled: NO];
	//[self onCancel:nil];
}
- (id) showSaveResultPanel:(ViewerController *) vc:(CMIV_CTA_TOOLS*) owner
{

	originalViewController=vc;	
	parent = owner;


	[NSBundle loadNibNamed:@"Save_Panel" owner:self];
	[seriesName setStringValue:[[originalViewController window] title]];
	[NSApp beginSheet: window modalForWindow:[originalViewController window] modalDelegate:self didEndSelector:nil contextInfo:nil];
	//[window makeKeyAndOrderFront:nil];
	return self;
}
- (void)findPreviewMatrix
{
	NSWindow* vcWin=[originalViewController window];
	NSResponder * tempresponer=[vcWin firstResponder];
	while(![tempresponer isKindOfClass:[NSSplitView class]]&&tempresponer!=nil)
	{
		tempresponer=[tempresponer nextResponder];
	}
	if(tempresponer)
	{
		NSView* tempview=(NSView*)tempresponer;
		NSArray* temparray=[tempview subviews];
		tempview=[temparray objectAtIndex: 0];
		temparray=[tempview subviews];
		tempview=[temparray objectAtIndex: 0];
		temparray=[tempview subviews];
		tempview=[temparray objectAtIndex: 0];
		if([tempview isKindOfClass:[NSMatrix class]])
			previewMatrix=(NSMatrix*)tempview;
		else
			previewMatrix=nil;
	}
	else
		previewMatrix=nil;
	if(previewMatrix)
		seriesBefore=[previewMatrix numberOfRows];
	
}
- (void)openNewCreatedSeries:(id) sender
{
	unsigned int i;
	BOOL isUpdated=NO;

	if([previewMatrix numberOfRows]>seriesBefore)
	{
		isUpdated=YES;
		
	}

	if(isUpdated)
	{
		[databaseUpdateTimer invalidate];
		[databaseUpdateTimer release];
		databaseUpdateTimer=nil;
		isUpdated=NO;
		for(i=1;i<[previewMatrix numberOfRows];i++)
		{
			NSManagedObject	*curSeries=nil;
			id tempid= [[previewMatrix cellAtRow: i column:0] representedObject];
			NSButtonCell *cell = [previewMatrix cellAtRow: i column:0];
			if([cell image]!=nil)
				if([tempid isKindOfClass:[NSManagedObject class]])
					curSeries=tempid;
			if(curSeries)
			{
				NSString* curSeriesUID=[curSeries primitiveValueForKey:@"seriesDICOMUID"];
				
#ifdef VERBOSEMODE
				NSLog(curSeriesUID);
#endif
				if(curSeriesUID&&[curSeriesUID isEqualToString: exportSeriesUID])
				{	

					[originalViewController endWaitWindow: waitWindow];
					waitWindow = [originalViewController startWaitWindow:@"loading new series..."];
					NSMutableArray* roilist=[NSMutableArray arrayWithCapacity:0];
					if([needSaveROI state]== NSOnState)
						[self backupROIs:roilist];
					[previewMatrix selectCellAtRow:i column:0];
					[originalViewController matrixPreviewPressed:previewMatrix];
					if([needSaveROI state]== NSOnState)
						[self restoreROIs:roilist];
					i=[previewMatrix numberOfRows];
					isUpdated=YES;
					

				}
			}
			
		}
		if(!isUpdated)
		{
			NSRunAlertPanel(NSLocalizedString(@"Loading new series failed", nil), NSLocalizedString(@"DICOM have been exported, ROIs will be lost.Try restart OsiriX.", nil), NSLocalizedString(@"OK", nil), nil, nil);
#ifdef VERBOSEMODE
			NSString* strwarning=[NSString stringWithFormat: @"searched %d to %d series",[previewMatrix numberOfRows],seriesBefore];
			NSLog(strwarning);
#endif
		}
		[self onCancel:nil];
		
	}
	else
	{
		checkTime++;
		if(checkTime>3*[[NSUserDefaults standardUserDefaults] integerForKey:@"LISTENERCHECKINTERVAL"])
		{
			[databaseUpdateTimer invalidate];
			[databaseUpdateTimer release];
			databaseUpdateTimer=nil;
			NSRunAlertPanel(NSLocalizedString(@"Database update failed", nil), NSLocalizedString(@"DICOM might be exported, ROIs will be lost.Try restart OsiriX.", nil), NSLocalizedString(@"OK", nil), nil, nil);
#ifdef VERBOSEMODE
			NSString* strwarning=[NSString stringWithFormat: @"timeout after %d s to %d s",checkTime,[[NSUserDefaults standardUserDefaults] integerForKey:@"LISTENERCHECKINTERVAL"]];
			NSLog(strwarning);
#endif
			
			[self onCancel:nil];

		}
	}
	;
}
-(void)backupROIs:(NSMutableArray*)roilist
{
	NSMutableArray* controllorROIList = [originalViewController roiList];
	unsigned int i;
	for(i=0;i<[controllorROIList count];i++)
	{
		[roilist  addObject:[NSMutableArray arrayWithCapacity:0]];
		[[roilist objectAtIndex:i] addObjectsFromArray:[controllorROIList objectAtIndex: i]];
	}
	
}
-(void)restoreROIs:(NSMutableArray*)roilist
{
	NSMutableArray* controllorROIList = [originalViewController roiList];
	unsigned int i;
	for(i=0;i<[controllorROIList count];i++)
	{
		[[controllorROIList objectAtIndex: i] addObjectsFromArray:[roilist objectAtIndex:i]];
	}
	
	for(i=0;i<[roilist count];i++)
	{
		[[roilist objectAtIndex: i] removeAllObjects];
	}
	[roilist removeAllObjects];
}
@end
