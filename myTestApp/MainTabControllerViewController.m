//
//  MainTabControllerViewController.m
//  myTestApp
//
//  Created by Denis Fromfontan on 22.10.15.
//  Copyright © 2015 Denis Fromfontan. All rights reserved.
//

#import "MainTabControllerViewController.h"

@interface MainTabControllerViewController ()

@end

@implementation MainTabControllerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    
    self.customizableViewControllers = nil;
  
    self.moreNavigationController.navigationBar.topItem.title = @"ИСЧО";
    
    
    
    
    UITabBarItem * tabBarItem =  [[UITabBarItem alloc] initWithTitle:@"ИСЧО" image:[UIImage imageNamed:@"tr.png"] tag:0];
    [[self.moreNavigationController.viewControllers objectAtIndex:0] setTabBarItem:tabBarItem];
    
   
    
    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
