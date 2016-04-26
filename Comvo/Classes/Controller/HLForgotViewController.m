//
//  HLForgotViewController.m
//  Comvo
//
//  Created by Max Broeckel on 28/09/15.
//  Copyright (c) 2015 DeMing Yu. All rights reserved.
//

#import "HLForgotViewController.h"

#import <MBProgressHUD.h>

#import "AppEngine.h"
#import "Constants_Comvo.h"
#import "HLCommunication.h"

@interface HLForgotViewController ()<UINavigationControllerDelegate, UIImagePickerControllerDelegate, UIActionSheetDelegate, UIAlertViewDelegate>

@end

@implementation HLForgotViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self.navigationController setNavigationBarHidden: NO];
    
    [self.navigationController.navigationBar setBackgroundImage:[UIImage new]
                                                  forBarMetrics:UIBarMetricsDefault];
    self.navigationController.navigationBar.shadowImage = [UIImage new];
    self.navigationController.navigationBar.translucent = YES;
    
    self.title = @"Forgot Password";
    [self.navigationController.navigationBar
     setTitleTextAttributes:@{NSForegroundColorAttributeName : [UIColor whiteColor]}];
    
    UIButton *btnBack = [UIButton buttonWithType: UIButtonTypeSystem];
    [btnBack setFrame: CGRectMake(0, 0, 30, 30)];
    [btnBack setTintColor: [UIColor whiteColor]];
    [btnBack setImage: [UIImage imageNamed: @"common_img_back.png"] forState: UIControlStateNormal];
    [btnBack addTarget: self action: @selector(onTouchBtnBack:) forControlEvents: UIControlEventTouchUpInside];
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView: btnBack];
    
    [[UIApplication sharedApplication] setStatusBarStyle: UIStatusBarStyleLightContent animated: YES];
    
    //mProgress = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    //mProgress.mode = MBProgressHUDModeIndeterminate;
    //[mProgress hide: NO];
    
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    //mSView.contentSize = CGSizeMake(mSView.frame.size.width, 504);
}

-(UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}



/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

//==========================================================================================================================

#pragma mark -
#pragma mark - Touch Event

- (IBAction)onTouchBtnBack: (id)sender {
    [self.navigationController popViewControllerAnimated: YES];
}



- (IBAction)onTouchBtnSubmit: (id)sender {
    NSLog(@"Touch Button Submit");
    
    NSLog(@"Login Started");
    
    if ([mEMailAddress.text isEqualToString: @""])
    {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Warning" message:@"Please input email address." delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
        [alertView show];
        
        return;
    }
    
    [self showLoading];
    
    NSDictionary *parameters = nil;
    
    parameters = @{@"email":         mEMailAddress.text};
    
    void ( ^successed )( id responseObject ) = ^( id responseObject ) {
        NSLog(@"JSON: %@", responseObject);
        
        int result = [[responseObject objectForKey: @"success"] intValue];
        
        if (result)
        {
            NSDictionary *dicData = [responseObject objectForKey: @"data"];
            
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle: @"Result" message: [dicData valueForKey: @"message"] delegate: nil cancelButtonTitle: @"OK" otherButtonTitles: nil];
            [alertView show];
        }
        
        [mProgress hide: YES];
    };
    
    void ( ^failure )( NSError* error ) = ^( NSError* error ) {
        NSLog(@"Error: %@", error);
        
        [mProgress hide: YES];
    };
    
    [[HLCommunication sharedManager] sendToService: API_FORGOTPASSWORD params: parameters success: successed failure: failure];
    
}

- (void)showLoading {
    mProgress = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    mProgress.mode = MBProgressHUDModeIndeterminate;
    mProgress.labelText = @"Submitting...";
    [mProgress show:YES];
}


@end
