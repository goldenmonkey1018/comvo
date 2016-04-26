//
//  SettingsViewController.m
//  Comvo
//
//  Created by Max Broeckel on 30/09/15.
//  Copyright (c) 2015 Max Broeckel. All rights reserved.
//

#import "SettingsViewController.h"
#import <MessageUI/MessageUI.h>

#import "AppEngine.h"
#import "Constants_Comvo.h"
#import "AppDelegate.h"


@interface SettingsViewController ()<MFMailComposeViewControllerDelegate, MFMessageComposeViewControllerDelegate>

@end

@implementation SettingsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//================================================================================================================

#pragma mark -
#pragma mark - Touch Event

- (IBAction)onTouchBtnBack: (id)sender {
    [self.navigationController popViewControllerAnimated: YES];
}

- (IBAction)onInviteFriends:(id)sender {
    
    MFMessageComposeViewController *controller = [[MFMessageComposeViewController alloc] init];
    if([MFMessageComposeViewController canSendText])
    {
        controller.body = @"Hello, Please check this comvo application. It's Wonderful!!! Link: ";
//        controller.recipients = [NSArray arrayWithObjects:@"1(234)567-8910", nil];
        controller.messageComposeDelegate = self;
        [self presentViewController:controller animated:YES completion:nil];
    }
}

- (void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult)result {
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)onChangedNotification:(id)sender{
    if (mNotification.isOn)
        [Engine setGNotificationMode:@"Enabled"];
    else
        [Engine setGNotificationMode:@"Disabled"];
}

- (IBAction)onTouchLogOut:(id)sender{
    NSLog(@"Log Out");
    
    [[AppEngine getInstance] logout];
    [(UINavigationController *)AppDel.window.rootViewController popToRootViewControllerAnimated:YES];
    
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
