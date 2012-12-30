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
                                               [[FourthViewController alloc] init],nil]];
    
//    //Tab background Image
//    [self.tabBarController setBackgroundImageName:@"newNoise"];
//    
//    // Tabs top embos Color
//    [self.tabBarController setTabEdgeColor:[UIColor colorWithRed:.1 green:.1 blue:.5 alpha:.8]];
//    
//    // Tabs Colors settings
//    [self.tabBarController setSelectedTabColors:@[[UIColor colorWithRed:1 green:0 blue:0 alpha:1],
//                                                  [UIColor colorWithRed:1 green:0 blue:0 alpha:0]]]; // MAX 2 Colors
//    [self.tabBarController setTabColors:@[[UIColor colorWithRed:0 green:0 blue:1 alpha:.5],
//                                                  [UIColor colorWithRed:0 green:0 blue:1 alpha:0]]]; // MAX 2 Colors
//    
//    // Tab Stroke Color
//    [self.tabBarController setTabStrokeColor:[UIColor colorWithRed:0 green:1 blue:0 alpha:.5]];
//    
//    // Icons Color settings
//    [self.tabBarController setIconColors:@[[UIColor colorWithRed:1 green:0 blue:0 alpha:1],
//                                           [UIColor colorWithRed:1 green:0 blue:0 alpha:1]]]; // MAX 2 Colors
//    [self.tabBarController setSelectedIconColors:@[[UIColor colorWithRed:1 green:0 blue:0 alpha:1],
//                                                   [UIColor colorWithRed:0 green:1 blue:0 alpha:1]]]; // MAX 2 Colors
//    
//    // Hide / Show glossy on tab icons
//    [self.tabBarController setIconGlossyIsHidden:YES];
    
    [self.window setRootViewController:self.tabBarController];
    [self.window makeKeyAndVisible];
    return YES;
}

@end
