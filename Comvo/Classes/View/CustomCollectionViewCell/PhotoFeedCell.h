//
//  PhotoFeedCell.h
//  Comvo
//
//  Created by Max Broeckel on 28/09/15.
//  Copyright (c) 2015 Max Broeckel Yu. All rights reserved.
//

#import <UIKit/UIKit.h>

@class PhotoFeedCell;

@protocol PhotoFeedCellDelegate

@optional;
- (void)didFinishedDeletePhoto: (PhotoFeedCell*) tableViewCell;
- (void)didTouchedPhotoThumbnail : (PhotoFeedCell *)tableViewCell;

@end

@class PostInfo;
@class MBProgressHUD;

@interface PhotoFeedCell : UICollectionViewCell{
    IBOutlet UIView             *mViewPhoto;
    
    MBProgressHUD           *mProgress;
}

@property (nonatomic, weak) IBOutlet UIImageView *imageView;
@property (nonatomic, weak) IBOutlet UIButton *btnPhotoDelete;
@property (nonatomic, weak) IBOutlet UIButton *btnThumbnail;

@property (nonatomic, assign) id<PhotoFeedCellDelegate> delegate;


@property (nonatomic, copy) PostInfo    *mPostInfo;

- (void)setPostInfo:(PostInfo *)postInfo flag: (BOOL) fDeleteFlg;
- (void)actionDeletePhoto;
- (void)actionPhotoThumbnail;

- (IBAction)onTouchPhotoDeleteButton:(id)sender;
- (IBAction)onTouchPhotoThumbnail:(id)sender;



@end
