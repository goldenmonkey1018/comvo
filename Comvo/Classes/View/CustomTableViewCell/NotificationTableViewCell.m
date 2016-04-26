//
//  NotificationTableViewCell.m
//  Comvo
//
//  Created by Max Brian on 05/10/15.
//  Copyright (c) 2015 DeMing Yu. All rights reserved.
//

#import "NotificationTableViewCell.h"
#import "HLProfileOtherViewController.h"

#import "AppEngine.h"
#import "Constants_Comvo.h"
#import "UIImageView+WebCache.h"

//#import <SDWebImage/SDWebImageManager.h>
#import <SDWebImage/UIButton+WebCache.h>

#import <AVFoundation/AVFoundation.h>

@implementation NotificationTableViewCell

@synthesize mNotiInfo;
@synthesize delegate;

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setNotificationInfo:(NotificationInfo *)notiInfo{
    [self setMNotiInfo: notiInfo];
    
    //NSLog(@"%@", mNotiInfo.mFullName);
    [mNotificationDetail setText: mNotiInfo.mFullName];
    
    mImgPhoto.layer.cornerRadius = 20.0f;
    mImgPhoto.clipsToBounds = YES;
    
    mBtnPhoto.layer.cornerRadius = 20.0f;
    mBtnPhoto.clipsToBounds = YES;
    
    NSString *strPhotoUrl = mNotiInfo.mProfilePhoto;
    
    if ([mNotiInfo.mNotifType isEqualToString:@"1"]){ // Likes Posting
        if ([mNotiInfo.mMediaType isEqualToString:@"1"]){
            [mNotificationDetail setText: [NSString stringWithFormat:@"%@ likes your Audio posting!!!",  mNotiInfo.mFullName]];
        }
        else if ([mNotiInfo.mMediaType isEqualToString:@"2"]){
            [mNotificationDetail setText: [NSString stringWithFormat:@"%@ likes your Picture posting!!!",  mNotiInfo.mFullName]];
        }
        else if ([mNotiInfo.mMediaType isEqualToString:@"3"]){
            [mNotificationDetail setText: [NSString stringWithFormat:@"%@ likes your Video posting!!!",  mNotiInfo.mFullName]];
        }
    }
    else if ([mNotiInfo.mNotifType isEqualToString:@"2"]){ // Commenting
        
        if ([mNotiInfo.mMediaType isEqualToString:@"1"]){
            [mNotificationDetail setText: [NSString stringWithFormat:@"%@ commented your Audio posting!!!",  mNotiInfo.mFullName]];
        }
        else if ([mNotiInfo.mMediaType isEqualToString:@"2"]){
            [mNotificationDetail setText: [NSString stringWithFormat:@"%@ commented your Picture posting!!!",  mNotiInfo.mFullName]];
        }
        else if ([mNotiInfo.mMediaType isEqualToString:@"3"]){
            [mNotificationDetail setText: [NSString stringWithFormat:@"%@ commented your Video posting!!!",  mNotiInfo.mFullName]];
        }
    }
    else if ([mNotiInfo.mNotifType isEqualToString:@"3"]){ // Mentioning
        
        if ([mNotiInfo.mMediaType isEqualToString:@"1"]){
            [mNotificationDetail setText: [NSString stringWithFormat:@"%@ mentioned you in his Audio posting!!!",  mNotiInfo.mFullName]];
        }
        else if ([mNotiInfo.mMediaType isEqualToString:@"2"]){
            [mNotificationDetail setText: [NSString stringWithFormat:@"%@ mentioned you in his Picture posting!!!",  mNotiInfo.mFullName]];
        }
        else if ([mNotiInfo.mMediaType isEqualToString:@"3"]){
            [mNotificationDetail setText: [NSString stringWithFormat:@"%@ mentioned you in his Video posting!!!",  mNotiInfo.mFullName]];
        }
    }
    else if ([mNotiInfo.mNotifType isEqualToString:@"4"]){ // Following
        [mNotificationDetail setText: [NSString stringWithFormat:@"%@ is following you now!!!",  mNotiInfo.mFullName]];
    }
    
    [mBtnPhoto sd_setBackgroundImageWithURL:[NSURL URLWithString: [NSString stringWithFormat: @"%@%@", API_HOME, strPhotoUrl]] forState:UIControlStateNormal placeholderImage:[UIImage imageNamed: @"profile_img_default_regular.png"]];
    
    NSDate *post_date = [NSDate dateWithTimeIntervalSince1970: [mNotiInfo.mNotifDate intValue]];
    NSDate *current_date  = [NSDate date];
    
    [mTimeAgo setText: [self stringFromTimeInterval: post_date toDate: current_date]];
    
}

- (IBAction)onTouchImgPhoto:(id)sender{
    //mNotiInfo.mNotifUser
    
    [delegate didTouchedUserID:self userID:mNotiInfo.mNotifUser];
}

- (NSString *)stringFromTimeInterval: (NSDate *)fromDate toDate: (NSDate *)toDate
{
    NSCalendar *sysCalendar = [NSCalendar currentCalendar];
    unsigned int unitFlags = NSHourCalendarUnit | NSMinuteCalendarUnit | NSDayCalendarUnit | NSMonthCalendarUnit;
    
    NSDateComponents *breakdownInfo = [sysCalendar components: unitFlags fromDate: fromDate toDate: toDate options: 0];
    
    if ([breakdownInfo month] > 0)
    {
        if ([breakdownInfo month] == 1)
            return [NSString stringWithFormat: @"a month ago"];
        else
            return [NSString stringWithFormat: @"%d months ago", (int)[breakdownInfo month]];
    }
    
    if ([breakdownInfo day] > 0)
    {
        if ([breakdownInfo day] == 1)
            return [NSString stringWithFormat: @"a day ago"];
        else
            return [NSString stringWithFormat: @"%d days ago", (int)[breakdownInfo day]];
    }
    
    
    if ([breakdownInfo hour] > 0)
    {
        if ([breakdownInfo hour] == 1)
        {
            return [NSString stringWithFormat: @"an hour ago"];
        }
        else
        {
            return [NSString stringWithFormat: @"%d hours ago", (int)[breakdownInfo hour]];
        }
    }
    
    if ([breakdownInfo minute] > 0)
    {
        if ([breakdownInfo minute] == 1)
        {
            return [NSString stringWithFormat: @"a min ago"];
        }
        else
        {
            return [NSString stringWithFormat: @"%d mins ago", (int)[breakdownInfo minute]];
        }
    }
    
    return @"a min ago";
}

@end
