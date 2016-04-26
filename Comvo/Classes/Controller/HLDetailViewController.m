//
//  HLDetailViewController.m
//  Comvo
//
//  Created by Max Broeckel on 19/10/15.
//  Copyright (c) 2015 Max Broeckel. All rights reserved.
//

#import "HLDetailViewController.h"
#import "Constants_Comvo.h"
#import "AppEngine.h"
#import "HLCommentViewController.h"

#import "HLCommunication.h"

#import <SDWebImage/UIImageView+WebCache.h>
#import <AVFoundation/AVFoundation.h>

#import <MBProgressHUD.h>

@interface HLDetailViewController ()

@end

@implementation HLDetailViewController

@synthesize mPostInfo;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
   
    [self initNavigation];
    
    //self.mPostInfo.mProfilePhoto
    [mProfilePhoto sd_setImageWithURL:[NSURL URLWithString: [NSString stringWithFormat: @"%@%@", API_HOME, self.mPostInfo.mProfilePhoto]] placeholderImage:[UIImage imageNamed: @"common_img_placehold_photo.png"]];
    
    mProfilePhoto.layer.cornerRadius = 20.0f;
    mProfilePhoto.clipsToBounds = YES;
    
    NSDate *post_date = [NSDate dateWithTimeIntervalSince1970: [self.mPostInfo.mPostDate intValue]];
    NSDate *current_date  = [NSDate date];
    
    //[mTimeAgo setText: [self stringFromTimeInterval: post_date toDate: current_date]];
    [mTimeAgo setTitle:[self stringFromTimeInterval: post_date toDate: current_date] forState:UIControlStateNormal];
    
    [mFullname setText: mPostInfo.mFullName];
    
    [mBtnLike setTitle:[NSString stringWithFormat:@"  %@ people likes", self.mPostInfo.mLikesCount] forState:UIControlStateNormal];
    
    if ([self.mPostInfo.mLiked isEqualToString:@"1"])
    {
        [mBtnLike setImage: [UIImage imageNamed: @"feed_img_liked.png"] forState: UIControlStateNormal];
        [mBtnLike setTitleColor: UIColorFromRGB(0x00aff0) forState: UIControlStateNormal];
    }
    else
    {
        [mBtnLike setImage: [UIImage imageNamed: @"feed_img_like.png"] forState: UIControlStateNormal];
        [mBtnLike setTitleColor: UIColorFromRGB(0x989898) forState: UIControlStateNormal];
    }
    
    
    if ([self.mPostInfo.mMediaType isEqualToString:@"2"]) // Photo Type
    {
        [self.mImgViewPhoto sd_setImageWithURL: [NSURL URLWithString: [NSString stringWithFormat: @"%@%@", API_HOME, self.mPostInfo.mMedia]]];
        [mBtnPlay setHidden:YES];
    }
    else if ([self.mPostInfo.mMediaType isEqualToString:@"3"]) // Video Type
    {
        [mBtnPlay setHidden: NO];
        
        AVURLAsset* asset = [AVURLAsset URLAssetWithURL: [NSURL URLWithString: [NSString stringWithFormat: @"%@%@", API_HOME, self.mPostInfo.mMedia]] options:nil];
        
        AVPlayerItem* item = [AVPlayerItem playerItemWithAsset:asset];
        mAVPlayer = [AVPlayer playerWithPlayerItem:item];
        mAVPlayer.actionAtItemEnd = AVPlayerActionAtItemEndNone;
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(videoPlayerItemDidReachEnd:)
                                                     name:AVPlayerItemDidPlayToEndTimeNotification
                                                   object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(videoPlayerItemPlaybackStalled:)
                                                     name:AVPlayerItemPlaybackStalledNotification
                                                   object:nil];
        
        AVPlayerLayer* lay = [AVPlayerLayer playerLayerWithPlayer: mAVPlayer];
        lay.frame = mViewVideo.bounds;
        lay.videoGravity = AVLayerVideoGravityResize;
        [mViewVideo.layer addSublayer:lay];
        mAVPlayerLayer = lay;
    }

    
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    
    if (mAVPlayerLayer) {
        mAVPlayerLayer.frame = mViewVideo.bounds;
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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

#pragma mark -
#pragma mark - Initialize

- (void)initNavigation {
    [self.navigationController setNavigationBarHidden: NO];
    
    [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed: @"common_img_bar.png"]
                                                  forBarMetrics:UIBarMetricsDefault];
    self.navigationController.navigationBar.shadowImage = [UIImage new];
    self.navigationController.navigationBar.translucent = NO;
    
    self.title = @"Thumbnail";
    [self.navigationController.navigationBar
     setTitleTextAttributes:@{NSForegroundColorAttributeName : [UIColor whiteColor]}];
    
    UIButton *btnBack = [UIButton buttonWithType: UIButtonTypeSystem];
    [btnBack setFrame: CGRectMake(0, 0, 30, 30)];
    [btnBack setTintColor: [UIColor whiteColor]];
    [btnBack setImage: [UIImage imageNamed: @"common_img_back.png"] forState: UIControlStateNormal];
    [btnBack addTarget: self action: @selector(onTouchBtnBack :) forControlEvents: UIControlEventTouchUpInside];
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView: btnBack];
}

//================================================================================================================

#pragma mark -
#pragma mark - Touch Event

- (IBAction)onTouchBtnBack: (id)sender {
    [self.navigationController popViewControllerAnimated: YES];
}

- (IBAction)onTouchPlayButton:(id)sender{
    NSLog(@"touched play button");
    
    [mBtnPlay setHidden: YES];
    
    [mAVPlayer play];
}

- (IBAction)onTouchViewComment:(id)sender{
    NSLog(@"View Comment");
    
    HLCommentViewController *commentView = (HLCommentViewController *)[self.storyboard instantiateViewControllerWithIdentifier: @"HLCommentViewController"];
    commentView.mPostInfo = self.mPostInfo;
    
    [self.navigationController pushViewController: commentView animated: YES];
}

- (IBAction)onTouchBtnLike: (id)sender {
    
    
    NSDictionary *parameters = nil;
    [self showLoading];
    
    void ( ^successed )( id responseObject ) = ^( id responseObject ) {
        NSLog(@"JSON: %@", responseObject);
        
        int result = [[responseObject objectForKey: @"success"] intValue];
        if (result) {
            NSDictionary *dicData = [responseObject objectForKey: @"data"];
            
            self.mPostInfo.mLiked = [dicData objectForKey: @"like_state"];
            self.mPostInfo.mLikesCount = [dicData objectForKey: @"likes_count"];
            
            [mBtnLike setTitle:[NSString stringWithFormat:@"  %@ people likes", self.mPostInfo.mLikesCount] forState:UIControlStateNormal];
            
            if ([self.mPostInfo.mLiked isEqualToString: @"1"]) {
                [mBtnLike setImage: [UIImage imageNamed: @"feed_img_liked.png"] forState: UIControlStateNormal];
                [mBtnLike setTitleColor: UIColorFromRGB(0x00aff0) forState: UIControlStateNormal];
            }
            else {
                [mBtnLike setImage: [UIImage imageNamed: @"feed_img_like.png"] forState: UIControlStateNormal];
                [mBtnLike setTitleColor: UIColorFromRGB(0x989898) forState: UIControlStateNormal];
            }
            
            [mProgress hide: YES];
        }
        else {
            [mProgress hide: YES];
        }
        [mProgress hide: YES];
    };
    
    void ( ^failure )( NSError* error ) = ^( NSError* error ) {
        NSLog(@"Error: %@", error);
        [mProgress hide: YES];
        
    };
    
    parameters = @{@"user_id":      [Engine gCurrentUser].mUserId,
                   @"post_id":      self.mPostInfo.mPostId};
    
    [[HLCommunication sharedManager] sendToService: API_LIKEPOST params: parameters success: successed failure: failure];
}

#pragma mark -
#pragma mark - Timer View

- (NSString *)stringFromTimeInterval: (NSDate *)fromDate toDate: (NSDate *)toDate
{
    NSCalendar *sysCalendar = [NSCalendar currentCalendar];
    unsigned int unitFlags = NSHourCalendarUnit | NSMinuteCalendarUnit | NSDayCalendarUnit | NSMonthCalendarUnit;
    
    NSDateComponents *breakdownInfo = [sysCalendar components: unitFlags fromDate: fromDate toDate: toDate options: 0];
    
    if ([breakdownInfo month] > 0)
    {
        if ([breakdownInfo month] == 1)
            return [NSString stringWithFormat: @"  a month ago"];
        else
            return [NSString stringWithFormat: @"  %d months ago", (int)[breakdownInfo month]];
    }
    
    if ([breakdownInfo day] > 0)
    {
        if ([breakdownInfo day] == 1)
            return [NSString stringWithFormat: @"  a day ago"];
        else
            return [NSString stringWithFormat: @"  %d days ago", (int)[breakdownInfo day]];
    }
    
    
    if ([breakdownInfo hour] > 0)
    {
        if ([breakdownInfo hour] == 1)
        {
            return [NSString stringWithFormat: @"  an hour ago"];
        }
        else
        {
            return [NSString stringWithFormat: @"  %d hours ago", (int)[breakdownInfo hour]];
        }
    }
    
    if ([breakdownInfo minute] > 0)
    {
        if ([breakdownInfo minute] == 1)
        {
            return [NSString stringWithFormat: @"  a min ago"];
        }
        else
        {
            return [NSString stringWithFormat: @"  %d mins ago", (int)[breakdownInfo minute]];
        }
    }
    
    return @"a min ago";
}

//==========================================================================================================================

#pragma mark -
#pragma mark - AVPlayer Notification

- (void)videoPlayerItemDidReachEnd:(NSNotification *)notification {
    //AVPlayerItem *p = [notification object];
    //[p seekToTime:kCMTimeZero];
    //[mAVPlayer pause];
    if (notification.object == mAVPlayer.currentItem) {
        [mAVPlayer pause];
        [mAVPlayer seekToTime:CMTimeMakeWithSeconds(0, NSEC_PER_SEC)];
        
        [mBtnPlay setHidden: NO];
    }
}

- (void)videoPlayerItemPlaybackStalled: (NSNotification *)notification {
    
    if (notification.object == mAVPlayer.currentItem) {
        [mAVPlayer play];
    }
}

//==========================================================================================================================

#pragma mark -
#pragma mark - showLoading
- (void)showLoading {
    mProgress = [MBProgressHUD showHUDAddedTo:[UIApplication sharedApplication].keyWindow animated:YES];
    mProgress.mode = MBProgressHUDModeIndeterminate;
    mProgress.labelText = @"";
    [mProgress show:YES];
}

@end
