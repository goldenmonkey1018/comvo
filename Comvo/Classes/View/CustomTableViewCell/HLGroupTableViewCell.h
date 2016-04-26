//
//  HLHomeFeedTableViewCell.h
//  BlueLetters
//
//  Created by DeMing Yu on 11/27/14.
//  Copyright (c) 2014 DeMing Yu. All rights reserved.
//

#import <UIKit/UIKit.h>

@class HLGroupTableViewCell;

@protocol HLGroupTableViewCellDelegate

@optional;

@end

@class GroupInfo;

@interface HLGroupTableViewCell : UITableViewCell {
    IBOutlet UIImageView        *mImgViewPhoto;
    IBOutlet UILabel            *mLblName;
    IBOutlet UILabel            *mLblMember;
}

@property (nonatomic, copy) GroupInfo *mGroupInfo;
@property (nonatomic, assign) id<HLGroupTableViewCellDelegate> delegate;

- (void)setGroupInfo: (GroupInfo *)info;

+ (id) sharedCell;


@end
