//
//  HLAudioView.h
//  Comvo
//
//  Created by Max Brian on 14/10/15.
//  Copyright (c) 2015 Max Brian. All rights reserved.
//

#import <UIKit/UIKit.h>

@class AVPlayer;
@class DDProgressView;

@interface HLAudioView : UIView
{
    AVPlayer        *mAudioPlayer;
    DDProgressView  *mProgressView;
    UIButton        *mBtnPlay;
    
    BOOL        mFlgPlay;
    
    id mTimeObserver;
}
@property (nonatomic, strong) NSURL *audioURL;

@end
