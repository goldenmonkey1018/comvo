//
//  ChangeEmailAddressViewController.h
//  Comvo
//
//  Created by Max Broeckel on 30/09/15.
//  Copyright (c) 2015 Max Broeckel. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MBProgressHUD;

@interface ChangeEmailAddressViewController : UIViewController{
    IBOutlet UITextField *mInputEmailAddress;
    
     MBProgressHUD           *mProgress;
}

- (IBAction)onTouchBtnBack: (id)sender;
- (IBAction)onTouchBtnSubmit: (id)sender;

@end
