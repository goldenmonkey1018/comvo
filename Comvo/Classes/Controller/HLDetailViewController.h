//
//  HLDetailViewController.h
//  Comvo
//
//  Created by Max Broeckel on 19/10/15.
//  Copyright (c) 2015 Max Broeckel. All rights reserved.
//

#import <UIKit/UIKit.h>

@class PostInfo;
@class AVPlayer;
@class AVPlayerLayer;
@class MBProgressHUD;

@interface HLDetailViewController : UIViewController{
    IBOutlet UIView *mViewPhoto;
    IBOutlet UIView *mViewVideo;
    
    IBOutlet UIImageView *mProfilePhoto;
    IBOutlet UIButton *mTimeAgo;
    
    IBOutlet UILabel *mFullname;
    
    IBOutlet UIButton *mBtnLike;
    IBOutlet UIButton *mBtnViewComment;
    
    IBOutlet UIButton *mBtnPlay;
    
    AVPlayer   *mAVPlayer;
    AVPlayerLayer *mAVPlayerLayer;
    
    MBProgressHUD      *mProgress;
}

- (IBAction)onTouchPlayButton:(id)sender;
- (IBAction)onTouchViewComment:(id)sender;

@property (nonatomic, weak) IBOutlet UIImageView        *mImgViewPhoto;

@property (nonatomic, copy) PostInfo    *mPostInfo;

@end
