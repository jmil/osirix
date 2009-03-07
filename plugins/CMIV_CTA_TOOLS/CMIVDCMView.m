//
//  CMIVDCMView.m
//  CMIV_CTA_TOOLS
//
//  Created by chuwa on 12/14/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import "CMIVDCMView.h"


@implementation CMIVDCMView

- (id) windowController
{
	return dcmViewWindowController;
}
- (BOOL) is2DViewer
{

//	[super is2DViewer];
	return NO;
}
-(void)setDcmViewWindowController:(id)vc
{
	dcmViewWindowController=vc;
}
-(void)setTranlateSlider:(NSSlider*) aSlider
{
	tranlateSlider=aSlider;
}
-(void)setHorizontalSlider:(NSSlider*) aSlider
{
	horizontalSlider=aSlider;
}
- (void)scrollWheel:(NSEvent *)theEvent
{
	[super scrollWheel:theEvent];
	CGFloat x,y;
	float loc;
	float acceleratefactor=0.1;
	if(tranlateSlider!=nil)
	{
		if([theEvent modifierFlags] & NSCommandKeyMask )
			y=[theEvent deltaX];
		else
			y=[theEvent deltaY];
		if(y!=0)
		{
			if(y>0)
				y=(y-0.1)*acceleratefactor+0.1;
			else 
				y=(y+0.1)*acceleratefactor-0.1;
			loc=[tranlateSlider floatValue];
			loc+=y*10;
			while(loc>[tranlateSlider maxValue])
				loc-=([tranlateSlider maxValue]-[tranlateSlider minValue]);
			while(loc<[tranlateSlider minValue])
				loc+=([tranlateSlider maxValue]-[tranlateSlider minValue]);
			[tranlateSlider setFloatValue:loc];
			[tranlateSlider performClick:self];
		}
		
		
	}
	if(horizontalSlider!=nil)
	{
		if([theEvent modifierFlags] & NSCommandKeyMask )
			x=[theEvent deltaY];
		else
			x=[theEvent deltaX];
		if(x!=0)
		{
			if(x>0)
				x=(x-0.1)*acceleratefactor+0.1;
			else 
				x=(x+0.1)*acceleratefactor-0.1;
			loc=[horizontalSlider floatValue];
			loc-=x*10;
			while(loc>[horizontalSlider maxValue])
				loc-=([horizontalSlider maxValue]-[horizontalSlider minValue]);
			while(loc<[horizontalSlider minValue])
				loc+=([horizontalSlider maxValue]-[horizontalSlider minValue]);
			
			[horizontalSlider setFloatValue:loc];
			[horizontalSlider performClick:self];
		}

	}
	if(tranlateSlider==nil&&horizontalSlider==nil)
		[[self nextResponder] scrollWheel:theEvent];
}
- (void)mouseDown:(NSEvent *)theEvent
{
	[[NSNotificationCenter defaultCenter] postNotificationName: @"cmivCTAViewMouseDown" object:self userInfo: [NSDictionary dictionaryWithObject:@"mouseDown" forKey:@"action"]];
	[super mouseDown:theEvent];
}
- (void)mouseUp:(NSEvent *)theEvent
{
	[[NSNotificationCenter defaultCenter] postNotificationName: @"cmivCTAViewMouseUp" object:self userInfo: [NSDictionary dictionaryWithObject:@"mouseUp" forKey:@"action"]];
	[super mouseUp:theEvent];
}
- (void)keyDown:(NSEvent *)event
{
	unsigned short i=[event keyCode];
	if((i>=123&&i<=126)||i==121||i==116)//arrows and pageup&down
	{
		float x=0,y=0;
		float loc;
		float acceleratefactor=1.0;
		if(tranlateSlider!=nil)
		{
			if([event modifierFlags] &  NSAlternateKeyMask)
				acceleratefactor=10.0;
				
			if( i==121)
				y=1;
			else if(i==116)
				y=-1;
			if(y!=0)
			{
				loc=[tranlateSlider floatValue];
				loc+=y*acceleratefactor;
				while(loc>[tranlateSlider maxValue])
					loc-=([tranlateSlider maxValue]-[tranlateSlider minValue]);
				while(loc<[tranlateSlider minValue])
					loc+=([tranlateSlider maxValue]-[tranlateSlider minValue]);
				[tranlateSlider setFloatValue:loc];
				[tranlateSlider performClick:self];
			}
			
			
		}
		if(horizontalSlider!=nil)
		{
			if(i==124)
			{
				x=1;
			}
			else if(i==123)
			{
				x=-1;
				
			}
			if(x!=0)
			{
	
				loc=[horizontalSlider floatValue];
				loc+=x*acceleratefactor;
				while(loc>[horizontalSlider maxValue])
					loc-=([horizontalSlider maxValue]-[horizontalSlider minValue]);
				while(loc<[horizontalSlider minValue])
					loc+=([horizontalSlider maxValue]-[horizontalSlider minValue]);
				
				[horizontalSlider setFloatValue:loc];
				[horizontalSlider performClick:self];
			}
			
		}
		if(tranlateSlider==nil&&horizontalSlider==nil)
			[[self nextResponder] keyDown:event];
	}
	else
		[super keyDown:event];
}
@end
