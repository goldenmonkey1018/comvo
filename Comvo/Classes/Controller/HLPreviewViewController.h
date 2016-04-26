//
//  HLPreviewViewController.h
//  Comvo
//
//  Created by DeMing Yu on 1/19/15.
//  Copyright (c) 2015 DeMing Yu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MediaPlayer/MediaPlayer.h>

@protocol HLPreviewViewControllerDelegate <NSObject>

@optional
- (void)didBackFromPreview: (NSString *)mediaType;
- (void)didDonePreview: (NSString *)mediaType mediaURL: (NSURL *)mediaURL mediaData: (NSData *)mediaData;
- (void)didDonePreview: (NSString *)mediaType mediaURL: (NSURL *)mediaURL mediaData: (NSData *)mediaData thumbnail: (UIImage *)imageThumbnail;

@end

@class DDProgressView;
@class AVAudioPlayer;
@class AVPlayer;

@interface HLPreviewViewController : UIViewController {
    IBOutlet UIView                 *mVideoPreview;
    
    AVPlayer                        *mAVPlayer;
    MPMoviePlayerController         *mMoviePlayer;
    DDProgressView                  *mProgressView;
    
    AVAudioPlayer                   *mAudioPlayer;
    NSTimer                         *mDuringTimer;
}

@property (nonatomic, assign) id<HLPreviewViewControllerDelegate> delegate;
@property (nonatomic, copy) NSString    *mMediaType;
@property (nonatomic, copy) NSURL       *mMediaURL;
@property (nonatomic, copy) NSData      *mMediaData;
@property (nonatomic, copy) UIImage     *mMediaThumbnail;


@end
