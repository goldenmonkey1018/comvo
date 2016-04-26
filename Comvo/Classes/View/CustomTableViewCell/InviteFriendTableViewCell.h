//
//  InviteFriendTableViewCell.h
//  Comvo
//
//  Created by Max Brian on 01/10/15.
//  Copyright (c) 2015 DeMing Yu. All rights reserved.
//

#import <UIKit/UIKit.h>

@class InviteFriendTableViewCell;

@protocol InviteFriendTableViewCellDelegate

@optional;
- (void)didTouchedFollowButton:(InviteFriendTableViewCell *)tableViewCell;

@end

@class UserInfo;
@class MBProgressHUD;

@interface InviteFriendTableViewCell : UITableViewCell{
    IBOutlet UIImageView *mPhoto;
    IBOutlet UILabel *mUsername;
    IBOutlet UIButton *mBtnFollow;
    
    MBProgressHUD           *mProgress;
    int nFollowMode;
}

@property (nonatomic, copy) UserInfo *mUserInfo;

@property (nonatomic, assign) id<InviteFriendTableViewCellDelegate> delegate;

- (void)setUsersInfo: (UserInfo *)info;
- (IBAction)onTouchBtnFollow:(id)sender;

@end
