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
	UITabBarController *tabBarController;
}

@property (nonatomic, retain) UIWindow *window;
@property (nonatomic, retain) UITabBarController *tabBarController;

- (void)applicationDidFinishLaunching:(UIApplication *)application;

@end
