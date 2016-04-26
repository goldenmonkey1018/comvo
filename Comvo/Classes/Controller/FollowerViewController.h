//
//  FollowerViewController.h
//  Comvo
//
//  Created by Max Brian on 05/10/15.
//  Copyright (c) 2015 DeMing Yu. All rights reserved.
//

#import <UIKit/UIKit.h>

@class  MBProgressHUD;
@interface FollowerViewController : UIViewController{
    int    mPage;      // Page Num
    NSMutableArray          *mArrFollowUsers; // Posts Array

    IBOutlet UIImageView *mImgPhoto;
    IBOutlet UILabel *mlblName;
    IBOutlet UIButton *mbtnFollow;
    
    MBProgressHUD           *mProgress;
}

@property (nonatomic, weak) IBOutlet UITableView *tblFollowFeeds;

- (IBAction)onTouchFollowBtn:(id)sender;
- (IBAction)onTouchBtnBack: (id)sender;

- (void)getFeedWithPage: (int)page;

@end
