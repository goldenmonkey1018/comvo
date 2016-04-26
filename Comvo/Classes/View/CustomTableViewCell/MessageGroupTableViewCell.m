//
//  MessageGroupTableViewCell.m
//  Comvo
//
//  Created by Max Brian on 11/11/15.
//  Copyright (c) 2015 DeMing Yu. All rights reserved.
//

#import "MessageGroupTableViewCell.h"


#import "HLCommunication.h"
#import <MBProgressHUD.h>

@implementation MessageGroupTableViewCell

@synthesize mUserInfo;
@synthesize delegate;


- (void)awakeFromNib {
    // Initialization code
    mPhotoGroup.layer.cornerRadius = 20.0f;
    mPhotoGroup.clipsToBounds = TRUE;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setUsersInfo: (UserInfo *)info{
    
}

@end
