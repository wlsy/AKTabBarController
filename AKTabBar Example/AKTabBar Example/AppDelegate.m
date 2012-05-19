//
//  AppDelegate.m
//  AKTabBar Example
//
//  Created by Ali KARAGOZ on 03/05/12.
//  Copyright (c) 2012 Ali Karagoz. All rights reserved.
//

#import "AppDelegate.h"
#import "AKTabBarController.h"

#import "FirstViewController.h"
#import "SecondViewController.h"
#import "ThirdViewController.h"
#import "FourthViewController.h"

@implementation AppDelegate
@synthesize window;
@synthesize tabBarController;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];

    // If the device is an iPad, we make it taller.
    self.tabBarController = [[AKTabBarController alloc] initWithTabBarHeight:(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) ? 70 : 50];
    
    UITableViewController *tableViewController = [[FirstViewController alloc] initWithStyle:UITableViewStylePlain];
    
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:tableViewController];
    navigationController.navigationBar.tintColor = [UIColor darkGrayColor];
    
    [self.tabBarController setViewControllers:[NSMutableArray arrayWithObjects:
                                               navigationController,
                                               [[SecondViewController alloc] init],
                                               [[ThirdViewController alloc] init],
                                               [[FourthViewController alloc] init],nil]
     ];
    
    [self.window addSubview:self.tabBarController.view];
    [self.window makeKeyAndVisible];
    return YES;
}

@end
