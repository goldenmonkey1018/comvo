//
//  HLPreviewViewController.m
//  Comvo
//
//  Created by Max Broeckel on 24/09/15.
//  Copyright (c) 2015 Max Broeckel. All rights reserved.
//

#import "HLPreviewViewController.h"

#import <DDProgressView.h>
#import <MediaPlayer/MediaPlayer.h>
#import <AVFoundation/AVFoundation.h>

#import "AppEngine.h"
#import "Constants_Comvo.h"

@interface HLPreviewViewController () <AVAudioPlayerDelegate, UIAlertViewDelegate>

@end

@implementation HLPreviewViewController

@synthesize delegate;
@synthesize mMediaType;
@synthesize mMediaURL;
@synthesize mMediaData;
@synthesize mMediaThumbnail;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self initNavigation];
    [self initView];
    
    if ([self.mMediaType isEqualToString: @"3"]) { // Video
        [mVideoPreview setHidden: NO];
    
//        mMoviePlayer = [[MPMoviePlayerController alloc] init];
//        [mMoviePlayer.view setFrame: mVideoPreview.bounds];
//        [mMoviePlayer setControlStyle: MPMovieControlStyleNone];
//        [mMoviePlayer setScalingMode: MPMovieScalingModeFill];
//        [mMoviePlayer setRepeatMode: MPMovieRepeatModeOne];
//        [mVideoPreview addSubview: mMoviePlayer.view];
//        [mMoviePlayer setContentURL: self.mMediaURL];
//        [mMoviePlayer play];
        
        AVURLAsset* asset = [AVURLAsset URLAssetWithURL: self.mMediaURL options:nil];
        AVPlayerItem* item = [AVPlayerItem playerItemWithAsset:asset];
        mAVPlayer = [AVPlayer playerWithPlayerItem:item];
        mAVPlayer.actionAtItemEnd = AVPlayerActionAtItemEndNone;
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(playerItemDidReachEnd:)
                                                     name:AVPlayerItemDidPlayToEndTimeNotification
                                                   object:[mAVPlayer currentItem]];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(playerItemPlaybackStalled:)
                                                     name:AVPlayerItemPlaybackStalledNotification
                                                   object:mAVPlayer];
        
        AVPlayerLayer* lay = [AVPlayerLayer playerLayerWithPlayer: mAVPlayer];
        lay.frame = mVideoPreview.bounds;
        lay.videoGravity = AVLayerVideoGravityResize;
        [mVideoPreview.layer addSublayer:lay];
        [mAVPlayer play];
    }
    else if ([self.mMediaType isEqualToString: @"1"]) { // Audio
        [mProgressView setHidden: NO];
        
        mAudioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL: self.mMediaURL error:nil];
        mAudioPlayer.delegate = self;
        [mAudioPlayer play];
        
        mDuringTimer = [NSTimer scheduledTimerWithTimeInterval: 0.1f
                                                         target: self
                                                       selector: @selector(refreshTimer)
                                                       userInfo: nil
                                                        repeats: YES];
    }
    
    [[NSNotificationCenter defaultCenter] addObserver: self selector: @selector(didEnterBackground) name: NOTIF_DID_ENTER_BACKGROUND object: nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear: animated];
    
    if ([self.mMediaType isEqualToString: @"1"]) {
        [mAudioPlayer pause];
    }
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
#pragma mark - Notification

- (void)didEnterBackground {
    if ([self.mMediaType isEqualToString: @"1"]) {
        [mAudioPlayer playAtTime: 0];
    }
}


//==========================================================================================================================

#pragma mark -
#pragma mark - Timer

- (void)refreshTimer {
    float progress = mAudioPlayer.currentTime / mAudioPlayer.duration;
    
    [mProgressView setProgress: progress];
}

//==================================================================================

#pragma mark -
#pragma mark - Initialize

- (void)initNavigation {
    [self.navigationController setNavigationBarHidden: NO];
    
    [[UINavigationBar appearance] setTintColor:[UIColor whiteColor]];
    self.navigationController.navigationBar.barTintColor = UIColorFromRGB(0x00AFF0);
    self.navigationController.navigationBar.translucent = NO;
    
    self.title = @"Preview";
    [self.navigationController.navigationBar
     setTitleTextAttributes:@{NSForegroundColorAttributeName : [UIColor whiteColor]}];
    
    UIButton *btnBack = [UIButton buttonWithType: UIButtonTypeSystem];
    [btnBack setFrame: CGRectMake(0, 0, 30, 30)];
    [btnBack setTintColor: [UIColor whiteColor]];
    [btnBack setImage: [UIImage imageNamed: @"common_img_back.png"] forState: UIControlStateNormal];
    [btnBack addTarget: self action: @selector(onTouchBtnBack :) forControlEvents: UIControlEventTouchUpInside];
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView: btnBack];
    
    UIButton *btnDone = [UIButton buttonWithType: UIButtonTypeSystem];
    [btnDone setFrame: CGRectMake(0, 0, 50, 30)];
    [btnDone setTintColor: [UIColor whiteColor]];
    [btnDone setTitle: @"Done" forState: UIControlStateNormal];
    [btnDone addTarget: self action: @selector(onTouchBtnDone:) forControlEvents: UIControlEventTouchUpInside];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView: btnDone];
}

- (void)initView {
    [mVideoPreview setFrame: CGRectMake(mVideoPreview.frame.origin.x,
                                        mVideoPreview.frame.origin.y,
                                        self.view.frame.size.width,
                                        self.view.frame.size.width)];
    [mVideoPreview setHidden: YES];
    
    
    mProgressView = [[DDProgressView alloc] initWithFrame: CGRectMake(mVideoPreview.frame.origin.x + 10.0f,
                                                                      self.view.frame.size.width / 2,
                                                                      self.view.frame.size.width - 20.0f,
                                                                      10.0f)];
    [mProgressView setOuterColor: UIColorFromRGB(0x00AFF0)];
    [mProgressView setInnerColor: UIColorFromRGB(0x00AFF0)];
    [mProgressView setProgress: 0.1f];
    [self.view addSubview: mProgressView];
    [mProgressView setHidden: YES];
}

//==========================================================================================================================

#pragma mark -
#pragma mark - Touch Event

- (IBAction)onTouchBtnBack: (id)sender {
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle: @"Confirm" message: @"You will lose current recording of you go back." delegate: self cancelButtonTitle: @"Cancel" otherButtonTitles: @"Ok", nil];
    [alertView show];
}

- (IBAction)onTouchBtnDone: (id)sender {
    [mAudioPlayer stop];
    
    if (mMediaThumbnail == nil)
        [delegate didDonePreview: self.mMediaType mediaURL: self.mMediaURL mediaData: self.mMediaData];
    else
        [delegate didDonePreview: self.mMediaType mediaURL: self.mMediaURL mediaData: self.mMediaData thumbnail: self.mMediaThumbnail];
    //[delegate didDonePreview: self.mMediaType mediaURL: self.mMediaURL mediaData: self.mMediaData];
}

//==========================================================================================================================

#pragma mark -
#pragma mark - AVPlayer Notification

- (void)playerItemDidReachEnd:(NSNotification *)notification {
    AVPlayerItem *p = [notification object];
    [p seekToTime:kCMTimeZero];
}

- (void)playerItemPlaybackStalled: (NSNotification *)notification {
    AVPlayer *player = [notification object];
    [player play];
}

//==========================================================================================================================

#pragma mark -
#pragma mark - AVAudioPlayerDelegate

- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag {
    [mProgressView setProgress: 1.0f];
    
    [player setCurrentTime: 0];
    [player play];
}

//==========================================================================================================================

#pragma mark -
#pragma mark - UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 1) {
        if(mDuringTimer) {
            [mDuringTimer invalidate];
            mDuringTimer = nil;
        }
        
        [delegate didBackFromPreview: self.mMediaType];
    }
}


@end
