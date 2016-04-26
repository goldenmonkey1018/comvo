//
//  InviteFriendsViewController.m
//  Comvo
//
//  Created by Max Broeckel on 30/09/15.
//  Copyright (c) 2015 Max Broeckel. All rights reserved.
//

#import "InviteFriendsViewController.h"

#import "AppEngine.h"
#import "FollowingTableViewCell.h"

@interface InviteFriendsViewController ()<UITableViewDataSource, UITableViewDelegate>

@end

@implementation InviteFriendsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//================================================================================================================

#pragma mark -
#pragma mark - Touch Event

- (IBAction)onTouchBtnBack: (id)sender {
    [self.navigationController popViewControllerAnimated: YES];
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if ([segue.identifier isEqualToString:@"GoInvite"]) {
        [Engine setGSearchMode:@"InviteFriend"];
    }
}

//================================================================================================================

#pragma mark Table View
#pragma mark - UITableView DataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 10;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    FollowingTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"FollowingCell" forIndexPath:indexPath];
    
    //cell.delegate = self;
    
    //UserInfo *userInfo = [mArrUsers objectAtIndex: indexPath.row];
    
    //[cell setUserInfo: userInfo];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
    
}


@end
