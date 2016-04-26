//
//  AudioFeedCell.m
//  Comvo
//
//  Created by Max Broeckel on 29/09/15.
//  Copyright (c) 2015 Max Broeckel. All rights reserved.
//

#import "AudioFeedCell.h"

#import <AVFoundation/AVFoundation.h>

#import "AppEngine.h"
#import "Constants_Comvo.h"

#import <DDProgressView.h>
#import <QuartzCore/QuartzCore.h>

#import "HLCommunication.h"

#import <MBProgressHUD.h>

@interface AudioFeedCell () <UIAlertViewDelegate>

@end

@implementation AudioFeedCell

@synthesize mPostInfo;
@synthesize delegate;

- (void)awakeFromNib {
    // Initialization code
    
    mProgressView = [[DDProgressView alloc] initWithFrame: CGRectMake(0,
                                                                      0,
                                                                      mViewProgress.frame.size.width,
                                                                      mViewProgress.frame.size.height)];
    [mProgressView setOuterColor: UIColorFromRGB(0x989898)];
    [mProgressView setInnerColor: UIColorFromRGB(0x989898)];
    [mProgressView setProgress: 0.0f];
    [mViewProgress addSubview: mProgressView];
    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setPostInfo:(PostInfo *)postInfo flag: (BOOL) fDeleteFlg{
    [self setMPostInfo: postInfo];
    
    
    [mBtnAudioPlay setImage: [UIImage imageNamed: @"feed_img_audio_play.png"]
                   forState: UIControlStateNormal];
    
    [mViewAudio setHidden: YES];

    NSDate *post_date = [NSDate dateWithTimeIntervalSince1970: [postInfo.mPostDate intValue]];
    NSDate *current_date  = [NSDate date];
    
    
    [mLblTime setText: [self stringFromTimeInterval: post_date toDate: current_date]];
    
    // 3. Likes and Comments Count
    if ([self.mPostInfo.mLiked isEqualToString: @"1"]) {
        [mBtnLikesCount setImage: [UIImage imageNamed: @"feed_img_liked.png"] forState: UIControlStateNormal];
        [mBtnLikesCount setTitleColor: UIColorFromRGB(0x00aff0) forState: UIControlStateNormal];
    }
    else {
        [mBtnLikesCount setImage: [UIImage imageNamed: @"feed_img_like.png"] forState: UIControlStateNormal];
        [mBtnLikesCount setTitleColor: UIColorFromRGB(0x989898) forState: UIControlStateNormal];
    }
    
    
    [mBtnLikesCount setTitle: [NSString stringWithFormat: @"  %@", postInfo.mLikesCount] forState: UIControlStateNormal];
    [mBtnCommentsCount setTitle: [NSString stringWithFormat: @"  %@", postInfo.mCommentsCount] forState: UIControlStateNormal];
    
    if (fDeleteFlg)
        BtnAudioDelete.hidden = NO;
    else
        BtnAudioDelete.hidden = YES;
}

- (IBAction)onTouchBtnLike: (id)sender {
    
    NSDictionary *parameters = nil;
    void ( ^successed )( id responseObject ) = ^( id responseObject ) {
        NSLog(@"JSON: %@", responseObject);
        
        int result = [[responseObject objectForKey: @"success"] intValue];
        if (result) {
            NSDictionary *dicData = [responseObject objectForKey: @"data"];
            
            self.mPostInfo.mLiked = [dicData objectForKey: @"like_state"];
            self.mPostInfo.mLikesCount = [dicData objectForKey: @"likes_count"];
            
            [mBtnLikesCount setTitle: [NSString stringWithFormat: @"%@", self.mPostInfo.mLikesCount] forState: UIControlStateNormal];
            
            if ([self.mPostInfo.mLiked isEqualToString: @"1"]) {
                [mBtnLikesCount setImage: [UIImage imageNamed: @"feed_img_liked.png"] forState: UIControlStateNormal];
                [mBtnLikesCount setTitleColor: UIColorFromRGB(0x00aff0) forState: UIControlStateNormal];
            }
            else {
                [mBtnLikesCount setImage: [UIImage imageNamed: @"feed_img_like.png"] forState: UIControlStateNormal];
                [mBtnLikesCount setTitleColor: UIColorFromRGB(0x989898) forState: UIControlStateNormal];
            }
            
            [delegate didTouchedProfileLike: self];
        }
        else {
            
        }
    };
    
    void ( ^failure )( NSError* error ) = ^( NSError* error ) {
        NSLog(@"Error: %@", error);
        
    };
    
    parameters = @{@"user_id":      [Engine gCurrentUser].mUserId,
                   @"post_id":      self.mPostInfo.mPostId};
    
    [[HLCommunication sharedManager] sendToService: API_LIKEPOST params: parameters success: successed failure: failure];
}

- (void)actionDeleteAudio{
    
    NSLog(@"You've touched Audio Delete Button");
    
    NSLog(@"Touched Photo Delete Button");
    
    NSLog(@"%@", mPostInfo.mPostId);
    
    [self showLoading];
    
    NSDictionary *parameters = nil;
    
    void ( ^successed )( id responseObject ) = ^( id responseObject ) {
        NSLog(@"JSON: %@", responseObject);
        
        int result = [[responseObject objectForKey: @"success"] intValue];
        if (result) {
            //NSDictionary *dicData = [responseObject objectForKey: @"data"];
            //NSDictionary *dicUser = [dicData objectForKey: @"user"];
            
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle: @"Delete Audio" message: @"Audio posting has been deleted successfully!!!" delegate: self cancelButtonTitle: @"Ok" otherButtonTitles: nil];
            [alertView show];
            
            [delegate didFinishedDeleteAudio:self];
        }
        else {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle: @"Warning" message: [responseObject valueForKey: @"message"] delegate: nil cancelButtonTitle: @"Ok" otherButtonTitles: nil];
            [alertView show];
        }
        
        [mProgress hide: YES];
    };
    
    void ( ^failure )( NSError* error ) = ^( NSError* error ) {
        NSLog(@"Error: %@", error);
        
        [mProgress hide: YES];
    };
    
    parameters = @{@"user_id":      [Engine gCurrentUser].mUserId,
                   @"post_id":      self.mPostInfo.mPostId,
                   @"media_type":   @"1"};  // Audio Type
    
    //parameters = @{@"user_id":      [Engine gCurrentUser].mUserId,
    //               @"post_id":      self.mPostInfo.mPostId};
    
    [[HLCommunication sharedManager] sendToService: API_DELETEPOST params: parameters success: successed failure: failure];
    
}

- (IBAction)onTouchBtnAudioDelete: (id)sender{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle: @"Delete" message: @"Do you want to really delete audio?" delegate: self cancelButtonTitle: @"Yes" otherButtonTitles: @"No", nil];
    [alertView show];
}


- (IBAction)onTouchBtnComment: (id)sender {
    [delegate didTouchedProfileComment: self];
}

- (IBAction)onTouchBtnReport: (id)sender {
    [delegate didTouchedProfileReport: self];
}

- (IBAction)onTouchBtnDownload: (id)sender {
    
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle: @"Download" message: @"Do you want download?" delegate: self cancelButtonTitle: @"Yes" otherButtonTitles: @"No", nil];
    [alertView show];
    
    
}

//==========================================================================================================================

#pragma mark -
#pragma mark - Timer

- (void)refreshTimer {
    
    if ([self.mPostInfo.mDuration isEqualToString: @"0"]) {
        return;
    }
    
    CMTime current = mAudioPlayer.currentTime;
    if (CMTIME_IS_INVALID(current))
        return;
    
    float currentTime = CMTimeGetSeconds(current);
    float duration = [self.mPostInfo.mDuration floatValue];
    
    float progress = currentTime / duration;
    
    [mProgressView setNeedsDisplay];
    
    if (progress > 1.0f)
        [mProgressView setProgress: 0.0f];
    else
        [mProgressView setProgress: progress];
    
    
}


- (IBAction)onTouchBtnAudioPlay: (id)sender {
    mFlgAudioPlay = !mFlgAudioPlay;
    
    if (mFlgAudioPlay) {
        AVPlayerItem *playerItem=[[AVPlayerItem alloc] initWithURL: [NSURL URLWithString: [NSString stringWithFormat: @"%@%@", API_HOME, self.mPostInfo.mMedia]]];
        
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
        
        mDuringTimer = [NSTimer scheduledTimerWithTimeInterval: 0.1f
                                                        target: self
                                                      selector: @selector(refreshTimer)
                                                      userInfo: nil
                                                       repeats: YES];
        
        [mProgressView setOuterColor: UIColorFromRGB(0x00AFF0)];
        [mProgressView setInnerColor: UIColorFromRGB(0x00AFF0)];
        [mProgressView setNeedsDisplay];
        
        [mBtnAudioPlay setImage: [UIImage imageNamed: @"feed_img_audio_pause.png"] forState: UIControlStateNormal];
    }
    else {
        [mAudioPlayer pause];
        
        [mDuringTimer invalidate];
        
        [mProgressView setOuterColor: UIColorFromRGB(0x989898)];
        [mProgressView setInnerColor: UIColorFromRGB(0x989898)];
        [mProgressView setNeedsDisplay];
        
        [mBtnAudioPlay setImage: [UIImage imageNamed: @"feed_img_audio_play.png"] forState: UIControlStateNormal];
    }
}

- (void)didEnterBackground {
    if (mFlgAudioPlay) {
        [mAudioPlayer pause];
        
        [mDuringTimer invalidate];
    }
}


//==========================================================================================================================

#pragma mark -
#pragma mark - AVPlayer Notification

- (void)audioPlayerItemDidReachEnd:(NSNotification *)notification {
    [mProgressView setOuterColor: UIColorFromRGB(0x989898)];
    [mProgressView setInnerColor: UIColorFromRGB(0x989898)];
    [mProgressView setNeedsDisplay];
    mFlgAudioPlay = FALSE;
    
    [mBtnAudioPlay setImage: [UIImage imageNamed: @"feed_img_audio_play.png"] forState: UIControlStateNormal];
}

- (void)audioPlayerItemPlaybackStalled: (NSNotification *)notification {
    
}


- (NSString *)stringFromTimeInterval: (NSDate *)fromDate toDate: (NSDate *)toDate
{
    NSCalendar *sysCalendar = [NSCalendar currentCalendar];
    unsigned int unitFlags = NSHourCalendarUnit | NSMinuteCalendarUnit | NSDayCalendarUnit | NSMonthCalendarUnit;
    
    NSDateComponents *breakdownInfo = [sysCalendar components: unitFlags fromDate: fromDate toDate: toDate options: 0];
    
    if ([breakdownInfo month] > 0)
    {
        if ([breakdownInfo month] == 1)
            return [NSString stringWithFormat: @"a month ago"];
        else
            return [NSString stringWithFormat: @"%d months ago", (int)[breakdownInfo month]];
    }
    
    if ([breakdownInfo day] > 0)
    {
        if ([breakdownInfo day] == 1)
            return [NSString stringWithFormat: @"a day ago"];
        else
            return [NSString stringWithFormat: @"%d days ago", (int)[breakdownInfo day]];
    }
    
    
    if ([breakdownInfo hour] > 0)
    {
        if ([breakdownInfo hour] == 1)
        {
            return [NSString stringWithFormat: @"an hour ago"];
        }
        else
        {
            return [NSString stringWithFormat: @"%d hours ago", (int)[breakdownInfo hour]];
        }
    }
    
    if ([breakdownInfo minute] > 0)
    {
        if ([breakdownInfo minute] == 1)
        {
            return [NSString stringWithFormat: @"a min ago"];
        }
        else
        {
            return [NSString stringWithFormat: @"%d mins ago", (int)[breakdownInfo minute]];
        }
    }
    
    return @"a min ago";
}

- (void)showLoading {
    mProgress = [MBProgressHUD showHUDAddedTo:[UIApplication sharedApplication].keyWindow animated:YES];
    mProgress.mode = MBProgressHUDModeIndeterminate;
    mProgress.labelText = @"";
    [mProgress show:YES];
}

//==========================================================================================================================

#pragma mark -
#pragma mark - UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 0) {
        
        if ([alertView.title isEqualToString:@"Download"])
        {
            [delegate didTouchedProfileDownload:self];
        }
        else if ([alertView.title isEqualToString:@"Delete"])
        {
            [self actionDeleteAudio];
        }
    }
}



@end
