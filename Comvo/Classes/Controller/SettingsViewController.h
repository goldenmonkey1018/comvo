//
//  SettingsViewController.h
//  Comvo
//
//  Created by Max Broeckel on 30/09/15.
//  Copyright (c) 2015 Max Broeckel. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SettingsViewController : UIViewController{
    IBOutlet UISwitch *mNotification;
}

- (IBAction)onTouchBtnBack: (id)sender;
- (IBAction)onInviteFriends:(id)sender ;
- (IBAction)onChangedNotification:(id)sender;

- (IBAction)onTouchLogOut:(id)sender;

@end
