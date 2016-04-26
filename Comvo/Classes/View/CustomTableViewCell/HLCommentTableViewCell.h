//
//  HLHomeFeedTableViewCell.h
//  BlueLetters
//
//  Created by DeMing Yu on 11/27/14.
//  Copyright (c) 2014 DeMing Yu. All rights reserved.
//

#import <UIKit/UIKit.h>

#include "SWTableViewCell.h"

@class HLCommentTableViewCell;

@protocol HLCommentTableViewCellDelegate

- (void)didTouchHashTag: (HLCommentTableViewCell *)tableViewCell hashTag: (NSString *)hashTag;

- (void)didTouchUserName: (HLCommentTableViewCell *)tableViewCell userName: (NSString *)userName;
- (void)didTouchUserName: (HLCommentTableViewCell *)tableViewCell userID: (NSString *)userID;

@optional;

- (void)didFinishedDelete: (HLCommentTableViewCell *)tableViewCell;


@end

@class CommentInfo;
@class OHAttributedLabel;
@class DDProgressView;
@class AVPlayer;
@class MBProgressHUD;


@interface HLCommentTableViewCell : SWTableViewCell {
    
    IBOutlet UIImageView        *mImgViewPhoto;
    IBOutlet UILabel            *mLblUserName;
    IBOutlet UIView             *mViewAudio;
    IBOutlet UIView             *mViewProgress;
    
    IBOutlet UIButton           *mBtnPlay;
    IBOutlet UIButton           *mBtnDelete;
    
    IBOutlet UIButton           *mBtnPhoto;
    IBOutlet UILabel            *mlblTimeAgo;
    
    DDProgressView              *mProgressView;
    
    AVPlayer                    *mAudioPlayer;
    NSTimer                     *mDuringTimer;
    BOOL                        mFlgPlay;
    
    MBProgressHUD               *mProgress;
}

@property (nonatomic, strong) IBOutlet OHAttributedLabel  *mLblCaption;
@property (nonatomic, copy) CommentInfo *mCommentInfo;
@property (nonatomic, assign) id<HLCommentTableViewCellDelegate> delegateComment;

- (void)setCommentInfo: (CommentInfo *)cInfo;

- (IBAction)onBtnDelete:(id)sender;
- (IBAction)onBtnPhotoImg:(id)sender;

+ (id) sharedCell;
+ (CGSize)messageSize:(NSString*)message;
+ (CGSize)messageSize:(NSString*)message label:(UILabel *)label;

@end
