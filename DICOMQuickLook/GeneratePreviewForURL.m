#import <Cocoa/Cocoa.h>
#import <CoreFoundation/CoreFoundation.h>
#import <CoreServices/CoreServices.h>
#import <QuickLook/QuickLook.h>
#import "DCMPix.h"

OSStatus GeneratePreviewForURL(void *thisInterface, QLPreviewRequestRef preview, CFURLRef url, CFStringRef contentTypeUTI, CFDictionaryRef options)
{
	NSAutoreleasePool* pool = [[NSAutoreleasePool alloc] init];
	
	NSLog( @"*** GENERATE - Preview");
	
	NSURL *nsurl = (NSURL*) url;

	DCMPix	*pix = [[DCMPix alloc] myinit:[nsurl path] :0 :1 :0L :0 :0];
	[pix CheckLoad];
	[pix changeWLWW:[pix savedWL] :[pix savedWW]];
	NSImage *image = [pix image];
	
	NSSize canvasSize = [image size];
	
    CGContextRef cgContext = QLPreviewRequestCreateContext(preview, *(CGSize *)&canvasSize, true, NULL);
    if(cgContext) {
		
        NSGraphicsContext* context = [NSGraphicsContext graphicsContextWithGraphicsPort:(void *)cgContext flipped:YES];
        if(context) {
		   [NSGraphicsContext setCurrentContext: context];
           [image drawAtPoint: NSMakePoint(0, 0) fromRect: NSMakeRect(0, 0, [image size].width, [image size].height) operation:NSCompositeCopy fraction:1.0];
        }
        QLPreviewRequestFlushContext(preview, cgContext);
        CFRelease(cgContext);
    }
	
	[pix release];
	
    [pool release];
	
    return noErr;
}

void CancelPreviewGeneration(void* thisInterface, QLPreviewRequestRef preview)
{
    // implement only if supported
}
