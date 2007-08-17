#import <Cocoa/Cocoa.h>
#import <CoreFoundation/CoreFoundation.h>
#import <CoreServices/CoreServices.h>
#import <QuickLook/QuickLook.h>
#import "DCMPix.h"

static PapyInitDone = NO;

OSStatus GenerateThumbnailForURL(void *thisInterface, QLThumbnailRequestRef thumbnail, CFURLRef url, CFStringRef contentTypeUTI, CFDictionaryRef options, CGSize maxSize)
{
	NSAutoreleasePool* pool = [[NSAutoreleasePool alloc] init];
	
	if( PapyInitDone == NO)
	{
		PapyInitDone = YES;
		Papy3Init();
	}
	
	NSURL *nsurl = (NSURL*) url;
	
	DCMPix	*pix = [[DCMPix alloc] myinit:[nsurl path] :0 :1 :0L :0 :0];
	[pix CheckLoad];
	[pix changeWLWW:[pix savedWL] :[pix savedWW]];
	NSImage *image = [pix computeWImage:YES :[pix savedWW] :[pix savedWL]];
	
	NSSize canvasSize = [image size];
 
    CGContextRef cgContext = QLThumbnailRequestCreateContext(thumbnail, *(CGSize *)&canvasSize, true, NULL);
    if(cgContext) {
        NSGraphicsContext* context = [NSGraphicsContext graphicsContextWithGraphicsPort:(void *)cgContext flipped:YES];
        if(context) {
			[NSGraphicsContext setCurrentContext: context];
            [image drawAtPoint: NSMakePoint(0, 0) fromRect: NSMakeRect(0, 0, [image size].width, [image size].height) operation:NSCompositeCopy fraction:1.0];
			
			NSString	*test = [NSString stringWithString:@"Hello"];
			[test drawAtPoint: NSMakePoint(10, 10) withAttributes:0L];
        }
        QLThumbnailRequestFlushContext(thumbnail, cgContext);
        CFRelease(cgContext);
    }
	
	[pix release];
    [pool release];
	
    return noErr;
}

void CancelThumbnailGeneration(void* thisInterface, QLThumbnailRequestRef thumbnail)
{
    // implement only if supported
}