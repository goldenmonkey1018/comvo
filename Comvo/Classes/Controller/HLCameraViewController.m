//
//  HLCameraViewController.m
//  Comvo
//
//  Created by DeMing Yu on 1/6/15.
//  Copyright (c) 2015 DeMing Yu. All rights reserved.
//

#import "HLCameraViewController.h"

#import <MBProgressHUD.h>
#import <AVFoundation/AVFoundation.h>
#import <AVFoundation/AVAsset.h>
#import <MobileCoreServices/MobileCoreServices.h>

#import <AdobeCreativeSDKImage/AdobeCreativeSDKImage.h>
#import <AdobeCreativeSDKCore/AdobeCreativeSDKCore.h>
#import <AssetsLibrary/AssetsLibrary.h>


#import <FBSDKShareKit/FBSDKShareKit.h>

#import "UIImage+Resize.h"
#import "UIImage+Crop.h"

#import "AppEngine.h"
#import "Constants_Comvo.h"

#import "HLAudioViewController.h"

#define CAPTURE_MAX_TIME        15.0f
#define DURATION_PER_FRAME      0.5f
#define kTempMoviePath          ([NSTemporaryDirectory() stringByAppendingPathComponent:@"temp.mov"])
#define kTempMovieURL           ([NSURL fileURLWithPath:kTempMoviePath])
#define kCapturedMoviePath      ([NSTemporaryDirectory() stringByAppendingPathComponent:@"capture.mov"])
#define kCapturedMovieURL       ([NSURL fileURLWithPath:kCapturedMoviePath])
#define kThumbnailImagePath     ([NSTemporaryDirectory() stringByAppendingPathComponent:@"thumbnail.jpg"])
#define kThumbnailImageURL      ([NSURL fileURLWithPath:kThumbnailImagePath])

@interface HLCameraViewController () <AdobeUXImageEditorViewControllerDelegate, UIAlertViewDelegate, HLAudioViewControllerDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate>

@end

@implementation HLCameraViewController

@synthesize AVSession;
@synthesize delegate;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self initNavigation];
    [self initView];
    
    mProgress = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    mProgress.mode = MBProgressHUDModeIndeterminate;
    [mProgress hide: NO];
    
    mDuringTimeOfVideo = 15;
    mFlgVideoProcessing = NO;
    
    mCounterDuringTimer = 0;
    mVideoDuringTimeLabel.text = [NSString stringWithFormat:@"%d s", mCounterDuringTimer];
    
    mTorchModePhoto = AVCaptureTorchModeOff;
    mTorchModeVideo = AVCaptureTorchModeOff;
    
    [mCameraView setFrame: CGRectMake(mCameraView.frame.origin.x,
                                     mCameraView.frame.origin.y,
                                      (IS_IPHONE6 ? 375.0f : 320.0f),
                                      (IS_IPHONE6 ? 375.0f : 320.0f))];
    
    imageThumbnail = [[UIImage alloc] init];
    
    mCameraMode = CAMERA_MODE_PHOTO;
    [self setupCameraForPhoto];
    
    [mVideoDuringTimeLabel setHidden: YES];
    
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget: self action: @selector(onTouchBtnLibrary:)];
    [mImgViewLibrary addGestureRecognizer: tapGesture];
    
    [[NSNotificationCenter defaultCenter] addObserver: self selector: @selector(onFinishRecordVideo) name: NOTIF_DID_FINISH_RECORD_VIDEO object: nil];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear: animated];
    
    [self.tabBarController.tabBar setHidden: YES];
    
    if (mCameraMode == CAMERA_MODE_PHOTO) {
        if ([mPhotoCamera.inputCamera isTorchAvailable]) {
            
            if ( [mPhotoCamera.inputCamera lockForConfiguration:nil] ) {
                
                if (mTorchModePhoto == AVCaptureTorchModeOn) {
                    [mBtnFlash setTitle: @"On" forState: UIControlStateNormal];
                    
                    [mPhotoCamera.inputCamera setTorchMode: AVCaptureTorchModeOff];
                    [mPhotoCamera.inputCamera setFlashMode: AVCaptureFlashModeOff];
                    
                    [mPhotoCamera.inputCamera setTorchMode: AVCaptureTorchModeOn];
                    [mPhotoCamera.inputCamera setFlashMode: AVCaptureFlashModeOn];
                }
                else if (mTorchModePhoto == AVCaptureTorchModeAuto) {
                    [mBtnFlash setTitle: @"Auto" forState: UIControlStateNormal];
                    
                    [mPhotoCamera.inputCamera setTorchMode: AVCaptureTorchModeAuto];
                    [mPhotoCamera.inputCamera setFlashMode: AVCaptureFlashModeAuto];
                }
                else {
                    [mBtnFlash setTitle: @"Off" forState: UIControlStateNormal];
                    
                    [mPhotoCamera.inputCamera setTorchMode: AVCaptureTorchModeOff];
                    [mPhotoCamera.inputCamera setFlashMode: AVCaptureFlashModeOff];
                }
                
                [mPhotoCamera.inputCamera unlockForConfiguration];
            }
        }
    }
    else if (mCameraMode == CAMERA_MODE_VIDEO) {
        if ([mVideoCamera.inputCamera isTorchAvailable]) {
            
            if ( [mVideoCamera.inputCamera lockForConfiguration:nil] ) {
                
                if (mTorchModeVideo == AVCaptureTorchModeOn) {
                    [mBtnFlash setTitle: @"On" forState: UIControlStateNormal];
                    
                    [mVideoCamera.inputCamera setTorchMode: AVCaptureTorchModeOn];
                    [mVideoCamera.inputCamera setFlashMode: AVCaptureFlashModeOn];
                }
                else if (mTorchModeVideo == AVCaptureTorchModeAuto) {
                    [mBtnFlash setTitle: @"Auto" forState: UIControlStateNormal];
                    
                    [mVideoCamera.inputCamera setTorchMode: AVCaptureTorchModeAuto];
                    [mVideoCamera.inputCamera setFlashMode: AVCaptureFlashModeAuto];
                }
                else {
                    [mBtnFlash setTitle: @"Off" forState: UIControlStateNormal];
                    
                    [mVideoCamera.inputCamera setTorchMode: AVCaptureTorchModeOff];
                    [mVideoCamera.inputCamera setFlashMode: AVCaptureFlashModeOff];
                }
                
                [mVideoCamera.inputCamera unlockForConfiguration];
            }
        }
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear: animated];
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

//==========================================================================================================

#pragma mark -
#pragma mark - Initialize

- (void)initNavigation {
    [self.navigationController setNavigationBarHidden: NO];
    
    [self.navigationController.navigationBar setBackgroundImage:[UIImage new]
                                                  forBarMetrics:UIBarMetricsDefault];
    self.navigationController.navigationBar.shadowImage = [UIImage new];
    self.navigationController.navigationBar.translucent = YES;
    
    UIButton *btnBack = [UIButton buttonWithType: UIButtonTypeSystem];
    [btnBack setFrame: CGRectMake(0, 0, 30, 30)];
    [btnBack setTintColor: [UIColor whiteColor]];
    [btnBack setImage: [UIImage imageNamed: @"common_img_back.png"] forState: UIControlStateNormal];
    [btnBack addTarget: self action: @selector(onTouchBtnBack :) forControlEvents: UIControlEventTouchUpInside];
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView: btnBack];
    
    mBtnRotate = [UIButton buttonWithType: UIButtonTypeSystem];
    [mBtnRotate setFrame: CGRectMake(0, 0, 30, 30)];
    [mBtnRotate setTintColor: [UIColor whiteColor]];
    [mBtnRotate setImage: [UIImage imageNamed: @"camera_img_rotate.png"] forState: UIControlStateNormal];
    [mBtnRotate addTarget: self action: @selector(onTouchBtnFlip:) forControlEvents: UIControlEventTouchUpInside];
    
    self.navigationItem.titleView = mBtnRotate;
    
    mBtnFlash = [UIButton buttonWithType: UIButtonTypeSystem];
    [mBtnFlash setFrame: CGRectMake(0, 0, 50, 30)];
    [mBtnFlash setTintColor: [UIColor whiteColor]];
    [mBtnFlash setImage: [UIImage imageNamed: @"camera_img_flash_auto.png"] forState: UIControlStateNormal];
    [mBtnFlash setTitle: @"Off" forState: UIControlStateNormal];
    [mBtnFlash setTitleEdgeInsets:UIEdgeInsetsMake(0, 5, 0, 0)];
    [mBtnFlash addTarget: self action: @selector(onTouchBtnFlash:) forControlEvents: UIControlEventTouchUpInside];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView: mBtnFlash];
}

- (void)initView {
    ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
    
    // Enumerate just the photos and videos group by using ALAssetsGroupSavedPhotos.
    [library enumerateGroupsWithTypes:ALAssetsGroupSavedPhotos usingBlock:^(ALAssetsGroup *group, BOOL *stop) {
        
        // Within the group enumeration block, filter to enumerate just photos.
        [group setAssetsFilter:[ALAssetsFilter allPhotos]];
        
        // Chooses the photo at the last index
        [group enumerateAssetsWithOptions:NSEnumerationReverse usingBlock:^(ALAsset *alAsset, NSUInteger index, BOOL *innerStop) {
            
            // The end of the enumeration is signaled by asset == nil.
            if (alAsset) {
                ALAssetRepresentation *representation = [alAsset defaultRepresentation];
                UIImage *latestPhoto = [UIImage imageWithCGImage:[representation fullScreenImage]];
                
                // Stop the enumerations
                *stop = YES; *innerStop = YES;
                
                // Do something interesting with the AV asset.
                [mImgViewLibrary setImage: latestPhoto];
            }
        }];
    } failureBlock: ^(NSError *error) {
        // Typically you should handle an error more gracefully than this.
        NSLog(@"No groups");
    }];
}

- (void)recordVideo
{
    if(mVideoDuringTimer) {
        [mVideoDuringTimer invalidate];
        mVideoDuringTimer = nil;
    }
    
    mCounterDuringTimer = 0;
    mVideoDuringTimer = [NSTimer scheduledTimerWithTimeInterval: 1.0f
                                                        target:self
                                                      selector:@selector(refreshTimerLabel)
                                                      userInfo:nil
                                                       repeats:YES];
    [self startCaptureVideo];
}

- (void)refreshTimerLabel
{
    mCounterDuringTimer += 1;
    if(mCounterDuringTimer > mDuringTimeOfVideo) {
        mCounterDuringTimer = mDuringTimeOfVideo;
        
        if (mFlgVideoProcessing)
            return;
        
        mFlgVideoProcessing = YES;
        
        [self stopCaptureVideo];
    }
    
    mVideoDuringTimeLabel.text = [NSString stringWithFormat:@"00:00:%02d", mCounterDuringTimer];
    
//    if (mCounterDuringTimer % 2 == 0) {
//        [mBtnRecordVideo setImage: [UIImage imageNamed: @"camera_img_video_highlighted.png"] forState: UIControlStateNormal];
//    }
//    else {
//        [mBtnRecordVideo setImage: [UIImage imageNamed: @"camera_img_video.png"] forState: UIControlStateNormal];
//    }
    
}

#pragma mark -
#pragma mark - Camera

- (void) initialize
{
    if (mPhotoCamera) {
        [mPhotoCamera stopCameraCapture];
        mPhotoCamera = nil;
        
        [NSThread sleepForTimeInterval: 1.0f];
    }
    
    if (mVideoCamera) {
        if (mMovieWriter) {
            mVideoCamera.audioEncodingTarget = nil;
            [mMovieWriter finishRecording];
            
            mMovieWriter = nil;
            
            [NSThread sleepForTimeInterval: 1.0f];
        }
        
        mVideoCamera = nil;
    }
    
    if (mCropFilter) {
        mCropFilter = nil;
    }
    
    if (mFilterView) {
        mFilterView = nil;
    }
    
    [[mCameraView subviews]
     makeObjectsPerformSelector:@selector(removeFromSuperview)];
}

- (void) setupCameraForVideo
{
    [self initialize];
    
    [mBtnFlash setTitle: @"Off" forState: UIControlStateNormal];
    
    mVideoCamera = [[GPUImageVideoCamera alloc] initWithSessionPreset:AVCaptureSessionPreset640x480
                                                       cameraPosition:AVCaptureDevicePositionBack];
    
    [mVideoCamera setHorizontallyMirrorFrontFacingCamera: YES];
    switch ([[UIDevice currentDevice] orientation])
    {
        case UIDeviceOrientationPortrait:
            mVideoCamera.outputImageOrientation =UIInterfaceOrientationPortrait;// UIInterfaceOrientationLandscapeRight;
            break;
            
        case UIDeviceOrientationPortraitUpsideDown:
            mVideoCamera.outputImageOrientation =UIInterfaceOrientationPortraitUpsideDown;// UIInterfaceOrientationLandscapeLeft;
            break;
        default:
            mVideoCamera.outputImageOrientation = UIInterfaceOrientationPortrait;//UIInterfaceOrientationLandscapeLeft;
            break;
    }
    
    if ( [mVideoCamera.inputCamera lockForConfiguration:nil] )
    {
        if ( [mVideoCamera.inputCamera respondsToSelector:@selector(isSmoothAutoFocusSupported)] )
        {
            if ( [mVideoCamera.inputCamera isSmoothAutoFocusSupported] )
                [mVideoCamera.inputCamera setSmoothAutoFocusEnabled:YES];
        }
        
        [mVideoCamera.inputCamera unlockForConfiguration];
    }
    
    if ([mVideoCamera.inputCamera isTorchAvailable]) {
        
        if ( [mVideoCamera.inputCamera lockForConfiguration:nil] ) {
            
            if (mTorchModeVideo == AVCaptureTorchModeOn) {
                [mBtnFlash setTitle: @"On" forState: UIControlStateNormal];
                
                [mVideoCamera.inputCamera setTorchMode: AVCaptureTorchModeOn];
                [mVideoCamera.inputCamera setFlashMode: AVCaptureFlashModeOn];
            }
            else if (mTorchModeVideo == AVCaptureTorchModeAuto) {
                [mBtnFlash setTitle: @"Auto" forState: UIControlStateNormal];
                
                [mVideoCamera.inputCamera setTorchMode: AVCaptureTorchModeAuto];
                [mVideoCamera.inputCamera setFlashMode: AVCaptureFlashModeAuto];
            }
            else {
                [mBtnFlash setTitle: @"Off" forState: UIControlStateNormal];
                
                [mVideoCamera.inputCamera setTorchMode: AVCaptureTorchModeOff];
                [mVideoCamera.inputCamera setFlashMode: AVCaptureFlashModeOff];
            }
            
            [mVideoCamera.inputCamera unlockForConfiguration];
        }
    }
    
    mCropFilter = [[GPUImageFilter alloc] init];
//    [mCropFilter setCropRegion:CGRectMake(0.0, 0.0, 1.0, 1.0)];
    
    mFilterView = [[GPUImageView alloc] initWithFrame:CGRectMake(0, 0, mCameraView.frame.size.width, mCameraView.frame.size.height)];
    [mFilterView setFillMode: kGPUImageFillModePreserveAspectRatioAndFill];
    [mCameraView addSubview:mFilterView];
    [mCameraView sendSubviewToBack:mFilterView];
    
    [mCropFilter addTarget:mFilterView];
    [mVideoCamera addTarget:mCropFilter];
    [mVideoCamera startCameraCapture];
    
    
    
    //filter = [[GPUImageFilter alloc] init];
    //force the output to 300*300
    //[filter forceProcessingAtSize:((GPUImageView*)mFilterView).sizeInPixels];
    
    //[filter addTarget:mFilterView];
}

- (void)setupCameraForPhoto {
    [self initialize];
    
    [mBtnFlash setTitle: @"Off" forState: UIControlStateNormal];
    
    mPhotoCamera = [[GPUImageStillCamera alloc] initWithSessionPreset:AVCaptureSessionPresetMedium
                                                       cameraPosition:AVCaptureDevicePositionBack];
    
    [mPhotoCamera setHorizontallyMirrorFrontFacingCamera: YES];
    
    switch ([[UIDevice currentDevice] orientation]) {
        case UIDeviceOrientationPortrait:
            mPhotoCamera.outputImageOrientation =UIInterfaceOrientationPortrait;// UIInterfaceOrientationLandscapeRight;
            break;
            
        case UIDeviceOrientationPortraitUpsideDown:
            mPhotoCamera.outputImageOrientation =UIInterfaceOrientationPortraitUpsideDown;// UIInterfaceOrientationLandscapeLeft;
            break;
        default:
            mPhotoCamera.outputImageOrientation = UIInterfaceOrientationPortrait;//UIInterfaceOrientationLandscapeLeft;
            break;
    }
    
    if ( [mPhotoCamera.inputCamera lockForConfiguration:nil] ) {
        if ([mPhotoCamera.inputCamera respondsToSelector:@selector(isSmoothAutoFocusSupported)]) {
            if ([mPhotoCamera.inputCamera isSmoothAutoFocusSupported])
                [mPhotoCamera.inputCamera setSmoothAutoFocusEnabled:YES];
        }
        
        [mPhotoCamera.inputCamera unlockForConfiguration];
    }
    
    if ([mPhotoCamera.inputCamera isTorchAvailable]) {
        
        if ( [mPhotoCamera.inputCamera lockForConfiguration:nil] ) {
            
            if (mTorchModePhoto == AVCaptureTorchModeOn) {
                [mBtnFlash setTitle: @"On" forState: UIControlStateNormal];
                
                [mPhotoCamera.inputCamera setTorchMode: AVCaptureTorchModeOn];
                [mPhotoCamera.inputCamera setFlashMode: AVCaptureFlashModeOn];
            }
            else if (mTorchModePhoto == AVCaptureTorchModeAuto) {
                [mBtnFlash setTitle: @"Auto" forState: UIControlStateNormal];
                
                [mPhotoCamera.inputCamera setTorchMode: AVCaptureTorchModeAuto];
                [mPhotoCamera.inputCamera setFlashMode: AVCaptureFlashModeAuto];
            }
            else {
                [mBtnFlash setTitle: @"Off" forState: UIControlStateNormal];
                
                [mPhotoCamera.inputCamera setTorchMode: AVCaptureTorchModeOff];
                [mPhotoCamera.inputCamera setFlashMode: AVCaptureFlashModeOff];
            }
            
            [mPhotoCamera.inputCamera unlockForConfiguration];
        }
    }
    
//    mCropFilter = [[GPUImageCropFilter alloc] init];
//    [mCropFilter setCropRegion:CGRectMake(0.0, 0.0, 1.0, 1.0)];
//    
//    mFilterView = [[GPUImageView alloc] initWithFrame: mCameraView.frame];
//    
//    [mFilterView setFillMode: kGPUImageFillModePreserveAspectRatioAndFill];
//    [mCameraView addSubview: mFilterView];
//    [mCameraView sendSubviewToBack: mFilterView];
//    
//    [mCropFilter addTarget:mFilterView];
//    [mPhotoCamera addTarget:mCropFilter];
//    [mPhotoCamera startCameraCapture];
    
#if 1
    
    mFilterView = [[GPUImageView alloc] initWithFrame: mCameraView.frame];
    
    //[mFilterView setFillMode: kGPUImageFillModePreserveAspectRatioAndFill];
    [mFilterView setFillMode: kGPUImageFillModePreserveAspectRatioAndFill];
     
     //kGPUImageFillModePreserveAspectRatioAndFill];
    [mCameraView addSubview: mFilterView];
    [mCameraView sendSubviewToBack: mFilterView];
    
    filter = [[GPUImageFilter alloc] init];
    //force the output to 300*300
//    [filter forceProcessingAtSize:((GPUImageView*)mFilterView).sizeInPixels];
//    [filter forceProcessingAtSizeRespectingAspectRatio:((GPUImageView*)mFilterView).sizeInPixels];
    
    [filter addTarget:mFilterView];
    [mPhotoCamera addTarget:filter];
    [mPhotoCamera startCameraCapture];
    
    NSLog(@"%@", NSStringFromCGRect(mCameraView.bounds));

#endif
}

- (void) startCaptureVideo
{
    NSMutableDictionary *videoSettings = [[NSMutableDictionary alloc] init];;
    [videoSettings setObject:AVVideoCodecH264 forKey:AVVideoCodecKey];
    [videoSettings setObject:[NSNumber numberWithInteger:mCameraView.frame.size.width] forKey:AVVideoWidthKey];
    [videoSettings setObject:[NSNumber numberWithInteger:mCameraView.frame.size.height] forKey:AVVideoHeightKey];
    [[NSFileManager defaultManager] removeItemAtPath:kTempMoviePath error:nil];
    
    NSDictionary *videoCleanApertureSettings = [NSDictionary dictionaryWithObjectsAndKeys:
                                                [NSNumber numberWithInt:mCameraView.frame.size.width], AVVideoCleanApertureWidthKey,
                                                [NSNumber numberWithInt:mCameraView.frame.size.height], AVVideoCleanApertureHeightKey,
                                                [NSNumber numberWithInt:0], AVVideoCleanApertureHorizontalOffsetKey,
                                                [NSNumber numberWithInt:0], AVVideoCleanApertureVerticalOffsetKey,
                                                nil];
    NSDictionary *videoAspectRatioSettings = [NSDictionary dictionaryWithObjectsAndKeys:
                                              [NSNumber numberWithInt:3], AVVideoPixelAspectRatioHorizontalSpacingKey,
                                              [NSNumber numberWithInt:3], AVVideoPixelAspectRatioVerticalSpacingKey,
                                              nil];
    
    NSMutableDictionary * compressionProperties = [[NSMutableDictionary alloc] init];
    [compressionProperties setObject:videoCleanApertureSettings forKey:AVVideoCleanApertureKey];
    [compressionProperties setObject:videoAspectRatioSettings forKey:AVVideoPixelAspectRatioKey];
    [compressionProperties setObject:[NSNumber numberWithInt: 400000] forKey:AVVideoAverageBitRateKey]; //6400000
    [compressionProperties setObject:[NSNumber numberWithInt: 32] forKey:AVVideoMaxKeyFrameIntervalKey];
    [compressionProperties setObject:AVVideoProfileLevelH264BaselineAutoLevel forKey:AVVideoProfileLevelKey];
    
    [videoSettings setObject:compressionProperties forKey:AVVideoCompressionPropertiesKey];
    [videoSettings setObject:AVVideoScalingModeResizeAspectFill forKey:AVVideoScalingModeKey];
    
    
    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        
        NSLog(@"1--------%@", [NSDate date]);
        if(IS_IPHONE5)
        {
            mMovieWriter = [[GPUImageMovieWriter alloc] initWithMovieURL:kTempMovieURL size:CGSizeMake(480, 640) fileType:AVFileTypeMPEG4 outputSettings:videoSettings];
        }
        else
        {
            mMovieWriter = [[GPUImageMovieWriter alloc] initWithMovieURL:kTempMovieURL size:CGSizeMake(480, 640) fileType:AVFileTypeMPEG4 outputSettings:videoSettings];
        }
        
        NSLog(@"2--------%@", [NSDate date]);
        
        [mCropFilter addTarget:mMovieWriter];
        
        
        NSLog(@"3--------%@", [NSDate date]);
        
        mVideoCamera.audioEncodingTarget = mMovieWriter;
//        mMovieWriter.shouldPassthroughAudio = YES;
        
        if ([mVideoCamera.inputCamera isTorchAvailable]) {
            if ( [mVideoCamera.inputCamera lockForConfiguration:nil] ) {
                
                [mVideoCamera.inputCamera setTorchMode: mTorchModeVideo];
                
                if (mTorchModeVideo == AVCaptureTorchModeOn) {
                    [mVideoCamera.inputCamera setFlashMode: AVCaptureFlashModeOn];
                }
                else if (mTorchModeVideo == AVCaptureTorchModeAuto) {
                    [mVideoCamera.inputCamera setFlashMode: AVCaptureFlashModeAuto];
                }
                else {
                    [mVideoCamera.inputCamera setFlashMode: AVCaptureFlashModeOff];
                }

                [mVideoCamera.inputCamera unlockForConfiguration];
            }
        }
        
        NSLog(@"4--------%@", [NSDate date]);
        [mMovieWriter startRecording];
        
        NSLog(@"5--------%@", [NSDate date]);
        
    });
    
}

- (void) stopCaptureVideo
{
    [mProgress show: YES];
    
    [mMovieWriter finishRecordingWithCompletionHandler:^{
        if(mVideoDuringTimer) {
            [mVideoDuringTimer invalidate];
            mVideoDuringTimer = nil;
        }
        
        mVideoCamera.audioEncodingTarget = nil;
        [mMovieWriter finishRecording];
        
        mMovieWriter = nil;
        mFlgVideoProcessing = NO;
        
        [self trimVideo];
        
        if ([mVideoCamera.inputCamera isTorchAvailable]) {
            if ( [mVideoCamera.inputCamera lockForConfiguration:nil] ) {
                
                [mVideoCamera.inputCamera setTorchMode: mTorchModeVideo];
                
                if (mTorchModeVideo == AVCaptureTorchModeOn) {
                    [mVideoCamera.inputCamera setFlashMode: AVCaptureFlashModeOn];
                }
                else if (mTorchModeVideo == AVCaptureTorchModeAuto) {
                    [mVideoCamera.inputCamera setFlashMode: AVCaptureFlashModeAuto];
                }
                else {
                    [mVideoCamera.inputCamera setFlashMode: AVCaptureFlashModeOff];
                }
                
                [mVideoCamera.inputCamera unlockForConfiguration];
            }
        }
    }];
}

- (void)trimVideo
{
    [self removeFile: kCapturedMoviePath];
    
    NSURL *videoFileUrl = [NSURL fileURLWithPath: kTempMoviePath];
    
    //AVAsset *anAsset = [[AVURLAsset alloc] initWithURL:videoFileUrl options:nil];
    AVAsset *anAsset = [AVAsset assetWithURL:videoFileUrl];
    
    AVAssetImageGenerator *imageGenerator = [[AVAssetImageGenerator alloc] initWithAsset:anAsset];
    imageGenerator.appliesPreferredTrackTransform=TRUE;
    
    CMTime time = CMTimeMake(1, 5);
    
    CGImageRef imageRef = [imageGenerator copyCGImageAtTime:time actualTime:NULL error:NULL];
    UIImage *thumbnail = [UIImage imageWithCGImage:imageRef];
    
    imageThumbnail = thumbnail;
    
//  [mImgViewLibrary setImage:thumbnail];
//  return;
    
    NSData *thumbnailData = UIImageJPEGRepresentation(thumbnail, 0.8);
    
    NSArray *compatiblePresets = [AVAssetExportSession exportPresetsCompatibleWithAsset:anAsset];
    if ([compatiblePresets containsObject:AVAssetExportPresetMediumQuality]) {
        
        AVAssetExportSession *exportSession = [[AVAssetExportSession alloc]
                                               initWithAsset:anAsset presetName:AVAssetExportPresetPassthrough];
        // Implementation continues.
        
        NSURL *furl = [NSURL fileURLWithPath: kCapturedMoviePath];
        
        exportSession.outputURL = furl;
        exportSession.outputFileType = AVFileTypeQuickTimeMovie;
        
        CMTime start = CMTimeMakeWithSeconds(0, anAsset.duration.timescale);
        CMTime duration = CMTimeMakeWithSeconds(anAsset.duration.value - anAsset.duration.timescale * 0.5, anAsset.duration.timescale);
        CMTimeRange range = CMTimeRangeMake(start, duration);
        exportSession.timeRange = range;
        
        [exportSession exportAsynchronouslyWithCompletionHandler:^{
            
            switch ([exportSession status]) {
                case AVAssetExportSessionStatusFailed:
                    NSLog(@"Export failed: %@", [[exportSession error] localizedDescription]);
                    break;
                case AVAssetExportSessionStatusCancelled:
                    NSLog(@"Export canceled");
                    break;
                default:
                    NSLog(@"NONE");
                    dispatch_async(dispatch_get_main_queue(), ^{
//                        [Engine setGVideoUrl: kCapturedMovieURL];
                        
//                        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle: @"Confirm" message: @"Are you sure to upload the video?" delegate: self cancelButtonTitle: @"No" otherButtonTitles: @"Yes", nil];
//                        alertView.tag = 1;
//                        [alertView show];
                        
                        [mProgress hide: YES];
                        
                        // TODO: 1/22
//                        [NSThread sleepForTimeInterval: 2.0f];
////                        [self initialize];                        
//                        [delegate didFinishedRecordVideo: [NSData dataWithContentsOfURL: kCapturedMovieURL] url: kCapturedMovieURL];
                        [[NSNotificationCenter defaultCenter] postNotificationName: NOTIF_DID_FINISH_RECORD_VIDEO object: nil];
                        //////////////
                    });
                    
                    break;
            }
        }];
        
    }
    
}

-(void)removeFile:(NSString *)filePath
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    NSError *error;
    BOOL success = [fileManager removeItemAtPath:filePath error:&error];
    if (success) {
        
    }
    else {
        NSLog(@"Could not delete file -:%@ ",[error localizedDescription]);
    }
}

//========================================================================================================

#pragma mark -
#pragma mark - Touch Event

- (IBAction)onTouchBtnBack: (id)sender {
    [self.navigationController popViewControllerAnimated: YES];
}

- (IBAction)onTouchBtnLibrary: (id)sender {
    UIImagePickerController *pickerController = [[UIImagePickerController alloc] init];
    pickerController.delegate = self;
    pickerController.allowsEditing = YES;
    pickerController.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    pickerController.mediaTypes = [[NSArray alloc] initWithObjects: (NSString *)kUTTypeImage, (NSString *)kUTTypeMovie, nil];
    
    [self presentViewController: pickerController animated: YES completion: nil];
}

- (IBAction)onTouchBtnCapture: (id)sender {
    
    if (mCameraMode == CAMERA_MODE_PHOTO) {
        [mVideoDuringTimeLabel setHidden: YES];
        
        if (mCameraMode != CAMERA_MODE_PHOTO) {
            mCameraMode = CAMERA_MODE_PHOTO;
            
            [self setupCameraForPhoto];
            
            return;
        }
        
        [mPhotoCamera capturePhotoAsJPEGProcessedUpToFilter: filter/*mCropFilter*/ withCompletionHandler: ^(NSData *processedJPEG, NSError *error) {
            if (error) {
                NSLog(@"%@",error);
                
            }
            else {
                UIImage* capturedImage = [[UIImage alloc] initWithData: processedJPEG];
    //
    //            UIImageWriteToSavedPhotosAlbum(capturedImage, nil, nil, nil);
                
                NSString* const CreativeSDKClientId = @"c09ef6af818c4ffd9abf963c8165eb4e";
                NSString* const CreativeSDKClientSecret = @"d7250b05-f316-453f-ac13-21c63a5e0625";
                
                [[AdobeUXAuthManager sharedManager] setAuthenticationParametersWithClientID:CreativeSDKClientId withClientSecret:CreativeSDKClientSecret];
                

                NSLog(@"%f", capturedImage.size.width);
                NSLog(@"%f", capturedImage.size.height);
                
                CGRect r;
                CGRect croppedRect;
                
                if (capturedImage.size.height > capturedImage.size.width)
                {
                    r = CGRectMake(0, (capturedImage.size.height - capturedImage.size.width) / 2,
                                          capturedImage.size.width, capturedImage.size.width);
                    croppedRect = r;
                }
                else if (capturedImage.size.height < capturedImage.size.width)
                {
                    r = CGRectMake((capturedImage.size.width - capturedImage.size.height) / 2, 0,
                                   capturedImage.size.height, capturedImage.size.height) ;
                    croppedRect = r;
                }
                
                UIImage *croppedImage = [capturedImage imageCroppedToRect:croppedRect];
                
                NSArray * toolOrder = @[kAFEnhance, kAFEffects, kAFStickers, kAFOrientation, kAFFocus, kAFColorAdjust,  kAFLightingAdjust, kAFOrientation, kAFSharpness, kAFAdjustments, kAFDraw, kAFRedeye, kAFWhiten, kAFText, kAFBlur, kAFMeme, kAFFrames, kAFSplash];
                [AFPhotoEditorCustomization setToolOrder:toolOrder];
                
                AdobeUXImageEditorViewController *editorController = [[AdobeUXImageEditorViewController alloc] initWithImage:croppedImage];
                [editorController setDelegate:self];
                [self presentViewController:editorController animated:YES completion:nil];
            }
            
        }];
        
    }
    else {
        if (!mFlgVideoProcessing) {
            
            if (mCameraMode != CAMERA_MODE_VIDEO) {
                mCameraMode = CAMERA_MODE_VIDEO;
                
                [self setupCameraForVideo];
                
                return;
            }
            
            [mBtnRotate setHidden: YES];
            [mBtnFlash setHidden: YES];
            [mBtnCapture setImage: [UIImage imageNamed: @"audio_img_record.png"] forState: UIControlStateNormal];
            [mBtnAudio setHidden: YES];
            [mBtnRecordVideo setHidden: YES];
            [mImgViewLibrary setHidden: YES];
            
            mFlgVideoProcessing = YES;
            [mVideoDuringTimeLabel setHidden: NO];
            
            [self recordVideo];
        }
        else {
            [mBtnRotate setHidden: NO];
            [mBtnFlash setHidden: NO];
            [mBtnCapture setImage: [UIImage imageNamed: @"video_img_record_start1.png"] forState: UIControlStateNormal];
            [mBtnAudio setHidden: NO];
            [mBtnRecordVideo setHidden: NO];
            [mImgViewLibrary setHidden: NO];
            
            mFlgVideoProcessing = NO;
            
            [self stopCaptureVideo];
        }
    }

}

- (IBAction)onTouchBtnRecordVideo: (id)sender {
    if (mCameraMode == CAMERA_MODE_PHOTO) {
        mCameraMode = CAMERA_MODE_VIDEO;
        [self setupCameraForVideo];
        
        [mBtnRecordVideo setImage: [UIImage imageNamed: @"camera_img_photo.png"] forState: UIControlStateNormal];
        [mBtnCapture setImage: [UIImage imageNamed: @"video_img_record_start1.png"] forState: UIControlStateNormal];
    }
    else {
        mCameraMode = CAMERA_MODE_PHOTO;
        [self setupCameraForPhoto];
        
        [mBtnRecordVideo setImage: [UIImage imageNamed: @"camera_img_video.png"] forState: UIControlStateNormal];
        [mBtnCapture setImage: [UIImage imageNamed: @"camera_img_capture.png"] forState: UIControlStateNormal];
    }
    
}

- (IBAction)onTouchBtnRecordAudio: (id)sender {
    [self initialize];
    
    [Engine setGAudioRecordingMode:@"StreamingAudio"];
    
    HLAudioViewController *audioView = (HLAudioViewController *)[self.storyboard instantiateViewControllerWithIdentifier: @"HLAudioViewController"];
    audioView.delegate = self;
    [self.navigationController pushViewController: audioView animated: YES];
}

- (IBAction)onTouchBtnFlash: (id)sender
{   
    if (mCameraMode == CAMERA_MODE_PHOTO) {
        if ([mPhotoCamera.inputCamera isTorchAvailable]) {
        
            if ( [mPhotoCamera.inputCamera lockForConfiguration:nil] ) {
                
                if ([mPhotoCamera.inputCamera torchMode] == AVCaptureTorchModeOn) {
                    [mBtnFlash setTitle: @"Auto" forState: UIControlStateNormal];
                    
                    [mPhotoCamera.inputCamera setTorchMode: AVCaptureTorchModeAuto];
                    [mPhotoCamera.inputCamera setFlashMode: AVCaptureFlashModeAuto];
                }
                else if ([mPhotoCamera.inputCamera torchMode] == AVCaptureTorchModeAuto) {
                    [mBtnFlash setTitle: @"Off" forState: UIControlStateNormal];
                    
                    [mPhotoCamera.inputCamera setTorchMode: AVCaptureTorchModeOff];
                    [mPhotoCamera.inputCamera setFlashMode: AVCaptureFlashModeOff];
                }
                else {
                    [mBtnFlash setTitle: @"On" forState: UIControlStateNormal];
                    
                    [mPhotoCamera.inputCamera setTorchMode: AVCaptureTorchModeOn];
                    [mPhotoCamera.inputCamera setFlashMode: AVCaptureFlashModeOn];
                }
                
                [mPhotoCamera.inputCamera unlockForConfiguration];
            }
        }
        
        mTorchModePhoto = [mPhotoCamera.inputCamera torchMode];
        
    }
    else if (mCameraMode == CAMERA_MODE_VIDEO) {
        if ([mVideoCamera.inputCamera isTorchAvailable]) {
            
            if ( [mVideoCamera.inputCamera lockForConfiguration:nil] ) {
                
                if ([mVideoCamera.inputCamera torchMode] == AVCaptureTorchModeOn) {
                    [mBtnFlash setTitle: @"Auto" forState: UIControlStateNormal];
                    
                    [mVideoCamera.inputCamera setTorchMode: AVCaptureTorchModeAuto];
                    [mVideoCamera.inputCamera setFlashMode: AVCaptureFlashModeAuto];
                }
                else if ([mVideoCamera.inputCamera torchMode] == AVCaptureTorchModeAuto) {
                    [mBtnFlash setTitle: @"Off" forState: UIControlStateNormal];
                    
                    [mVideoCamera.inputCamera setTorchMode: AVCaptureTorchModeOff];
                    [mVideoCamera.inputCamera setFlashMode: AVCaptureFlashModeOff];
                }
                else {
                    [mBtnFlash setTitle: @"On" forState: UIControlStateNormal];
                    
                    [mVideoCamera.inputCamera setTorchMode: AVCaptureTorchModeOn];
                    [mVideoCamera.inputCamera setFlashMode: AVCaptureFlashModeOn];
                }
                
                [mVideoCamera.inputCamera unlockForConfiguration];
            }
        }
        
        mTorchModeVideo = [mVideoCamera.inputCamera torchMode];
    }
}

- (IBAction)onTouchBtnFlip: (id)sender {
    if (mCameraMode == CAMERA_MODE_PHOTO) {
        [mPhotoCamera rotateCamera];
    }
    else if (mCameraMode == CAMERA_MODE_VIDEO) {
        [mVideoCamera rotateCamera];
    }
}

//========================================================================================================

#pragma mark -
#pragma mark - AdobeUXImageEditorViewControllerDelegate

- (void)photoEditor:(AdobeUXImageEditorViewController *)editor finishedWithImage:(UIImage *)image {
    // Handle the result image here
    
    if (abs(image.size.height - image.size.width) < 10)
    {
        [self dismissViewControllerAnimated: YES completion: nil];
        
        [self initialize];
        
        NSLog(@"%f", image.size.height);
        NSLog(@"%f", image.size.width);
        
        
        [delegate didFinishedPhotoEdit: UIImageJPEGRepresentation(image, 0.8) url: nil];
    }
    else
    {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle: @"Warning" message: @"Please adjust width/height rate with your image." delegate: nil cancelButtonTitle: @"OK" otherButtonTitles: nil, nil];
        
        [alertView show];
    }
    
}

- (void)photoEditorCanceled:(AdobeUXImageEditorViewController *)editor {
    // Handle cancellation here

    [self dismissViewControllerAnimated: YES completion: nil];
}

//========================================================================================================

#pragma mark -
#pragma mark - UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (alertView.tag == 1) {
        if (buttonIndex == 1) {
            [self initialize];
            
            [delegate didFinishedRecordVideo: [NSData dataWithContentsOfURL: kCapturedMovieURL] url: kCapturedMovieURL image:imageThumbnail];
        }
    }
}

- (void)onFinishRecordVideo {
//    [self initialize];
    
//    [delegate didFinishedRecordVideo: [NSData dataWithContentsOfURL: kCapturedMovieURL] url: kCapturedMovieURL];
    
    [delegate didFinishedRecordVideo:[NSData dataWithContentsOfURL: kCapturedMovieURL] url:kCapturedMovieURL image:imageThumbnail];
}

//========================================================================================================

#pragma mark - 
#pragma mark - HLAudioViewControllerDelegate

- (void)didBackedFromRecordAudio {
    [self.navigationController popViewControllerAnimated: NO];
    
    [delegate didBackedFromRecordAudio];
}

- (void)didFinishedRecordAudio: (NSURL *)audioURL {
    [self.navigationController popViewControllerAnimated: NO];
    
    [delegate didFinishedRecordAudio: [NSData dataWithContentsOfURL: audioURL] url: audioURL];
}

//=========================================================================================================

#pragma mark -
#pragma mark - Image Picker

- (void)imagePickerController: (UIImagePickerController *) picker didFinishPickingMediaWithInfo: (NSDictionary *) _info {
    
//    UIImageJPEGRepresentation([_info valueForKey: UIImagePickerControllerEditedImage], 0.6)
    
    [picker dismissViewControllerAnimated : YES completion : ^{
        
        if ([[_info valueForKey: UIImagePickerControllerMediaType] isEqualToString: (NSString *)kUTTypeImage]) {
            NSString* const CreativeSDKClientId = @"c09ef6af818c4ffd9abf963c8165eb4e";
            NSString* const CreativeSDKClientSecret = @"d7250b05-f316-453f-ac13-21c63a5e0625";
            
            [[AdobeUXAuthManager sharedManager] setAuthenticationParametersWithClientID:CreativeSDKClientId withClientSecret:CreativeSDKClientSecret];
            
            UIImage *image = [_info[UIImagePickerControllerOriginalImage] resizedImage];
            
            CGRect rect = [_info[UIImagePickerControllerCropRect] CGRectValue];
            CGFloat s = MAX(rect.size.width, rect.size.height);
            CGRect r = CGRectMake(CGRectGetMidX(rect) - s * 0.5,
                                  CGRectGetMidY(rect) - s * 0.5, s, s);
            CGRect croppedRect = r;
            UIImage *croppedImage = [image imageCroppedToRect:croppedRect];
            
            NSArray * toolOrder = @[kAFEnhance, kAFEffects, kAFStickers, kAFOrientation, kAFFocus, kAFColorAdjust,  kAFLightingAdjust, kAFOrientation, kAFSharpness, kAFAdjustments, kAFDraw, kAFRedeye, kAFWhiten, kAFText, kAFBlur, kAFMeme, kAFFrames, kAFSplash];
            [AFPhotoEditorCustomization setToolOrder:toolOrder];
            
            AdobeUXImageEditorViewController *editorController = [[AdobeUXImageEditorViewController alloc] initWithImage: croppedImage];
            [editorController setDelegate:self];
            [self presentViewController:editorController animated:YES completion:nil];
        }
        else {
            [delegate didFinishedRecordVideo: [NSData dataWithContentsOfURL: [_info valueForKey: UIImagePickerControllerMediaURL]] url: [_info valueForKey: UIImagePickerControllerReferenceURL]];
            
            /*NSURL *videoURL = [_info objectForKey:UIImagePickerControllerReferenceURL];
            
            FBSDKShareVideo *video = [[FBSDKShareVideo alloc] init];
            video.videoURL = videoURL;
            FBSDKShareVideoContent *content = [[FBSDKShareVideoContent alloc] init];
            content.video = video;
            
            [FBSDKShareDialog showFromViewController:self
                                         withContent:content
                                            delegate:nil];*/
        }
        
    }];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    //    mFlgChangePhoto = NO;
    
    [picker dismissViewControllerAnimated: YES completion: nil];
}

//=========================================================================================================

#pragma mark -
#pragma mark - UITableView

- ( CGFloat ) tableView : ( UITableView* ) tableView heightForRowAtIndexPath : ( NSIndexPath* ) indexPath
{
    if (indexPath.row == 0) {
        return IS_IPHONE6 ? 375.0f : 320.0f;
    }
    
    return  186.0f;
}

@end
