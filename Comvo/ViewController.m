//
//  ViewController.m
//  Comvo
//
//  Created by DeMing Yu on 12/22/14.
//  Copyright (c) 2014 DeMing Yu. All rights reserved.
//

#import "ViewController.h"

#import "AppEngine.h"
#import "Constants_Comvo.h"
#import "AppDelegate.h"

@interface ViewController () <UIScrollViewDelegate>

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    mBtnLogin.layer.cornerRadius = 10.0f;
    mBtnLogin.clipsToBounds = YES;
    
    mBtnSignup.layer.cornerRadius = 10.0f;
    mBtnSignup.clipsToBounds = YES;
    
    [[AppEngine getInstance] loadLastLogin];
    
    [[UIApplication sharedApplication] setStatusBarStyle: UIStatusBarStyleLightContent animated: YES];
    
    self.edgesForExtendedLayout = UIRectEdgeNone;
    self.extendedLayoutIncludesOpaqueBars = NO;
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    for (int i = 0; i < 6; i++) {
        UIImageView *imgView = [[UIImageView alloc] initWithFrame: CGRectMake((IS_IPHONE6 ? 375.0f : 320.0f) * i, 0, (IS_IPHONE6 ? 375.0f : 320.0f), mSView.frame.size.height)];
        
        //[imgView setImage: [UIImage imageNamed: @"login_img_slide%d.png", i]];
        [imgView setImage: [UIImage imageNamed: [NSString stringWithFormat:@"login_img_slide%d.png", i+1]]];
        
        //[NSString stringWithFormat: @"%d months ago", (int)[breakdownInfo month]];
        [mSView addSubview: imgView];
    }
    
    [mSView setContentSize: CGSizeMake((IS_IPHONE6 ? 375.0f : 320.0f) * 6, mSView.frame.size.height)];
    
    mLocationMgr  = [[CLLocationManager alloc] init];
    mLocationMgr.delegate = self;
    
    if ([mLocationMgr respondsToSelector:@selector(requestWhenInUseAuthorization)])
    {
        [mLocationMgr requestWhenInUseAuthorization];
    }
    
    [mLocationMgr startUpdatingLocation];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear: animated];
    
    UserInfo *currentUser = [[AppEngine getInstance] gCurrentUser];
    
    NSLog(@"%@", [Engine gCurrentUser].mGreetingAudioUrl);
    
    if (currentUser != nil) {
        mButtonView.hidden = YES;
    } else {
        mButtonView.hidden = NO;
    }
    
    if (currentUser != nil) {
        mContentView.hidden = YES;
    } else {
        mContentView.hidden = YES;
    }
    
    [self.navigationController setNavigationBarHidden: YES];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    if ([[AppEngine getInstance] gCurrentUser]) {
        NSLog(@"%@", [Engine gCurrentUser].mUserName);
        [AppDel showHomeViewController];
    }
}

-(UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//======================================================================================================

#pragma mark -
#pragma mark - CLLocationManager

- (void)locationManager:(CLLocationManager *)manager
     didUpdateLocations:(NSArray *)locations
{
    CLLocation *newLocation = [locations lastObject];
    
    CLLocationCoordinate2D centerLocation;
    centerLocation.latitude = newLocation.coordinate.latitude;
    centerLocation.longitude = newLocation.coordinate.longitude;
    
    mCentreLocation.latitude = newLocation.coordinate.latitude;
    mCentreLocation.longitude = newLocation.coordinate.longitude;
    
    [Engine setGCurrentLocation: centerLocation];
}


//======================================================================================================

#pragma mark - 
#pragma mark - Touch Event

- (IBAction)onTouchBtnLogin: (id)sender {
    
}

- (IBAction)onTouchBtnSignup: (id)sender {
    
}

//===========================================================================================================================================

#pragma mark -
#pragma mark - UIScrollViewController Delegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    CGFloat pageWidth = scrollView.frame.size.width;
    int page = floor((scrollView.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
    
    mPageCtl.currentPage = page;
}

@end
