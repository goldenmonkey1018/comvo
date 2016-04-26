//
//  HLHomeViewController.m
//  Comvo
//
//  Created by Max Brian on 05/11/15.
//  Copyright (c) 2015 DeMing Yu. All rights reserved.
//

#import "HLHomeViewController.h"

#import "HLCameraViewController.h"
#import "HLBroadcastViewController.h"
#import "HLPreviewViewController.h"
#import "HLAudioViewController.h"
#import "HLCommunication.h"
#import "HLStreamViewController.h"

#import "AppEngine.h"

#import "Constants_Comvo.h"

@interface HLHomeViewController () <HLCameraViewControllerDelegate, HLBroadcastViewControllerDelegate, HLPreviewViewControllerDelegate, HLAudioViewControllerDelegate>

@end

@implementation HLHomeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Do any additional setup after loading the view.
    
    AppEngine *sharedEngine = (AppEngine *)[AppEngine getInstance];
    sharedEngine.gHomeViewController = self;
    
    [self updateDeviceToken];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateDeviceToken) name:@"UpdateDeviceToken" object:nil];
    
    [self getNotifCnt];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)updateDeviceToken{
    
    if ([Engine gDeviceToken].length > 0) {
        NSMutableDictionary *parameters = [NSMutableDictionary new];
        
        void ( ^successed )( id responseObject ) = ^( id responseObject ) {
            NSLog(@"JSON: %@", responseObject);
            
            int result = [[responseObject objectForKey: @"success"] intValue];
            if (result) {
                NSLog(@"token update success");
            }
            else {
                NSLog(@"token update error");
            }
            
            
        };
        
        void ( ^failure )( NSError* error ) = ^( NSError* error ) {
            NSLog(@"Error: %@", error);
            
        };
        
        NSString *updatelist = [[NSString alloc] initWithData:[NSJSONSerialization dataWithJSONObject:@{@"sess_token":[Engine gDeviceToken]} options:0 error:nil] encoding:NSUTF8StringEncoding];
        
        parameters[@"updatelist"] = updatelist;
        parameters[@"user_id"] = [Engine gCurrentUser].mUserId;
        
        [[HLCommunication sharedManager] sendToService: API_UPDATEPROFILE params: parameters success: successed failure: failure];
    }
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:animated];

}

- (void)getNotifCnt {
    
    NSDictionary *parameters = nil;
    
    void ( ^successed )( id responseObject ) = ^( id responseObject ) {
        NSLog(@"JSON: %@", responseObject);
        
        
        int result = [[responseObject objectForKey: @"success"] intValue];
        if (result) {
            
            NSDictionary *dicData = [responseObject objectForKey: @"data"];
            NSArray *arrPosts = [dicData objectForKey: @"notifications"];
            
            for (int i = 0; i < [arrPosts count]; i++) {
                NSDictionary *dicPost = [arrPosts objectAtIndex: i];
                
                NotificationInfo *notiInfo = [[NotificationInfo alloc] init];
                
                notiInfo.mNotifId            = [dicPost objectForKey: @"notif_id"];
                notiInfo.mNewCount           = [dicPost objectForKey: @"new_count"];
                
                RDVTabBarItem *tabItem = self.tabBar.items[3];
                
                if (![notiInfo.mNewCount isEqualToString:@"0"] && notiInfo.mNewCount != nil)
                    tabItem.badgeValue = notiInfo.mNewCount;
                else
                    tabItem.badgeValue = @"";
                
                tabItem.badgePositionAdjustment = UIOffsetMake(-20, 5);
            }
        }
        else {
            
        }
    };
    
    void ( ^failure )( NSError* error ) = ^( NSError* error ) {
        NSLog(@"Error: %@", error);
        
        
    };
    
    parameters = @{@"user_id":      [Engine gCurrentUser].mUserId,
                   @"start":         [NSString stringWithFormat: @"%d", 0],
                   @"page":         [NSString stringWithFormat: @"%d", 0],
                   @"is_new":       @"0"};
    
    
    [[HLCommunication sharedManager] sendToService: API_GETNOTIFICATIONS_NEW params: parameters success: successed failure: failure];
}


- (UIStoryboard *)storyboard {
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    return storyboard;
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

#pragma mark - RDVTabbarController Delegate

- (void)tabBarController:(RDVTabBarController *)tabBarController didDoubleTapViewController:(UIViewController *)viewController {
    NSInteger viewIndex = [self.viewControllers indexOfObject:viewController];
    
    if (viewIndex == 0) {
        HLStreamViewController *streamVC = (HLStreamViewController *)[(UINavigationController *)viewController viewControllers].firstObject;
        [streamVC moveToTop];
        
    }
    NSLog(@"%d", (int)viewIndex);
}

#pragma mark -
#pragma mark - HLCameraViewControllerDelegate

- (void)didFinishedPhotoEdit: (NSData *)mediaData url: (NSURL *)url {
    [self.navigationController popViewControllerAnimated: NO];
    
    HLBroadcastViewController *broadcastView = (HLBroadcastViewController *)[self.storyboard instantiateViewControllerWithIdentifier: @"HLBroadcastViewController"];
    broadcastView.delegate = self;
    broadcastView.mMediaType = @"2";
    broadcastView.mMediaURL  = url;
    broadcastView.mMediaData = mediaData;
    [self.navigationController pushViewController: broadcastView animated: YES];
    
}

- (void)didFinishedRecordVideo: (NSData *)mediaData url: (NSURL *)url image: (UIImage *) thumbnailImage{
    [self.navigationController popViewControllerAnimated: NO];
    
    HLPreviewViewController *previewView = (HLPreviewViewController *)[self.storyboard instantiateViewControllerWithIdentifier: @"HLPreviewViewController"];
    previewView.delegate = self;
    previewView.mMediaType = @"3";
    previewView.mMediaURL = url;
    previewView.mMediaData = mediaData;
    previewView.mMediaThumbnail = thumbnailImage;
    
    [self.navigationController pushViewController: previewView animated: YES];
    
}

- (void)didFinishedRecordVideo: (NSData *)mediaData url: (NSURL *)url{
    [self.navigationController popViewControllerAnimated: NO];
    
    HLPreviewViewController *previewView = (HLPreviewViewController *)[self.storyboard instantiateViewControllerWithIdentifier: @"HLPreviewViewController"];
    previewView.delegate = self;
    previewView.mMediaType = @"3";
    previewView.mMediaURL = url;
    previewView.mMediaData = mediaData;
    
    [self.navigationController pushViewController: previewView animated: YES];
    
}

- (void)didFinishedRecordAudio: (NSData *)mediaData url: (NSURL *)url {
    [self.navigationController popViewControllerAnimated: NO];
    
    HLPreviewViewController *previewView = (HLPreviewViewController *)[self.storyboard instantiateViewControllerWithIdentifier: @"HLPreviewViewController"];
    previewView.delegate = self;
    previewView.mMediaType = @"1";
    previewView.mMediaURL = url;
    previewView.mMediaData = mediaData;
    [self.navigationController pushViewController: previewView animated: YES];
}

- (void)didBackedFromRecordAudio {
    [self.navigationController popViewControllerAnimated: NO];
}

//==========================================================================================================================

#pragma mark -
#pragma mark - HLBroadcastViewControllerDelegate

- (void)didBackToCameraView: (HLBroadcastViewController *)viewController {
    [self.navigationController popViewControllerAnimated: NO];
    
    HLCameraViewController *cameraView = (HLCameraViewController *)[self.storyboard instantiateViewControllerWithIdentifier: @"HLCameraViewController"];
    cameraView.delegate = self;
    [self.navigationController pushViewController: cameraView animated: YES];
}

//========================================================================================================

#pragma mark -
#pragma mark - HLAudioViewControllerDelegate

- (void)didFinishedRecordAudio: (NSURL *)audioURL {
    [self.navigationController popViewControllerAnimated: NO];
    
    HLPreviewViewController *previewView = (HLPreviewViewController *)[self.storyboard instantiateViewControllerWithIdentifier: @"HLPreviewViewController"];
    previewView.delegate = self;
    previewView.mMediaType = @"1";
    previewView.mMediaURL = audioURL;
    previewView.mMediaData = [NSData dataWithContentsOfURL: audioURL];
    [self.navigationController pushViewController: previewView animated: YES];
}

//==========================================================================================================================

#pragma mark -
#pragma mark - HLPreviewViewControllerDelegate

- (void)didBackFromPreview: (NSString *)mediaType {
    [self.navigationController popViewControllerAnimated: NO];
    
    if ([mediaType isEqualToString: @"1"]) {
        [Engine setGAudioRecordingMode:@"StreamingAudio"];
        
        HLAudioViewController *audioView = (HLAudioViewController *)[self.storyboard instantiateViewControllerWithIdentifier: @"HLAudioViewController"];
        audioView.delegate = self;
        [self.navigationController pushViewController: audioView animated: YES];
    }
    else if ([mediaType isEqualToString: @"3"]) {
        HLCameraViewController *cameraView = (HLCameraViewController *)[self.storyboard instantiateViewControllerWithIdentifier: @"HLCameraViewController"];
        cameraView.delegate = self;
        [self.navigationController pushViewController: cameraView animated: YES];
        
    }
}

- (void)didDonePreview: (NSString *)mediaType mediaURL: (NSURL *)mediaURL mediaData: (NSData *)mediaData {
    [self.navigationController popViewControllerAnimated: NO];
    
    HLBroadcastViewController *broadcastView = (HLBroadcastViewController *)[self.storyboard instantiateViewControllerWithIdentifier: @"HLBroadcastViewController"];
    broadcastView.delegate = self;
    broadcastView.mMediaType = mediaType;
    broadcastView.mMediaURL  = mediaURL;
    broadcastView.mMediaData = mediaData;
    [self.navigationController pushViewController: broadcastView animated: YES];
}

- (void)didDonePreview: (NSString *)mediaType mediaURL: (NSURL *)mediaURL mediaData: (NSData *)mediaData thumbnail: (UIImage *)imageThumbnail{
    [self.navigationController popViewControllerAnimated: NO];
    
    HLBroadcastViewController *broadcastView = (HLBroadcastViewController *)[self.storyboard instantiateViewControllerWithIdentifier: @"HLBroadcastViewController"];
    broadcastView.delegate = self;
    broadcastView.mMediaType = mediaType;
    broadcastView.mMediaURL  = mediaURL;
    broadcastView.mMediaData = mediaData;
    broadcastView.mMediaThumbnail = imageThumbnail;
    
    [self.navigationController pushViewController: broadcastView animated: YES];
}

- (BOOL)tabBarController:(RDVTabBarController *)tabBarController shouldSelectViewController:(UIViewController *)viewController {
    
    if ([[viewController restorationIdentifier] isEqualToString: @"BroadCastRootViewController"]) {
        HLCameraViewController *cameraView = (HLCameraViewController *)[self.storyboard instantiateViewControllerWithIdentifier: @"HLCameraViewController"];
        cameraView.delegate = self;
        [self.navigationController pushViewController: cameraView animated: YES];
        
        return NO;
    }
    
    return YES;
}


@end
