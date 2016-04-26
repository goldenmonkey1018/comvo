//
//  HLBroadcastViewController.h
//  Comvo
//
//  Created by DeMing Yu on 1/8/15.
//  Copyright (c) 2015 DeMing Yu. All rights reserved.
//

#import <UIKit/UIKit.h>

@class HLBroadcastViewController;

@protocol HLBroadcastViewControllerDelegate <NSObject>

@optional
- (void)didBackToCameraView: (HLBroadcastViewController *)viewController;

@end

@class SZTextView;
@class MBProgressHUD;

@interface HLBroadcastViewController : UITableViewController {
    IBOutlet SZTextView         *mTextCaption;
    IBOutlet UILabel            *mlblLocation;
    
    MBProgressHUD           *mProgress;
    
    NSArray                 *mHashTagArray;
    
    
}

@property (nonatomic, assign) id<HLBroadcastViewControllerDelegate> delegate;
@property (nonatomic, copy) NSString    *mMediaType;
@property (nonatomic, copy) NSURL       *mMediaURL;
@property (nonatomic, copy) NSData      *mMediaData;
@property (nonatomic, copy) UIImage     *mMediaThumbnail;

@property (nonatomic,strong) UIDocumentInteractionController *docFile;

-(void)getFullAddress:(NSString*)latitude :(NSString*)longitude ;
-(void)fetchedFullMyAddress:(NSData *)responseData;

- (IBAction)onTouchFacebookSharing:(id)sender;
- (IBAction)onTouchTwitterSharing:(id)sender;
- (IBAction)onTouchInstagramSharing:(id)sender;
- (IBAction)onTouchTumblrSharing:(id)sender;


@end
