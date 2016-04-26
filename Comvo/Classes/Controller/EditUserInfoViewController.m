//
//  EditUserInfoViewController.m
//  Comvo
//
//  Created by Max Brian on 02/10/15.
//  Copyright (c) 2015 DeMing Yu. All rights reserved.
//

#import "EditUserInfoViewController.h"

#import <MBProgressHUD.h>

#import "AppEngine.h"
#import "Constants_Comvo.h"
#import "HLCommunication.h"

#import <SDWebImage/UIButton+WebCache.h>
#import <SDWebImage/UIImageView+WebCache.h>

#import <MobileCoreServices/MobileCoreServices.h>

#import <AdobeCreativeSDKImage/AdobeCreativeSDKImage.h>
#import <AdobeCreativeSDKCore/AdobeCreativeSDKCore.h>

#import "UIImage+Resize.h"
#import "UIImage+Crop.h"

@interface EditUserInfoViewController ()<UINavigationControllerDelegate, UIImagePickerControllerDelegate, UIActionSheetDelegate, UIAlertViewDelegate>

@end

@implementation EditUserInfoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self initNavigationBar];
    // Do any additional setup after loading the view.

    mImgPhoto.layer.cornerRadius = 50.0f;
    mImgPhoto.clipsToBounds = YES;
    
    NSString *strPhotoUrl = [Engine gCurrentUser].mPhotoUrl;
    
    [mImgPhoto sd_setImageWithURL:[NSURL URLWithString: [NSString stringWithFormat: @"%@%@", API_HOME, strPhotoUrl]] placeholderImage:[UIImage imageNamed: @"common_img_placehold_photo.png"]];
    
    NSLog(@"%@", [Engine gCurrentUser].mUserId);
    NSLog(@"%@", [Engine gCurrentUser].mUserName);
    NSLog(@"%@", [Engine gCurrentUser].mEmail);
    NSLog(@"%@", [Engine gCurrentUser].mFullName);
    NSLog(@"%@", [Engine gCurrentUser].mPassword);
    NSLog(@"%@", [Engine gCurrentUser].mPostCount);
    
    
    mUsername.text = [Engine gCurrentUser].mUserName;
    mFullname.text = [Engine gCurrentUser].mFullName;
    mEmailAddress.text = [Engine gCurrentUser].mEmail;
    
    //[mImgPhoto sd_setImageWithURL:[NSURL URLWithString: [NSString stringWithFormat: @"%@%@", FILE_HOME, strPhotoUrl]] forState:UIControlStateNormal placeholderImage:[UIImage imageNamed: @"common_img_placehold_photo.png"]];
    
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget: self action: @selector(onTapPhotoImg:)];
    [mImgPhoto addGestureRecognizer: tapGesture];


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

- (void) initNavigationBar{
    UIButton *button =  [UIButton buttonWithType:UIButtonTypeCustom];
    [button setBackgroundImage:[UIImage imageNamed:@"common_img_bar.png"] forState:UIControlStateNormal];
    [button addTarget:self action:@selector(onTouchBtnConfirm:)forControlEvents:UIControlEventTouchUpInside];
    [button setFrame:CGRectMake(0, 0, 63, 31)];
    
    UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(3, 5, 60, 20)];
    [label setFont:[UIFont fontWithName:@"Arial-BoldMT" size:13]];
    [label setText:@"Done"];
    label.textAlignment = UITextAlignmentCenter;
    [label setTextColor:[UIColor whiteColor]];
    [label setBackgroundColor:[UIColor clearColor]];
    [button addSubview:label];
    
    UIBarButtonItem *barButton = [[UIBarButtonItem alloc] initWithCustomView:button];
    self.navigationItem.rightBarButtonItem = barButton;
}

//================================================================================================================

#pragma mark -
#pragma mark - Touch Event

- (IBAction)onTouchBtnBack: (id)sender {
    [self.navigationController popViewControllerAnimated: YES];
}

- (IBAction)onTouchBtnConfirm:(id)sender{
    NSLog(@"Confirm Button");
    
    NSLog(@"Touched Submit");
    
    NSString *newUsername = mUsername.text;
    NSString *newFullname = mFullname.text;
    //NSString *newPassword = mPassword.text;
    NSString *newEmailAddress = mEmailAddress.text;
    
    if ([newUsername isEqualToString: @""] || [newFullname isEqualToString: @""] ||
        [newEmailAddress isEqualToString: @""])
    {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Warning" message:@"Please fill out items." delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
        [alertView show];
        
        return;
    }
    
    [self showLoading];
    
    NSMutableDictionary *parameters = [NSMutableDictionary new];
    
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
            
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle: @"User information has been changed successfully." message: [responseObject valueForKey: @"Success"] delegate: nil cancelButtonTitle: @"Ok" otherButtonTitles: nil];
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
    
    NSString *updatelist = [[NSString alloc] initWithData:[NSJSONSerialization dataWithJSONObject:@{@"username":newUsername, @"fullname":newFullname, @"email":newEmailAddress} options:0 error:nil] encoding:NSUTF8StringEncoding];
    
//    NSString *updatelist = [[NSString alloc] initWithData:[NSJSONSerialization dataWithJSONObject:@{@"username":newUsername } options:0 error:nil] encoding:NSUTF8StringEncoding];
    
    
    parameters[@"user_id"] = [Engine gCurrentUser].mUserId;
    
    //NSDictionary *parameterDic = @{@"username" : newUsername ,
    //                               @"fullname" : newFullname ,
    //                               @"password" : newPassword ,
    //                               @"email" : newEmailAddress};
    
    parameters[@"updatelist"] = updatelist;
    
    //[[HLCommunication sharedManager] sendToService: API_UPDATEPROFILE params: parameters success: successed failure: failure];
    
    [[HLCommunication sharedManager] sendToServiceWithProfileImage: API_UPDATEPROFILE params: parameters image: UIImageJPEGRepresentation(mImgPhoto.image, 0.8) success: successed failure: failure];
}

- (void)showLoading {
    mProgress = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    mProgress.mode = MBProgressHUDModeIndeterminate;
    mProgress.labelText = @"Submitting...";
    [mProgress show:YES];
}

//==========================================================================================================================

#pragma mark -
#pragma mark - Tap Gesture

- (void)onTapPhotoImg: (UITapGestureRecognizer *)recognizer {
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
                                                              pickerController.editing = NO;
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

//========================================================================================================

#pragma mark -
#pragma mark - AdobeUXImageEditorViewControllerDelegate

- (void)photoEditor:(AdobeUXImageEditorViewController *)editor finishedWithImage:(UIImage *)image {
    // Handle the result image here
    
    NSLog(@"%f", image.size.height);
    NSLog(@"%f", image.size.width);
    
    if (abs(image.size.height - image.size.width) < 5)
    {
        [self dismissViewControllerAnimated: YES completion: nil];
        
        //[self initialize];
        
        NSLog(@"%f", image.size.height);
        NSLog(@"%f", image.size.width);
        
        [mImgPhoto setImage:image];
    }
    else
    {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle: @"Warning" message: @"Please adjust width/height rate with your image." delegate: nil cancelButtonTitle: @"OK" otherButtonTitles: nil, nil];
        
        [alertView show];
    }
    
}

- (void)photoEditorCanceled:(AdobeUXImageEditorViewController *)editor {
    // Handle cancellation here
    
    [self dismissViewControllerAnimated: YES completion: nil];
}

//=========================================================================================================

#pragma mark -
#pragma mark - Image Picker

- (void)imagePickerController: (UIImagePickerController *) picker didFinishPickingMediaWithInfo: (NSDictionary *) _info {
    mFlgChangePhoto = YES;
    
    //[mImgPhoto setImage: [_info valueForKey: UIImagePickerControllerEditedImage]];
    
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
            
            NSArray * toolOrder = @[kAFEnhance, kAFEffects, kAFCrop, kAFStickers, kAFOrientation, kAFFocus, kAFColorAdjust,  kAFLightingAdjust, kAFOrientation, kAFSharpness, kAFAdjustments, kAFDraw, kAFRedeye, kAFWhiten, kAFText, kAFBlur, kAFMeme, kAFFrames, kAFSplash, ];
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


@end
