//
//  AudioFeedCell.h
//  Comvo
//
//  Created by Max Broeckel on 29/09/15.
//  Copyright (c) 2015 Max Broeckel. All rights reserved.
//

#import <UIKit/UIKit.h>

@class AudioFeedCell;

@protocol AudioFeedCellDelegate

@optional;
- (void)didTouchedProfileLike: (AudioFeedCell *)tableViewCell;
- (void)didTouchedProfileComment: (AudioFeedCell *)tableViewCell;
- (void)didTouchedProfileReport: (AudioFeedCell *)tableViewCell;
- (void)didTouchedProfileDownload: (AudioFeedCell *)tableViewCell;
- (void)didTouchedProfileAudioDelete: (AudioFeedCell *)tableViewCell;

- (void)didFinishedDeleteAudio: (AudioFeedCell*) tableViewCell;

@end

@class PostInfo;
@class DDProgressView;
@class AVPlayer;

@class MBProgressHUD;

@interface AudioFeedCell : UITableViewCell{
    IBOutlet UIView             *mViewAudio;
    
    IBOutlet UIButton           *mBtnLikesCount;    // Like Button
    IBOutlet UIButton           *mBtnCommentsCount; // Comment Button
    IBOutlet UIButton           *mBtnDownload;      // Download Button
    IBOutlet UIButton           *mBtnShare;         // Share Button
    
    IBOutlet UIButton           *BtnAudioDelete;         // Delete Button
    
    IBOutlet UILabel            *mLblTime;          // Time (how many ago)
    
    IBOutlet UIView             *mViewProgress;     // Audio Play Progress
    IBOutlet UIButton           *mBtnAudioPlay;     // Audio Play Button
    
    DDProgressView              *mProgressView;
    
    AVPlayer                    *mAudioPlayer;
    NSTimer                     *mDuringTimer;
    
    BOOL                        mFlgAudioPlay;
    
    MBProgressHUD           *mProgress;
}

@property (nonatomic, copy) PostInfo    *mPostInfo;
@property (nonatomic, assign) id<AudioFeedCellDelegate> delegate;


- (void)setPostInfo:(PostInfo *)postInfo flag: (BOOL) fDeleteFlg;
- (void)actionDeleteAudio;

- (IBAction)onTouchBtnLike: (id)sender;
- (IBAction)onTouchBtnComment: (id)sender;
- (IBAction)onTouchBtnReport: (id)sender;
- (IBAction)onTouchBtnDownload: (id)sender;
- (IBAction)onTouchBtnAudioDelete: (id)sender;

@end
