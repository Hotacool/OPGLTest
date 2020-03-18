//
//  AppDelegate.m
//  OPGLDemo
//
//  Created by Hotacool on 2020/3/18.
//  Copyright © 2020 Hotacool. All rights reserved.
//

#import "AppDelegate.h"
#import "OPGLViewController.h"

@interface AppDelegate ()

@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    OPGLViewController *rootVC = [[OPGLViewController alloc] init];
    rootVC.view.backgroundColor = [UIColor whiteColor];
    self.window.rootViewController = [[UINavigationController alloc] initWithRootViewController:rootVC];
    [self.window makeKeyAndVisible];
    return YES;
}
@end
