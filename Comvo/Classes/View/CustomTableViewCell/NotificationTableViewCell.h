//
//  NotificationTableViewCell.h
//  Comvo
//
//  Created by Max Brian on 05/10/15.
//  Copyright (c) 2015 DeMing Yu. All rights reserved.
//

#import <UIKit/UIKit.h>

@class NotificationTableViewCell;

@protocol NotificationTableViewCellDelegate

- (void)didTouchedUserID: (NotificationTableViewCell *)tableViewCell userID: (NSString *)userID;

@end

@class NotificationInfo;

@interface NotificationTableViewCell : UITableViewCell{
    IBOutlet UIImageView *mImgPhoto;        // Image Photo
    IBOutlet UIButton *mBtnPhoto;           // Photo Button
    
    IBOutlet UILabel *mNotificationDetail;  // Notification Details
    
    IBOutlet UILabel *mTimeAgo;             // Time mins ago (ex: 11 min ago)
}

@property (nonatomic, copy) NotificationInfo    *mNotiInfo;
@property (nonatomic, assign) id<NotificationTableViewCellDelegate> delegate;


- (void)setNotificationInfo: (NotificationInfo *)notiInfo;
- (IBAction)onTouchImgPhoto:(id)sender;

@end
