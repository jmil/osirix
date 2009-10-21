//
//  NSAlert+N2.mm
//  Nitrogen
//
//  Created by Alessandro Volz on 20.10.09.
//  Copyright 2009 HUG. All rights reserved.
//

#import "NSPanel+N2.h"


@implementation NSPanel (N2)

+(NSPanel*)alertWithTitle:(NSString*)title message:(NSString*)message defaultButton:(NSString*)defaultButton alternateButton:(NSString*)alternateButton icon:(NSImage*)icon {
	NSPanel* panel = NSGetAlertPanel(title, message, defaultButton, alternateButton, NULL);
	
	if (icon)
		for (NSImageView* view in [[panel contentView] subviews])
			if ([view isKindOfClass:[NSImageView class]])
				[view setImage:icon];
	
	return [panel autorelease];
}

@end
