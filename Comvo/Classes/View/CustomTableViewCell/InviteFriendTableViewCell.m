//
//  InviteFriendTableViewCell.m
//  Comvo
//
//  Created by Max Brian on 01/10/15.
//  Copyright (c) 2015 DeMing Yu. All rights reserved.
//

#import "InviteFriendTableViewCell.h"

#import "AppEngine.h"
#import "Constants_Comvo.h"

#import <SDWebImage/UIImageView+WebCache.h>

#import "HLCommunication.h"
#import <MBProgressHUD.h>

@interface InviteFriendTableViewCell ()

@end

@implementation InviteFriendTableViewCell

@synthesize mUserInfo;
@synthesize delegate;

- (void)awakeFromNib {
    // Initialization code
    mPhoto.layer.cornerRadius = 20.0f;
    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
    
}

- (void)setUsersInfo: (UserInfo *)info {
    
    [self setMUserInfo: info];
    
    if ([[Engine gCurrentUser].mUserId isEqualToString:info.mUserId])
        [mBtnFollow setHidden: YES];
    
    if([info.mIsFollowing isEqualToString:@"1"])
        [mBtnFollow setTitle:@"Unfollow" forState:UIControlStateNormal];
    else
        [mBtnFollow setTitle:@"Follow" forState:UIControlStateNormal];
    
    // 1. Photo and User name
    if ([info.mPhotoUrl isEqualToString: @""]) {
        [mPhoto setImage: [UIImage imageNamed: @"profile_img_default_regular.png"]];
    }
    else {
        [mPhoto sd_setImageWithURL: [NSURL URLWithString: [NSString stringWithFormat: @"%@%@", API_HOME, info.mPhotoUrl]] placeholderImage: [UIImage imageNamed: @"profile_img_default_regular.png"]];
    }
    
    mPhoto.layer.cornerRadius = 20.0f;
    mPhoto.clipsToBounds = YES;
    
    
    [mUsername setText: info.mFullName];
}

- (IBAction)onTouchBtnFollow:(id)sender{
    NSLog(@"Invite Friend Table View");
    
    NSLog(@"%@", mUserInfo.mUserId);
    
    nFollowMode = 0;
    if ([mBtnFollow.currentTitle isEqualToString:@"Follow"])
        nFollowMode = 1;
    else if ([mBtnFollow.currentTitle isEqualToString:@"Unfollow"])
        nFollowMode = 2;
    
    [self showLoading];
    
    NSDictionary *parameters = nil;
    void ( ^successed )( id responseObject ) = ^( id responseObject ) {
        NSLog(@"JSON: %@", responseObject);
        
        int result = [[responseObject objectForKey: @"success"] intValue];
        if (result) {
            NSDictionary *dicData = [responseObject objectForKey: @"data"];
            
            //self.mPostInfo.mLiked = [dicData objectForKey: @"like_state"];
            
            if (nFollowMode == 1)
                [mBtnFollow setTitle:@"Unfollow" forState:UIControlStateNormal];
            else if (nFollowMode == 2)
                [mBtnFollow setTitle:@"Follow" forState:UIControlStateNormal];   //
            [mProgress hide:YES];
          
            [delegate didTouchedFollowButton: self];
        }
        else {
            [mProgress hide:YES];
        }
    };
    
    void ( ^failure )( NSError* error ) = ^( NSError* error ) {
        NSLog(@"Error: %@", error);
        [mProgress hide:YES];
        
    };
    
    if (nFollowMode == 1)
        parameters = @{@"user_id":      [Engine gCurrentUser].mUserId,
                       @"target_user":  mUserInfo.mUserId,
                       @"action_type":  @"follow"};
    else if (nFollowMode == 2)
        parameters = @{@"user_id":      [Engine gCurrentUser].mUserId,
                       @"target_user":  mUserInfo.mUserId,
                       @"action_type":  @"unfollow"};
    
    [[HLCommunication sharedManager] sendToService: API_FOLLOWUSER params: parameters success: successed failure: failure];
    
    
}

- (void)showLoading {
    //mProgress = [MBProgressHUD showHUDAddedTo:self.superview animated:YES];
    mProgress = [MBProgressHUD showHUDAddedTo:[UIApplication sharedApplication].keyWindow animated:YES];
    mProgress.mode = MBProgressHUDModeIndeterminate;
    
    if (nFollowMode == 1)
        mProgress.labelText = @"Following...";
    else if (nFollowMode == 2)
        mProgress.labelText = @"Unfollowing...";
    
    [mProgress show:YES];
}

@end
