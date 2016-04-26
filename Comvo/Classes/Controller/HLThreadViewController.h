//
//  HLThreadViewController.h
//  Comvo
//
//  Created by Max Brian on 04/11/15.
//  Copyright (c) 2015 DeMing Yu. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HLThreadViewController : UIViewController{
    IBOutlet UITableView        *mTView;
    
    NSMutableArray              *mArrHistory;
    int                         mPage;
    
}

- (IBAction)onTouchBtnAdd: (id)sender;

@end