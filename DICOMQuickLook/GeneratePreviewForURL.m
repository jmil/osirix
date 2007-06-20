#import <Cocoa/Cocoa.h>
#import <CoreFoundation/CoreFoundation.h>
#import <CoreServices/CoreServices.h>
#import <QuickLook/QuickLook.h>
#import <OsiriX/DCM.h>

OSStatus GeneratePreviewForURL(void *thisInterface, QLPreviewRequestRef preview, CFURLRef url, CFStringRef contentTypeUTI, CFDictionaryRef options)
{
	NSAutoreleasePool* pool = [[NSAutoreleasePool alloc] init];
 
	DCMObject *dcmObject;
	NSURL *nsurl = (NSURL*) url;
	
	dcmObject = [DCMObject objectWithContentsOfFile: [nsurl path] decodingPixelData:YES];
	
	DCMPixelDataAttribute *pixelAttr = (DCMPixelDataAttribute *)[dcmObject attributeWithName:@"PixelData"];
	
	NSImage *image = [pixelAttr imageAtIndex: 0 ww: 0 wl: 0];
	NSSize canvasSize = [image size];
 
    // Preview will be drawn in a vectorized context
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
    [pool release];
	
    return noErr;
}

void CancelPreviewGeneration(void* thisInterface, QLPreviewRequestRef preview)
{
    // implement only if supported
}
