//
//  HLSignupViewController.h
//  Comvo
//
//  Created by DeMing Yu on 12/22/14.
//  Copyright (c) 2014 DeMing Yu. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol HLSignupViewControllerDelegate <NSObject>

@optional

- (void)didBackedFromRecordAudio;
- (void)didFinishedRecordAudio: (NSData *)mediaData url: (NSURL *)url;

@end

@class MBProgressHUD;

@interface HLSignupViewController : UIViewController {
    IBOutlet UIScrollView   *mSView;
    
    IBOutlet UIImageView    *mImgViewPhoto;
    IBOutlet UITextField    *mTextFullname;
    IBOutlet UITextField    *mTextUsername;
    IBOutlet UITextField    *mTextEmail;
    IBOutlet UITextField    *mTextPassword;
    IBOutlet UITextField    *mTextConfirmPwd;
    
    IBOutlet UIButton       *mBtnTerms;
    
    MBProgressHUD           *mProgress;
    BOOL                    mFlgChangePhoto;
    BOOL                    mFlgChangeAudio;
    BOOL                    mFlgTerms;
    
    NSURL                   *mAudioURL;
}

@property (nonatomic, assign) id<HLSignupViewControllerDelegate> delegate;

@end
