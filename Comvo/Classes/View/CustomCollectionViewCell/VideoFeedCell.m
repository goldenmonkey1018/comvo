//
//  VideoFeedCell.m
//  Comvo
//
//  Created by Max Broeckel on 28/09/15.
//  Copyright (c) 2015 Max Broeckel. All rights reserved.
//

#import "VideoFeedCell.h"
#import <AVFoundation/AVFoundation.h>
#import "AppEngine.h"
#import "Constants_Comvo.h"
#import "HLCommunication.h"

#import <MBProgressHUD.h>
#import <SDWebImage/UIImageView+WebCache.h>

@interface VideoFeedCell () <UIAlertViewDelegate>

@end

@implementation VideoFeedCell

@synthesize mPostInfo;
@synthesize delegate;

- (void)setPostInfo:(PostInfo *)postInfo flag: (BOOL) fDeleteFlg{
    [self setMPostInfo: postInfo];
    
    if ([postInfo.mMediaType isEqualToString: @"2"]) {
        [self.imageView sd_setImageWithURL: [NSURL URLWithString: [NSString stringWithFormat: @"%@%@", API_HOME, postInfo.mThumbnail]] placeholderImage: [UIImage imageNamed: @"common_img_placehold_photo.png"]];
    }
    
    AVURLAsset* asset = [AVURLAsset URLAssetWithURL: [NSURL URLWithString: [NSString stringWithFormat: @"%@%@", API_HOME, postInfo.mMedia]] options:nil];
    
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
    lay.frame = self.viewPhoto.bounds;
    lay.videoGravity = AVLayerVideoGravityResize;
    [self.viewPhoto.layer addSublayer:lay];
    
    self.btnThumbnail.hidden = YES;
    
    if (fDeleteFlg)
        self.deleteVideoButton.hidden = NO;
    else
        self.deleteVideoButton.hidden = TRUE;
    
}
- (IBAction)onTogglePlay:(id)sender{
    //[self.playButton setHidden: YES];
    
    //[mAVPlayer play];
    
    NSLog(@"Touched Video Thumbnail");
    
    [delegate didTouchedVideoThumbnail: self];
}

- (void)actionDeleteVideo {
    NSLog(@"Toggled Video Delete Button");
    
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
            
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle: @"Video has been deleted successfully." message: [responseObject valueForKey: @"Success"] delegate: nil cancelButtonTitle: @"Ok" otherButtonTitles: nil];
            [alertView show];
            
            [delegate didFinishedDeleteVideo:self];
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
                   @"media_type":   @"3"}; // Video Type
    
    //parameters = @{@"user_id":      [Engine gCurrentUser].mUserId,
    //               @"post_id":      self.mPostInfo.mPostId};
    
    [[HLCommunication sharedManager] sendToService: API_DELETEPOST params: parameters success: successed failure: failure];
}

- (IBAction)onToggleVideoDelete:(id)sender{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle: @"Confirm" message: @"Do you want to really delete video?" delegate: self cancelButtonTitle: @"Yes" otherButtonTitles: @"No", nil];
    [alertView show];
}

- (IBAction)onTouchVideoThumbnail:(id)sender{
    NSLog(@"Touched Video Thumbnail");
    
    [delegate didTouchedVideoThumbnail: self];
}

- (void)actionVideoThumbnail{
    
}

//==========================================================================================================================

#pragma mark -
#pragma mark - Video Inner Function

- (void)playerItemDidReachEnd:(NSNotification *)notification {
    AVPlayerItem *p = [notification object];
    [p seekToTime:kCMTimeZero];
    [mAVPlayer pause];
    
    [self.playButton setHidden: NO];
}

- (void)playerItemPlaybackStalled: (NSNotification *)notification {
    AVPlayer *player = [notification object];
    [player play];
}


//==========================================================================================================================

#pragma mark -
#pragma mark - Progress Bar Delegate

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
        [self actionDeleteVideo];
    }
}

@end
