/*=========================================================================
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

#import "CMIV_CTA_TOOLS.h"
#import "CMIVChopperController.h"
#import "CMIVSpoonController.h"
#import "CMIVContrastController.h"
#import "CMIVVRcontroller.h"
#import "CMIVScissorsController.h"
#import "CMIVContrastPreview.h"
#import "CMIVSaveResult.h"

@implementation CMIV_CTA_TOOLS

- (void) initPlugin
{
	
}


- (long) filterImage:(NSString*) menuName
{
	if(currentController)
		[currentController release];
	currentController=nil;
	int err=0;
	if( [menuName isEqualToString:NSLocalizedString(@"Wizard For Coronary CTA", nil)] == YES)
		[self gotoStepNo:1 ];
	else if( [menuName isEqualToString:NSLocalizedString(@"VOI Cutter", nil)] == YES)
		err = [self startChopper:viewerController];
	else if ( [menuName isEqualToString:NSLocalizedString(@"MathMorph Tool", nil)] == YES)
		err = [self startSpoon:viewerController];
	else if ( [menuName isEqualToString:NSLocalizedString(@"2D Views", nil)] == YES)
		err = [self startScissors:viewerController];	
	else if ( [menuName isEqualToString:NSLocalizedString(@"Interactive Segmentation", nil)] == YES)
		err = [self startContrast:viewerController];	
	else if ( [menuName isEqualToString:NSLocalizedString(@"Segmental VR", nil)] == YES)
		err = [self startVR:viewerController];
	else if ( [menuName isEqualToString:NSLocalizedString(@"Save Results", nil)] == YES)
		err = [self saveResult:viewerController];
	else
		[self showAboutDlg];
	return err;
}



- (int)  startChopper:(ViewerController *) vc
{
	int err=0;
	CMIVChopperController* chopperController=[[CMIVChopperController alloc] init] ;
	err=[chopperController showChopperPanel:vc:self];
	currentController=chopperController;
	return err;
}


- (int)  startSpoon:(ViewerController *) vc
{
	int err=0;
	CMIVSpoonController* spoonController=[[CMIVSpoonController alloc] init];
	err=[spoonController showSpoonPanel:vc:self];
	if(!err)
		currentController=spoonController;
	return err;
}


- (int)  startScissors:(ViewerController *) vc
{
	int err=0;
	CMIVScissorsController * scissorsController = [[CMIVScissorsController alloc] init];
	err=[scissorsController showScissorsPanel:vc:self];
	if(!err)
		currentController=scissorsController;
	return err;
	
}


- (int)  startContrast:(ViewerController *) vc
{
	int err=0;
	CMIVContrastController* contrastController = [[CMIVContrastController alloc] init];
	err=[contrastController showContrastPanel:vc:self];
	if(!err)
		currentController=contrastController;
	return err;
	
}


- (int)  startVR:(ViewerController *) vc
{
	int err=0;
	CMIVVRcontroller* vrController = [[CMIVVRcontroller alloc] init];
	err = [vrController showVRPanel:vc:self];
	if(!err)
		currentController=vrController;
	return err;
	
}
- (int)  saveResult:(ViewerController *) vc
{
	int err=0;
	
	CMIVSaveResult *saver=[[CMIVSaveResult alloc] showSaveResultPanel:vc:self];

	
//	CMIVSaveResult *saver=[[CMIVSaveResult alloc] init];
//	err = [saver showSaveResultPanel:vc:self];

	if(!err)
		currentController=saver;
	return err;
}
- (void) gotoStepNo:(int)stage
{


	if(currentController)
		[currentController release];
	currentController=nil;

	if(stage==1)// VOI cutter
	{

		NSLog( @"step 1");

		CMIVChopperController* chopperController=[[CMIVChopperController alloc] init] ;
		[chopperController showPanelAsWizard:viewerController:self];
		currentController=chopperController;
	}
	else if(stage==2)// 2D viewer
	{

		NSLog( @"step 2");

		CMIVScissorsController * scissorsController = [[CMIVScissorsController alloc] init];
		[scissorsController showPanelAsWizard:viewerController:self]; 
		currentController=scissorsController;		
	}
	else if(stage==3) //result preview
	{
		NSLog( @"finish step 3");
		CMIVContrastPreview * previewer = [[CMIVContrastPreview alloc] init];
		[previewer showPanelAsWizard:viewerController:self]; 
		currentController=previewer;
	}
	else if(stage==4) //2D viewer CPR only
	{
		NSLog( @"finish step 4");
		CMIVScissorsController * scissorsController = [[CMIVScissorsController alloc] init];
		[scissorsController showPanelAsCPROnly:viewerController:self]; 
		currentController=scissorsController;
	}
	
}
- (NSMutableDictionary*) dataOfWizard
{
	if(!dataOfWizard)
		dataOfWizard=[[NSMutableDictionary alloc] initWithCapacity: 0];
	return dataOfWizard;
}
- (void) setDataofWizard:(NSMutableDictionary*) dic
{
	dataOfWizard=dic;
	[dic retain];
}
- (void) cleanDataOfWizard
{
	
	if(dataOfWizard)
	{
		NSMutableArray* temparray,*tempnamearray;
		temparray=[dataOfWizard objectForKey:@"SeedList"];
		if(temparray)
			[temparray removeAllObjects];
		temparray =[dataOfWizard objectForKey:@"ShownColorList"];
		if(temparray)
			[temparray removeAllObjects];
		temparray=[dataOfWizard objectForKey:@"ROIList"];
		if(temparray)
			[temparray removeAllObjects];
		temparray=[dataOfWizard objectForKey:@"CenterlinesNameList"];
		if(temparray)
			[temparray removeAllObjects];
		temparray=[dataOfWizard objectForKey:@"CenterlinesList"];
		if(temparray)
		{
			unsigned int i;
			for(i=0;i<[temparray count];i++)
				[[temparray objectAtIndex: i] removeAllObjects];
			[temparray removeAllObjects];	
		}
		temparray=[dataOfWizard objectForKey:@"VCList"];
		tempnamearray=[dataOfWizard objectForKey:@"VCTitleList"];
		if(temparray&&tempnamearray)
		{
			unsigned int i;
			for(i=0;i<[temparray count];i++)
				[[[temparray objectAtIndex: i] window] setTitle:[tempnamearray objectAtIndex: i]];
			[temparray removeAllObjects];
			[tempnamearray removeAllObjects];
		}
		[dataOfWizard removeAllObjects];//list in list shoule be clean separatedly
	}
}
- (void) exitCurrentDialog
{
	if(dataOfWizard)
	{
		[self cleanDataOfWizard];
		[dataOfWizard release];
		dataOfWizard=nil;
	}
	if(currentController)
		[currentController release];
	currentController=nil;
}
- (void) showAboutDlg
{
	[NSBundle loadNibNamed:@"AboutDlg" owner:self];
	[NSApp beginSheet: window modalForWindow:[NSApp keyWindow] modalDelegate:self didEndSelector:nil contextInfo:nil];
}
- (IBAction)closeAboutDlg:(id)sender
{
	[window setReleasedWhenClosed:YES];
	[window close];
    [NSApp endSheet:window returnCode:[sender tag]];
}
- (IBAction)openCMIVWebSite:(id)sender
{
	[[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:@"http://www.cmiv.liu.se/"]];
}
- (IBAction)mailToAuthors:(id)sender
{
	[[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:@"mailto:chunliang.wang@imv.liu.se,orjan.smedby@cmiv.liu.se"]]; 
}
@end
