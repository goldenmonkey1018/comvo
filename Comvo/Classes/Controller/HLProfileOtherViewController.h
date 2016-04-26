//
//  HLProfileViewController.h
//  Comvo
//
//  Created by Max Broeckel on 9/28/15.
//  Copyright (c) 2015 Max Broeckel. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol HLProfileOtherViewControllerDelegate <NSObject>

@optional

//- (void)didBackedFromRecordAudio;
//- (void)didFinishedRecordAudio: (NSData *)mediaData url: (NSURL *)url;

@end

@class MBProgressHUD;
@class UserInfo;
@class AVPlayer;


@interface HLProfileOtherViewController : UIViewController{
    IBOutlet UILabel *mUserName;        // Username
    
    IBOutlet UIButton *mUserImage;      // UserImage
    IBOutlet UIButton *mPlayGreeting;   // Play Greeting Audio
    IBOutlet UIButton *mBtnFollow;      // Follow / Unfollow Button
    
    IBOutlet UILabel *mUserPostCnt;        // Username Post Cnt
    IBOutlet UILabel *mUserVoicesCnt;        // Username Post Cnt
    IBOutlet UILabel *mUserListenersCnt;        // Username Post Cnt
    
    MBProgressHUD           *mProgress; // Progress Bar
    int                     mPage;      // Page Num
    __strong NSMutableArray          *mArrPosts; // Posts Array
    __strong NSMutableArray          *mArrAudios; // Posts Array
    __strong UserInfo                *mUserInfo;
    
    int                     mFeedMode;  // Feed Method
    // (Photo -> 0 / Video -> 1 / Audio -> 2)
    BOOL                    mFlgGreetingPlay;
    AVPlayer                *mAudioPlayer;
    
    int              mFlgDeleteButton;      // the Flag whether Delete button toggled or not
    int              mFollowMode;
    
    NSString         *mUserID;
    
    NSURL                   *mAudioURL;
    
}

@property (nonatomic, assign) id<HLProfileOtherViewControllerDelegate> delegate;

@property (nonatomic, weak) IBOutlet UITableView *tblAudioFeeds;
@property (nonatomic, weak) IBOutlet UICollectionView *colFeeds;

@property (nonatomic, weak) IBOutlet UIButton *btnTabAudio;
@property (nonatomic, weak) IBOutlet UIButton *btnTabVideo;
@property (nonatomic, weak) IBOutlet UIButton *btnTabPhoto;

@property (nonatomic, copy) NSString    *mStrProfileTag;
@property (nonatomic, copy) NSString    *mStrProfileID;



- (void)getCurrentUserInfo;
//- (void)actionUpdateGreetingAudio;
//- (IBAction)onTouchDeleteButton:(id)sender;

@end
