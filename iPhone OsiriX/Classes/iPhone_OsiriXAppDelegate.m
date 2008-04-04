//
//  iPhone_OsiriXAppDelegate.m
//  iPhone OsiriX
//
//  Created by antoinerosset on 09.03.08.
//  Copyright __MyCompanyName__ 2008. All rights reserved.
//

#import "iPhone_OsiriXAppDelegate.h"

#import "MyViewController.h"
#import "StudiesViewController.h"
#import "ImageViewController.h"

UIImage *toolbarImageWithColor(CGSize imageSize, UIColor *color);

@implementation iPhone_OsiriXAppDelegate

@synthesize window;
@synthesize tabBarController;

- (void)applicationDidFinishLaunching:(UIApplication *)application {
    // Create window
    self.window = [[[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]] autorelease];
    
	 // Create a toolbar controller and an array to contain the view controllers
	tabBarController = [[UITabBarController alloc] init];
	NSMutableArray *viewControllers = [[NSMutableArray alloc] initWithCapacity:3];
	
	/*
	 Create and configure the view controllers
	 For simplicity, in this case, each is an instance of the same class but each has a different color;
	 typically you'd use a number of different controller classes.
	 */
	MyViewController *viewController;
	
	viewController = [[StudiesViewController alloc] init];	
	viewController.title = @"Patients";
	viewController.tabBarItem.image = [UIImage imageNamed:@"patients.png"];
	[viewControllers addObject:viewController];
	[viewController release];

	viewController = [[ImageViewController alloc] init];	
	viewController.title = @"Images";
	viewController.tabBarItem.image = [UIImage imageNamed:@"images.png"];
	[viewControllers addObject:viewController];
	[viewController release];
	
	viewController = [[MyViewController alloc] init];	
	viewController.title = @"Q&R";
	viewController.tabBarItem.image =[UIImage imageNamed:@"qr.png"];
	[viewControllers addObject:viewController];
	[viewController release];
	
	viewController = [[MyViewController alloc] init];	
	viewController.title = @"Send";
	viewController.tabBarItem.image =[UIImage imageNamed:@"send.png"];
	[viewControllers addObject:viewController];
	[viewController release];
		
	// Add the view controllers to the toolbar controller
	tabBarController.viewControllers = viewControllers;
	[viewControllers release];
	
	// Add the toolbar controller's current view as a subview of the window, then display the window
	[window addSubview:tabBarController.view];
    [window makeKeyAndVisible];
}

- (void)dealloc {
    [tabBarController release];
    [window release];
	[super dealloc];
}

@end

// Returns a transparent image of the given size containing the text in displayString drawn in the specified color.
UIImage *toolbarImageWithColor(CGSize imageSize, UIColor *color) {
	void *bitmapData;
	int bitmapBytesPerRow = (imageSize.width * 4);
	bitmapData = malloc(bitmapBytesPerRow * imageSize.height);
	if (bitmapData == NULL) {
 		return nil;
	}
	
	CGContextRef context = NULL;
	CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
	context = CGBitmapContextCreate(bitmapData, imageSize.width, imageSize.height, 8, bitmapBytesPerRow, colorSpace, kCGImageAlphaPremultipliedLast);
	if (context== NULL) {
		free(bitmapData);
 		return nil;
	}
	CGColorSpaceRelease(colorSpace);

	UIGraphicsPushContext(context);
	[color set];
	// Inset the color rect (custom CGContext coordinate system is flipped with respect to UIView)
	UIRectFill(CGRectMake(20, 12, imageSize.width-40, imageSize.height-20));
	CGImageRef cgImage = CGBitmapContextCreateImage(context);	
	UIImage *uiImage = [UIImage imageWithCGImage:cgImage];
    CGContextRelease(context);
	CGImageRelease(cgImage);
	return uiImage;
}
