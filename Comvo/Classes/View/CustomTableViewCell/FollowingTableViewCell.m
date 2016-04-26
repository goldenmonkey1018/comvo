//
//  FollowingTableViewCell.m
//  Comvo
//
//  Created by Max Brian on 01/10/15.
//  Copyright (c) 2015 DeMing Yu. All rights reserved.
//

#import "FollowingTableViewCell.h"

#import <SDWebImage/UIImageView+WebCache.h>

#import "AppEngine.h"
#import "Constants_Comvo.h"

#import "HLCommunication.h"
#import <MBProgressHUD.h>

@implementation FollowingTableViewCell


@synthesize mUserInfo;
@synthesize delegate;

- (void)awakeFromNib {
    // Initialization code
    mPhoto.layer.cornerRadius = 20.0f;
    mPhoto.clipsToBounds = YES;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setUserInfo:(UserInfo *)userInfo{
    [self setMUserInfo: userInfo];
    
    if([userInfo.mIsFollowing isEqualToString:@"1"])
        [btnFollow setTitle:@"Unfollow" forState:UIControlStateNormal];
    else
        [btnFollow setTitle:@"Follow" forState:UIControlStateNormal];
    
    [mPhoto sd_setImageWithURL: [NSURL URLWithString: [NSString stringWithFormat: @"%@%@", API_HOME, userInfo.mPhotoUrl]]   placeholderImage: [UIImage imageNamed: @"common_img_placehold_photo.png"]];
    
    [mUsername setText: userInfo.mFullName];
}

- (IBAction)onTouchFollowBtn:(id)sender{
    NSLog(@"Touched Follow Button");
    NSLog(@"%@", mUserInfo.mUserId);
    
    nFollowMode = 0;
    if ([btnFollow.currentTitle isEqualToString:@"Follow"])
         nFollowMode = 1;
    else if ([btnFollow.currentTitle isEqualToString:@"Unfollow"])
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
                [btnFollow setTitle:@"Unfollow" forState:UIControlStateNormal];
            else if (nFollowMode == 2)
                [btnFollow setTitle:@"Follow" forState:UIControlStateNormal];   //
            [mProgress hide:YES];
            [delegate didTouchedFollow: self];
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
    mProgress = [MBProgressHUD showHUDAddedTo:self.superview animated:YES];
    mProgress.mode = MBProgressHUDModeIndeterminate;
    
    if (nFollowMode == 1)
        mProgress.labelText = @"Following...";
    else if (nFollowMode == 2)
        mProgress.labelText = @"Unfollowing...";
    
    [mProgress show:YES];
}

@end
