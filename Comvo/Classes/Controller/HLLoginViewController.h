//
//  HLLoginViewController.h
//  Comvo
//
//  Created by DeMing Yu on 12/22/14.
//  Copyright (c) 2014 DeMing Yu. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MBProgressHUD;
@class SocialInfo;

@interface HLLoginViewController : UIViewController {
    IBOutlet UIScrollView   *mSView;
    IBOutlet UITextField    *mTextEmail;
    IBOutlet UITextField    *mTextPassword;
    
    MBProgressHUD           *mProgress;
}

@property (nonatomic, copy) SocialInfo  *mSocialInfo;

- (void)facebookLoaded;

@end
