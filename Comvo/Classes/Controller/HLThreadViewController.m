//
//  HLThreadViewController.m
//  Comvo
//
//  Created by Max Brian on 04/11/15.
//  Copyright (c) 2015 DeMing Yu. All rights reserved.
//

#import "HLThreadViewController.h"

#import "MessageGroupTableViewCell.h"

#import <SVPullToRefresh.h>
#import <MBProgressHUD.h>

#import "HLCommunication.h"

@interface HLThreadViewController () <UITableViewDelegate, UITableViewDataSource, MessageGroupTableViewCellDelegate>

@end

@implementation HLThreadViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    mArrHistory = [[NSMutableArray alloc] init];
    
    __block HLThreadViewController *selfView = self;
    
    [mTView addPullToRefreshWithActionHandler: ^{
        [selfView insertRowAtTop];
    }];
    
    [mTView addInfiniteScrollingWithActionHandler: ^{
        [selfView insertRowAtBottom];
    }];
    
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


//================================================================================================================

#pragma mark -
#pragma mark - Touch Event

- (IBAction)onTouchBtnAdd: (id)sender{
    
}

//================================================================================================================

#pragma mark -
#pragma mark - SVPullToRefresh

- (void)insertRowAtTop {
    int64_t delayInSeconds = 2.0;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        mPage = 0;
        [self getFeedGroup: mPage];
        
        [mTView.pullToRefreshView stopAnimating];
    });
}



- (void)insertRowAtBottom {
    int64_t delayInSeconds = 2.0;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        
        [self getFeedGroup: mPage];
        
        [mTView.infiniteScrollingView stopAnimating];
    });
}

//================================================================================================================

#pragma mark -
#pragma mark - Searh User

- (void)getFeedGroup: (int)page {
    NSDictionary *parameters = nil;
    
    void ( ^successed )( id responseObject ) = ^( id responseObject ) {
        NSLog(@"JSON: %@", responseObject);
        
        int result = [[responseObject objectForKey: @"success"] intValue];
        if (result) {
            if (mPage == 0) {
                [mArrHistory removeAllObjects];
            }
            
            NSDictionary *dicData = [responseObject objectForKey: @"data"];
            NSArray *arrUsers = [dicData objectForKey: @"user"];
            
            for (int i = 0; i < [arrUsers count]; i++) {
                NSDictionary *dicUser = [arrUsers objectAtIndex: i];
                
                UserInfo *userInfo = [[UserInfo alloc] init];
                
                userInfo.mUserId            = [dicUser objectForKey: @"user_id"];
                userInfo.mEmail             = [dicUser objectForKey: @"email"];
                userInfo.mUserName          = [dicUser objectForKey: @"username"];
                userInfo.mEmail             = [dicUser objectForKey: @"email"];
                userInfo.mSessToken         = [dicUser objectForKey: @"sess_token"];
                userInfo.mPhotoUrl          = [dicUser objectForKey: @"profile_photo"];
                userInfo.mPassword          = [dicUser objectForKey: @"password"];
                userInfo.mFullName          = [dicUser objectForKey: @"fullname"];
                userInfo.mFollowersCount    = [dicUser objectForKey: @"followers_count"];
                userInfo.mFollowingsCount   = [dicUser objectForKey: @"followings_count"];
                userInfo.mStatus            = [dicUser objectForKey: @"status"];
                userInfo.mLastLogin         = [dicUser objectForKey: @"last_login"];
                userInfo.mRegisterDate      = [dicUser objectForKey: @"register_date"];
                userInfo.mIsFollowing       = [dicUser objectForKey: @"is_following"];
                userInfo.mGreetingAudioUrl  = [dicUser objectForKey: @"greeting_audio"];
                userInfo.mPhotosCount       = [dicUser objectForKey: @"picture_count"];
                userInfo.mAudioCount        = [dicUser objectForKey: @"audio_count"];
                userInfo.mVideoCount        = [dicUser objectForKey: @"video_count"];
                
                [mArrHistory addObject: userInfo];
            }
            
            if ([arrUsers count] > 0) {
                mPage ++;
            }
            
            [mTView reloadData];
            
        }
        else {
            
        }
        
        
    };
    
    void ( ^failure )( NSError* error ) = ^( NSError* error ) {
        NSLog(@"Error: %@", error);
        
        
    };
    
   parameters = @{@"user_id":      [Engine gCurrentUser].mUserId,
                  @"page":         [NSString stringWithFormat: @"%d", page]};
    
    
    [[HLCommunication sharedManager] sendToService: API_GETUSERS
                                            params: parameters
                                           success: successed
                                           failure: failure];
}


//================================================================================================================

#pragma mark -
#pragma mark - UITableView DataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [mArrHistory count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 70;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    //static NSString *tableIdentifier = @"HLUserTableViewCell";
    
    UITableViewCell *res = nil;
    
    //NSString *strSearchMode = [Engine gSearchMode];
    
    /* if ([strSearchMode isEqualToString:@"SearchFriend"]){
     HLUserTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier: tableIdentifier];
     
     if (cell == nil) {
     cell = [HLUserTableViewCell sharedCell];
     cell.delegate = self;
     }
     
     UserInfo *info = [mArrUsers objectAtIndex: indexPath.row];
     [cell setUserInfo: info];
     
     return cell;
     } */
    
    //if ([strSearchMode isEqualToString:@"InviteFriend"]){
    MessageGroupTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"InviteFriendCell" forIndexPath:indexPath];
    
    UserInfo *userInfo = [mArrHistory objectAtIndex: indexPath.row];
    
    cell.delegate = self;
    [cell setUsersInfo: userInfo];
    
    res = cell;
    //}
    
    return res;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    //UserInfo *info = [mArrUsers objectAtIndex: indexPath.row];
    
    //[self createChat: info];
}


@end
