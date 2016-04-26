//
//  FollowingTableViewCell.h
//  Comvo
//
//  Created by Max Brian on 01/10/15.
//  Copyright (c) 2015 DeMing Yu. All rights reserved.
//

#import <UIKit/UIKit.h>

@class  FollowingTableViewCell;;
@class  UserInfo;

@protocol FollowingTableViewCellDelegate

@optional;
- (void)didTouchedFollow: (FollowingTableViewCell *)tableViewCell;

@end

@class AudioFeedCell;
@class MBProgressHUD;


@interface FollowingTableViewCell : UITableViewCell{
    IBOutlet    UIImageView *mPhoto;
    IBOutlet    UILabel *mUsername;
    IBOutlet    UIButton *btnFollow;
    
    MBProgressHUD           *mProgress;
    int nFollowMode;
}

@property (nonatomic, copy) UserInfo    *mUserInfo;
@property (nonatomic, assign) id<FollowingTableViewCellDelegate> delegate;

- (IBAction)onTouchFollowBtn:(id)sender;
- (void)setUserInfo:(UserInfo *)userInfo;

@end
