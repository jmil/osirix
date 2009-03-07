//
//  CMIVDCMView.h
//  CMIV_CTA_TOOLS
//
//  Created by chuwa on 12/14/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "DCMView.h"	

@interface CMIVDCMView : DCMView {
	NSSlider* tranlateSlider;
	NSSlider* horizontalSlider;
	id dcmViewWindowController;
	
}

-(void)setTranlateSlider:(NSSlider*) aSlider;
-(void)setHorizontalSlider:(NSSlider*) aSlider;
-(void)setDcmViewWindowController:(id)vc;
@end
