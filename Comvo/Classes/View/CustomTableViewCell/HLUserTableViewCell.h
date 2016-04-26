//
//  HLHomeFeedTableViewCell.h
//  BlueLetters
//
//  Created by DeMing Yu on 11/27/14.
//  Copyright (c) 2014 DeMing Yu. All rights reserved.
//

#import <UIKit/UIKit.h>

@class HLUserTableViewCell;

@protocol HLUserTableViewCellDelegate

@optional;

@end

@class UserInfo;

@interface HLUserTableViewCell : UITableViewCell {
    IBOutlet UIImageView        *mImgViewPhoto;
    IBOutlet UILabel            *mLblUserName;
}

@property (nonatomic, copy) UserInfo *mUserInfo;
@property (nonatomic, assign) id<HLUserTableViewCellDelegate> delegate;

- (void)setUserInfo: (UserInfo *)info;

+ (id) sharedCell;


@end
