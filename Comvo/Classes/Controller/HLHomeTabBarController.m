//
//  HLHomeTabBarController.m
//  Comvo
//
//  Created by Akio Morita on 12/23/14.
//  Copyright (c) 2014 DeMing Yu. All rights reserved.
//

#import "HLHomeTabBarController.h"

@interface HLHomeTabBarController ()

@end

@implementation HLHomeTabBarController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    UITabBar *tabBar = self.tabBar;
    UITabBarItem *tabBarItem1 = [tabBar.items objectAtIndex:0];
    UITabBarItem *tabBarItem2 = [tabBar.items objectAtIndex:1];
    UITabBarItem *tabBarItem3 = [tabBar.items objectAtIndex:2];
    UITabBarItem *tabBarItem4 = [tabBar.items objectAtIndex:3];
    UITabBarItem *tabBarItem5 = [tabBar.items objectAtIndex:4];
    
    tabBarItem1.title = @"";
    tabBarItem2.title = @"";
    tabBarItem3.title = @"";
    tabBarItem4.title = @"";
    tabBarItem5.title = @"";
    
    [tabBarItem1 setImageInsets:UIEdgeInsetsMake(5, 0, -5, 0)];
    [tabBarItem2 setImageInsets:UIEdgeInsetsMake(5, 0, -5, 0)];
    [tabBarItem3 setImageInsets:UIEdgeInsetsMake(5, 0, -5, 0)];
    [tabBarItem4 setImageInsets:UIEdgeInsetsMake(5, 0, -5, 0)];
    [tabBarItem5 setImageInsets:UIEdgeInsetsMake(5, 0, -5, 0)];
    
    [tabBarItem1 setImage: [[UIImage imageNamed: @"tab_img_stream.png"] imageWithRenderingMode: UIImageRenderingModeAlwaysOriginal]];
    [tabBarItem2 setImage: [[UIImage imageNamed: @"tab_img_message.png"] imageWithRenderingMode: UIImageRenderingModeAlwaysOriginal]];
    [tabBarItem3 setImage: [[UIImage imageNamed: @"tab_img_broadcast.png"] imageWithRenderingMode: UIImageRenderingModeAlwaysOriginal]];
    [tabBarItem4 setImage: [[UIImage imageNamed: @"tab_img_notification.png"] imageWithRenderingMode: UIImageRenderingModeAlwaysOriginal]];
    [tabBarItem5 setImage: [[UIImage imageNamed: @"tab_img_profile.png"] imageWithRenderingMode: UIImageRenderingModeAlwaysOriginal]];
    
    [tabBarItem1 setSelectedImage: [[UIImage imageNamed: @"tab_img_stream_selected.png"] imageWithRenderingMode: UIImageRenderingModeAlwaysOriginal]];
    [tabBarItem2 setSelectedImage: [[UIImage imageNamed: @"tab_img_message_selected.png"] imageWithRenderingMode: UIImageRenderingModeAlwaysOriginal]];
    [tabBarItem3 setSelectedImage: [[UIImage imageNamed: @"tab_img_broadcast_selected.png"] imageWithRenderingMode: UIImageRenderingModeAlwaysOriginal]];
    [tabBarItem4 setSelectedImage: [[UIImage imageNamed: @"tab_img_notification_selected.png"] imageWithRenderingMode: UIImageRenderingModeAlwaysOriginal]];
    [tabBarItem5 setSelectedImage: [[UIImage imageNamed: @"tab_img_profile_selected.png"] imageWithRenderingMode: UIImageRenderingModeAlwaysOriginal]];
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
