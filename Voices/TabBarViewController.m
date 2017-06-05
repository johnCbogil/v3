//
//  TabBarViewController.m
//  Voices
//
//  Created by John Bogil on 4/17/16.
//  Copyright © 2016 John Bogil. All rights reserved.
//

#import "TabBarViewController.h"
#import "TakeActionViewController.h"
#import "RootViewController.h"

@interface TabBarViewController ()

@end

@implementation TabBarViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self createViewControllers];
    [self createTabBarButtons];
    
    [UITabBar appearance].tintColor = [UIColor voicesOrange];
}

- (void)createViewControllers {
    
    UIStoryboard *takeActionSB = [UIStoryboard storyboardWithName:@"TakeAction" bundle: nil];
    UIStoryboard *repsSB = [UIStoryboard storyboardWithName:@"Reps" bundle:nil];
    
    UIViewController *rootVC = (UIViewController *)[repsSB instantiateViewControllerWithIdentifier: @"RepsNavCtrl"];
    TakeActionViewController *groupsVC = (TakeActionViewController *)[takeActionSB instantiateViewControllerWithIdentifier: @"TakeActionNavigationViewController"];
    
    self.viewControllers = @[rootVC, groupsVC];
}

- (void)createTabBarButtons {
    
    UITabBarItem *repsTab = [self.tabBar.items objectAtIndex:0];
    repsTab.title = @"Contact Reps";
    repsTab.image = [UIImage imageNamed:@"Triangle"];
    
    if (self.tabBar.items.count > 1) {
        UITabBarItem *groupsTab = [self.tabBar.items objectAtIndex:1];
        groupsTab.title = @"Take Action";
        groupsTab.image = [UIImage imageNamed:@"GroupIcon"];
    }
    
}

@end
