//
//  FollowerViewController.m
//  Comvo
//
//  Created by Max Brian on 05/10/15.
//  Copyright (c) 2015 DeMing Yu. All rights reserved.
//

#import "FollowingViewController.h"
#import "FollowingTableViewCell.h"

#import "AppEngine.h"
#import "Constants_Comvo.h"

#import "HLCommunication.h"

#import <SVPullToRefresh.h>
#import <MBProgressHUD.h>

@interface FollowingViewController ()<UITableViewDelegate, UITableViewDataSource, FollowingTableViewCellDelegate>

@end

@implementation FollowingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    mArrFollowUsers = [[NSMutableArray alloc] init];
    
    mPage = 0;
    [self getFeedWithPage:mPage];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)onTouchBtnBack: (id)sender {
    [self.navigationController popViewControllerAnimated: YES];
}

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

- (IBAction)onTouchFollowBtn:(id)sender{
    NSLog(@"Touched Follow Button");
}

//================================================================================================================

#pragma mark -
#pragma mark - SVPullToRefresh

- (void)insertRowAtTop {
    int64_t delayInSeconds = 2.0;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        mPage = 0;
        
        [self getFeedWithPage:mPage];
        
        [self.tblFollowFeeds.pullToRefreshView stopAnimating];
        
    });
}


- (void)insertRowAtBottom {
    int64_t delayInSeconds = 2.0;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        
        [self getFeedWithPage:mPage];
        
        [self.tblFollowFeeds.infiniteScrollingView stopAnimating];
    });
}

//================================================================================================================

#pragma mark -
#pragma mark - Get Feed

- (void)getFeedWithPage: (int)page {
    NSDictionary *parameters = nil;
    
    [self showLoading];
    
    void ( ^successed )( id responseObject ) = ^( id responseObject ) {
        NSLog(@"JSON: %@", responseObject);
        
        int result = [[responseObject objectForKey: @"success"] intValue];
        if (result) {
            NSDictionary *dicData = [responseObject objectForKey: @"data"];
            NSArray *arrPosts = [dicData objectForKey: @"user"];
            
            for (int i = 0; i < [arrPosts count]; i++) {
                NSDictionary *dicPost = [arrPosts objectAtIndex: i];
                
                UserInfo *userInfo = [[UserInfo alloc] init];
                
                userInfo.mUserId            = [dicPost objectForKey: @"user_id"];
                userInfo.mUserName          = [dicPost objectForKey: @"username"];
                userInfo.mPhotoUrl          = [dicPost objectForKey: @"profile_photo"];
                userInfo.mFullName          = [dicPost objectForKey: @"fullname"];
                userInfo.mPhotosCount       = [dicPost objectForKey: @"picture_count"];
                userInfo.mFollowingsCount   = [dicPost objectForKey: @"followings_count"];
                userInfo.mFollowersCount    = [dicPost objectForKey: @"followers_count"];
                userInfo.mPostCount         = [dicPost objectForKey: @"posts_count"];
                userInfo.mIsFollowing       = [dicPost objectForKey: @"is_following"];
                
                [mArrFollowUsers addObject: userInfo];
                
            }
            
            if ([arrPosts count] > 0) {
                mPage ++;
            }
            
            [self.tblFollowFeeds reloadData];
            
        }
        else {
            
        }
        [mProgress hide:YES];
        
        
    };
    
    void ( ^failure )( NSError* error ) = ^( NSError* error ) {
        NSLog(@"Error: %@", error);
        [mProgress hide:YES];
        
    };
    
    parameters = @{@"user_id":      [Engine gCurrentUser].mUserId,
                   @"target_user":  [Engine gCurrentUser].mUserId,
                   @"request_type": @"followings",
                   @"page":         [NSString stringWithFormat: @"%d", page]};
    
    [[HLCommunication sharedManager] sendToService: API_GETUSERS params: parameters success: successed failure: failure];
}

//================================================================================================================

#pragma mark -
#pragma mark - FollowTableViewCellDelegate


- (void)didTouchedFollow: (FollowingTableViewCell *)tableViewCell {
    
}


//================================================================================================================

#pragma mark Table View
#pragma mark - UITableView DataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [mArrFollowUsers count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    FollowingTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"FollowerCell" forIndexPath:indexPath];
    
    cell.delegate = self;
    
    UserInfo *userInfo = [mArrFollowUsers objectAtIndex: indexPath.row];
    
    [cell setUserInfo: userInfo];
    
    return cell;
    
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
}

#pragma mark Waiting Progress

- (void)showLoading {
    mProgress = [MBProgressHUD showHUDAddedTo:[UIApplication sharedApplication].keyWindow animated:YES];
    mProgress.mode = MBProgressHUDModeIndeterminate;
    mProgress.labelText = @"";
    [mProgress show:YES];
}

@end
