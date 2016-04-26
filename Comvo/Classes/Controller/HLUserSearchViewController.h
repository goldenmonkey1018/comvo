//
//  HLUserSearchViewController.h
//  Comvo
//
//  Created by Max Broeckel on 2/4/15.
//  Copyright (c) 2015 Max Broeckel. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MBProgressHUD.h>

@interface HLUserSearchViewController : UIViewController {
    IBOutlet UISearchBar    *mSearchBar;
    IBOutlet UITableView    *mTView;
    
    NSMutableArray          *mArrUsers;
    int                     mPage;
    int                     nSearchMode;
    int                     nSearchFeedMode;
    
    MBProgressHUD           *mProgress;
    NSMutableArray          *mArrPosts;
    
    int                     mFeedMode;
    
    
    IBOutlet UIButton       *mBtnOptionUsername;
    IBOutlet UIButton       *mBtnOptionHashtag;
}

@property (nonatomic, copy) NSString    *mStrHashTag;

@end
