//
//  HLNotificationViewController.h
//  Comvo
//
//  Created by DeMing Yu on 1/8/15.
//  Copyright (c) 2015 DeMing Yu. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MBProgressHUD;

@interface HLNotificationViewController : UIViewController{
    int    mPage;      // Page Num
    NSMutableArray          *mArrNotiInfo; // Posts Array
    
    MBProgressHUD           *mProgress;
}

- (void)getFeedWithMode: (int)page;

@property (nonatomic, weak) IBOutlet UITableView *tblNotiFeeds;


@end
