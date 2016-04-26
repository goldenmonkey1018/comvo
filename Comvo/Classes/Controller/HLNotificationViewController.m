//
//  HLNotificationViewController.m
//  Comvo
//
//  Created by DeMing Yu on 1/8/15.
//  Copyright (c) 2015 DeMing Yu. All rights reserved.
//

#import "HLNotificationViewController.h"

#import "AppEngine.h"
#import "Constants_Comvo.h"

#import "RDVTabBarController.h"
#import "RDVTabBarItem.h"
#import "HLHomeViewController.h"

#import <SVPullToRefresh.h>

#import "NotificationTableViewCell.h"
#import "HLProfileOtherViewController.h"
#import "HLDetailViewController.h"
#import "HLStreamViewController.h"

#import "HLCommunication.h"

#import <MBProgressHUD.h>

@interface HLNotificationViewController ()<UITableViewDataSource, UITableViewDelegate, NotificationTableViewCellDelegate>

@end

@implementation HLNotificationViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self initNavigation];
    
    mArrNotiInfo = [[NSMutableArray alloc] init];
    
    RDVTabBarItem *tabItem = [Engine gHomeViewController].tabBar.items[3];
    
    tabItem.badgeValue = @"";
    
    //tabItem.badgePositionAdjustment = UIOffsetMake(-20, 5);
    
    mPage = 0;
    [self getFeedWithMode:mPage];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

//==========================================================================================================================

#pragma mark -
#pragma mark - Initialize

- (void)initNavigation {
    [self.navigationController setNavigationBarHidden: NO];
    
    [[UINavigationBar appearance] setTintColor:[UIColor whiteColor]];
    self.navigationController.navigationBar.barTintColor = UIColorFromRGB(0x00AFF0);
    self.navigationController.navigationBar.translucent = NO;
    
    self.title = @"Notification";
    [self.navigationController.navigationBar
     setTitleTextAttributes:@{NSForegroundColorAttributeName : [UIColor whiteColor]}];
    
    UIImageView *imgView = [[UIImageView alloc] initWithImage: [[UIImage imageNamed: @"common_img_title.png"] imageWithRenderingMode: UIImageRenderingModeAlwaysOriginal]];
    self.navigationItem.titleView = imgView;
}

//================================================================================================================

#pragma mark -
#pragma mark - UITableView DataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [mArrNotiInfo count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NotificationTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"NotificationCell" forIndexPath:indexPath];
    
    cell.delegate = self;
    
    NotificationInfo *notiInfo = [mArrNotiInfo objectAtIndex: indexPath.row];
    
    [cell setNotificationInfo: notiInfo];
    
    return cell;

}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    NSLog(@"touched index");
    
    NotificationInfo *notiInfo = [mArrNotiInfo objectAtIndex: indexPath.row];
    
    //notiInfo.mPostId
    
    if ([notiInfo.mNotifType isEqualToString:@"4"]){ // Following
        
        HLProfileOtherViewController *profileOtherView = (HLProfileOtherViewController *)[self.storyboard instantiateViewControllerWithIdentifier: @"HLProfileOtherViewController"];
        //detailView.mPostInfo = tableViewCell.mPostInfo;
        
        //profileOtherView.mStrHashTag = hashTag;
        profileOtherView.mStrProfileID = notiInfo.mNotifUser;
        [self.navigationController pushViewController: profileOtherView animated: YES];
    }
    else {      // Commenting Liking Mentioning
        [self getCurrentPostInfo:notiInfo];
    }
    
}



//================================================================================================================

#pragma mark -
#pragma mark - SVPullToRefresh

- (void)insertRowAtTop {
    int64_t delayInSeconds = 2.0;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        mPage = 0;
        
        [self getFeedWithMode:mPage];
        
        [self.tblNotiFeeds.pullToRefreshView stopAnimating];
        
    });
}


- (void)insertRowAtBottom {
    int64_t delayInSeconds = 2.0;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        
        [self getFeedWithMode:mPage];
        
        [self.tblNotiFeeds.infiniteScrollingView stopAnimating];
    });
}


//================================================================================================================

#pragma mark -
#pragma mark - Get Current User Info

- (void)getCurrentPostInfo: (NotificationInfo *) notiInfo{

    NSDictionary *parameters = nil;
    
    //[self showLoading];
    
    void ( ^successed )( id responseObject ) = ^( id responseObject ) {
        NSLog(@"JSON: %@", responseObject);
        
        int result = [[responseObject objectForKey: @"success"] intValue];
        if (result) {
            NSDictionary *dicData = [responseObject objectForKey: @"data"];
            NSDictionary *dicPost = [dicData objectForKey: @"post"];
            
            PostInfo *postInfo = [[PostInfo alloc] init];
            
            postInfo.mPostId            = [dicPost objectForKey: @"post_id"];
            postInfo.mUserId            = [dicPost objectForKey: @"user_id"];
            postInfo.mDescription       = [dicPost objectForKey: @"description"];
            postInfo.mMedia             = [dicPost objectForKey: @"media"];
            postInfo.mMediaType         = [dicPost objectForKey: @"media_type"];
            postInfo.mHashTags          = [dicPost objectForKey: @"hashtags"];
            postInfo.mCategoryId        = [dicPost objectForKey: @"category_id"];
            postInfo.mCommentsCount     = [dicPost objectForKey: @"comments_count"];
            postInfo.mLikesCount        = [dicPost objectForKey: @"likes_count"];
            postInfo.mPostDate          = [dicPost objectForKey: @"post_date"];
            postInfo.mLiked             = [dicPost objectForKey: @"liked"];
            postInfo.mFullName          = [dicPost objectForKey: @"fullname"];
            postInfo.mUserName          = [dicPost objectForKey: @"username"];
            postInfo.mProfilePhoto      = [dicPost objectForKey: @"profile_photo"];
            postInfo.mDuration          = [dicPost objectForKey: @"duration"];
            postInfo.mLocation          = [dicPost objectForKey: @"location"];
            
            //HLDetailViewController *detailView = (HLDetailViewController *)[self.storyboard instantiateViewControllerWithIdentifier: @"HLDetailViewController"];
            
            //detailView.mPostInfo = postInfo;
            
            //[self.navigationController pushViewController: detailView animated: YES];
            
            HLStreamViewController *streamingView = (HLStreamViewController *)[self.storyboard instantiateViewControllerWithIdentifier: @"HLStreamViewController"];
            //detailView.mPostInfo = tableViewCell.mPostInfo;
            
            streamingView.mSpecializedPostID = postInfo.mPostId;
            [self.navigationController pushViewController: streamingView animated: YES];
       
        }
        else {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle: @"Warning" message: [responseObject valueForKey: @"message"] delegate: nil cancelButtonTitle: @"Ok" otherButtonTitles: nil];
            [alertView show];
            
            //[mProgress hide: YES];
            //[self.navigationController popViewControllerAnimated: YES];
        }
        
        //[mProgress hide: YES];
    };
    
    void ( ^failure )( NSError* error ) = ^( NSError* error ) {
        NSLog(@"Error: %@", error);
        
        //[mProgress hide: YES];
    };
    
    parameters = @{@"user_id":         [Engine gCurrentUser].mUserId,
                   @"post_id":         notiInfo.mPostId};
    
    
    [[HLCommunication sharedManager] sendToService: API_GETSINGLEPOST params: parameters success: successed failure: failure];
}

//================================================================================================================

#pragma mark -
#pragma mark - Get Feed

- (void)getFeedWithMode: (int)page {
    [self showLoading];
    NSDictionary *parameters = nil;
    
    void ( ^successed )( id responseObject ) = ^( id responseObject ) {
        NSLog(@"JSON: %@", responseObject);
        
        
        int result = [[responseObject objectForKey: @"success"] intValue];
        if (result) {
            
            NSDictionary *dicData = [responseObject objectForKey: @"data"];
            NSArray *arrPosts = [dicData objectForKey: @"notifications"];
            
            for (int i = 0; i < [arrPosts count]; i++) {
                NSDictionary *dicPost = [arrPosts objectAtIndex: i];
                
                NotificationInfo *notiInfo = [[NotificationInfo alloc] init];
                
                notiInfo.mNotifId            = [dicPost objectForKey: @"notif_id"];
                notiInfo.mUserId             = [dicPost objectForKey: @"user_id"];
                notiInfo.mPostId             = [dicPost objectForKey: @"post_id"];
                notiInfo.mNotifType          = [dicPost objectForKey: @"notif_type"];
                notiInfo.mNotifUser          = [dicPost objectForKey: @"notif_user"];
                notiInfo.mUserName           = [dicPost objectForKey: @"username"];
                notiInfo.mFullName           = [dicPost objectForKey: @"fullname"];
                notiInfo.mIsNew              = [dicPost objectForKey: @"is_new"];
                notiInfo.mTotalCount         = [dicPost objectForKey: @"total_count"];
                notiInfo.mProfilePhoto       = [dicPost objectForKey: @"profile_photo"];
                notiInfo.mPicInfo            = [dicPost objectForKey: @"pic_info"];
                notiInfo.mNotifDate          = [dicPost objectForKey: @"notif_date"];
                notiInfo.mMediaType          = [dicPost objectForKey: @"media_type"];
                notiInfo.mNewCount           = [dicPost objectForKey: @"new_count"];
                            
                [mArrNotiInfo addObject: notiInfo];
            }
            
            if ([arrPosts count] > 0) {
                mPage ++;
            }
            
            [self.tblNotiFeeds reloadData];
            [mProgress hide: YES];
            
        }
        else {
            [mProgress hide: YES];
        }
        
        
    };
    
    void ( ^failure )( NSError* error ) = ^( NSError* error ) {
        NSLog(@"Error: %@", error);
        [mProgress hide: YES];
        
    };
    
    parameters = @{@"user_id":      [Engine gCurrentUser].mUserId,
                   @"start":         [NSString stringWithFormat: @"%d", page],
                   @"page":         [NSString stringWithFormat: @"%d", page],
                   @"is_new":       @"1"};
    
    
    [[HLCommunication sharedManager] sendToService: API_GETNOTIFICATIONS_NEW params: parameters success: successed failure: failure];
}

- (void)showLoading {
    mProgress = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    mProgress.mode = MBProgressHUDModeIndeterminate;
    mProgress.labelText = @"Feeding...";
    [mProgress show:YES];
}

//================================================================================================================

#pragma mark -
#pragma mark - NotificationTableViewCellDelegate

- (void)didTouchedUserID: (NotificationTableViewCell *)tableViewCell userID: (NSString *)userID{
    
    HLProfileOtherViewController *profileOtherView = (HLProfileOtherViewController *)[self.storyboard instantiateViewControllerWithIdentifier: @"HLProfileOtherViewController"];
    //detailView.mPostInfo = tableViewCell.mPostInfo;
    
    //profileOtherView.mStrHashTag = hashTag;
    profileOtherView.mStrProfileID = userID;
    [self.navigationController pushViewController: profileOtherView animated: YES];
}

@end
