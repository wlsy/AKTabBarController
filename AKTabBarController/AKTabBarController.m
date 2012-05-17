// AKTabBarController.m
//
// Copyright (c) 2012 Ali Karagoz (http://alikaragoz.net)
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

#import "AKTabBarController.h"
#import "UIViewController+AKTabBarController.h"

// Default height of the tab bar
static const int kDefaultTabBarHeight = 50;

@interface AKTabBarController ()
    BOOL visible;

// Bottom tab bar view
@property (nonatomic, strong) AKTabBar *tabBar;

// Content view
@property (nonatomic, strong) AKTabBarView *tabBarView;

// Current active view controller
@property (nonatomic, strong) UIViewController *selectedViewController;

// Tab Bar height
@property (nonatomic, assign) NSUInteger tabBarHeight;

- (void)loadTabs;

@end

@implementation AKTabBarController

// Private properties
@synthesize tabBar, tabBarView, tabBarHeight;
@synthesize selectedViewController = _selectedViewController;

// Public properties
@synthesize minimumHeightToDisplayTitle, tabTitleIsHidden;
@synthesize viewControllers = _viewControllers;

#pragma mark - Initialization

- (id)init
{
    self = [super init];
    if (self) {
        // Setting the default tab bar height
        self.tabBarHeight = kDefaultTabBarHeight;
    }
    return self;
}

- (id)initWithTabBarHeight:(NSUInteger)height
{
    self = [super init];
    if (self) {
        self.tabBarHeight = height;
    }
    return self;
}

- (void)loadView
{
    [super loadView];
    
    // Creating and adding the tab bar view
    self.tabBarView = [[AKTabBarView alloc] initWithFrame:[[UIScreen mainScreen] applicationFrame]];
    self.view = self.tabBarView;
        
    // Creating and adding the tab bar
    
    // After the device rotation, the height is changing, this fixes it.
    CGFloat offset = 1;
    
    CGRect tabBarRect = CGRectMake(0, self.view.bounds.size.height - self.tabBarHeight, self.view.frame.size.width, self.tabBarHeight + offset);
    CGRect tabBarRect = CGRectMake(0, self.view.bounds.size.height - self.tabBarHeight, self.view.bounds.size.width, self.tabBarHeight + offset);
    self.tabBar = [[AKTabBar alloc] initWithFrame:tabBarRect];
    self.tabBar.delegate = self;
    
    self.tabBarView.tabBar = self.tabBar;
    self.tabBarView.contentView = self.selectedViewController.view;
    [self loadTabs];
}

- (void)loadTabs
{
    NSMutableArray *tabs = [[NSMutableArray alloc] init];
    for (UIViewController *vc in self.viewControllers) {
        AKTab *tab = [[AKTab alloc] init];
        [tab setTabImageWithName:[vc tabImageName]];
        [tab setTabTitle:[vc tabTitle]];
        
        if (self.minimumHeightToDisplayTitle) {
            [tab setMinimumHeightToDisplayTitle:self.minimumHeightToDisplayTitle];
        }
        
        if (self.tabTitleIsHidden) {
            [tab setTitleIsHidden:YES];
        }
        
        [tabs addObject:tab];
    }
    [self.tabBar setTabs:tabs];
    
    // Setting the first view controller as the active one
    [self.tabBar setSelectedTab:[self.tabBar.tabs objectAtIndex:0]];
}

#pragma mark - Setters

- (void)setViewControllers:(NSMutableArray *)viewControllers
{
    _viewControllers = viewControllers;
    
    // When setting the view controllers, the first vc is the selected one;
    [self setSelectedViewController:[viewControllers objectAtIndex:0]];
}

- (void)setSelectedViewController:(UIViewController *)selectedViewController
{
    
    UIViewController *previousSelectedViewController = selectedViewController;
    if (self.selectedViewController != selectedViewController) {
        _selectedViewController = selectedViewController;
        
        selectedViewController = selectedViewController;
        if (!self.childViewControllers && visible) {
			[previousSelectedViewController viewWillDisappear:NO];
			[selectedViewController viewWillAppear:NO];
		}

        [self.tabBarView setContentView:selectedViewController.view];
        
        if (!self.childViewControllers && visible) {
			[previousSelectedViewController viewDidDisappear:NO];
			[selectedViewController viewDidAppear:NO];
		}
        
        [self.tabBar setSelectedTab:[self.tabBar.tabs objectAtIndex:[self.viewControllers indexOfObject:selectedViewController]]];
    }
}


#pragma mark - Required Protocol Method

- (void)tabBar:(AKTabBar *)AKTabBarDelegate didSelectTabAtIndex:(NSInteger)index
{
    UIViewController *vc = [self.viewControllers objectAtIndex:index];
    
    if (self.selectedViewController == vc) {
        
        if ([vc isKindOfClass:[UINavigationController class]]) {
            
            [(UINavigationController *)self.selectedViewController popToRootViewControllerAnimated:YES];
        }
    
    } else {
        
        self.selectedViewController = vc;
    }
}

#pragma mark - Rotation Events

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    return [self.selectedViewController shouldAutorotateToInterfaceOrientation:toInterfaceOrientation];
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    [self.selectedViewController willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation duration:(NSTimeInterval)duration
{

    // Redraw with will rotating and keeping the aspect ratio
    for (AKTab *tab in [self.tabBar tabs]) {
        [tab setNeedsDisplay];
    }

    [self.selectedViewController willAnimateRotationToInterfaceOrientation:interfaceOrientation duration:duration];
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    [self.selectedViewController didRotateFromInterfaceOrientation:fromInterfaceOrientation];
}

@end
#pragma mark - ViewController Life cycle

- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
    
    if (!self.childViewControllers)
        [self.selectedViewController viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
	[super viewDidAppear:animated];
    
    if (!self.childViewControllers)
        [self.selectedViewController viewDidAppear:animated];
    
    visible = YES;
}

- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
    
    if (!self.childViewControllers)
        [self.selectedViewController viewWillDisappear:animated];	
}

- (void)viewDidDisappear:(BOOL)animated
{
	[super viewDidDisappear:animated];
    
    if (![self respondsToSelector:@selector(addChildViewController:)])
        [self.selectedViewController viewDidDisappear:animated];
    
    visible = NO;
}

@end