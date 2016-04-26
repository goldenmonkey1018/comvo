//
//  EditUserInfoViewController.h
//  Comvo
//
//  Created by Max Brian on 02/10/15.
//  Copyright (c) 2015 DeMing Yu. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MBProgressHUD;

@interface EditUserInfoViewController : UIViewController{
    IBOutlet UIImageView *mImgPhoto;
    
    IBOutlet UITextField *mUsername;
    IBOutlet UITextField *mFullname;
    IBOutlet UITextField *mEmailAddress;
    //IBOutlet UITextField *mPassword;
    
    MBProgressHUD           *mProgress;
    
    BOOL                    mFlgChangePhoto;
}

- (IBAction)onTouchBtnBack: (id)sender;
- (IBAction)onTouchBtnConfirm:(id)sender;

@end
