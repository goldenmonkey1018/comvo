//
//  HLAudioView.m
//  Comvo
//
//  Created by Max Brian on 14/10/15.
//  Copyright (c) 2015 Max Brian. All rights reserved.
//

#import "HLAudioView.h"
#import "DDProgressView.h"
#import "Constants_Comvo.h"

#import <AVFoundation/AVFoundation.h>

@implementation HLAudioView

- (void)dealloc
{
    [self removeAVPlayer];
}

- (id) initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    self.backgroundColor = [UIColor clearColor];
    mFlgPlay = NO;
    mAudioPlayer = nil;
    mTimeObserver = nil;
    
    CGFloat height = frame.size.height;
    
    UIButton *playButton = [UIButton buttonWithType: UIButtonTypeCustom];
    [playButton setFrame:CGRectMake(0, 10, height-20, height-20)];
    [playButton setImage: [UIImage imageNamed: @"comment_img_play.png"] forState: UIControlStateNormal];
    [playButton addTarget:self action:@selector(onToggleCommentAudioPlay:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview: playButton];
    mBtnPlay = playButton;
    
    DDProgressView *progressView = [[DDProgressView alloc] initWithFrame: CGRectMake(height-10, 14.0f, frame.size.width - height - 5, height)];
    
    [progressView setOuterColor: UIColorFromRGB(0x989898)];
    [progressView setInnerColor: UIColorFromRGB(0x989898)];
    [progressView setProgress: 0.0f];
    [self addSubview: progressView];
    mProgressView = progressView;
    
    return self;
}

- (void)removeFromSuperview
{
    [self removeAVPlayer];
    [super removeFromSuperview];
}

- (void)onToggleCommentAudioPlay:(id)sender
{
    if (!mAudioPlayer) {
        
        
        AVPlayerItem *playerItem=[[AVPlayerItem alloc] initWithURL: self.audioURL];
        
        mAudioPlayer = [[AVPlayer alloc] initWithPlayerItem:playerItem];
        mAudioPlayer.actionAtItemEnd = AVPlayerActionAtItemEndNone;
        [self addTimeObserverToPlayer];
        [mAudioPlayer addObserver:self forKeyPath:@"rate" options:NSKeyValueObservingOptionNew context:nil];
    }
    
    mFlgPlay = !mFlgPlay;
    
    if (mFlgPlay) {
        [mAudioPlayer play];
        [mProgressView setProgress: 0.0f];
        if (mAudioPlayer.status == AVPlayerItemStatusReadyToPlay) {
            [mAudioPlayer seekToTime:CMTimeMakeWithSeconds(0, NSEC_PER_SEC)];
        }
    }
    else {
        [mAudioPlayer pause];
    }

}

- (void)updateButtonStatus
{
    if (mFlgPlay) {
        [mBtnPlay setImage: [UIImage imageNamed: @"comment_img_pause.png"] forState: UIControlStateNormal];
        [mProgressView setOuterColor: UIColorFromRGB(0x00AFF0)];
        [mProgressView setInnerColor: UIColorFromRGB(0x00AFF0)];
        [mProgressView setNeedsDisplay];
    } else {
        [mBtnPlay setImage: [UIImage imageNamed: @"comment_img_play.png"] forState: UIControlStateNormal];
        [mProgressView setOuterColor: UIColorFromRGB(0x989898)];
        [mProgressView setInnerColor: UIColorFromRGB(0x989898)];
        [mProgressView setNeedsDisplay];
    }
}

#pragma mark Audio Player

- (void) removeAVPlayer
{
    
    [self removeTimeObserverFromPlayer];
    if (mAudioPlayer)
    {
        [mAudioPlayer removeObserver:self forKeyPath:@"rate"];
        mAudioPlayer = nil;
    }
}

- (void)removeTimeObserverFromPlayer
{
    if (mTimeObserver)
    {
        if (mAudioPlayer)
            [mAudioPlayer removeTimeObserver:mTimeObserver];
        mTimeObserver = nil;
    }
}

- (void)addTimeObserverToPlayer
{
    if (mTimeObserver)
        return;
    
    __weak typeof(self) wself = self;
    mTimeObserver = [mAudioPlayer addPeriodicTimeObserverForInterval:CMTimeMakeWithSeconds(0.1, NSEC_PER_SEC) queue:dispatch_get_main_queue() usingBlock:
                        ^(CMTime time) {
                            __strong typeof (self) sself = wself;
                            [sself refreshTime];
                        }];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if (mAudioPlayer && object == mAudioPlayer) {
        if ([keyPath isEqualToString:@"rate"]) {
            float newRate = [[change objectForKey:@"new"] floatValue];
            mFlgPlay = newRate != 0.0;
            [self performSelectorOnMainThread:@selector(updateButtonStatus) withObject:nil waitUntilDone:YES];
        }
    }
}

- (NSTimeInterval)playableDuration
{
    AVPlayerItem * item = mAudioPlayer.currentItem;
    
    if (item.status == AVPlayerItemStatusReadyToPlay) {
        NSArray * timeRangeArray = item.loadedTimeRanges;
        
        CMTimeRange aTimeRange = [[timeRangeArray objectAtIndex:0] CMTimeRangeValue];
        
        double startTime = CMTimeGetSeconds(aTimeRange.start);
        double loadedDuration = CMTimeGetSeconds(aTimeRange.duration);
        
        // FIXME: shoule we sum up all sections to have a total playable duration,
        // or we just use first section as whole?
        
        NSLog(@"get time range, its start is %f seconds, its duration is %f seconds.", startTime, loadedDuration);
        
        
        return (NSTimeInterval)(startTime + loadedDuration);
    }
    else
    {
        return 0;
    }
}

- (void)refreshTime {
    
    NSTimeInterval duration = [self playableDuration];
    
    if (!mAudioPlayer || duration == 0)
        return;
    
    NSTimeInterval currentTime = CMTimeGetSeconds(mAudioPlayer.currentTime);
    
    float progress = (float)(currentTime / duration);
    
    if (progress >= 1) {
        [mAudioPlayer pause];
        [mAudioPlayer seekToTime:CMTimeMakeWithSeconds(0, NSEC_PER_SEC)];
        [mProgressView setProgress: 0.0f];
    } else {
        [mProgressView setProgress: progress];
    }
}

@end
