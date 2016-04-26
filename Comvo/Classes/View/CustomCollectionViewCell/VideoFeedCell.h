//
//  VideoFeedCell.h
//  Comvo
//
//  Created by Max Broeckel on 28/09/15.
//  Copyright (c) 2015 Max Broeckel. All rights reserved.
//

#import <UIKit/UIKit.h>

@class VideoFeedCell;

@protocol VideoFeedCellDelegate

@optional;
- (void)didFinishedDeleteVideo: (VideoFeedCell*) tableViewCell;
- (void)didTouchedVideoThumbnail : (VideoFeedCell *)tableViewCell;
@end

@class AVPlayer;
@class PostInfo;

@class MBProgressHUD;


@interface VideoFeedCell : UICollectionViewCell{
    
    AVPlayer                    *mAVPlayer;
    
    MBProgressHUD           *mProgress;
}

@property (nonatomic, weak) IBOutlet UIView *viewPhoto;
@property (nonatomic, weak) IBOutlet UIImageView *imageView;

@property (nonatomic, weak) IBOutlet UIButton *playButton;
@property (nonatomic, weak) IBOutlet UIButton *deleteVideoButton;
@property (nonatomic, weak) IBOutlet UIButton *btnThumbnail;

@property (nonatomic, assign) id<VideoFeedCellDelegate> delegate;

@property (nonatomic, copy) PostInfo    *mPostInfo;

- (void)setPostInfo:(PostInfo *)postInfo flag: (BOOL) fDeleteFlg;
- (void)actionDeleteVideo;
- (void)actionVideoThumbnail;

- (IBAction)onTogglePlay:(id)sender;
- (IBAction)onToggleVideoDelete:(id)sender;
- (IBAction)onTouchVideoThumbnail:(id)sender;

@end
