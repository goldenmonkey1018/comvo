//
//  ViewController.h
//  Comvo
//
//  Created by DeMing Yu on 12/22/14.
//  Copyright (c) 2014 DeMing Yu. All rights reserved.
//

#import <UIKit/UIKit.h>

#import <CoreLocation/CoreLocation.h>

@interface ViewController : UIViewController <CLLocationManagerDelegate> {
    IBOutlet UIView         *mContentView;
    IBOutlet UIView         *mButtonView;
    
    IBOutlet UIButton       *mBtnLogin;
    IBOutlet UIButton       *mBtnSignup;
    
    IBOutlet UIScrollView   *mSView;
    IBOutlet UIPageControl  *mPageCtl;
    
    CLLocationCoordinate2D  mCentreLocation;
    CLLocationManager       *mLocationMgr;
}


@end

