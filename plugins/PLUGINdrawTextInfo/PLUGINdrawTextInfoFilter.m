//
//  PLUGINdrawTextInfoFilter.m
//  PLUGINdrawTextInfo
//
//  Copyright (c) 2006 opendicom.com. All rights reserved.
//
//  This example can be modified in order to customize the text overlay, based on the information
//  provided in the userInfo dictionary and  whichever other available information.
//  This plugin was made for photographying subtracted angiographic runs coming from a Philips Integris
//  It adds in particular frame and mask time, whether available in multiframe or monoframe files.
//  It adds as well angle and rotation information
//  For now (2006-10-08) this specific information is made available only when a modified version of
//  DCMFramework parser is used.
//  To activate this plugin: enter in a 2D viewer and from the menu 2D viewer, change annotations to "plugin only"
//  you can switch back and forth to any other option of the annotations any time.
//  The original idea of the plugin was learned from Bruce Rakes, who implemented a notification mode of relation
//  between OsiriX and a plugin. The notification carries on all the necesary information within a dictionary, which
//  can contain whatever object. In fact the programs hangs up, if you pass  objects other than copies of string and
//  numbers.
//  If you want to study the functionment of the plugin look at DCMView :
//  (1) the end of the method -drawTextualData:: (which prepares the notification), and
//  (2) -DrawNSStringGLPLUGINonly::: (which draws the comands issued in the plugin)

#import "PLUGINdrawTextInfoFilter.h"

@implementation PLUGINdrawTextInfoFilter

- (void) initPlugin
{
	[[NSNotificationCenter defaultCenter] 
	addObserver:self selector:@selector(PLUGINdrawTextInfoFilter:) 
	name:@"PLUGINdrawTextInfo" object:nil];
	NSLog(@"initialized with observer to notification PLUGINdrawTextInfo");
}

- (void) PLUGINdrawTextInfoFilter:(NSNotification*)note
{
	//- (void) DrawNSStringGLPLUGINonly:(NSString*)str :(long)line :(_Bool)right
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];

	NSDictionary *info = [note userInfo];
	/*
	Dictionary made of the following keys and respective values
			@"SOPclassUID"		NSString
			@"Modality"			NSString 
			@"PatientName"		NSString 
			@"BirthDate"		NSString 
			@"PatientSex"		NSString 
			@"PatientID"		NSString 
			@"FrameTime"		NSNumber float 
			@"MaskTime"			NSNumber float
			@"SeriesTime"		NSString											
			@"StudyDate"		NSString
			@"StudyTime"		NSString
			@"Rot"				NSNumber float
			@"Ang"				NSNumber float
			@"CurFrame"			NSNumber short
			@"CurMask"			NSNumber short
			@"FrameCount"		NSNumber short
			@"SeriesNumber"		NSNumber short
	all available in order to build the fixed frame annotatation
	*/
	
	//Case of Philips SC angiographic, which already contains annotations burned in
	BOOL PhilipsSC = ([[info valueForKey: @"SOPclassUID"] isEqualToString: @"1.2.840.10008.5.1.4.1.1.7"] & [[info valueForKey: @"Modality"] isEqualToString: @"XA"]);
	// ([info count] == 17) => plugin only option.
	//([info count] == 1) => additional information to standard annotation for radiotherapy
	if(([info count] == 17) & (PhilipsSC == FALSE))
	{
		//case plugin only: opening view object in order to draw the annotations with the help of the method
		// - (void) DrawNSStringGLPLUGINonly:(NSString*)str :(long)flor :(_Bool)right
		// where
		// (NSString*)str => one annotation
		// (long)flor	  => its vertical position (1=top, 2=next line from top, 3=bottom, 4=previous line from bottom)
		// (_Bool)right   => its horizontal position (FALSE= left, TRUE=right)
		
		DCMView *view = [note object];
	//LEFT	
		//...TOP DOWN
		[view DrawNSStringGLPLUGINonly:[info valueForKey: @"PatientName"] :1 :FALSE];
		[view DrawNSStringGLPLUGINonly:[NSString stringWithFormat: @"%@  %@",[info valueForKey: @"BirthDate"],[info valueForKey: @"PatientSex"]] :2 :FALSE];
		[view DrawNSStringGLPLUGINonly:[info valueForKey: @"PatientID"] :2 :FALSE];

		//...BOTTOM UP 		
		[view DrawNSStringGLPLUGINonly:[NSString stringWithFormat: @"Imag. +%1.3f", [[info valueForKey: @"FrameTime"] floatValue]] :4 :FALSE];
		[view DrawNSStringGLPLUGINonly:[NSString stringWithFormat: @"Masc. +%1.3f", [[info valueForKey: @"MaskTime"] floatValue]] :3 :FALSE];
		[view DrawNSStringGLPLUGINonly:[info valueForKey: @"SeriesTime"] :3 :FALSE];
		[view DrawNSStringGLPLUGINonly:@"Serie" :3 :FALSE];

	//RIGHT
		//...TOP DOWN				
		[view DrawNSStringGLPLUGINonly: @"CEDIVA URUGUAY" :1 :TRUE];
		[view DrawNSStringGLPLUGINonly:[info valueForKey: @"StudyDate"] :2 :TRUE];
		[view DrawNSStringGLPLUGINonly:[info valueForKey: @"StudyTime"] :2 :TRUE];			
		[view DrawNSStringGLPLUGINonly:[NSString stringWithFormat: @"%1.1f rot", [[info valueForKey: @"Rot"] floatValue]] :2 :TRUE];				
		[view DrawNSStringGLPLUGINonly: [NSString stringWithFormat: @"%1.1f ang", [[info valueForKey: @"Ang"] floatValue]]  :2 :TRUE];				
					
		//...BOTTOM	UP
		[view DrawNSStringGLPLUGINonly :[NSString stringWithFormat: @"Imag. # %d", [[info valueForKey: @"CurFrame"] shortValue]] :4 :TRUE];			
		[view DrawNSStringGLPLUGINonly :[NSString stringWithFormat: @"Masc. # %d", [[info valueForKey: @"CurMask"] shortValue]] :3 :TRUE];		
		[view DrawNSStringGLPLUGINonly:[NSString stringWithFormat: @"[1-%d]", [[info valueForKey: @"FrameCount"] shortValue]] :3 :TRUE];			
		[view DrawNSStringGLPLUGINonly:[NSString stringWithFormat: @"# %@", [info valueForKey: @"SeriesNumber"]] :3 :TRUE];
	}
	[pool release];
}

@end
