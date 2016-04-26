//
//  HLCommentViewController.h
//  Comvo
//
//  Created by Max Broeckel on 29/01/15.
//  Copyright (c) 2015 Max Broeckel. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MBProgressHUD;
@class PostInfo;
@class SZTextView;

@interface HLCommentViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate> {
    IBOutlet UITableView    *mTView;
    IBOutlet UIView         *mViewBottom;
//  IBOutlet UITextField    *mTextComment;
//  IBOutlet UITextView     *mTextComment;
    IBOutlet SZTextView     *mTextComment;
    
    NSMutableArray          *mArrComment;
    int                     mPage;
    
    MBProgressHUD           *mProgress;
}

@property (nonatomic, copy) PostInfo    *mPostInfo;

@end
