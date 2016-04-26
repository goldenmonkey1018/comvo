//
//  HLHomeFeedTableViewCell.m
//  BlueLetters
//
//  Created by DeMing Yu on 11/27/14.
//  Copyright (c) 2014 DeMing Yu. All rights reserved.
//

#import "HLUserTableViewCell.h"

#import "AppEngine.h"
#import "Constants_Comvo.h"

#import <SDWebImage/UIImageView+WebCache.h>

@interface HLUserTableViewCell ()

@end

@implementation HLUserTableViewCell

@synthesize delegate;

+(id) sharedCell
{
    HLUserTableViewCell* cell = nil;
    
    if (IS_IPHONE5) {
        cell = [[[ NSBundle mainBundle ] loadNibNamed:@"HLUserTableViewCell~iPhone5" owner:nil options:nil] objectAtIndex:0] ;
    }
    else if (IS_IPHONE6) {
        cell = [[[ NSBundle mainBundle ] loadNibNamed:@"HLUserTableViewCell~iPhone6" owner:nil options:nil] objectAtIndex:0] ;
    }
    else {
        cell = [[[ NSBundle mainBundle ] loadNibNamed:@"HLUserTableViewCell~iPhone5" owner:nil options:nil] objectAtIndex:0] ;
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

- (void)setUserInfo: (UserInfo *)info {
    [self setMUserInfo: info];
    
    // 1. Photo and User name
    if ([info.mPhotoUrl isEqualToString: @""]) {
        [mImgViewPhoto setImage: [UIImage imageNamed: @"profile_img_default_regular.png"]];
    }
    else {
        [mImgViewPhoto sd_setImageWithURL: [NSURL URLWithString: [NSString stringWithFormat: @"%@%@", API_HOME, info.mPhotoUrl]] placeholderImage: [UIImage imageNamed: @"profile_img_default_regular.png"]];
    }
    [mLblUserName setText: info.mFullName];
}

@end
