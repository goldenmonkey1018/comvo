//
//  HLHomeFeedTableViewCell.h
//  BlueLetters
//
//  Created by DeMing Yu on 11/27/14.
//  Copyright (c) 2014 DeMing Yu. All rights reserved.
//

#import <UIKit/UIKit.h>

@class HLHomeFeedTableViewCell;

@protocol HLHomeFeedTableViewCellDelegate

@optional;
- (void)didTouchedLike: (HLHomeFeedTableViewCell *)tableViewCell;
- (void)didTouchedComment: (HLHomeFeedTableViewCell *)tableViewCell;
- (void)didTouchedReport: (HLHomeFeedTableViewCell *)tableViewCell;
- (void)didTouchedHashTag: (HLHomeFeedTableViewCell *)tableViewCell hashTag: (NSString *)hashTag;

- (void)didTouchedUserName: (HLHomeFeedTableViewCell *)tableViewCell userName: (NSString *)userName;
- (void)didTouchedUserName: (HLHomeFeedTableViewCell *)tableViewCell userID: (NSString *)userID;

- (void)didTouchedDownload: (HLHomeFeedTableViewCell *)tableViewCell;
- (void)didTouchedThumbnail : (HLHomeFeedTableViewCell *)tableViewCell;

- (void)didTouchedDeleteButton : (HLHomeFeedTableViewCell *)tableViewCell;


@end

@class OHAttributedLabel;
@class PostInfo;

@class AVPlayer;
@class AVPlayerLayer;

@class DDProgressView;
@class MBProgressHUD;

@interface HLHomeFeedTableViewCell : UITableViewCell {
    IBOutlet UIView             *mViewComment;
    
    IBOutlet UIView             *mViewAudio;
    IBOutlet UIView             *mViewPhoto;
    IBOutlet UIView             *mViewVideo;
    IBOutlet UIView             *mViewOption;
    
    IBOutlet UILabel            *mLblUserName;
    IBOutlet UILabel            *mLblLocation;
    IBOutlet UILabel            *mLblTime;
    
    IBOutlet UIButton           *mBtnPlay;
    IBOutlet UIButton           *mBtnProfilePhoto;
    IBOutlet UIButton           *mBtnUsername;
    
    IBOutlet OHAttributedLabel  *mLblCaption;
    IBOutlet UIButton           *mBtnLikesCount;
    IBOutlet UIButton           *mBtnCommentsCount;
    IBOutlet UIButton           *mBtnDownload;
    IBOutlet UIButton           *mBtnShare;
    IBOutlet UIButton           *mBtnDelete;
    
    IBOutlet UIButton           *mBtnThumbnail;
    
    AVPlayer                    *mAVPlayer;
    AVPlayerLayer               *mAVPlayerLayer;
    
    IBOutlet UIView             *mViewProgress;
    IBOutlet UIButton           *mBtnAudioPlay;
    DDProgressView              *mProgressView;
    
    AVPlayer                    *mAudioPlayer;
    NSTimer                     *mDuringTimer;
    BOOL                        mFlgPlay;
    BOOL                        mFlgCommentPlay;
    
    MBProgressHUD               *mProgress;
}

@property (nonatomic, weak) IBOutlet UIImageView        *mImgViewPhoto;
@property (nonatomic, weak) IBOutlet UIImageView        *mImgViewProfilePhoto;

@property (nonatomic, copy) PostInfo    *mPostInfo;
@property (nonatomic, assign) id<HLHomeFeedTableViewCellDelegate> delegate;

- (void)setPostInfo:(PostInfo *)postInfo;

- (IBAction)onTouchThumbnail:(id)sender;
- (IBAction)onTouchDeleteButton:(id)sender;

- (IBAction)onTouchUsername:(id)sender;
- (IBAction)onTouchProfilePhoto:(id)sender;

+ (id) sharedCell;
+ (CGSize)messageSize:(NSString*)message;
+ (CGSize)messageSize:(NSString*)message label:(UILabel *)label;

@end
