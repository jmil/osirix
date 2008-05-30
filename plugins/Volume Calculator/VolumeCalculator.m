#import "VolumeCalculator.h"
#import "Controller.h"

@implementation VolumeCalculator

- (ViewerController*)   viewerController
{
	return viewerController;
}

- (long) filterImage:(NSString*) menuName
{
	// Display a nice window to thanks the user for using our powerful filter!
	ControllerT2Fit* coWin = [[ControllerT2Fit alloc] init:self];
	[coWin showWindow:self];
	
	return 0;
}
@end
