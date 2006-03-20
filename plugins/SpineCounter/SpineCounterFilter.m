//
//  SpineCounterFilter.m
//  SpineCounter
//
//  Created by Jo‘l Spaltenstein on Mar 20 2006.
//

#import "SpineCounterFilter.h"
#import "AppController.h"
#import "AppControllerFiltersMenu.h"
#import "ROI.h"
#import "stringNumericCompare.h"
#import <AppKit/AppKit.h>
 

//extern AppController * appController;

@implementation SpineCounterFilter

- (long) filterImage:(NSString*) menuName
{

	if ([menuName isEqualToString:@"Switch Spine Type"])
		[self switchTypes];
	else if ([menuName isEqualToString:@"Increment Count"])
		[self incrementDefaultName];
	else
		[self exportSpines];

	return 0;
}

- (void) setMenus
{
	AppController *appController = 0L;
	NSMenuItem *spineMenu = 0L;
	NSMenuItem *switchMenuItem = 0L;
	NSMenuItem *countMenuItem = 0L;
	
	appController = [AppController sharedAppController];
	
	spineMenu = [[appController roisMenu] itemWithTitle:@"SpineCounter"];
	if (spineMenu && [spineMenu hasSubmenu])
	{
		NSMenu *spineSubMenu = 0L;
		spineSubMenu = [spineMenu submenu];
		
		switchMenuItem = [spineSubMenu itemWithTitle:@"Switch Spine Type"];
		countMenuItem = [spineSubMenu itemWithTitle:@"Increment Count"];
		
		[switchMenuItem setKeyEquivalent:@"s"];
		[switchMenuItem setKeyEquivalentModifierMask:NSAlternateKeyMask | NSCommandKeyMask];

		[countMenuItem setKeyEquivalent:@"a"];
		[countMenuItem setKeyEquivalentModifierMask:NSAlternateKeyMask | NSCommandKeyMask];
	}
}

- (void) switchTypes
{
	NSMutableArray  *pixList;
	NSMutableArray  *roiSeriesList;
	NSMutableArray  *roiImageList;
	DCMPix			*curPix;
	NSString		*roiName = 0L;
	long			i, x;
	
	// In this plugin, we will take the selected roi of the current 2D viewer
	// and search all rois with same name in other images of the series
	
	pixList = [viewerController pixList];
	
	curPix = [pixList objectAtIndex: [[viewerController imageView] curImage]];
	
	// All rois contained in the current series
	roiSeriesList = [viewerController roiList];
	
	// All rois contained in the current image
	roiImageList = [roiSeriesList objectAtIndex: [[viewerController imageView] curImage]];
	
	// Find the first selected ROI of current image
	for( i = 0; i < [roiImageList count]; i++)
	{
		if( [[roiImageList objectAtIndex: i] ROImode] == ROI_selected)
		{
			// We find it! What's his name?
			
			roiName = [NSString stringWithString:[[roiImageList objectAtIndex: i] name]];
			
			i = [roiImageList count];   //Break the loop
		}
	}
	
	if( roiName == 0L)
	{
		NSRunInformationalAlertPanel(@"Switch Types", @"You need to select a ROI!", @"OK", 0L, 0L);
		return;
	}
	
	// Now find all ROIs with the same name on other images of the series
	for( x = 0; x < [pixList count]; x++)
	{
		roiImageList = [roiSeriesList objectAtIndex: x];
		
		for( i = 0; i < [roiImageList count]; i++)
			if( [[[roiImageList objectAtIndex: i] name] isEqualToString: roiName])
				[self rotateType:[roiImageList objectAtIndex: i]];
	}
	
	[viewerController needsDisplayUpdate];
}

- (void) incrementDefaultName
{
	NSString* currentDefaultName = 0L;
	
	currentDefaultName = [ROI defaultName];
	
	[ROI setDefaultName:[NSString stringWithFormat:@"%d", ([currentDefaultName intValue] + 1)]];
	
	if ([currentDefaultName intValue] == 99)
		NSRunInformationalAlertPanel(@"Bravo Mathias", @"Va prendre un cafe!", @"OK", 0L, 0L);
}

- (void) exportSpines
{
	NSSavePanel *panel = [ NSSavePanel savePanel ];
	assert( panel != nil );

	[ panel setRequiredFileType: nil ];
	[ panel beginSheetForDirectory:nil file:nil modalForWindow: [ viewerController window ] modalDelegate:self didEndSelector: @selector(endSavePanel:returnCode:contextInfo:) contextInfo: nil ];
}


- (void) endSavePanel: (NSSavePanel *) sheet returnCode: (int) retCode contextInfo: (void *) contextInfo
{
	NSMutableArray* roiList = 0L;
	NSMutableArray* roiShortNameList = 0L;
	NSArray* sortedShortNameList = 0L;
	NSString* lastchars = @"";
	NSString* shortName = 0L;
	NSMutableString	*outputText = [NSMutableString stringWithCapacity: 1024];
	int i, j, k;

	if ( retCode != NSFileHandlingPanelOKButton ) return;
	
	roiList = [NSMutableArray arrayWithCapacity:[[self viewerControllersList] count]];
	
	for (i=0; i < [[self viewerControllersList] count]; i++)
		[roiList addObject:[NSMutableArray arrayWithCapacity:20]];
	
	roiShortNameList = [NSMutableArray arrayWithCapacity:20];
	
	for (i=0; i < [[self viewerControllersList] count]; i++) // over the viewers
	{
		ViewerController*   currentController = 0L;
		NSMutableArray  *pixList;
		NSMutableArray  *roiSeriesList;
		NSMutableArray  *roiImageList;
		NSString		*roiName = 0L;
			
		currentController = [[self viewerControllersList] objectAtIndex:i];
		// All rois contained in the current series
		roiSeriesList = [currentController roiList];
		
		pixList = [currentController pixList];
		
		for (j=0; j < [pixList count]; j++) // over the images in the viewers
		{
			roiImageList = [roiSeriesList objectAtIndex:j];
			
			for (k=0; k < [roiImageList count]; k++) // over each roi
			{
				roiName = [[roiImageList objectAtIndex: k] name];
				
				
				if ([roiName length] > 2)
				{
					lastchars = [roiName substringFromIndex:([roiName length] - 2)];
					if ([lastchars isEqualToString:@" S"] || [lastchars isEqualToString:@" M"] || [lastchars isEqualToString:@" F"])
						if ([[roiName substringToIndex:([roiName length] - 2)] intValue] > 0)
							shortName = [roiName substringToIndex:([roiName length] - 2)];
				}
				else if ([roiName intValue] > 0)
					shortName = roiName;
					
				if (shortName)
				{
					if ([[roiList objectAtIndex:i] indexOfObject:roiName] == NSNotFound)
						[[roiList objectAtIndex:i] addObject:[NSString stringWithString:roiName]];
					
					if ([roiShortNameList indexOfObject:shortName] == NSNotFound)
						[roiShortNameList addObject:[NSString stringWithString:shortName]];
				}
			}

		}
	}
	
	sortedShortNameList = [roiShortNameList sortedArrayUsingSelector:@selector(numericCompare:)];
	
	for (i = 0; i < [sortedShortNameList count]; i++)
	{
		NSString* spineNumberString = [sortedShortNameList objectAtIndex:i];
		NSString* prevType = @"start";
		int spineNumber = [spineNumberString intValue];
		[outputText appendFormat:@"%d", spineNumber];
		for (j=0; j < [[self viewerControllersList] count]; j++) // over the viewers
		{
			NSArray* rois = [roiList objectAtIndex:j];
			int roiFound = NO;
			
			// find the right ROI
			for (k = 0; k < [rois count]; k++)
			{
				NSString* currentROIName = [rois objectAtIndex:k];
				if ([currentROIName hasPrefix:spineNumberString])
				{
					roiFound = YES;
					if ([currentROIName hasSuffix:@"S"])
					{
						[outputText appendFormat:@"\t %@", [self outputString:prevType:@"S"]];
						prevType = @"S";
					}
					else if ([currentROIName hasSuffix:@"M"])
					{
						[outputText appendFormat:@"\t %@", [self outputString:prevType:@"M"]];
						prevType = @"M";
					}
					else if ([currentROIName hasSuffix:@"F"])
					{
						[outputText appendFormat:@"\t %@", [self outputString:prevType:@"F"]];
						prevType = @"F";
					}
					else
					{
						[outputText appendFormat:@"\t %@", [self outputString:prevType:@""]];
						prevType = @"";
					}
					break;
				}
			}
			if (roiFound == NO)
			{
				[outputText appendFormat:@"\t %@", [self outputString:prevType:@""]];
				prevType = @"";
			}
		}
		[outputText appendFormat:@"\n"];
	}
	
	
	NSMutableString *fname = [ NSMutableString stringWithString: [ sheet filename ] ];
	
	const char *str = [outputText cStringUsingEncoding: NSASCIIStringEncoding ];
	NSData *data = [ NSData dataWithBytes: str length: strlen( str ) ];
	[data writeToFile: fname atomically: YES];
}

- (NSString*) outputString:(NSString*) prevType: (NSString*) newType
{
	if ([prevType isEqualToString:@"start"])
		return newType;
	
	if ([prevType isEqualToString:newType])
		return newType;
	
	if ([prevType isEqualToString:@""])
		return [@"+" stringByAppendingString:newType];

	if ([newType isEqualToString:@""])
		return [@"-" stringByAppendingString:prevType];
	
	return [prevType stringByAppendingString:newType];
}


- (void) rotateType:(ROI*) roi
{
	NSString* name;
	NSString* newName;
	RGBColor green = {76, 255, 76};
	RGBColor yellow = {255, 255, 64};
	RGBColor red = {255, 0, 0};
	RGBColor blue = {0, 0, 255};
	
	green.red *= 256;
	green.green *= 256;
	green.blue *= 256;
	
	yellow.red *= 256;
	yellow.green *= 256;
	yellow.blue *= 256;
	
	red.red *= 256;
	red.green *= 256;
	red.blue *= 256;
	
	blue.red *= 256;
	blue.green *= 256;
	blue.blue *= 256;
	
	name = [roi name];
	
	NSString* lastchars = @"";
	
	if ([name length] > 2)
	{
		lastchars = [name substringFromIndex:([name length] - 2)];
		if ([lastchars isEqualToString:@" S"])
		{
			newName = [[name substringToIndex:([name length] - 2)] stringByAppendingString:@" M"];
			[roi setColor:red];
		}
		else if ([lastchars isEqualToString:@" M"])
		{
			newName = [[name substringToIndex:([name length] - 2)] stringByAppendingString:@" F"];
			[roi setColor:blue];
		}
		else if ([lastchars isEqualToString:@" F"])
		{
			newName = [name substringToIndex:([name length] - 2)];
			[roi setColor:green];
		}
		else
		{
			newName = [name stringByAppendingString:@" S"];
			[roi setColor:yellow];
		}
	}
	else
	{
		newName = [name stringByAppendingString:@" S"];
		[roi setColor:yellow];
	}

	[roi setName:newName];
	
	[[NSUserDefaults standardUserDefaults] setFloat:green.red forKey:@"ROIColorR"];
	[[NSUserDefaults standardUserDefaults] setFloat:green.green forKey:@"ROIColorG"];
	[[NSUserDefaults standardUserDefaults] setFloat:green.blue forKey:@"ROIColorB"];

}

@end
