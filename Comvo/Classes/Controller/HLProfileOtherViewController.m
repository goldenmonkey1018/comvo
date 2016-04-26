//
//  HLProfileViewController.m
//  Comvo
//
//  Created by Max Broeckel on 9/28/15.
//  Copyright (c) 2015  Yu. All rights reserved.
//

#import "HLProfileOtherViewController.h"

#import "PhotoFeedCell.h"
#import "VideoFeedCell.h"
#import "AppEngine.h"

#import "Constants_Comvo.h"
#import <MBProgressHUD.h>
#import <SVPullToRefresh.h>

#import <AVFoundation/AVFoundation.h>

#import <DDProgressView.h>
#import <QuartzCore/QuartzCore.h>
#import <SDWebImage/UIImageView+WebCache.h>
#import <SDWebImage/UIButton+WebCache.h>

#include "AudioFeedCell.h"
#include "PhotoFeedCell.h"
#include "VideoFeedCell.h"

#include "HLDetailViewController.h"
#import "HLAudioViewController.h"
#import "HLStreamViewController.h"

#include "HLCommentViewController.h"
#include "SettingsViewController.h"

#import "HLCommunication.h"

#import <SDWebImage/SDWebImageManager.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import <FBSDKShareKit/FBSDKShareKit.h>

#import "HLCommunication.h"


@interface HLProfileOtherViewController ()<UITableViewDataSource, UITableViewDelegate, UICollectionViewDataSource, UICollectionViewDelegate, AudioFeedCellDelegate, PhotoFeedCellDelegate, VideoFeedCellDelegate, HLAudioViewControllerDelegate, UIAlertViewDelegate>

@end

@implementation HLProfileOtherViewController

@synthesize delegate;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self initNavigation];
    
    __weak HLProfileOtherViewController *wself = self;
    [self.colFeeds addPullToRefreshWithActionHandler: ^{
        __strong HLProfileOtherViewController *sself = wself;
        if (!sself)
            return;
        [sself insertRowAtTop];
    }];
    
    [self.colFeeds addInfiniteScrollingWithActionHandler: ^{
        __strong HLProfileOtherViewController *sself = wself;
        if (!sself)
            return;
        [sself insertRowAtTop];
    }];
    
    [self.tblAudioFeeds addPullToRefreshWithActionHandler: ^{
        __strong HLProfileOtherViewController *sself = wself;
        if (!sself)
            return;
        [sself insertRowAtTop];
    }];
    
    [self.tblAudioFeeds addInfiniteScrollingWithActionHandler: ^{
        __strong HLProfileOtherViewController *sself = wself;
        if (!sself)
            return;
        [sself insertRowAtTop];
    }];
    
    NSLog(@"Profile tag : %@", self.mStrProfileTag);
    NSLog(@"Profile ID : %@", self.mStrProfileID);
    
    //[self initNavigation];
    mArrPosts = [[NSMutableArray alloc] init];
    mArrAudios = [[NSMutableArray alloc] init];
    
    mUserInfo = [[UserInfo alloc] init];
    
    mProgress = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    mProgress.mode = MBProgressHUDModeIndeterminate;
    [mProgress hide: NO];
    
    mFeedMode = FEED_MODE_PHOTO;
    
    mPage = 0;
    
    mFlgDeleteButton = FALSE;
    //[self getFeedWithMode:mFeedMode page:mPage];
    
    self.title = @"";
    //[Engine gCurrentUser].mFollowersCount
    
    //UIBarButtonItem *item1 = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"settings.png"] style:UIBarButtonItemStylePlain target:self action:@selector(onSettings)];
    //UIBarButtonItem *item2 = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"camera_img_record.png"] style:UIBarButtonItemStylePlain target:self action:@selector(onCameraImgRecord)];
    
    //self.navigationItem.rightBarButtonItems = @[item1, item2];
    //self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear: animated];
    
    [self.tabBarController.tabBar setHidden: NO];
    
    [self getCurrentUserInfo];
    // adding code
    NSLog(@"%@", mUserInfo.mFollowersCount);
    NSLog(@"%@", mUserInfo.mFollowingsCount);
    NSLog(@"%@", mUserInfo.mPostCount);
    
    [self refreshPostFollowNum];
    
    mUserImage.layer.cornerRadius = 20.0f;
    mUserImage.clipsToBounds = YES;
    
}


- (void) refreshPostFollowNum{
    if(mUserInfo.mFullName == nil)
        self.title = @"";
    else
        self.title = mUserInfo.mFullName;
    
    NSString *strPhotoUrl = mUserInfo.mPhotoUrl;
    if (mUserInfo.mPhotoUrl == nil)
        strPhotoUrl = @"";
    
    [mUserImage sd_setImageWithURL:[NSURL URLWithString: [NSString stringWithFormat: @"%@%@", API_HOME, strPhotoUrl]] forState:UIControlStateNormal placeholderImage:[UIImage imageNamed: @"common_img_placehold_photo.png"]];
    
    if(mUserInfo.mPostCount == nil)
        [mUserPostCnt setText:@"0"];
    else
        [mUserPostCnt setText:mUserInfo.mPostCount];
    
    if(mUserInfo.mFollowersCount == nil)
        [mUserVoicesCnt setText:@"0"];
    else
        [mUserVoicesCnt setText:mUserInfo.mFollowingsCount];
    
    if(mUserInfo.mFollowersCount == nil)
        [mUserListenersCnt setText:@"0"];
    else
        [mUserListenersCnt setText:mUserInfo.mFollowersCount];
    
    if (mUserInfo.mIsFollowing == nil)
    {
        [mBtnFollow setImage: [UIImage imageNamed: @"profile_follow.png"] forState: UIControlStateNormal];
    }
    else
    {
        if ([mUserInfo.mIsFollowing isEqualToString:@"0"])
            [mBtnFollow setImage: [UIImage imageNamed: @"profile_follow.png"] forState: UIControlStateNormal];
        else if ([mUserInfo.mIsFollowing isEqualToString:@"1"])
            [mBtnFollow setImage: [UIImage imageNamed: @"profile_unfollow.png"] forState: UIControlStateNormal];
    }
}

//================================================================================================================

#pragma mark -
#pragma mark - Get Current User Info

- (void)getCurrentUserInfo{
    NSLog(@"Greeting URL %@", [Engine gCurrentUser].mGreetingAudioUrl);
    NSDictionary *parameters = nil;
    
    [self showLoading];
    
    void ( ^successed )( id responseObject ) = ^( id responseObject ) {
        NSLog(@"JSON: %@", responseObject);
        
        int result = [[responseObject objectForKey: @"success"] intValue];
        if (result) {
            NSDictionary *dicData = [responseObject objectForKey: @"data"];
            NSDictionary *dicUser = [dicData objectForKey: @"user"];
            
            mUserInfo.mUserId            = [dicUser objectForKey: @"user_id"];
            mUserInfo.mUserName          = [dicUser objectForKey: @"username"];
            mUserInfo.mFullName          = [dicUser objectForKey: @"fullname"];
            mUserInfo.mFollowingsCount   = [dicUser objectForKey: @"followings_count"];
            mUserInfo.mFollowersCount    = [dicUser objectForKey: @"followers_count"];
            mUserInfo.mPostCount         = [dicUser objectForKey: @"posts_count"];
            mUserInfo.mPhotosCount       = [dicUser objectForKey: @"picture_count"];
            mUserInfo.mAudioCount        = [dicUser objectForKey: @"audio_count"];
            mUserInfo.mVideoCount        = [dicUser objectForKey: @"video_count"];
            mUserInfo.mPhotoUrl          = [dicUser objectForKey: @"profile_photo"];
            mUserInfo.mGreetingAudioUrl  = [dicUser objectForKey: @"greeting_audio"];
            mUserInfo.mIsFollowing       = [dicUser objectForKey: @"is_following"];
            
            [self refreshPostFollowNum];
            
            mPage = 0;
            mUserID = mUserInfo.mUserId;
            
            [self getFeedWithMode:mFeedMode page:mPage];
            
            NSLog(@"Greeting URL %@", mUserInfo.mGreetingAudioUrl);
            [mProgress hide: YES];
            
        }
        else {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle: @"Warning" message: [responseObject valueForKey: @"message"] delegate: nil cancelButtonTitle: @"Ok" otherButtonTitles: nil];
            [alertView show];
            
            [mProgress hide: YES];
            [self.navigationController popViewControllerAnimated: YES];
        }
        
        [mProgress hide: YES];
    };
    
    void ( ^failure )( NSError* error ) = ^( NSError* error ) {
        NSLog(@"Error: %@", error);
        
        [mProgress hide: YES];
    };
    
    if (![self.mStrProfileTag isEqualToString:@""] && self.mStrProfileTag != nil)
    {
        parameters = @{@"user_id":         [Engine gCurrentUser].mUserId,
                       @"target_username": self.mStrProfileTag};
    }
    else if (![self.mStrProfileID isEqualToString:@""] && self.mStrProfileID != nil)
    {
        parameters = @{@"user_id":         [Engine gCurrentUser].mUserId,
                       @"target_user":     self.mStrProfileID};
    }
    
    [[HLCommunication sharedManager] sendToService: API_GETSINGLEUSER params: parameters success: successed failure: failure];
}

- (NSString *)mediaTypeWithFeedMode:(NSInteger)feedMode
{
    switch (feedMode) {
        case FEED_MODE_AUDIO:
            return @"1";
        case FEED_MODE_PHOTO:
            return @"2";
        case FEED_MODE_VIDEO:
            return @"3";
            
        default:
            return @"2";
    }
}

- (void)initNavigation {
    [self.navigationController setNavigationBarHidden: NO];
    
    [[UINavigationBar appearance] setTintColor:[UIColor whiteColor]];
    self.navigationController.navigationBar.barTintColor = UIColorFromRGB(0x00AFF0);
    [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed: @"common_img_bar.png"]
                                                  forBarMetrics:UIBarMetricsDefault];
    self.navigationController.navigationBar.shadowImage = [UIImage new];
    self.navigationController.navigationBar.translucent = NO;
    
    
    [self.navigationController.navigationBar
     setTitleTextAttributes:@{NSForegroundColorAttributeName : [UIColor whiteColor]}];
    
    UIButton *btnBack = [UIButton buttonWithType: UIButtonTypeSystem];
    [btnBack setFrame: CGRectMake(0, 0, 30, 30)];
    [btnBack setTintColor: [UIColor whiteColor]];
    [btnBack setImage: [UIImage imageNamed: @"common_img_back.png"] forState: UIControlStateNormal];
    [btnBack addTarget: self action: @selector(onTouchBtnBack :) forControlEvents: UIControlEventTouchUpInside];
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView: btnBack];
    
}

- (IBAction)onTouchBtnBack: (id)sender {
    [self.navigationController popViewControllerAnimated: YES];
}

//================================================================================================================

#pragma mark -
#pragma mark - SVPullToRefresh

- (void)insertRowAtTop {
    int64_t delayInSeconds = 2.0;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        mPage = 0;
        
        [self getFeedWithMode:mFeedMode page:mPage];
        
        if (mFeedMode == FEED_MODE_AUDIO)
            [self.tblAudioFeeds.pullToRefreshView stopAnimating];
        else if (mFeedMode == FEED_MODE_PHOTO || mFeedMode == FEED_MODE_VIDEO)
            [self.colFeeds.pullToRefreshView stopAnimating];
    });
}


- (void)insertRowAtBottom {
    int64_t delayInSeconds = 2.0;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        
        [self getFeedWithMode:mFeedMode page:mPage];
        
        if (mFeedMode == FEED_MODE_AUDIO)
            [self.tblAudioFeeds.infiniteScrollingView stopAnimating];
        else if (mFeedMode == FEED_MODE_PHOTO || mFeedMode == FEED_MODE_VIDEO)
            [self.colFeeds.infiniteScrollingView stopAnimating];
    });
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)onSelectTab:(UIButton *)sender
{
    [self.btnTabPhoto setImage:[UIImage new] forState:UIControlStateNormal];
    [self.btnTabAudio setImage:[UIImage new] forState:UIControlStateNormal];
    [self.btnTabVideo setImage:[UIImage new] forState:UIControlStateNormal];
    [sender setImage:[UIImage imageNamed:@"profile_select_indicator"] forState:UIControlStateNormal];
    
    if (sender == self.btnTabAudio) { // Audio
        [UIView animateWithDuration:.2 animations:^{
            self.colFeeds.alpha = 0;
            self.tblAudioFeeds.alpha = 1;
        }];
        mFeedMode = FEED_MODE_AUDIO;
        
    } else if (sender == self.btnTabPhoto) { // Photo
        [UIView animateWithDuration:.2 animations:^{
            self.colFeeds.alpha = 1;
            self.tblAudioFeeds.alpha = 0;
        }];
        mFeedMode = FEED_MODE_PHOTO;
    } else { // Video
        [UIView animateWithDuration:.2 animations:^{
            self.colFeeds.alpha = 1;
            self.tblAudioFeeds.alpha = 0;
        }];
        mFeedMode = FEED_MODE_VIDEO;
    }
    
    mPage = 0;
    [self getFeedWithMode:mFeedMode page:mPage];
}

// Yemen vs. Korea DPR 0:1 (Awarded 0:3)
// Korea DPR vs. Uzbekistan 4:2
//
//================================================================================================================

#pragma mark -
#pragma mark - Get Feed

- (void)getFeedWithMode:(NSInteger)feedMode page: (int)page {
    NSDictionary *parameters = nil;
    
    NSLog(@"%d", mFeedMode);
    void ( ^successed )( id responseObject ) = ^( id responseObject ) {
        NSLog(@"JSON: %@", responseObject);
        
        NSMutableArray *posts = (feedMode == FEED_MODE_AUDIO) ? mArrAudios : mArrPosts;
        
        int result = [[responseObject objectForKey: @"success"] intValue];
        if (result) {
            
            if (mPage == 0) {
                [posts removeAllObjects];
            }
            
            NSDictionary *dicData = [responseObject objectForKey: @"data"];
            NSArray *arrPosts = [dicData objectForKey: @"posts"];
            
            for (int i = 0; i < [arrPosts count]; i++) {
                NSDictionary *dicPost = [arrPosts objectAtIndex: i];
                
                PostInfo *postInfo = [[PostInfo alloc] init];
                
                postInfo.mPostId            = [dicPost objectForKey: @"post_id"];
                postInfo.mUserId            = [dicPost objectForKey: @"user_id"];
                postInfo.mDescription       = [dicPost objectForKey: @"description"];
                postInfo.mMedia             = [dicPost objectForKey: @"media"];
                postInfo.mMediaType         = [dicPost objectForKey: @"media_type"];
                postInfo.mHashTags          = [dicPost objectForKey: @"hashtags"];
                postInfo.mCategoryId        = [dicPost objectForKey: @"category_id"];
                postInfo.mCommentsCount     = [dicPost objectForKey: @"comments_count"];
                postInfo.mLikesCount        = [dicPost objectForKey: @"likes_count"];
                postInfo.mPostDate          = [dicPost objectForKey: @"post_date"];
                postInfo.mLiked             = [dicPost objectForKey: @"liked"];
                postInfo.mFullName          = [dicPost objectForKey: @"fullname"];
                postInfo.mUserName          = [dicPost objectForKey: @"username"];
                postInfo.mProfilePhoto      = [dicPost objectForKey: @"profile_photo"];
                postInfo.mDuration          = [dicPost objectForKey: @"duration"];
                postInfo.mLocation          = [dicPost objectForKey: @"location"];
                postInfo.mThumbnail         = [dicPost objectForKey: @"thumbnail"];
                
                NSMutableArray *arrComments = [[NSMutableArray alloc] init];
                
                NSArray *comments = [dicPost objectForKey: @"commentlist"];
                for (NSDictionary *dicComment in comments) {
                    CommentInfo *cInfo = [[CommentInfo alloc] init];
                    
                    cInfo.mCommentId    = [dicComment objectForKey: @"comment_id"];
                    cInfo.mUserId       = [dicComment objectForKey: @"user_id"];
                    cInfo.mPostId       = [dicComment objectForKey: @"post_id"];
                    cInfo.mComment      = [dicComment objectForKey: @"comment"];
                    cInfo.mCommentDate  = [dicComment objectForKey: @"comment_date"];
                    cInfo.mFullName     = [dicComment objectForKey: @"fullname"];
                    cInfo.mUserName     = [dicComment objectForKey: @"username"];
                    
                    cInfo.mProfilePhoto = [dicComment objectForKey: @"profile_photo"];
                    cInfo.mCommentType  = [dicComment objectForKey: @"comment_type"];
                    cInfo.mDuration     = [dicComment objectForKey: @"duration"];
                    
                    [arrComments addObject: cInfo];
                }
                
                postInfo.mArrComments = arrComments;
                
                [posts addObject: postInfo];
            }
            
            if ([arrPosts count] > 0) {
                mPage ++;
            }
            
            if (feedMode == FEED_MODE_AUDIO)
                [self.tblAudioFeeds reloadData];
            else
                [self.colFeeds reloadData];
            
        }
        else {
            
        }
        
        
    };
    
    void ( ^failure )( NSError* error ) = ^( NSError* error ) {
        NSLog(@"Error: %@", error);
        
        
    };
    
    parameters = @{@"user_id":      mUserID,
                   @"target_user":  mUserID,
                   @"feed_type":    @"userprofile" ,
                   @"page":         [NSString stringWithFormat: @"%d", page],
                   @"media_type":   [self mediaTypeWithFeedMode:feedMode]};
    
    
    [[HLCommunication sharedManager] sendToService: API_GETFEED params: parameters success: successed failure: failure];
}

- (IBAction)onTouchSetting:(UIButton *)sender
{
    NSLog(@"Settings Button Touched");
}

- (IBAction)onTouchPlayProfile:(UIButton *)sender
{
    NSLog(@"Play Profile Button Touched");
    NSLog(@"%@", [Engine gCurrentUser].mGreetingAudioUrl);
    
    NSString *strGreetingUrl = mUserInfo.mGreetingAudioUrl;
    
    mFlgGreetingPlay = !mFlgGreetingPlay;
    
    if (mFlgGreetingPlay) {
        AVPlayerItem *playerItem=[[AVPlayerItem alloc] initWithURL: [NSURL URLWithString: [NSString stringWithFormat: @"%@%@", API_HOME, strGreetingUrl]]];
        
        if ([strGreetingUrl isEqualToString:@""])
        {
            mFlgGreetingPlay = FALSE;
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle: @"Play Profile" message: @"Greeting audio is empty" delegate: nil cancelButtonTitle: @"OK" otherButtonTitles: nil];
            [alertView show];
        }
        else
        {
            mAudioPlayer = [[AVPlayer alloc] initWithPlayerItem:playerItem];
            mAudioPlayer.actionAtItemEnd = AVPlayerActionAtItemEndNone;
            [[NSNotificationCenter defaultCenter] addObserver:self
                                                     selector:@selector(audioPlayerItemDidReachEnd:)
                                                         name:AVPlayerItemDidPlayToEndTimeNotification
                                                       object:[mAudioPlayer currentItem]];
            [[NSNotificationCenter defaultCenter] addObserver:self
                                                     selector:@selector(audioPlayerItemPlaybackStalled:)
                                                         name:AVPlayerItemPlaybackStalledNotification
                                                       object:mAudioPlayer];
            
            [mAudioPlayer play];
            
            // [mProgressView setOuterColor: UIColorFromRGB(0x00AFF0)];
            // [mProgressView setInnerColor: UIColorFromRGB(0x00AFF0)];
            // [mProgressView setNeedsDisplay];
            
            [mPlayGreeting setImage: [UIImage imageNamed: @"play_profile_pause"] forState: UIControlStateNormal];
            //[mPlayGreeting setBackgroundImage:[UIImage imageNamed: @"comment_img.pause.png"] forState:UIControlStateNormal];
        }
    }
    else {
        [mAudioPlayer pause];
        
        //        [mProgressView setOuterColor: UIColorFromRGB(0x989898)];
        //        [mProgressView setInnerColor: UIColorFromRGB(0x989898)];
        //        [mProgressView setNeedsDisplay];
        
        //[mPlayGreeting setImage: [UIImage imageNamed: @"feed_img_audio_play.png"] forState: UIControlStateNormal];
        [mPlayGreeting setImage:[UIImage imageNamed: @"play_profile"] forState:UIControlStateNormal];
        //[mPlayGreeting setHidden:NO];
        //[mPlayGreeting setAlpha:1.0];
        //mPlayGreeting.backgroundColor = [UIColor clearColor];
    }
    
}

- (IBAction)onTouchWriteProfile:(UIButton *)sender
{
    NSLog(@"Write Profile Button Touched");
    
    NSLog(@"Touched Follow Button");
    NSLog(@"%@", mUserInfo.mUserId);
    NSLog(@"%@", mUserInfo.mIsFollowing);
    
    mFollowMode = 0;
    if ([mUserInfo.mIsFollowing isEqualToString:@"0"])
        mFollowMode = 1;
    else if ([mUserInfo.mIsFollowing isEqualToString:@"1"])
        mFollowMode = 2;
    
    //if ([mUserInfo.mIsFollowing isEqualToString:@"1"])
    //{
    //    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Warning"
    //                                                    message:@"You're already following him."
    //                                                   delegate:self
    //                                          cancelButtonTitle:@"OK"
    //                                          otherButtonTitles:nil];
    //    [alert show];
    //    return;
    //}
    
    [self showLoading];
    
    NSDictionary *parameters = nil;
    void ( ^successed )( id responseObject ) = ^( id responseObject ) {
        NSLog(@"JSON: %@", responseObject);
        
        int result = [[responseObject objectForKey: @"success"] intValue];
        if (result) {
            NSDictionary *dicData = [responseObject objectForKey: @"data"];
            
            //self.mPostInfo.mLiked = [dicData objectForKey: @"like_state"];
            
            if (mFollowMode == 1)
            {
                [mBtnFollow setImage: [UIImage imageNamed: @"profile_unfollow.png"] forState: UIControlStateNormal];
                mUserInfo.mIsFollowing = @"1";
                
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Success"
                                                                message:@"You followed him successfully."
                                                               delegate:self
                                                      cancelButtonTitle:@"OK"
                                                      otherButtonTitles:nil];
                [alert show];
            }
            else if (mFollowMode == 2)
            {
                [mBtnFollow setImage: [UIImage imageNamed: @"profile_follow.png"] forState: UIControlStateNormal];
                mUserInfo.mIsFollowing = @"0";
                
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Success"
                                                                message:@"You unfollowed him successfully."
                                                               delegate:self
                                                      cancelButtonTitle:@"OK"
                                                      otherButtonTitles:nil];
                [alert show];
            }
            
            [mProgress hide:YES];

        }
        else {
            [mProgress hide:YES];
        }
    };
    
    void ( ^failure )( NSError* error ) = ^( NSError* error ) {
        NSLog(@"Error: %@", error);
        [mProgress hide:YES];
        
    };
    
    if (mFollowMode == 1)
        parameters = @{@"user_id":      [Engine gCurrentUser].mUserId,
                       @"target_user":  mUserInfo.mUserId,
                       @"action_type":  @"follow"};
    else if (mFollowMode == 2)
        parameters = @{@"user_id":      [Engine gCurrentUser].mUserId,
                       @"target_user":  mUserInfo.mUserId,
                       @"action_type":  @"unfollow"};
    
    [[HLCommunication sharedManager] sendToService: API_FOLLOWUSER params: parameters success: successed failure: failure];
}

- (IBAction)onTouchUserImage:(UIButton *)sender
{
    NSLog(@"User Image Button Touched");
}


//==========================================================================================================================

#pragma mark -
#pragma mark - AVPlayer Notification

- (void)audioPlayerItemDidReachEnd:(NSNotification *)notification {
    //    [mProgressView setOuterColor: UIColorFromRGB(0x989898)];
    //    [mProgressView setInnerColor: UIColorFromRGB(0x989898)];
    //    [mProgressView setNeedsDisplay];
    //
    mFlgGreetingPlay = FALSE;
    [mPlayGreeting setImage: [UIImage imageNamed: @"play_profile"] forState: UIControlStateNormal];
}

- (void)audioPlayerItemPlaybackStalled: (NSNotification *)notification {
    
}

//================================================================================================================

#pragma mark Collection View
#pragma mark - UICollectionView DataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    //[mUserPostCnt setText:[NSString stringWithFormat:@"%d", (int)[mArrPosts count]]];
    return mFeedMode == FEED_MODE_AUDIO ? 0 : [mArrPosts count];; // count of feeds
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewCell *res = nil;
    
    if (mFeedMode == FEED_MODE_PHOTO)
    {
        PhotoFeedCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"PhotoCell" forIndexPath:indexPath];
        
        cell.delegate = self;
        PostInfo *postInfo = [mArrPosts objectAtIndex: indexPath.row];
        
        //NSString *userID = postInfo.mUserId;
        //UserInfo *myUserInfo = [Engine gCurrentUser];
        
        //if ([userID isEqualToString:myUserInfo.mUserId] &&
        //   [postInfo.mMediaType integerValue] == 2) { // Photo
        
        
        [cell setPostInfo: postInfo flag:mFlgDeleteButton];
        //}
        res = cell;
    }
    else if (mFeedMode == FEED_MODE_VIDEO)
    {
        VideoFeedCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"VideoCell" forIndexPath:indexPath];
        
        cell.delegate = self;
        PostInfo *postInfo = [mArrPosts objectAtIndex: indexPath.row];
        
        [cell setPostInfo: postInfo flag:mFlgDeleteButton];
        
        res = cell;
    }
    
    return res;
}

//================================================================================================================

#pragma mark Table View
#pragma mark - UITableView DataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    //[mUserPostCnt setText:[NSString stringWithFormat:@"%d", (int)[mArrAudios count]]];
    return [mArrAudios count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    AudioFeedCell *cell = [tableView dequeueReusableCellWithIdentifier:@"AudioCell" forIndexPath:indexPath];
    
    cell.delegate = self;
    
    PostInfo *postInfo = [mArrAudios objectAtIndex: indexPath.row];
    
    [cell setPostInfo: postInfo flag:mFlgDeleteButton];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
    
}

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

//==========================================================================================================================

//#pragma mark -
//#pragma mark - Initialize

//- (void)initNavigation {
//    [self.navigationController setNavigationBarHidden: NO];

//[[UINavigationBar appearance] setTintColor:[UIColor whiteColor]];
//self.navigationController.navigationBar.barTintColor = UIColorFromRGB(0x00AFF0);
//self.navigationController.navigationBar.translucent = NO;

//    self.title = @"Profile";
//[self.navigationController.navigationBar
// setTitleTextAttributes:@{NSForegroundColorAttributeName : [UIColor whiteColor]}];

//UIImageView *imgView = [[UIImageView alloc] initWithImage: [[UIImage imageNamed: @"common_img_title.png"] imageWithRenderingMode: UIImageRenderingModeAlwaysOriginal]];
//self.navigationItem.titleView = imgView;
//}


//================================================================================================================

#pragma mark -
#pragma mark - AudioFeedCellDelegate

- (void)didTouchedProfileAudioDelete:(AudioFeedCell *)tableViewCell{
    
}

- (void)didTouchedProfileLike: (AudioFeedCell *)tableViewCell {
    
}

- (void)didTouchedProfileComment: (AudioFeedCell *)tableViewCell {
    HLCommentViewController *commentView = (HLCommentViewController *)[self.storyboard instantiateViewControllerWithIdentifier: @"HLCommentViewController"];
    commentView.mPostInfo = tableViewCell.mPostInfo;
    
    [self.navigationController pushViewController: commentView animated: YES];
}



- (void)didTouchedProfileDownload:(AudioFeedCell *)tableViewCell
{
    NSLog(@"This is Download Button");
    
    NSIndexPath *indexPath = [self.tblAudioFeeds indexPathForCell:tableViewCell];
    
    PostInfo *postInfo = [mArrAudios objectAtIndex: indexPath.row];
    
    if ([postInfo.mMediaType isEqualToString: @"1"]) { // Audio
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Information"
                                                        message:@"By technical issue, audio file can't download on your music gallery."
                                                       delegate:self
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
        /* NSURL *url = [NSURL URLWithString: [NSString stringWithFormat: @"%@%@", FILE_HOME, postInfo.mMedia]];\
         
         dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
         NSData *data = [NSData dataWithContentsOfURL:url];
         
         //Find a cache directory. You could consider using documenets dir instead (depends on the data you are fetching)
         NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
         NSString *path = [paths  objectAtIndex:0];
         
         //Save the data
         NSString *dataPath = [path stringByAppendingPathComponent:@"filename"];
         dataPath = [dataPath stringByStandardizingPath];
         NSLog(dataPath);
         
         BOOL success = [data writeToFile:dataPath atomically:YES];
         }); */
        
        // http://stackoverflow.com/questions/13147044/programmatically-add-content-to-music-library
        // Content - It is only possible if the app is for jailbroken devices.
        // In this case, you can use my libipodimport library for importing music and audio files to the iPod media library.
        
        
        //Download data
        
    }
    else if ([postInfo.mMediaType isEqualToString: @"2"]) { // Photo
        
        NSURL *url = [NSURL URLWithString: [NSString stringWithFormat: @"%@%@", API_HOME, postInfo.mMedia]];
        
        [[SDWebImageManager sharedManager] downloadImageWithURL:url options:0 progress:^(NSInteger receivedSize, NSInteger expectedSize) {
            
        } completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished, NSURL *imageURL) {
            
            if (image != nil) {
                ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
                [library writeImageToSavedPhotosAlbum:image.CGImage orientation:(ALAssetOrientation)image.imageOrientation completionBlock:^(NSURL *assetURL, NSError *error )
                 {
                     NSLog(@"IMAGE SAVED TO PHOTO ALBUM");
                     
                     [library assetForURL:assetURL resultBlock:^(ALAsset *asset )
                      {
                          NSLog(@"we have our ALAsset!");
                          
                          UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Success Download"
                                                                          message:@"Image saved to photo album."
                                                                         delegate:self
                                                                cancelButtonTitle:@"OK"
                                                                otherButtonTitles:nil];
                          [alert show];
                      }
                             failureBlock:^(NSError *error )
                      {
                          NSLog(@"Error loading asset");
                          
                          UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Failed Download"
                                                                          message:@"Image Download failed."
                                                                         delegate:self
                                                                cancelButtonTitle:@"OK"
                                                                otherButtonTitles:nil];
                          [alert show];
                          
                      }];
                 }];
            }
        }];
    }
    else if ([postInfo.mMediaType isEqualToString: @"3"]) { // Video
        NSURL *url = [NSURL URLWithString: [NSString stringWithFormat: @"%@%@", API_HOME, postInfo.mMedia]];
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
            NSData *data = [NSData dataWithContentsOfURL:url];
            
            //Find a cache directory. You could consider using documenets dir instead (depends on the data you are fetching)
            NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
            NSString *path = [paths  objectAtIndex:0];
            
            //Save the data
            NSString *dataPath = [path stringByAppendingPathComponent:@"filename.mp4"];
            dataPath = [dataPath stringByStandardizingPath];
            
            BOOL success = [data writeToFile:dataPath atomically:YES];
            
            NSURL *movieURL = [NSURL fileURLWithPath:dataPath];
            
            ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
            [library writeVideoAtPathToSavedPhotosAlbum:movieURL
                                        completionBlock:^(NSURL *assetURL, NSError *error)
             {
                 if (error)
                 {
                     UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Failed Download"
                                                                     message:@"Video Download failed."
                                                                    delegate:self
                                                           cancelButtonTitle:@"OK"
                                                           otherButtonTitles:nil];
                     [alert show];
                 }
                 else
                 {
                     UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Success Download"
                                                                     message:@"Video Download Successed."
                                                                    delegate:self
                                                           cancelButtonTitle:@"OK"
                                                           otherButtonTitles:nil];
                     [alert show];
                     
                 }
                 
             }];
        });
        
        
    }
    
}

- (void)didTouchedProfileReport: (AudioFeedCell *)tableViewCell {
    NSLog(@"This is Report Button");
    
    /*  Facebook Integration
     if ([tableViewCell.mPostInfo.mMediaType isEqualToString: @"1"]) // audio
     {
     
     }
     else if ([tableViewCell.mPostInfo.mMediaType isEqualToString: @"2"]) // photo
     {
     //        UIImage *image = tableViewCell.mImgViewPhoto.image;
     
     //        FBSDKSharePhoto *photo = [[FBSDKSharePhoto alloc] init];
     //        photo.image = image;
     //        photo.userGenerated = YES;
     //        FBSDKSharePhotoContent *content = [[FBSDKSharePhotoContent alloc] init];
     //        content.photos = @[photo];
     
     NSLog(@"%@", [NSString stringWithFormat: @"%@%@", FILE_HOME, tableViewCell.mPostInfo.mMedia]);
     FBSDKShareLinkContent *content = [[FBSDKShareLinkContent alloc] init];
     content.imageURL = [NSURL URLWithString:[NSString stringWithFormat: @"%@%@", FILE_HOME, tableViewCell.mPostInfo.mMedia]];
     
     [FBSDKShareDialog showFromViewController:self
     withContent:content
     delegate:nil];
     }
     else if ([tableViewCell.mPostInfo.mMediaType isEqualToString: @"3"]) // video
     {
     //NSURL *videoURL = [info objectForKey:UIImagePickerControllerReferenceURL];
     
     //NSURL *videoURL = tableViewCell.mPostInfo.mMedia;
     //NSURL *videoURL = [[NSURL URLWithString: [NSString stringWithFormat: @"%@%@", FILE_HOME, tableViewCell.mPostInfo.mMedia]] options:nil];
     
     //NSLog(tableViewCell.mPostInfo.mMedia);
     
     // NSURL *videoURL = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@", FILE_HOME, tableViewCell.mPostInfo.mMedia]];
     
     //FBSDKShareVideo *video = [[FBSDKShareVideo alloc] init];
     //video.videoURL = videoURL;
     ///FBSDKShareVideoContent *content = [[FBSDKShareVideoContent alloc] init];
     //content.video = video;
     
     //[FBSDKShareDialog showFromViewController:self
     withContent:content
     delegate:nil];
     
     NSLog(@"%@", [NSString stringWithFormat: @"%@%@", FILE_HOME, tableViewCell.mPostInfo.mMedia]);
     FBSDKShareLinkContent *content = [[FBSDKShareLinkContent alloc] init];
     content.imageURL = [NSURL URLWithString:[NSString stringWithFormat: @"%@%@", FILE_HOME, tableViewCell.mPostInfo.mMedia]];
     
     [FBSDKShareDialog showFromViewController:self
     withContent:content
     delegate:nil];
     } */
    
    
    // Instagram Integration
    
    UIActivityViewController *activityController = [[UIActivityViewController alloc] initWithActivityItems:@[[NSURL URLWithString:[NSString stringWithFormat: @"%@%@", API_HOME, tableViewCell.mPostInfo.mMedia]], @"sharing"] applicationActivities:nil];
    
    activityController.excludedActivityTypes = @[];
    [self presentViewController:activityController animated:YES completion:nil];
}


#pragma mark -
#pragma mark - PhotoFeedCellDelegate

- (void)didTouchedPhotoThumbnail:(PhotoFeedCell *)tableViewCell{
    //HLDetailViewController *detailView = (HLDetailViewController *)[self.storyboard instantiateViewControllerWithIdentifier: @"HLDetailViewController"];
    //detailView.mPostInfo = tableViewCell.mPostInfo;
    //[self.navigationController pushViewController: detailView animated: YES];
    
    HLStreamViewController *streamingView = (HLStreamViewController *)[self.storyboard instantiateViewControllerWithIdentifier: @"HLStreamViewController"];
    //detailView.mPostInfo = tableViewCell.mPostInfo;
    
    streamingView.mSpecializedPostID = tableViewCell.mPostInfo.mPostId;
    [self.navigationController pushViewController: streamingView animated: YES];
}

#pragma mark -
#pragma mark - VideoFeedCellDelegate

- (void)didTouchedVideoThumbnail:(VideoFeedCell *)tableViewCell{
    //HLDetailViewController *detailView = (HLDetailViewController *)[self.storyboard instantiateViewControllerWithIdentifier: @"HLDetailViewController"];
    //detailView.mPostInfo = tableViewCell.mPostInfo;
    //[self.navigationController pushViewController: detailView animated: YES];
    
    HLStreamViewController *streamingView = (HLStreamViewController *)[self.storyboard instantiateViewControllerWithIdentifier: @"HLStreamViewController"];
    //detailView.mPostInfo = tableViewCell.mPostInfo;
    
    streamingView.mSpecializedPostID = tableViewCell.mPostInfo.mPostId;
    [self.navigationController pushViewController: streamingView animated: YES];
}



//==========================================================================================================================

#pragma mark -
#pragma mark - UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 0) {
        if ([alertView.title isEqualToString:@"Play Profile"])
        {
            NSLog(@"Play Profile");
        }
    }
}

//==========================================================================================================================

#pragma mark -
#pragma mark - Waiting Progress Bar Delegate

- (void)showLoading {
    mProgress = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    mProgress.mode = MBProgressHUDModeIndeterminate;
    mProgress.labelText = @"Waiting...";
    [mProgress show:YES];
}
@end
