/*=========================================================================
CMIV_CTA_TOOLS.h

CMIV_CTA_TOOLS is the main entry of this plugin, which handle the
"plugins" menu action and invoke corresponding windows.

The menu item and corresponding classes are listed as following:
menu text                       class name
---------------------------------------------------------------
VOI Cutter                      CMIVChopperController
MathMorph Tool                  CMIVSpoonController
2D Views                        CMIVScissorsController
Interactive Segmentation        CMIVContrastController
Segmental VR                    CMIVVRcontroller
Save Results                    CMIVSaveResult
Wizard For Coronary CTA         invoke CMIVChopperController,
                                CMIVScissorsController,
                                CMIVContrastPreview,
                                CMIVScissorsController in turn

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


#import <Foundation/Foundation.h>
#import "PluginFilter.h"

@interface CMIV_CTA_TOOLS : PluginFilter {
	
	IBOutlet NSWindow	*window;
	NSMutableDictionary* dataOfWizard;
	NSObject* currentController;

}
- (IBAction)closeAboutDlg:(id)sender;
- (IBAction)openCMIVWebSite:(id)sender;
- (IBAction)mailToAuthors:(id)sender;
- (long) filterImage:(NSString*) menuName;
- (int)  startChopper:(ViewerController *) vc;
- (int)  startSpoon:(ViewerController *) vc;
- (int)  startScissors:(ViewerController *) vc;
- (int)  startContrast:(ViewerController *) vc;
- (int)  startVR:(ViewerController *) vc;
- (int)  saveResult:(ViewerController *) vc;
- (void) gotoStepNo:(int)stage;
- (NSMutableDictionary*) dataOfWizard;
- (void) setDataofWizard:(NSMutableDictionary*) dic;
- (void) cleanDataOfWizard;
- (void) exitCurrentDialog;
- (void) showAboutDlg;
- (int)  startAutomaticSeeding:(ViewerController *) vc;
@end
