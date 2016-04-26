//
//  HLLoginViewController.m
//  Comvo
//
//  Created by DeMing Yu on 12/22/14.
//  Copyright (c) 2014 DeMing Yu. All rights reserved.
//

#import "HLLoginViewController.h"

#import <MBProgressHUD.h>
#import <FacebookSDK/FacebookSDK.h>

#import "AppEngine.h"
#import "Constants_Comvo.h"
#import "HLCommunication.h"

#import "AppDelegate.h"
#import "RDVTabBarController.h"
#import "RDVTabBarItem.h"


@interface HLLoginViewController ()

@end

@implementation HLLoginViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self.navigationController setNavigationBarHidden: NO];
    
    [self.navigationController.navigationBar setBackgroundImage:[UIImage new]
                             forBarMetrics:UIBarMetricsDefault];
    self.navigationController.navigationBar.shadowImage = [UIImage new];
    self.navigationController.navigationBar.translucent = YES;
    
    self.title = @"Log in";
    [self.navigationController.navigationBar
     setTitleTextAttributes:@{NSForegroundColorAttributeName : [UIColor whiteColor]}];
    
    UIButton *btnBack = [UIButton buttonWithType: UIButtonTypeSystem];
    [btnBack setFrame: CGRectMake(0, 0, 30, 30)];
    [btnBack setTintColor: [UIColor whiteColor]];
    [btnBack setImage: [UIImage imageNamed: @"common_img_back.png"] forState: UIControlStateNormal];
    [btnBack addTarget: self action: @selector(onTouchBtnBack :) forControlEvents: UIControlEventTouchUpInside];
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView: btnBack];

    [[UIApplication sharedApplication] setStatusBarStyle: UIStatusBarStyleLightContent animated: YES];
    
    [Engine setGSearchMode:@"SearchFriend"];
    [Engine setGAudioRecordingMode:@"StreamingAudio"];  //  StreamingAudio  or    GreetingAudio
    [Engine setGFlgCommentModified:@"NO"];    // The flag whether the Comment on Streaming page is deleted or not
    [Engine setGNotificationMode:@"Enabled"];
}

-(void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    mSView.contentSize = CGSizeMake(mSView.frame.size.width, 504);
}

-(UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
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



//==========================================================================================================================

#pragma mark - 
#pragma mark - Touch Event

- (IBAction)onTouchBtnBack: (id)sender {
    [self.navigationController popViewControllerAnimated: YES];
}

- (IBAction)onTouchBtnLogin: (id)sender {
#if 0
    
//    HLCameraViewController *cameraView = (HLCameraViewController *)[self.storyboard instantiateViewControllerWithIdentifier: @"HLCameraViewController"];
//    [self.navigationController pushViewController: cameraView animated: YES];
    
    [Engine setGAudioRecordingMode:@"StreamingAudio"];
    
    HLAudioViewController *audioView = (HLAudioViewController *)[self.storyboard instantiateViewControllerWithIdentifier: @"HLAudioViewController"];
    [self.navigationController pushViewController: audioView animated: YES];

    
    return;
    
#endif
    
    NSLog(@"Login Started");
        
    if ([mTextEmail.text isEqualToString: @""] || [mTextPassword.text isEqualToString: @""])
    {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Warning" message:@"Please fill out fields." delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
        [alertView show];
        
        return;
    }
    
    [self showLoading];
    
    NSDictionary *parameters = nil;
    
    void ( ^successed )( id responseObject ) = ^( id responseObject ) {
        NSLog(@"JSON: %@", responseObject);
        
        int result = [[responseObject objectForKey: @"success"] intValue];
        if (result) {
            NSDictionary *dicData = [responseObject objectForKey: @"data"];
            NSDictionary *dicUser = [dicData objectForKey: @"user"];
            
            UserInfo *userInfo = [[UserInfo alloc] init];
            
            userInfo.mUserId            = [dicUser objectForKey: @"user_id"];
            userInfo.mEmail             = [dicUser objectForKey: @"email"];
            userInfo.mUserName          = [dicUser objectForKey: @"username"];
            userInfo.mSessToken         = [dicUser objectForKey: @"sess_token"];
            userInfo.mPhotoUrl          = [dicUser objectForKey: @"profile_photo"];
            userInfo.mPassword          = [dicUser objectForKey: @"password"];
            userInfo.mFullName          = [dicUser objectForKey: @"fullname"];
            userInfo.mFollowingsCount   = [dicUser objectForKey: @"followings_count"];
            userInfo.mFollowersCount    = [dicUser objectForKey: @"followers_count"];
            userInfo.mStatus            = [dicUser objectForKey: @"status"];
            userInfo.mLastLogin         = [dicUser objectForKey: @"last_login"];
            userInfo.mRegisterDate      = [dicUser objectForKey: @"register_date"];
            userInfo.mGreetingAudioUrl  = [dicUser objectForKey: @"greeting_audio"];
            userInfo.mPostCount         = [dicUser objectForKey: @"posts_count"];
            
            [Engine setGCurrentUser: userInfo];
            
            [AppDel showHomeViewController];
        }
        else {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle: @"Warning" message: [responseObject valueForKey: @"message"] delegate: nil cancelButtonTitle: @"Ok" otherButtonTitles: nil];
            [alertView show];
        }
        
        [mProgress hide: YES];
    };
    
    void ( ^failure )( NSError* error ) = ^( NSError* error ) {
        NSLog(@"Error: %@", error);
        
        [mProgress hide: YES];
    };
    
    
    parameters = @{@"email":         mTextEmail.text,
                   @"password":      mTextPassword.text};
    
    [[HLCommunication sharedManager] sendToService: API_LOGIN params: parameters success: successed failure: failure];
}

- (IBAction)onTouchBtnFacebook: (id)sender {

    AppDelegate *delegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    delegate.callback = self;
    
    // If the session state is any of the two "open" states when the button is clicked
    if (FBSession.activeSession.state == FBSessionStateOpen
        || FBSession.activeSession.state == FBSessionStateOpenTokenExtended) {
        
        // Close the session and remove the access token from the cache
        // The session state handler (in the app delegate) will be called automatically
        [FBSession.activeSession closeAndClearTokenInformation];
        
        // If the session state is not any of the two "open" states when the button is clicked
    } else {
        // Open a session showing the user the login UI
        // You must ALWAYS ask for public_profile permissions when opening a session
        // Open session with public_profile (required) and user_birthday read permissions
        [FBSession openActiveSessionWithReadPermissions:@[@"public_profile",
                                                          @"user_friends",
                                                          @"user_birthday",
                                                          @"user_location",
                                                          @"user_hometown",
                                                          @"email"]
                                           allowLoginUI:YES
                                      completionHandler:
         ^(FBSession *session, FBSessionState state, NSError *error) {
             // Retrieve the app delegate
             AppDelegate* appDelegate = [UIApplication sharedApplication].delegate;
             // Call the app delegate's sessionStateChanged:state:error method to handle session state changes
             [appDelegate sessionStateChanged:session state:state error:error];
         }];
    }
}

- (void)onActionLoginWithFacebook: (NSString *)address {
    NSDictionary *parameters = nil;
    
    void ( ^successed )( id responseObject ) = ^( id responseObject ) {
        NSLog(@"JSON: %@", responseObject);
        
        int result = [[responseObject objectForKey: @"success"] intValue];
        if (result) {
            NSDictionary *dicData = [responseObject objectForKey: @"data"];
            NSDictionary *dicUser = [dicData objectForKey: @"user"];
            
            UserInfo *userInfo = [[UserInfo alloc] init];
            
            userInfo.mUserId            = [dicUser objectForKey: @"user_id"];
            userInfo.mEmail             = [dicUser objectForKey: @"email"];
            userInfo.mUserName          = [dicUser objectForKey: @"username"];
            userInfo.mSessToken         = [dicUser objectForKey: @"sess_token"];
            userInfo.mPhotoUrl          = [dicUser objectForKey: @"profile_photo"];
            userInfo.mFullName          = [dicUser objectForKey: @"fullname"];
            userInfo.mFollowersCount    = [dicUser objectForKey: @"followers_count"];
            userInfo.mStatus            = [dicUser objectForKey: @"status"];
            userInfo.mLastLogin         = [dicUser objectForKey: @"last_login"];
            userInfo.mRegisterDate      = [dicUser objectForKey: @"register_date"];
            
            [Engine setGCurrentUser: userInfo];
            
            [AppDel showHomeViewController];
        }
        else {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle: @"Warning" message: [responseObject valueForKey: @"message"] delegate: nil cancelButtonTitle: @"Ok" otherButtonTitles: nil];
            [alertView show];
        }
        
        [mProgress hide: YES];
    };
    
    void ( ^failure )( NSError* error ) = ^( NSError* error ) {
        NSLog(@"Error: %@", error);
        
        [mProgress hide: YES];
    };
    
    
    parameters = @{@"email":         self.mSocialInfo.mEmail,
                   @"fullname":      self.mSocialInfo.mName,
                   @"lat":           [NSString stringWithFormat: @"%f", [Engine gCurrentLocation].latitude],
                   @"lng":           [NSString stringWithFormat: @"%f", [Engine gCurrentLocation].longitude],
                   @"location":      address,
                   @"fb_id":         self.mSocialInfo.mId};
    
    [[HLCommunication sharedManager] sendToService: API_LOGINWITHFACEBOOK params: parameters success: successed failure: failure];
}

- (IBAction)onTouchBtnForgotpassword: (id)sender {
    NSLog(@"Forgot Password");
}

/**********************************************************************************************************************/

#pragma mark -
#pragma mark - Facebook

- (void) facebookLoaded;{
    
    [self showLoading];
    
    NSString *url = [NSString stringWithFormat:@"https://graph.facebook.com/me?access_token=%@&fields=id,birthday,name,picture,email,location,hometown", [[FBSession.activeSession accessTokenData] accessToken]];

    NSURL *googleRequestURL=[NSURL URLWithString:url];

    dispatch_async(kBgQueue, ^{
        NSData* data = [NSData dataWithContentsOfURL: googleRequestURL];
        [self performSelectorOnMainThread:@selector(fetchedFacebookData:) withObject:data waitUntilDone:YES];
    });
}

-(void)fetchedFacebookData:(NSData *)responseData{
    if(responseData.length < 1)
    {
        UIAlertView *alertView = [[UIAlertView alloc]initWithTitle: @"Connect Error" message: @"Can't access to Facebook" delegate: nil cancelButtonTitle: @"OK" otherButtonTitles: nil, nil];
        [alertView show];
        [mProgress hide: YES];
        return;
    }
    
    NSError* error;
    NSDictionary* json = [NSJSONSerialization
                          JSONObjectWithData:responseData
                          options:kNilOptions
                          error:&error];
    NSLog(@"%@",json);
    
    NSString    *fbId = [json objectForKey: @"id"];
    NSString    *fbName = [json objectForKey: @"name"];
    
    NSDictionary *dic = [json objectForKey: @"picture"];
    NSDictionary *dicdata = [dic objectForKey: @"data"];
    
    NSString    *fbPicture = [dicdata objectForKey: @"url"];
    NSString    *fbEmail = [json objectForKey: @"email"];
    
    SocialInfo *info = [[SocialInfo alloc] init];
    
    info.mId        = fbId;
    info.mEmail     = fbEmail;
    info.mName      = fbName;
    info.mPhotoUrl  = fbPicture;
    
    [self setMSocialInfo: info];
    
    [FBSession.activeSession closeAndClearTokenInformation];
    
    [self getFullAddress: [NSString stringWithFormat: @"%f", [Engine gCurrentLocation].latitude] : [NSString stringWithFormat: @"%f", [Engine gCurrentLocation].longitude]];
}

//============================================================================================================================

-(void)getFullAddress:(NSString*)latitude :(NSString*)longitude {
    NSString *url = [NSString stringWithFormat:@"http://maps.googleapis.com/maps/api/geocode/json?latlng=%@,%@&sensor=true",latitude,longitude];
    NSURL *RequestURL=[NSURL URLWithString:url];
    
    dispatch_async(kBgQueue, ^{
        NSData* data = [NSData dataWithContentsOfURL: RequestURL];
        [self performSelectorOnMainThread:@selector(fetchedFullAddress:) withObject:data waitUntilDone:YES];
    });
    
}

-(void)fetchedFullAddress:(NSData *)responseData {
    NSError* error;
    
    if (responseData.length > 0) {
        NSDictionary* json = [NSJSONSerialization
                              JSONObjectWithData:responseData
                              options:kNilOptions
                              error:&error];
        
        NSArray *arr = [json objectForKey:@"results"];
        
        if ([arr count] > 0) {
            NSDictionary *dict = [arr objectAtIndex: 0];
            
            NSLog(@"address: %@", dict);
            
            NSString *country = @"";
            
            NSArray *arrComponents = [dict objectForKey: @"address_components"];
            
            for (int i = 0; i < [arrComponents count]; i++) {
                NSDictionary *dicComp = [arrComponents objectAtIndex: i];
                
                NSArray *types = [dicComp objectForKey: @"types"];
                
                if ([types containsObject: @"country"]) {
                    country = [dicComp objectForKey: @"short_name"];
                    
                    break;
                }
                else if ([types containsObject: @"administrative_area_level_1"]) {
                    
                }
                else if ([types containsObject: @"locality"]) {
                    
                }
            }
            
            [self onActionLoginWithFacebook: country];
        }
        else {
            [mProgress hide: YES];
        }
    }
    else {
        [mProgress hide: YES];
    }
}

- (void)showLoading {
    //mProgress = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    mProgress = [MBProgressHUD showHUDAddedTo:[UIApplication sharedApplication].keyWindow animated:YES];
    mProgress.mode = MBProgressHUDModeIndeterminate;
    mProgress.labelText = @"Connecting...";
    [mProgress show:YES];
    
}

@end
