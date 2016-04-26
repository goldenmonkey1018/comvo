//
//  ChangeUsernameViewController.h
//  Comvo
//
//  Created by Max Broeckel on 30/09/15.
//  Copyright (c) 2015 Max Broeckel. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MBProgressHUD;

@interface ChangeUsernameViewController : UIViewController{
    IBOutlet UITextField *mInputUsername;
    
    MBProgressHUD           *mProgress;
}

- (IBAction)onTouchBtnBack: (id)sender;
- (IBAction)onTouchBtnSubmit:(id)sender;

@end
