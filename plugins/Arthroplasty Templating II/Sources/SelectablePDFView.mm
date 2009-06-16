//
//  SelectablePDFView.m
//  Arthroplasty Templating II
//
//  Created by Alessandro Volz on 6/8/09.
//  Copyright 2009 HUG. All rights reserved.
//

#import "SelectablePDFView.h"
#import "NSImage+ArthroplastyTemplating.h"
#import "ArthroplastyTemplatingWindowController.h"
#include <algorithm>
#include <cmath>

CGFloat NSDistance(NSPoint p1, NSPoint p2) {
	return std::sqrt(std::pow(p1.x-p2.x, 2)+std::pow(p1.y-p2.y, 2));
}

@implementation SelectablePDFView

-(void)awakeFromNib {
	[self setMenu:NULL];
}

-(NSPoint)convertPointTo01:(NSPoint)point forPage:(PDFPage*)page {
	NSRect box = [page boundsForBox:kPDFDisplayBoxMediaBox];
	return NSMakePoint([_controller flipTemplatesHorizontally]? 1-point.x/box.size.width : point.x/box.size.width, point.y/box.size.height);
}

-(NSPoint)convertPointFrom01:(NSPoint)point forPage:(PDFPage*)page {
	NSRect box = [page boundsForBox:kPDFDisplayBoxMediaBox];
	return NSMakePoint(box.origin.x+point.x*box.size.width,
					   box.origin.y+point.y*box.size.height);
}

-(NSRect)convertRectFrom01:(NSRect)rect forPage:(PDFPage*)page {
	NSRect box = [page boundsForBox:kPDFDisplayBoxMediaBox];
	return NSMakeRect(box.origin.x+rect.origin.x*box.size.width,
					  box.origin.y+rect.origin.y*box.size.height,
					  rect.size.width*box.size.width,
					  rect.size.height*box.size.height);
}

-(BOOL)performKeyEquivalent:(NSEvent *)theEvent {
	return NO;
}

-(void)mouseDown:(NSEvent*)event {
	_selectionInitiated = NO;
	_mouseDownLocation = [event locationInWindow];
	if ([event modifierFlags]&NSCommandKeyMask) {
		_selected = NO;
		if ([event clickCount] == 1) {
			_selectionInitiated = YES;
			_selectedRect.origin = [self convertPointTo01: [self convertPoint:[self convertPoint:[event locationInWindow] fromView:NULL] toPage:[self currentPage]] forPage:[self currentPage]];
			_selectedRect.size = NSMakeSize(0, 0);
		}
	}
	
	[self setNeedsDisplay:YES];
}

-(void)mouseDragged:(NSEvent*)event {
	if (_selectionInitiated) {
		_selected = YES;
		NSPoint position = [self convertPointTo01: [self convertPoint:[self convertPoint:[event locationInWindow] fromView:NULL] toPage:[self currentPage]] forPage:[self currentPage]];
		_selectedRect.size = NSMakeSize(position.x-_selectedRect.origin.x, position.y-_selectedRect.origin.y);
		[self setNeedsDisplay:YES];
	} else
		if (NSDistance(_mouseDownLocation, [event locationInWindow]) > 5)
			[_controller dragTemplate:[_controller currentTemplate] startedByEvent:event onView:self];
}

-(void)enhanceSelection {
/*	ATImage* image = [[ATImage alloc] initWithContentsOfFile:[[[self document] documentURL] path]];
	
	NSSize size = [image size];
	NSRect sel = _selectedRect;
	sel = NSMakeRect(std::floor(sel.origin.x*size.width), std::floor(sel.origin.y*size.height), std::ceil(sel.size.width*size.width), std::ceil(sel.size.height*size.height));
	
	sel = [image boundingBoxSkippingColor:[NSColor colorWithCalibratedRed:0 green:0 blue:0 alpha:0] inRect:sel];
	
	sel = NSMakeRect(sel.origin.x/size.width, sel.origin.y/size.height, sel.size.width/size.width, sel.size.height/size.height);

 	const static float margin = 0.01; // %
	sel.origin.x -= margin; sel.origin.y -= margin;
	sel.size.width += margin*2; sel.size.height += margin*2;
	
	_selectedRect = sel;*/
}

-(void)mouseUp:(NSEvent*)event {
	if (_selectionInitiated)
		if (_selected) {
			[self enhanceSelection];
			[_controller setSelectionForCurrentTemplate:_selectedRect];
			[self setNeedsDisplay:YES];
		} else [_controller setSelectionForCurrentTemplate:NSMakeRect(0,0,1,1)];
}

-(void)setDocument:(PDFDocument*)document {
	[super setDocument:document];
	_selected = [_controller selectionForCurrentTemplate:&_selectedRect];
}

-(void)drawPage:(PDFPage*)page {
	NSGraphicsContext* context = [NSGraphicsContext currentContext];
	[context saveGraphicsState];
	NSRect box = [page boundsForBox:kPDFDisplayBoxMediaBox];

	if ([_controller flipTemplatesHorizontally]) {
		NSAffineTransform* transform = [NSAffineTransform transform];
		[transform translateXBy:box.size.width yBy:0];
		[transform scaleXBy:-1 yBy:1];
		[transform concat];
	}	
	
	[super drawPage:page];
	
	if (!_selected) return;
	if (_selectedRect.origin.x == 0 && _selectedRect.origin.y == 0 && _selectedRect.size.width == 1 && _selectedRect.size.height == 1) return;
	
	NSRect selection = [self convertRectFrom01:_selectedRect forPage:[self currentPage]];
	
	NSBezierPath* path = [NSBezierPath bezierPath];
	[path appendBezierPathWithRect:box];
	[path setWindingRule:NSEvenOddWindingRule];
	[path appendBezierPathWithRect:selection];
	[[[NSColor grayColor] colorWithAlphaComponent:.75] setFill];
	[path fill];
	
	[context restoreGraphicsState];
}

@end
