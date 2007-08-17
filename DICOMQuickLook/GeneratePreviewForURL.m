#import <Cocoa/Cocoa.h>
#import <CoreFoundation/CoreFoundation.h>
#import <CoreServices/CoreServices.h>
#import <QuickLook/QuickLook.h>

#import "DCMPix.h"
#import "dicomFile.h"

static PapyInitDone = NO;

NSString* stringFromData( NSString *a, NSString *b)
{
	if( [a isEqualTo:@""]) a = 0L;
	if( [b isEqualTo:@""]) b = 0L;
	if( a && b) return [NSString stringWithFormat:@"%@ - %@", a, b];
	if( a) return a;
	if( b) return b;
	return @"";
}

OSStatus GeneratePreviewForURL(void *thisInterface, QLPreviewRequestRef preview, CFURLRef url, CFStringRef contentTypeUTI, CFDictionaryRef options)
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
	NSImage *image = [pix image];
	
	NSSize canvasSize = [image size];
	
    CGContextRef cgContext = QLPreviewRequestCreateContext(preview, *(CGSize *)&canvasSize, true, NULL);
    if(cgContext)
	{
        NSGraphicsContext* context = [NSGraphicsContext graphicsContextWithGraphicsPort:(void *)cgContext flipped:NO];
        if(context)
		{
		   [NSGraphicsContext setCurrentContext: context];
           [image drawAtPoint: NSMakePoint(0, 0) fromRect: NSMakeRect(0, 0, [image size].width, [image size].height) operation:NSCompositeCopy fraction:1.0];
		   
		   
		   DicomFile	*file = [[DicomFile alloc] init: [nsurl path]];
		   
			if( file)
			{
				NSDateFormatter		*date = [[[NSDateFormatter alloc] init] autorelease];
				[date setDateStyle: NSDateFormatterShortStyle];
				
				NSDateFormatter		*time = [[[NSDateFormatter alloc] init] autorelease];
				[time setTimeStyle: NSDateFormatterShortStyle];
				
				NSShadow	*shadow = [[[NSShadow alloc] init] autorelease];
				[shadow setShadowColor: [NSColor blackColor]];
				[shadow setShadowOffset: NSMakeSize(-2, -2)];
				[shadow setShadowBlurRadius: 4];
				
				float fontSize = 14.*[image size].width/512.;
				if( fontSize < 10) fontSize = 10;
				
				NSDictionary	*attributes = [NSDictionary dictionaryWithObjectsAndKeys: shadow, NSShadowAttributeName, [NSFont fontWithName:@"Helvetica" size:fontSize], NSFontAttributeName, [NSColor whiteColor], NSForegroundColorAttributeName, 0L];
				
				NSMutableString	*text = [NSMutableString string];
				
				[text appendString: stringFromData( [file elementForKey:@"patientName"], [date stringFromDate: [file elementForKey:@"patientBirthDate"]])];
				[text appendString: @"\r"];
				[text appendString: stringFromData( [file elementForKey:@"accessionNumber"], [file elementForKey:@"patientID"])];
				[text appendString: @"\r"];
				
				NSString *s = 0L;
				if( [file elementForKey:@"studyDate"]) s = [NSString stringWithFormat: @"%@ / %@", [date stringFromDate: [file elementForKey:@"studyDate"]], [time stringFromDate: [file elementForKey:@"studyDate"]]];
				[text appendString: stringFromData( [file elementForKey:@"studyDescription"], s)];
				
				[text drawAtPoint: NSMakePoint(10, 10) withAttributes: attributes];
				
				[file release];
			}
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
