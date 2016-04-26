//
//  HLStreamViewController.h
//  Comvo
//
//  Created by Max Broeckel on 1/7/15.
//  Copyright (c) 2015 Max Broeckel. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MBProgressHUD;

@interface HLStreamViewController : UIViewController <UITableViewDataSource, UITableViewDelegate> {
    
    IBOutlet UIView         *mViewTop;
    IBOutlet UITableView    *mTView;
    
    IBOutlet UIButton       *mBtnFollowing;
    IBOutlet UIButton       *mBtnPopluar;
    IBOutlet UIButton       *mBtnTrending;
    
    MBProgressHUD           *mProgress;
    int                     mPage;
    NSMutableArray          *mArrPosts;
    
    int                     mFeedMode;
    
}

@property (nonatomic, copy) NSString    *mStrHashTag;
@property (nonatomic, copy) NSString    *mSpecializedPostID;

- (void)moveToTop;

@end
