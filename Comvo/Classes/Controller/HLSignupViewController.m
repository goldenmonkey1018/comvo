//
//  HLSignupViewController.m
//  Comvo
//
//  Created by DeMing Yu on 12/22/14.
//  Copyright (c) 2014 DeMing Yu. All rights reserved.
//

#import "HLSignupViewController.h"

#import <MBProgressHUD.h>

#import "AppEngine.h"
#import "Constants_Comvo.h"
#import "HLCommunication.h"
#import "HLPreviewViewController.h"

#import "AppDelegate.h"

#import "HLAudioViewController.h"

#import "HLHomeTabBarController.h"

#import <MobileCoreServices/MobileCoreServices.h>

#import <AdobeCreativeSDKImage/AdobeCreativeSDKImage.h>
#import <AdobeCreativeSDKCore/AdobeCreativeSDKCore.h>
#import <AssetsLibrary/AssetsLibrary.h>


#import "UIImage+Resize.h"
#import "UIImage+Crop.h"

@interface HLSignupViewController () <UINavigationControllerDelegate, UIImagePickerControllerDelegate, UIActionSheetDelegate, UIAlertViewDelegate, HLAudioViewControllerDelegate, HLPreviewViewControllerDelegate, AdobeUXImageEditorViewControllerDelegate>

@end

@implementation HLSignupViewController

@synthesize delegate;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self.navigationController setNavigationBarHidden: NO];
    
    [self.navigationController.navigationBar setBackgroundImage:[UIImage new]
                                                  forBarMetrics:UIBarMetricsDefault];
    self.navigationController.navigationBar.shadowImage = [UIImage new];
    self.navigationController.navigationBar.translucent = YES;
    
    self.title = @"Sign Up";
    [self.navigationController.navigationBar
     setTitleTextAttributes:@{NSForegroundColorAttributeName : [UIColor whiteColor]}];
    
    UIButton *btnBack = [UIButton buttonWithType: UIButtonTypeSystem];
    [btnBack setFrame: CGRectMake(0, 0, 30, 30)];
    [btnBack setTintColor: [UIColor whiteColor]];
    [btnBack setImage: [UIImage imageNamed: @"common_img_back.png"] forState: UIControlStateNormal];
    [btnBack addTarget: self action: @selector(onTouchBtnBack :) forControlEvents: UIControlEventTouchUpInside];
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView: btnBack];
    
    [[UIApplication sharedApplication] setStatusBarStyle: UIStatusBarStyleLightContent animated: YES];
    
    mImgViewPhoto.layer.cornerRadius = 31.0f;
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget: self action: @selector(onTapPhoto:)];
    [mImgViewPhoto addGestureRecognizer: tapGesture];
    
    mFlgChangeAudio = FALSE;
    mFlgTerms = FALSE;
    
    //mProgress = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    //mProgress.mode = MBProgressHUDModeIndeterminate;
    //[mProgress hide: NO];
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

- (IBAction)onTouchBtnRecord: (id)sender {
    NSLog(@"Record Button Touched");
    
    [Engine setGAudioRecordingMode:@"GreetingAudio"];
    
    HLAudioViewController *audioView = (HLAudioViewController *)[self.storyboard instantiateViewControllerWithIdentifier: @"HLAudioViewController"];
    audioView.delegate = self;
    
    [self.navigationController pushViewController: audioView animated: YES];
}

- (IBAction)onTouchBtnBack: (id)sender {
    [self.navigationController popViewControllerAnimated: YES];
}

- (IBAction)onTouchBtnCheckTerms: (id)sender {
    mFlgTerms = !mFlgTerms;
    
    if (mFlgTerms) {
        [mBtnTerms setImage: [UIImage imageNamed: @"common_img_check.png"] forState: UIControlStateNormal];
    }
    else {
        [mBtnTerms setImage: [UIImage imageNamed: @"common_img_uncheck.png"] forState: UIControlStateNormal];
    }
}

- (IBAction)onTouchBtnSignup: (id)sender {
    NSLog(@"Touch Button Signup");
    
    if ([mTextFullname.text isEqualToString: @""] || [mTextUsername.text isEqualToString: @""] || [mTextEmail.text isEqualToString: @""])
    {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Warning" message:@"Please fill out fields." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alertView show];
        
        return;
    }
    
    if (![mTextPassword.text isEqualToString: mTextConfirmPwd.text])
    {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Warning" message:@"Wrong password with confirm password" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alertView show];
        
        return;
    }
    
    if (!mFlgTerms)
    {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Warning" message:@"Please check Agree Terms" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
        [alertView show];
        
        return;
    }
    
    [self getFullAddress: [NSString stringWithFormat: @"%f", [Engine gCurrentLocation].latitude] :[NSString stringWithFormat: @"%f", [Engine gCurrentLocation].longitude]];
}

//==========================================================================================================================

#pragma mark -
#pragma mark - Tap Gesture

- (void)onTapPhoto: (UITapGestureRecognizer *)recognizer {
    if (SYSTEM_VERSION_LESS_THAN(@"8.0")) {
        
        UIActionSheet *actionSheet = [[UIActionSheet alloc]
                                      initWithTitle:@"Edit Photo"
                                      delegate:self
                                      cancelButtonTitle:@"Cancel"
                                      destructiveButtonTitle: nil
                                      otherButtonTitles: @"Camera", @"From Photo Library", nil];
        
        actionSheet.tag = 0;
        
        [actionSheet showInView: self.view];
        
    }
    else {
        UIAlertController * alertController = [UIAlertController alertControllerWithTitle:@"Edit Photo"
                                                                                  message:nil
                                                                           preferredStyle:UIAlertControllerStyleActionSheet];
        
        [alertController addAction:[UIAlertAction actionWithTitle:@"Camera"
                                                            style:UIAlertActionStyleDefault
                                                          handler:^(UIAlertAction *action) {
                                                              if([UIImagePickerController isSourceTypeAvailable: UIImagePickerControllerSourceTypeCamera] == NO)
                                                              {
                                                                  return ;
                                                              }
                                                              
                                                              UIImagePickerController *pickerController = [[UIImagePickerController alloc] init];
                                                              pickerController.delegate  = self;
                                                              pickerController.allowsEditing = YES;
                                                              pickerController.sourceType = UIImagePickerControllerSourceTypeCamera;
                                                              pickerController.cameraCaptureMode = UIImagePickerControllerCameraCaptureModePhoto;
                                                              
                                                              [self presentViewController: pickerController animated: YES completion: nil];
                                                          }]];
        [alertController addAction:[UIAlertAction actionWithTitle:@"From Photo Library"
                                                            style:UIAlertActionStyleDefault
                                                          handler:^(UIAlertAction *action) {
                                                              
                                                              UIImagePickerController *pickerController = [[UIImagePickerController alloc] init];
                                                              pickerController.delegate = self;
                                                              //pickerController.allowsEditing = YES;
                                                              pickerController.allowsEditing = YES;
                                                              pickerController.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
                                                              
                                                              [self presentViewController: pickerController animated: YES completion: nil];
                                                          }]];
        
        [alertController addAction:[UIAlertAction actionWithTitle:@"Cancel"
                                                            style:UIAlertActionStyleCancel
                                                          handler:nil]];
        
        [self presentViewController:alertController animated:YES completion:nil];
    }
}

//=========================================================================================================

#pragma mark -
#pragma mark - Image Picker

- (void)imagePickerController: (UIImagePickerController *) picker didFinishPickingMediaWithInfo: (NSDictionary *) _info {
    
    
    [picker dismissViewControllerAnimated : YES completion : ^{
        if ([[_info valueForKey: UIImagePickerControllerMediaType] isEqualToString: (NSString *)kUTTypeImage]) {
            NSString* const CreativeSDKClientId = @"c09ef6af818c4ffd9abf963c8165eb4e";
            NSString* const CreativeSDKClientSecret = @"d7250b05-f316-453f-ac13-21c63a5e0625";
            
            [[AdobeUXAuthManager sharedManager] setAuthenticationParametersWithClientID:CreativeSDKClientId withClientSecret:CreativeSDKClientSecret];
            
            UIImage *image = [_info[UIImagePickerControllerOriginalImage] resizedImage];
            
            CGRect rect = [_info[UIImagePickerControllerCropRect] CGRectValue];
            CGFloat s = MAX(rect.size.width, rect.size.height);
            CGRect r = CGRectMake(CGRectGetMidX(rect) - s * 0.5,
                                  CGRectGetMidY(rect) - s * 0.5, s, s);
            CGRect croppedRect = r;
            UIImage *croppedImage = [image imageCroppedToRect:croppedRect];
            
            NSArray * toolOrder = @[kAFEnhance, kAFEffects, kAFStickers, kAFOrientation, kAFFocus, kAFColorAdjust,  kAFLightingAdjust, kAFOrientation, kAFSharpness, kAFAdjustments, kAFDraw, kAFRedeye, kAFWhiten, kAFText, kAFBlur, kAFMeme, kAFFrames, kAFSplash];
            [AFPhotoEditorCustomization setToolOrder:toolOrder];
            
            AdobeUXImageEditorViewController *editorController = [[AdobeUXImageEditorViewController alloc] initWithImage: croppedImage];
            [editorController setDelegate:self];
            [self presentViewController:editorController animated:YES completion:nil];
        }
    }];
    
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    mFlgChangePhoto = NO;
    
    [picker dismissViewControllerAnimated: YES completion: nil];
}


//========================================================================================================

#pragma mark -
#pragma mark - AdobeUXImageEditorViewControllerDelegate

- (void)photoEditor:(AdobeUXImageEditorViewController *)editor finishedWithImage:(UIImage *)image {
    // Handle the result image here
    
    if (abs(image.size.height - image.size.width) < 5)
    {
        [self dismissViewControllerAnimated: YES completion: nil];
        
        //[self initialize];
        
        NSLog(@"%f", image.size.height);
        NSLog(@"%f", image.size.width);
        
        
        //[delegate didFinishedPhotoEdit: UIImageJPEGRepresentation(image, 0.8) url: nil];
        mFlgChangePhoto = YES;
        
        [mImgViewPhoto setImage: image];
    }
    else
    {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle: @"Warning" message: @"Please adjust width/height rate with your image." delegate: nil cancelButtonTitle: @"OK" otherButtonTitles: nil, nil];
        
        [alertView show];
    }
    
}

//================================================================================================================

#pragma mark -
#pragma mark - UIActionSheet Delegate

-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (actionSheet.tag == 0) {
        NSString *buttonTitle = [actionSheet buttonTitleAtIndex:buttonIndex];
        if  ([buttonTitle isEqualToString:@"Camera"]) {
            if([UIImagePickerController isSourceTypeAvailable: UIImagePickerControllerSourceTypeCamera] == NO)
            {
                return ;
            }
            
            UIImagePickerController *pickerController = [[UIImagePickerController alloc] init];
            pickerController.delegate  = self;
            pickerController.sourceType = UIImagePickerControllerSourceTypeCamera;
            pickerController.cameraCaptureMode = UIImagePickerControllerCameraCaptureModePhoto;
            
            [self presentViewController: pickerController animated: YES completion: nil];
            
        }
        else if ([buttonTitle isEqualToString:@"From Photo Library"]) {
            UIImagePickerController *pickerController = [[UIImagePickerController alloc] init];
            pickerController.delegate = self;
            pickerController.editing = NO;
            pickerController.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
            
            [self presentViewController: pickerController animated: YES completion: nil];
            
        }
    }
    
}

//==========================================================================================================================

#pragma mark -
#pragma mark - Action

- (void)onActionSignup: (NSString *)address {

    NSDictionary *parameters = nil;
    
    void ( ^successed )( id responseObject ) = ^( id responseObject ) {
        NSLog(@"JSON: %@", responseObject);
        
        NSDictionary *dicData = [responseObject objectForKey: @"data"];
        
        if ([dicData count] == 0){
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle: @"Error" message: [responseObject valueForKey: @"message"] delegate: nil cancelButtonTitle: @"Ok" otherButtonTitles: nil];
            [alertView show];
            
            [mProgress hide: YES];
        }
        else if ([dicData count] > 0){
            NSDictionary *dicUser = [dicData objectForKey: @"user"];
            
            UserInfo *userInfo = [[UserInfo alloc] init];
            
            userInfo.mUserId            = [dicUser objectForKey: @"user_id"];
            userInfo.mEmail             = [dicUser objectForKey: @"email"];
            userInfo.mUserName          = [dicUser objectForKey: @"username"];
            userInfo.mSessToken         = [dicUser objectForKey: @"sess_token"];
            userInfo.mPhotoUrl          = [dicUser objectForKey: @"profile_photo"];
            userInfo.mPassword          = [dicUser objectForKey: @"password"];
            userInfo.mFullName          = [dicUser objectForKey: @"fullname"];
            userInfo.mFollowersCount    = [dicUser objectForKey: @"followers_count"];
            userInfo.mFollowingsCount   = [dicUser objectForKey: @"following_count"];
            userInfo.mStatus            = [dicUser objectForKey: @"status"];
            userInfo.mLastLogin         = [dicUser objectForKey: @"last_login"];
            userInfo.mRegisterDate      = [dicUser objectForKey: @"register_date"];
            userInfo.mGreetingAudioUrl  = [dicUser objectForKey: @"greeting_audio"];
            userInfo.mPostCount         = [dicUser objectForKey: @"posts_count"];
            userInfo.mPhotosCount       = [dicUser objectForKey: @"picture_count"];
            userInfo.mAudioCount        = [dicUser objectForKey: @"audio_count"];
            userInfo.mVideoCount        = [dicUser objectForKey: @"video_count"];
            userInfo.mLocation          = [dicUser objectForKey: @"location"];
            
            [Engine setGCurrentUser: userInfo];
            
            int result = [[responseObject objectForKey: @"success"] intValue];
            if (result) {
                
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle: @"Welcome to signing up --- OUR COMVO!!!" message: [responseObject valueForKey: @"message"] delegate: nil cancelButtonTitle: @"Ok" otherButtonTitles: nil];
                [alertView show];
                
                [AppDel showHomeViewController];
            }
            else {
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle: @"Warning" message: [responseObject valueForKey: @"message"] delegate: nil cancelButtonTitle: @"Ok" otherButtonTitles: nil];
                [alertView show];
            }
            
            [mProgress hide: YES];
        }
        
    };
    
    void ( ^failure )( NSError* error ) = ^( NSError* error ) {
        NSLog(@"Error: %@", error);
        
        [mProgress hide: YES];
    };
    
    parameters = @{@"email":         mTextEmail.text,
                   @"username":      mTextUsername.text,
                   @"fullname":      mTextFullname.text,
                   @"password":      mTextPassword.text,
                   @"lat":           [NSString stringWithFormat: @"%f", [Engine gCurrentLocation].latitude],
                   @"lng":           [NSString stringWithFormat: @"%f", [Engine gCurrentLocation].longitude],
                   @"location":      address};
    
    //parameters = @{@"email":         mTextEmail.text,
    //               @"username":      mTextUsername.text,
    //               @"fullname":      mTextFullname.text,
    //               @"password":      mTextPassword.text,
    //               @"lat":           @"37.332331",
    //               @"lng":           @"-122.031219",
    //               @"location":      @"US"};
    
    if (mFlgChangePhoto && mFlgChangeAudio) {
        [[HLCommunication sharedManager] sendToServiceWithProfileImage:API_REGISTER params:parameters image:UIImageJPEGRepresentation(mImgViewPhoto.image, 0.8) greetingAudio:[NSData dataWithContentsOfURL: mAudioURL] success:successed failure:failure];
    }
    else if (mFlgChangePhoto){
        [[HLCommunication sharedManager] sendToServiceWithProfileImage:API_REGISTER params:parameters image:UIImageJPEGRepresentation(mImgViewPhoto.image, 0.8)  success:successed failure:failure];
    }
    else {
        [[HLCommunication sharedManager] sendToService: API_REGISTER params: parameters success: successed failure: failure];
    }
}

//============================================================================================================================

-(void)getFullAddress:(NSString*)latitude :(NSString*)longitude {
    //[mProgress show: YES];
    [self showLoading];
    
    //[self onActionSignup: @"US"];
    
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
            
            [self onActionSignup: country];
        }
        else {
            [mProgress hide: YES];
        }
    }
    else {
        [mProgress hide: YES];
    }
}

//==========================================================================================================================

#pragma mark -
#pragma mark - HLPreviewViewControllerDelegate

- (void)didDonePreview: (NSString *)mediaType mediaURL: (NSURL *)mediaURL mediaData: (NSData *)mediaData {
    [self.navigationController popViewControllerAnimated: NO];
    
    mAudioURL = mediaURL;
    mFlgChangeAudio = TRUE;
    
    //[delegate didFinishedRecordAudio: [NSData dataWithContentsOfURL: mAudioURL] url: mediaURL];
}

- (void)didBackFromPreview: (NSString *)mediaType {
    [self.navigationController popViewControllerAnimated: NO];
    
    if ([mediaType isEqualToString: @"1"]) {
        [Engine setGAudioRecordingMode:@"StreamingAudio"];
        
        HLAudioViewController *audioView = (HLAudioViewController *)[self.storyboard instantiateViewControllerWithIdentifier: @"HLAudioViewController"];
        audioView.delegate = self;
        [self.navigationController pushViewController: audioView animated: YES];
    }
}

//========================================================================================================

#pragma mark -
#pragma mark - HLAudioViewControllerDelegate

- (void)didBackedFromRecordAudio {
    [self.navigationController popViewControllerAnimated: NO];
    
    [delegate didBackedFromRecordAudio];
}

- (void)didFinishedRecordAudio: (NSURL *)audioURL {
    [self.navigationController popViewControllerAnimated: NO];
    
    //mAudioURL = audioURL;
    
    HLPreviewViewController *previewView = (HLPreviewViewController *)[self.storyboard instantiateViewControllerWithIdentifier: @"HLPreviewViewController"];
    previewView.delegate = self;
    previewView.mMediaType = @"1";
    previewView.mMediaURL = audioURL;
    previewView.mMediaData = [NSData dataWithContentsOfURL: audioURL];
    [self.navigationController pushViewController: previewView animated: YES];
    
    
}

- (void)showLoading {
    mProgress = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    mProgress.mode = MBProgressHUDModeIndeterminate;
    mProgress.labelText = @"Registering...";
    [mProgress show:YES];
}


@end
