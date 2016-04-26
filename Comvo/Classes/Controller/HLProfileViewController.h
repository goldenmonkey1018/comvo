//
//  HLProfileViewController.h
//  Comvo
//
//  Created by Max Broeckel on 9/28/15.
//  Copyright (c) 2015 Max Broeckel. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol HLProfileViewControllerDelegate <NSObject>

@optional

- (void)didBackedFromRecordAudio;
- (void)didFinishedRecordAudio: (NSData *)mediaData url: (NSURL *)url;

@end

@class MBProgressHUD;
@class AVPlayer;


@interface HLProfileViewController : UIViewController{
    IBOutlet UILabel *mUserName;        // Username
    
    IBOutlet UIButton *mUserImage;      // UserImage
    IBOutlet UIButton *mPlayGreeting;   // Play Greeting Audio
    
    IBOutlet UILabel *mUserPostCnt;        // Username Post Cnt
    IBOutlet UILabel *mUserVoicesCnt;        // Username Post Cnt
    IBOutlet UILabel *mUserListenersCnt;        // Username Post Cnt
    
    MBProgressHUD           *mProgress; // Progress Bar
    int                     mPage;      // Page Num
    __strong NSMutableArray          *mArrPosts; // Posts Array
    __strong NSMutableArray          *mArrAudios; // Posts Array
    
    int                     mFeedMode;  // Feed Method
                                        // (Photo -> 0 / Video -> 1 / Audio -> 2)
    BOOL                    mFlgGreetingPlay;
    AVPlayer                *mAudioPlayer;
    
    int              mFlgDeleteButton;      // the Flag whether Delete button toggled or not
    
    NSURL                   *mAudioURL;
    
}

@property (nonatomic, assign) id<HLProfileViewControllerDelegate> delegate;

@property (nonatomic, weak) IBOutlet UITableView *tblAudioFeeds;
@property (nonatomic, weak) IBOutlet UICollectionView *colFeeds;

@property (nonatomic, weak) IBOutlet UIButton *btnTabAudio;
@property (nonatomic, weak) IBOutlet UIButton *btnTabVideo;
@property (nonatomic, weak) IBOutlet UIButton *btnTabPhoto;

- (void)getCurrentUserInfo;
- (void)actionUpdateGreetingAudio;
- (IBAction)onTouchDeleteButton:(id)sender;

@end
