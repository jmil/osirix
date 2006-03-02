/*=========================================================================
  Program:   OsiriX

  Copyright (c) OsiriX Team
  All rights reserved.
  Distributed under GNU - GPL
  
  See http://homepage.mac.com/rossetantoine/osirix/copyright.html for details.

     This software is distributed WITHOUT ANY WARRANTY; without even
     the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR
     PURPOSE.
=========================================================================*/

#import <PreferencePanes/PreferencePanes.h>


@interface OSIListenerPreferencePanePref : NSPreferencePane 
{
	IBOutlet NSForm *aeForm;
	IBOutlet NSMatrix *deleteFileModeMatrix;
	IBOutlet NSButton *listenerOnOffButton;
	IBOutlet NSBox *transferSyntaxBox;
	IBOutlet NSMatrix *transferSyntaxModeMatrix;
	IBOutlet NSMatrix *useStoreSCPModeMatrix;
	IBOutlet NSFormCell *aeTitleField;
	IBOutlet NSFormCell *portField;
	IBOutlet NSFormCell *ipField;
	IBOutlet NSFormCell *nameField;
	IBOutlet NSButton *listenerOnOffAnonymize;
	IBOutlet NSTextField *extrastorescp;
}

- (void) mainViewDidLoad;
- (IBAction)setAE:(id)sender;
- (IBAction)setUseStoreSCP:(id)sender;
- (IBAction)setTransferSyntaxMode:(id)sender;
- (IBAction)setDeleteFileMode:(id)sender;
- (IBAction)setListenerOnOff:(id)sender;
- (IBAction)setAnonymizeListenerOnOff:(id)sender;
- (IBAction)helpstorescp:(id) sender;
- (IBAction)setExtraStoreSCP:(id)sender;
@end
