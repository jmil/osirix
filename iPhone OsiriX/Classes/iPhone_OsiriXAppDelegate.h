//
//  iPhone_OsiriXAppDelegate.h
//  iPhone OsiriX
//
//  Created by antoinerosset on 09.03.08.
//  Copyright __MyCompanyName__ 2008. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface iPhone_OsiriXAppDelegate : NSObject <UIApplicationDelegate> {
    UIWindow *window;
    UIToolbarController *toolbarController;
}

@property (nonatomic, retain) UIWindow *window;
@property (nonatomic, retain) UIToolbarController *toolbarController;

- (void)applicationDidFinishLaunching:(UIApplication *)application;

@end
