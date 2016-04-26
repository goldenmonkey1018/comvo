//
//  HLAudioViewController.h
//  Comvo
//
//  Created by DeMing Yu on 1/8/15.
//  Copyright (c) 2015 DeMing Yu. All rights reserved.
//

#import <UIKit/UIKit.h>

#import <EZAudio.h>

@protocol HLAudioViewControllerDelegate <NSObject>

- (void)didBackedFromRecordAudio;
- (void)didFinishedRecordAudio: (NSURL *)audioURL;

@end

@interface HLAudioViewController : UITableViewController <AVAudioRecorderDelegate, AVAudioPlayerDelegate, EZMicrophoneDelegate> {
    IBOutlet UIButton   *mBtnRecord;
    IBOutlet UILabel    *mLblTime;
    
    IBOutlet UILabel    *mLblDescription; // Page Description
    
    AVAudioRecorder     *mRecorder;
    
    NSTimer             *mDuringTimer;
    int                 mCounterDuringTimer;
    BOOL                mIsRecording;
}

@property (nonatomic, assign) id<HLAudioViewControllerDelegate> delegate;

/**
 Use a OpenGL based plot to visualize the data coming in
 */
@property (nonatomic,weak) IBOutlet EZAudioPlotGL *audioPlot;

/**
 A flag indicating whether we are recording or not
 */
@property (nonatomic,assign) BOOL isRecording;

/**
 The microphone component
 */
@property (nonatomic,strong) EZMicrophone *microphone;

/**
 The recorder component
 */
@property (nonatomic,strong) EZRecorder *recorder;


@end
