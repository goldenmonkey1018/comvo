//
//  MessageGroupTableViewCell.h
//  Comvo
//
//  Created by Max Brian on 11/11/15.
//  Copyright (c) 2015 DeMing Yu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppEngine.h"
#import "Constants_Comvo.h"

@class MessageGroupTableViewCell;

@protocol MessageGroupTableViewCellDelegate

@optional;
//- (void)didTouchedFollowButton:(InviteFriendTableViewCell *)tableViewCell;

@end

@interface MessageGroupTableViewCell : UITableViewCell{
    IBOutlet UIButton *mPhotoGroup;
    IBOutlet UILabel  *mGroupName;
    IBOutlet UILabel  *mGroupMember;

}

@property (nonatomic, copy) UserInfo *mUserInfo;

@property (nonatomic, assign) id<MessageGroupTableViewCellDelegate> delegate;

- (void)setUsersInfo: (UserInfo *)info;

@end
