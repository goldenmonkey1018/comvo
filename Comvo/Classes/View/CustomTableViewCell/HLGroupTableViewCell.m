//
//  HLHomeFeedTableViewCell.m
//  BlueLetters
//
//  Created by DeMing Yu on 11/27/14.
//  Copyright (c) 2014 DeMing Yu. All rights reserved.
//

#import "HLGroupTableViewCell.h"

#import "AppEngine.h"
#import "Constants_Comvo.h"

#import <SDWebImage/UIImageView+WebCache.h>

@interface HLGroupTableViewCell ()

@end

@implementation HLGroupTableViewCell

@synthesize delegate;

+(id) sharedCell
{
    HLGroupTableViewCell* cell = nil;
    
    if (IS_IPHONE5) {
        cell = [[[ NSBundle mainBundle ] loadNibNamed:@"HLGroupTableViewCell~iPhone5" owner:nil options:nil] objectAtIndex:0] ;
    }
    else if (IS_IPHONE6) {
        cell = [[[ NSBundle mainBundle ] loadNibNamed:@"HLGroupTableViewCell~iPhone6" owner:nil options:nil] objectAtIndex:0] ;
    }
    else {
        cell = [[[ NSBundle mainBundle ] loadNibNamed:@"HLGroupTableViewCell~iPhone5" owner:nil options:nil] objectAtIndex:0] ;
    }
    
    return cell ;
}

- (void)awakeFromNib {
    // Initialization code
    
    mImgViewPhoto.layer.cornerRadius = 20.0f;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setGroupInfo: (GroupInfo *)info {
    [self setMGroupInfo: info];   
    
    if ([info.mGroupName isEqualToString: @""]) {
        [mLblMember setText: @""];
        
        // 1:1 Chat
        for (UserInfo *uInfo in info.mArrMembers) {
            if (![uInfo.mUserId isEqualToString: [Engine gCurrentUser].mUserId]) {
                [mLblName setText: uInfo.mFullName];
                if ([uInfo.mPhotoUrl isEqualToString: @""]) {
                    [mImgViewPhoto setImage: [UIImage imageNamed: @"profile_img_default_regular.png"]];
                }
                else {
                    [mImgViewPhoto sd_setImageWithURL: [NSURL URLWithString: [NSString stringWithFormat: @"%@%@", API_HOME, uInfo.mPhotoUrl]] placeholderImage: [UIImage imageNamed: @"profile_img_default_regular.png"]];
                }
            }
        }
        
        [mLblName setFrame: CGRectMake(mLblName.frame.origin.x, 24, mLblName.frame.size.width, mLblName.frame.size.height)];
        
    }
    else {
        [mLblName setText: info.mGroupName];
        
        NSString *members = @"";
        
        for (int i = 0; i < [info.mArrMembers count]; i++) {
            UserInfo *uInfo = [info.mArrMembers objectAtIndex: i];
            
            members = [members stringByAppendingString: uInfo.mFullName];
            
            if (i < [info.mArrMembers count] - 1) {
                members = [members stringByAppendingString: @","];
            }
        }
        
        [mLblMember setText: members];
        
        [mLblName setFrame: CGRectMake(mLblName.frame.origin.x, 13, mLblName.frame.size.width, mLblName.frame.size.height)];
    }
}

@end
