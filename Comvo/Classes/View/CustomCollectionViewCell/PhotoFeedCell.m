//
//  PhotoFeedCell.m
//  Comvo
//
//  Created by Max Broekcel on 28/09/15.
//  Copyright (c) 2015 Max Broeckel. All rights reserved.
//

#import "PhotoFeedCell.h"
#import <SDWebImage/UIImageView+WebCache.h>

#import "AppEngine.h"
#import "Constants_Comvo.h"

#import "HLCommunication.h"

#import <MBProgressHUD.h>

@interface PhotoFeedCell () <UIAlertViewDelegate>
    
@end

@implementation PhotoFeedCell

@synthesize mPostInfo;
@synthesize delegate;

//- (void)getFeedWithMode:(NSInteger)feedMode page: (int)page {
//}
- (void)setPostInfo:(PostInfo *)postInfo flag: (BOOL) fDeleteFlg {
    [self setMPostInfo: postInfo];
    
    if ([postInfo.mMediaType isEqualToString: @"2"]) {
            [self.imageView sd_setImageWithURL: [NSURL URLWithString: [NSString stringWithFormat: @"%@%@", API_HOME, postInfo.mMedia]]
                placeholderImage: [UIImage imageNamed: @"common_img_placehold_photo.png"]];
    }
    
    self.btnThumbnail.hidden = TRUE;
    
    if (fDeleteFlg)
        self.btnPhotoDelete.hidden = FALSE;
    else
        self.btnPhotoDelete.hidden = TRUE;
}

- (void)actionDeletePhoto{
    NSLog(@"Touched Photo Delete Button");
    
    NSLog(@"%@", mPostInfo.mPostId);
    
    [self showLoading];
    
    NSDictionary *parameters = nil;
    
    void ( ^successed )( id responseObject ) = ^( id responseObject ) {
        NSLog(@"JSON: %@", responseObject);
        
        int result = [[responseObject objectForKey: @"success"] intValue];
        if (result) {
            // NSDictionary *dicData = [responseObject objectForKey: @"data"];
            // NSDictionary *dicUser = [dicData objectForKey: @"user"];
            
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle: @"Photo has been deleted successfully." message: [responseObject valueForKey: @"Success"] delegate: nil cancelButtonTitle: @"Ok" otherButtonTitles: nil];
            [alertView show];
            
            [delegate didFinishedDeletePhoto:self];
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
                   @"media_type":   @"2"};              // Photo Type
    
    //parameters = @{@"user_id":      [Engine gCurrentUser].mUserId,
    //               @"post_id":      self.mPostInfo.mPostId};
    
    [[HLCommunication sharedManager] sendToService: API_DELETEPOST params: parameters success: successed failure: failure];
}

- (IBAction)onTouchPhotoDeleteButton:(id)sender{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle: @"Confirm" message: @"Do you want to really delete photo?" delegate: self cancelButtonTitle: @"Yes" otherButtonTitles: @"No", nil];
    [alertView show];
}

- (IBAction)onTouchPhotoThumbnail:(id)sender{
    NSLog(@"Touched Photo Thumbnail");
    
    [delegate didTouchedPhotoThumbnail: self];
}


//==========================================================================================================================
#pragma mark -
#pragma mark - Waiting Progress Bar Delegate

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
        [self actionDeletePhoto];
    }
}
@end
