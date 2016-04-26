//
//  HLCameraViewController.h
//  Comvo
//
//  Created by DeMing Yu on 1/6/15.
//  Copyright (c) 2015 DeMing Yu. All rights reserved.
//

#import <UIKit/UIKit.h>

#import <GPUImage.h>

@protocol HLCameraViewControllerDelegate <NSObject>

@optional
- (void)didFinishedPhotoEdit: (NSData *)mediaData url: (NSURL *)url;
- (void)didFinishedRecordVideo: (NSData *)mediaData url: (NSURL *)url;
- (void)didFinishedRecordVideo: (NSData *)mediaData url: (NSURL *)url image: (UIImage *) thumbnailImage;
- (void)didBackedFromRecordAudio;
- (void)didFinishedRecordAudio: (NSData *)mediaData url: (NSURL *)url;



@end

@class MBProgressHUD;

@interface HLCameraViewController : UITableViewController <GPUImageMovieWriterDelegate> {
    IBOutlet UIView                 *mCameraView;
    IBOutlet UILabel                *mVideoDuringTimeLabel;
    
    IBOutlet UIButton               *mBtnRecordVideo;
    IBOutlet UIButton               *mBtnFlash;
    IBOutlet UIButton               *mBtnRotate;
    IBOutlet UIButton               *mBtnCapture;
    IBOutlet UIButton               *mBtnAudio;    
    IBOutlet UIImageView            *mImgViewLibrary;
    
    
    int                             mDuringTimeOfVideo;
    int                             mCounterDuringTimer;
    BOOL                            mFlgVideoProcessing;
    int                             mCameraMode;
    NSTimer                         *mVideoDuringTimer;
    
    MBProgressHUD                   *mProgress;
    
    GPUImageStillCamera             *mPhotoCamera;
    GPUImagePicture                 *mPictureForPhoto;
    
    GPUImageVideoCamera             *mVideoCamera;
    
    GPUImageView                    *mFilterView;
    GPUImageMovieWriter             *mMovieWriter;
    GPUImageFilter                  *mCropFilter;
    GPUImageOutput<GPUImageInput>   *mBlurFilter;
    GPUImageZoomBlurFilter          *mZoomFilter;
    
    GPUImageFilter *filter;
    
    UIImage *imageThumbnail;
    
    AVCaptureSession                *AVSession;
    AVCaptureTorchMode              mTorchModePhoto;
    AVCaptureTorchMode              mTorchModeVideo;
}

@property (nonatomic, retain) AVCaptureSession *AVSession;
@property (nonatomic, assign) id<HLCameraViewControllerDelegate> delegate;

@end
