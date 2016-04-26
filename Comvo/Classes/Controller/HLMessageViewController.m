//
//  HLMessageViewController.m
//  Comvo
//
//  Created by Max Broeckel on 1/8/15.
//  Copyright (c) 2015 Max Broeckel. All rights reserved.
//

#import "HLMessageViewController.h"

#import <SVPullToRefresh.h>

#import "AppEngine.h"
#import "Constants_Comvo.h"
#import "HLCommunication.h"

#import "HLMessageTypeViewController.h"
#import "HLGroupTableViewCell.h"
#import "HLChatViewController.h"
#import "HLUserSearchViewController.h"

@interface HLMessageViewController () <UITableViewDataSource, UITableViewDelegate, HLGroupTableViewCellDelegate>

@end

@implementation HLMessageViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self initNavigation];
    
    mArrHistory = [[NSMutableArray alloc] init];
    
    __block HLMessageViewController *selfView = self;
    
    [mTView addPullToRefreshWithActionHandler: ^{
        [selfView insertRowAtTop];
    }];
    
    [mTView addInfiniteScrollingWithActionHandler: ^{
        [selfView insertRowAtBottom];
    }];
    
    [self loadHistory: mPage];
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
    
    self.title = @"Messaging";
    [self.navigationController.navigationBar
     setTitleTextAttributes:@{NSForegroundColorAttributeName : [UIColor whiteColor]}];
    
    UIButton *btnAdd = [UIButton buttonWithType: UIButtonTypeSystem];
    [btnAdd setFrame: CGRectMake(0, 0, 30, 30)];
    [btnAdd setTintColor: [UIColor whiteColor]];
    [btnAdd setImage: [UIImage imageNamed: @"message_img_add.png"] forState: UIControlStateNormal];
    [btnAdd addTarget: self action: @selector(onTouchBtnAdd :) forControlEvents: UIControlEventTouchUpInside];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView: btnAdd];
    // 19 - 22
    // 10 7 2 1    23
    // 10 6 3 1    21
    // 10 5 2 3    17
    // 10 4 3 3    15
    // 10 2 1 7     7
    // 10 1 1 8     4
    
}

//================================================================================================================

#pragma mark -
#pragma mark - SVPullToRefresh

- (void)insertRowAtTop {
    int64_t delayInSeconds = 2.0;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        mPage = 0;
        [self loadHistory: mPage];
        
        [mTView.pullToRefreshView stopAnimating];
    });
}


- (void)insertRowAtBottom {
    int64_t delayInSeconds = 2.0;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        
        [self loadHistory: mPage];
        
        [mTView.infiniteScrollingView stopAnimating];
    });
}


//==========================================================================================================================

#pragma mark -
#pragma mark - Touch Event

- (IBAction)onTouchBtnAdd: (id)sender {
//    HLMessageTypeViewController *messageTypeView = (HLMessageTypeViewController *)[self.storyboard instantiateViewControllerWithIdentifier: @"HLMessageTypeViewController"];
//    [self.navigationController pushViewController: messageTypeView animated: YES];
    
    HLUserSearchViewController *userSearchView = (HLUserSearchViewController *)[self.storyboard instantiateViewControllerWithIdentifier: @"HLUserSearchViewController"];
    [self.navigationController pushViewController: userSearchView animated: YES];
}

//=====================================================================================================

#pragma mark -
#pragma mark - Load

- (void)loadHistory: (int)page {
    NSDictionary *parameters = nil;
    
    void ( ^successed )( id responseObject ) = ^( id responseObject ) {
        NSLog(@"JSON: %@", responseObject);
        
        
        int result = [[responseObject objectForKey: @"success"] intValue];
        if (result) {
            
            if (mPage == 0) {
                [mArrHistory removeAllObjects];
            }
            
            NSDictionary *dicData = [responseObject objectForKey: @"data"];
            NSArray *arrGroups = [dicData objectForKey: @"groups"];
            
            for (NSDictionary *dicGroup in arrGroups) {
                GroupInfo *info = [[GroupInfo alloc] init];
                
                info.mGroupId   = [dicGroup objectForKey: @"group_id"];
                info.mGroupName = [dicGroup objectForKey: @"group_name"];
                
                NSArray *arrMembers = [dicGroup objectForKey: @"members"];
                NSMutableArray *arrUsers = [[NSMutableArray alloc] init];
                
                for (NSDictionary *dicMember  in arrMembers) {
                    UserInfo *userInfo = [[UserInfo alloc] init];
                    
                    userInfo.mUserId = [dicMember objectForKey: @"user_id"];
                    userInfo.mUserName = [dicMember objectForKey: @"username"];
                    userInfo.mFullName = [dicMember objectForKey: @"fullname"];
                    userInfo.mPhotoUrl = [dicMember objectForKey: @"profile_photo"];
                    
                    [arrUsers addObject: userInfo];
                }
                
                info.mArrMembers = arrUsers;
                
                [mArrHistory addObject: info];
            }
            
            if ([arrGroups count] > 0) {
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
    
    [[HLCommunication sharedManager] sendToService: API_GETCHATHISTORY
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
    static NSString *tableIdentifier = @"HLGroupTableViewCell";
    
    HLGroupTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier: tableIdentifier];
    
    if (cell == nil) {
        cell = [HLGroupTableViewCell sharedCell];
        cell.delegate = self;
    }
    
    GroupInfo *info = [mArrHistory objectAtIndex: indexPath.row];
    [cell setGroupInfo: info];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    GroupInfo *info = [mArrHistory objectAtIndex: indexPath.row];
    
    HLChatViewController *chatView = [HLChatViewController messagesViewController];
    chatView.mGroupInfo = info;
    [self.navigationController pushViewController: chatView animated: YES];
}


@end
