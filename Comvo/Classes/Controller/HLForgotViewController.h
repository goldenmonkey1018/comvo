//
//  HLForgotViewController.h
//  Comvo
//
//  Created by Max Broeckel on 28/09/15.
//  Copyright (c) 2015 DeMing Yu. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MBProgressHUD;

@interface HLForgotViewController : UIViewController{
    IBOutlet UITextField    *mEMailAddress;
    
    IBOutlet UIButton       *mBtnSubmit;
    
    MBProgressHUD           *mProgress;
}

@end
