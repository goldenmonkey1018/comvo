//
//  ChangePasswordViewController.m
//  Comvo
//
//  Created by Max Broeckel on 30/09/15.
//  Copyright (c) 2015 Max Broeckel. All rights reserved.
//

#import "ChangePasswordViewController.h"

#import <MBProgressHUD.h>

#import "AppEngine.h"
#import "Constants_Comvo.h"
#import "HLCommunication.h"


@interface ChangePasswordViewController ()

@end

@implementation ChangePasswordViewController

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

- (IBAction)onTouchBtnSubmit: (id)sender {
    NSLog(@"Touched Password Submit Button");
    
    NSString *newPassword = mInputPassword.text;
    
    if ([newPassword isEqualToString: @""])
    {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Warning" message:@"Please input password." delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
        [alertView show];
        
        return;
    }
    
    [self showLoading];
    
    NSMutableDictionary *parameters = [NSMutableDictionary new];
    
    void ( ^successed )( id responseObject ) = ^( id responseObject ) {
        NSLog(@"JSON: %@", responseObject);
        
        int result = [[responseObject objectForKey: @"success"] intValue];
        if (result) {
            //NSDictionary *dicData = [responseObject objectForKey: @"data"];
            //NSDictionary *dicUser = [dicData objectForKey: @"user"];
            
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle: @"Password has been changed successfully." message: [responseObject valueForKey: @"Success"] delegate: nil cancelButtonTitle: @"Ok" otherButtonTitles: nil];
            [alertView show];
        }
        else {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle: @"Warning" message: [responseObject valueForKey: @"message"] delegate: nil cancelButtonTitle: @"Ok" otherButtonTitles: nil];
            [alertView show];
        }
        
        [mProgress hide: YES];
        [self.navigationController popViewControllerAnimated: YES];
    };
    
    void ( ^failure )( NSError* error ) = ^( NSError* error ) {
        NSLog(@"Error: %@", error);
        
        [mProgress hide: YES];
        [self.navigationController popViewControllerAnimated: YES];
    };
    
    NSString *updatelist = [[NSString alloc] initWithData:[NSJSONSerialization dataWithJSONObject:@{@"password":newPassword} options:0 error:nil] encoding:NSUTF8StringEncoding];
    
    parameters[@"updatelist"] = updatelist;
    parameters[@"user_id"] = [Engine gCurrentUser].mUserId;
    
    [[HLCommunication sharedManager] sendToService: API_UPDATEPROFILE params: parameters success: successed failure: failure];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (void)showLoading {
    mProgress = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    mProgress.mode = MBProgressHUDModeIndeterminate;
    mProgress.labelText = @"Submitting...";
    [mProgress show:YES];
}

@end
