//
//  HLMessageViewController.h
//  Comvo
//
//  Created by Max Broeckel on 1/8/15.
//  Copyright (c) 2015 Max Broeckel. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HLMessageViewController : UIViewController {
    IBOutlet UITableView        *mTView;
    
    NSMutableArray              *mArrHistory;
    int                         mPage;
}

- (IBAction)onTouchBtnAdd: (id)sender;
@end
