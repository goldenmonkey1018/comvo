//
//  HLUserSearchViewController.m
//  Comvo
//
//  Created by Max Broeckel on 2/4/15.
//  Copyright (c) 2015 Max Broeckel. All rights reserved.
//

#import "HLUserSearchViewController.h"

#import <SVPullToRefresh.h>
#import <MBProgressHUD.h>

#import "AppEngine.h"
#import "Constants_Comvo.h"

#import "HLUserTableViewCell.h"
#import "InviteFriendTableViewCell.h"
#import "HLHomeFeedTableViewCell.h"

#import "HLProfileViewController.h"
#import "HLProfileOtherViewController.h"
#import "HLCommentViewController.h"
#import "HLDetailViewController.h"
#import "HLStreamViewController.h"

#import "HLCommunication.h"

#import "HLChatViewController.h"
#import "HLHomeViewController.h"

#import <SDWebImage/SDWebImageManager.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import <FBSDKShareKit/FBSDKShareKit.h>


@interface HLUserSearchViewController () <UISearchBarDelegate, UITableViewDelegate, UITableViewDataSource, HLUserTableViewCellDelegate, InviteFriendTableViewCellDelegate, HLHomeFeedTableViewCellDelegate, UIDocumentInteractionControllerDelegate>

@end

@implementation HLUserSearchViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self initNavigation];
    
    __block HLUserSearchViewController *selfView = self;
    
    [mTView addPullToRefreshWithActionHandler: ^{
        [selfView insertRowAtTop];
    }];
    
    [mTView addInfiniteScrollingWithActionHandler: ^{
        [selfView insertRowAtBottom];
    }];
    
    self.view.translatesAutoresizingMaskIntoConstraints = YES;
    
    mArrUsers = [[NSMutableArray alloc] init];
    mArrPosts = [[NSMutableArray alloc] init];
    
    nSearchMode = 0;
    nSearchFeedMode = 0;
    
    mFeedMode = FEED_MODE_FOLLOWING;
    
    [mBtnOptionUsername setBackgroundColor: UIColorFromRGB(0xffffff)];
    [mBtnOptionHashtag setBackgroundColor:UIColorFromRGB(0x00aff0)];
    
    [mBtnOptionUsername setTitleColor:UIColorFromRGB(0x00aff0) forState:UIControlStateNormal];
    [mBtnOptionHashtag setTitleColor:UIColorFromRGB(0xffffff) forState:UIControlStateNormal];
    
    //[self getFeed: mPage];

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
    
    self.title = @"Search User";
    [self.navigationController.navigationBar
     setTitleTextAttributes:@{NSForegroundColorAttributeName : [UIColor whiteColor]}];
    
    //UIButton *btnBack = [UIButton buttonWithType: UIButtonTypeSystem];
    //[btnBack setFrame: CGRectMake(0, 0, 30, 30)];
    //[btnBack setTintColor: [UIColor whiteColor]];
    //[btnBack setImage: [UIImage imageNamed: @"common_img_back.png"] forState: UIControlStateNormal];
    //[btnBack addTarget: self action: @selector(onTouchBtnBack :) forControlEvents: UIControlEventTouchUpInside];
    
    //self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView: btnBack];
    
    /*UIButton *button =  [UIButton buttonWithType:UIButtonTypeCustom];
    [button setBackgroundImage:[UIImage imageNamed:@"common_img_bar.png"] forState:UIControlStateNormal];
    [button addTarget:self action:@selector(onTouchModeUsername:)forControlEvents:UIControlEventTouchUpInside];
    [button setFrame:CGRectMake(0, 0, 30, 31)];
    
    UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(5, 5, 20, 20)];
    [label setFont:[UIFont fontWithName:@"Arial-BoldMT" size:18]];
    [label setText:@"@"];
    label.textAlignment = UITextAlignmentCenter;
    [label setTextColor:[UIColor whiteColor]];
    [label setBackgroundColor:[UIColor clearColor]];
    [button addSubview:label];
    
    UIBarButtonItem *barButton = [[UIBarButtonItem alloc] initWithCustomView:button];
    //self.navigationItem.leftBarButtonItem = barButton;
    
    UIButton *button1 =  [UIButton buttonWithType:UIButtonTypeCustom];
    [button1 setBackgroundImage:[UIImage imageNamed:@"common_img_bar.png"] forState:UIControlStateNormal];
    [button1 addTarget:self action:@selector(onTouchHashtag:)forControlEvents:UIControlEventTouchUpInside];
    [button1 setFrame:CGRectMake(0, 0, 30, 31)];
    
    UILabel *label1 = [[UILabel alloc]initWithFrame:CGRectMake(5, 5, 20, 20)];
    [label1 setFont:[UIFont fontWithName:@"Arial-BoldMT" size:18]];
    [label1 setText:@"#"];
    label1.textAlignment = UITextAlignmentCenter;
    [label1 setTextColor:[UIColor whiteColor]];
    [label1 setBackgroundColor:[UIColor clearColor]];
    [button1 addSubview:label1];
    
    UIBarButtonItem *barButton1 = [[UIBarButtonItem alloc] initWithCustomView:button1];
    //self.navigationItem.rightBarButtonItem = barButton1;
    
    
    self.navigationItem.rightBarButtonItems = @[barButton1, barButton];*/
    //self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    
    
}

//==========================================================================================================================

#pragma mark -
#pragma mark - Touch Event

//- (IBAction)onTouchBtnBack: (id)sender {
//    [self.navigationController popViewControllerAnimated: YES];
//}

- (IBAction)onTouchModeUsername: (id)sender {
    NSLog(@"Touch mode username");
    
    mSearchBar.placeholder = @"Please input username";
    nSearchMode = 0;
    
    [mBtnOptionUsername setBackgroundColor: UIColorFromRGB(0xffffff)];
    [mBtnOptionHashtag setBackgroundColor:UIColorFromRGB(0x00aff0)];
    
    [mBtnOptionUsername setTitleColor:UIColorFromRGB(0x00aff0) forState:UIControlStateNormal];
    [mBtnOptionHashtag setTitleColor:UIColorFromRGB(0xffffff) forState:UIControlStateNormal];
}

- (IBAction)onTouchHashtag: (id)sender {
    NSLog(@"Touch mode hashtag");
    
    mSearchBar.placeholder = @"Please input hashtag";
    nSearchMode = 1;
    
    [mBtnOptionUsername setBackgroundColor: UIColorFromRGB(0x00aff0)];
    [mBtnOptionHashtag setBackgroundColor:UIColorFromRGB(0xffffff)];
    
    [mBtnOptionUsername setTitleColor:UIColorFromRGB(0xffffff) forState:UIControlStateNormal];
    [mBtnOptionHashtag setTitleColor:UIColorFromRGB(0x00aff0) forState:UIControlStateNormal];
}

//================================================================================================================

#pragma mark -
#pragma mark - SVPullToRefresh

- (void)insertRowAtTop {
    int64_t delayInSeconds = 2.0;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        mPage = 0;
        
        if (nSearchMode == 0)
        {
            nSearchFeedMode = 1;
            [self searchUser: mPage];
        }
        else if (nSearchMode == 1)
        {
            nSearchFeedMode = 2;
            [self getFeedPost: mPage];
        }
        
        [mTView.pullToRefreshView stopAnimating];
    });
}


- (void)insertRowAtBottom {
    int64_t delayInSeconds = 2.0;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        
        if (nSearchMode == 0)
        {
            nSearchFeedMode = 1;
            [self searchUser: mPage];
        }
        else if (nSearchMode == 1)
        {
            nSearchFeedMode = 2;
            [self getFeedPost: mPage];
        }
        
        [mTView.infiniteScrollingView stopAnimating];
    });
}

//================================================================================================================

#pragma mark -
#pragma mark - Searh User

- (void)searchUser: (int)page {
    NSDictionary *parameters = nil;
    
    void ( ^successed )( id responseObject ) = ^( id responseObject ) {
        NSLog(@"JSON: %@", responseObject);
        
        int result = [[responseObject objectForKey: @"success"] intValue];
        if (result) {
            if (mPage == 0) {
                [mArrUsers removeAllObjects];
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
                
                [mArrUsers addObject: userInfo];
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
    
    if ([mSearchBar.text isEqualToString:@""])
        return;
    
    if (nSearchMode == 0)
        parameters = @{@"user_id":      [Engine gCurrentUser].mUserId,
                       @"keyword":      mSearchBar.text,
                       @"page":         [NSString stringWithFormat: @"%d", page],
                       @"request_type": @"keyword_search"};
    else
        parameters = @{@"user_id":      [Engine gCurrentUser].mUserId,
                       @"keyword":      mSearchBar.text,
                       @"page":         [NSString stringWithFormat: @"%d", page],
                       @"request_type": @"hashtags"};
    
    [[HLCommunication sharedManager] sendToService: API_GETUSERS
                                            params: parameters
                                           success: successed
                                           failure: failure];
}


- (void)createChat: (UserInfo *)userInfo {
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.mode = MBProgressHUDModeIndeterminate;
    hud.labelText = @"Creating...";
    
    NSDictionary *parameters = nil;
    
    void ( ^successed )( id responseObject ) = ^( id responseObject ) {
        NSLog(@"JSON: %@", responseObject);
        
        
        int result = [[responseObject objectForKey: @"success"] intValue];
        if (result) {
            
            NSDictionary *dicData = [responseObject objectForKey: @"data"];
            NSDictionary *dicGroup = [dicData objectForKey: @"group"];
            
            GroupInfo *gInfo = [[GroupInfo alloc] init];
            
            gInfo.mGroupId = [dicGroup objectForKey: @"group_id"];
            gInfo.mGroupName = @"";
            gInfo.mArrMembers = [[NSMutableArray alloc] initWithObjects: userInfo, nil];
            
            HLChatViewController *chatView = [HLChatViewController messagesViewController];
            chatView.mGroupInfo = gInfo;
            [self.navigationController pushViewController: chatView animated: YES];
        }
        else {
            
        }
        
        [hud hide: YES];
        
    };
    
    void ( ^failure )( NSError* error ) = ^( NSError* error ) {
        NSLog(@"Error: %@", error);
        
        [hud hide: YES];
    };
    
    parameters = @{@"user_id":      [Engine gCurrentUser].mUserId,
                   @"group_name":   @"",
                   @"member_list":  userInfo.mUserId};
    
    [[HLCommunication sharedManager] sendToService: API_CREATEGROUP
                                            params: parameters
                                           success: successed
                                           failure: failure];
}


//================================================================================================================

#pragma mark -
#pragma mark - Get Feed

- (void)getFeedPost: (int)page {
    NSDictionary *parameters = nil;
    
    [self showLoading];
    
    void ( ^successed )( id responseObject ) = ^( id responseObject ) {
        NSLog(@"JSON: %@", responseObject);
        
        int result = [[responseObject objectForKey: @"success"] intValue];
        if (result) {
            
            if (mPage == 0) {
                [mArrPosts removeAllObjects];
            }
            
            NSDictionary *dicData = [responseObject objectForKey: @"data"];
            NSArray *arrPosts = [dicData objectForKey: @"posts"];
            
            for (int i = 0; i < [arrPosts count]; i++) {
                NSDictionary *dicPost = [arrPosts objectAtIndex: i];
                
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
                
                NSMutableArray *arrComments = [[NSMutableArray alloc] init];
                
                NSArray *comments = [dicPost objectForKey: @"commentlist"];
                for (NSDictionary *dicComment in comments) {
                    CommentInfo *cInfo = [[CommentInfo alloc] init];
                    
                    cInfo.mCommentId    = [dicComment objectForKey: @"comment_id"];
                    cInfo.mUserId       = [dicComment objectForKey: @"user_id"];
                    cInfo.mPostId       = [dicComment objectForKey: @"post_id"];
                    cInfo.mComment      = [dicComment objectForKey: @"comment"];
                    cInfo.mCommentDate  = [dicComment objectForKey: @"comment_date"];
                    cInfo.mFullName     = [dicComment objectForKey: @"fullname"];
                    cInfo.mUserName     = [dicComment objectForKey: @"username"];
                    cInfo.mProfilePhoto = [dicComment objectForKey: @"profile_photo"];
                    cInfo.mCommentType  = [dicComment objectForKey: @"comment_type"];
                    cInfo.mDuration     = [dicComment objectForKey: @"duration"];
                    
                    [arrComments addObject: cInfo];
                }
                
                postInfo.mArrComments = arrComments;
                
                [mArrPosts addObject: postInfo];
            }
            
            if ([arrPosts count] > 0) {
                mPage ++;
            }
            [mProgress hide:YES];
            
            [mTView reloadData];
            
        }
        else {
            [mProgress hide:YES];
        }
        
        
    };
    
    void ( ^failure )( NSError* error ) = ^( NSError* error ) {
        NSLog(@"Error: %@", error);
        
        [mProgress hide:YES];
    };
    
    NSString *feedType = @"following";
    
    switch (mFeedMode) {
        case FEED_MODE_FOLLOWING:
            feedType = @"following";
            break;
        case FEED_MODE_POPULAR:
            feedType = @"popular";
            break;
            
        case FEED_MODE_TRENDING:
            feedType = @"trending";
            break;
        default:
            break;
    }
    
    
    feedType = @"hashtag";
    self.mStrHashTag = mSearchBar.text;
    
    parameters = @{@"user_id":      [Engine gCurrentUser].mUserId,
                   @"feed_type":    feedType,
                   @"hashtag":      self.mStrHashTag,
                   @"page":         [NSString stringWithFormat: @"%d", page]};
    
    [[HLCommunication sharedManager] sendToService: API_GETFEED params: parameters success: successed failure: failure];
}

//==========================================================================================================================

#pragma mark -
#pragma mark - UISearchBarDelegate

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    [searchBar resignFirstResponder];
    
    mPage = 0;
    [mArrUsers removeAllObjects];
    [mArrPosts removeAllObjects];
    [mTView reloadData];
    
    if (nSearchMode == 0)
    {
        nSearchFeedMode = 1;
        [self searchUser: mPage];
    }
    else if (nSearchMode == 1)
    {
        nSearchFeedMode = 2;
        [self getFeedPost: mPage];
    }
}

//==========================================================================================================================
#pragma mark -
#pragma mark - InviteFriendTableViewCellDelegate

- (IBAction)onTouchButtonFollow:(id)sender{
    NSLog(@"User Search View");
}


//================================================================================================================

#pragma mark -
#pragma mark - UITableView DataSource

- (void)didTouchedFollowButton:(InviteFriendTableViewCell *)tableViewCell {
    NSLog(@"This is User Search View Controller - Follow Button");
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    long nReturnCnt = 0;
    
    if (nSearchMode == 0)
        nReturnCnt = [mArrUsers count];
    else if (nSearchMode == 1)
        nReturnCnt = [mArrPosts count];
    
    return  nReturnCnt;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    float lReturnHeight = 0;
    
    if (nSearchMode == 0)
        lReturnHeight = 70.0;
    else if (nSearchMode == 1)
    {
        PostInfo *postInfo = [mArrPosts objectAtIndex: indexPath.row];
        
        lReturnHeight = 40.0f;
        
        if (IS_IPHONE6) {
            //height += 467;
            lReturnHeight += ([postInfo.mMediaType isEqualToString: @"1"]) ? 269 : 497;
        }
        else {
            lReturnHeight += ([postInfo.mMediaType isEqualToString: @"1"]) ? 219 : 427;
        }
        
        if (![postInfo.mDescription isEqualToString: @""]) {
            lReturnHeight += [HLHomeFeedTableViewCell messageSize: postInfo.mDescription].height;
        }
        
        lReturnHeight += [postInfo.mArrComments count] * 60.0f + 3.0f;
        
        long nCommentViewCnt = postInfo.mCommentsCount.integerValue;
        if (nCommentViewCnt > [postInfo.mArrComments count])
            lReturnHeight += 50.0f;
        
        lReturnHeight = lReturnHeight;
    }
    
    return lReturnHeight;
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
    
    if (nSearchMode == 0)
    {
        InviteFriendTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"InviteFriendCell" forIndexPath:indexPath];
        
        UserInfo *userInfo = [mArrUsers objectAtIndex: indexPath.row];
        
        cell.delegate = self;
        [cell setUsersInfo: userInfo];
        
        res = cell;
    }
    else if (nSearchMode == 1)
    {
        static NSString *tableIdentifier = @"HLHomeFeedTableViewCell";
        
        HLHomeFeedTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier: tableIdentifier];
        
        if (cell == nil) {
            cell = [HLHomeFeedTableViewCell sharedCell];
            cell.delegate = self;
        }
        
        PostInfo *postInfo = [mArrPosts objectAtIndex: indexPath.row];
        [cell setPostInfo: postInfo];
        
        res = cell;
    }
    
    //}
    
    return res;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    //UserInfo *info = [mArrUsers objectAtIndex: indexPath.row];
    
    //[self createChat: info];
    if (nSearchFeedMode == 1)
    {
        NSLog(@"nSearchFeedMode == 1");
        UserInfo *userInfo = [mArrUsers objectAtIndex: indexPath.row];
        if ([userInfo.mUserId isEqualToString:[Engine gCurrentUser].mUserId])
        {
            HLHomeViewController *homeVC = [[AppEngine getInstance] gHomeViewController];
            homeVC.selectedIndex = 4;
        }
        else
        {
            HLProfileOtherViewController *profileOtherView = (HLProfileOtherViewController *)[self.storyboard instantiateViewControllerWithIdentifier: @"HLProfileOtherViewController"];
            //detailView.mPostInfo = tableViewCell.mPostInfo;
            
            //profileOtherView.mStrHashTag = hashTag;
            profileOtherView.mStrProfileID = userInfo.mUserId;
            [self.navigationController pushViewController: profileOtherView animated: YES];
        }
    }
}

//================================================================================================================

#pragma mark -
#pragma mark - HLHomeFeedTableViewCellDelegate

- (void)didTouchedLike: (HLHomeFeedTableViewCell *)tableViewCell {
    
}

- (void)didTouchedComment: (HLHomeFeedTableViewCell *)tableViewCell {
    HLCommentViewController *commentView = (HLCommentViewController *)[self.storyboard instantiateViewControllerWithIdentifier: @"HLCommentViewController"];
    commentView.mPostInfo = tableViewCell.mPostInfo;
    [self.navigationController pushViewController: commentView animated: YES];
}

- (void)didTouchedThumbnail:(HLHomeFeedTableViewCell *)tableViewCell {
    HLDetailViewController *detailView = (HLDetailViewController *)[self.storyboard instantiateViewControllerWithIdentifier: @"HLDetailViewController"];
    detailView.mPostInfo = tableViewCell.mPostInfo;
    [self.navigationController pushViewController: detailView animated: YES];
}

- (void)didTouchedDeleteButton : (HLHomeFeedTableViewCell *)tableViewCell{
    NSLog(@"This is Delete Button.");
    
    mPage = 0;
    [self getFeedPost: mPage];
}

- (void)didTouchedDownload:(HLHomeFeedTableViewCell *)tableViewCell
{
    NSLog(@"This is Download Button");
    
    NSIndexPath *indexPath = [mTView indexPathForCell:tableViewCell];
    
    PostInfo *postInfo = [mArrPosts objectAtIndex: indexPath.row];
    
    if ([postInfo.mMediaType isEqualToString: @"1"]) { // Audio
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Information"
                                                        message:@"By technical issue, audio file can't download on your music gallery."
                                                       delegate:self
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
        /* NSURL *url = [NSURL URLWithString: [NSString stringWithFormat: @"%@%@", FILE_HOME, postInfo.mMedia]];\
         
         dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
         NSData *data = [NSData dataWithContentsOfURL:url];
         
         //Find a cache directory. You could consider using documenets dir instead (depends on the data you are fetching)
         NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
         NSString *path = [paths  objectAtIndex:0];
         
         //Save the data
         NSString *dataPath = [path stringByAppendingPathComponent:@"filename"];
         dataPath = [dataPath stringByStandardizingPath];
         NSLog(dataPath);
         
         BOOL success = [data writeToFile:dataPath atomically:YES];
         }); */
        
        // http://stackoverflow.com/questions/13147044/programmatically-add-content-to-music-library
        // Content - It is only possible if the app is for jailbroken devices.
        // In this case, you can use my libipodimport library for importing music and audio files to the iPod media library.
        
        
        //Download data
        
    }
    else if ([postInfo.mMediaType isEqualToString: @"2"]) { // Photo
        
        NSURL *url = [NSURL URLWithString: [NSString stringWithFormat: @"%@%@", API_HOME, postInfo.mMedia]];
        
        [[SDWebImageManager sharedManager] downloadImageWithURL:url options:0 progress:^(NSInteger receivedSize, NSInteger expectedSize) {
            
        } completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished, NSURL *imageURL) {
            
            if (image != nil) {
                ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
                [library writeImageToSavedPhotosAlbum:image.CGImage orientation:(ALAssetOrientation)image.imageOrientation completionBlock:^(NSURL *assetURL, NSError *error )
                 {
                     NSLog(@"IMAGE SAVED TO PHOTO ALBUM");
                     
                     [library assetForURL:assetURL resultBlock:^(ALAsset *asset )
                      {
                          NSLog(@"we have our ALAsset!");
                          
                          UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Success Download"
                                                                          message:@"Image saved to photo album."
                                                                         delegate:self
                                                                cancelButtonTitle:@"OK"
                                                                otherButtonTitles:nil];
                          [alert show];
                      }
                             failureBlock:^(NSError *error )
                      {
                          NSLog(@"Error loading asset");
                          
                          UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Failed Download"
                                                                          message:@"Image Download failed."
                                                                         delegate:self
                                                                cancelButtonTitle:@"OK"
                                                                otherButtonTitles:nil];
                          
                      }];
                 }];
            }
        }];
    }
    else if ([postInfo.mMediaType isEqualToString: @"3"]) { // Video
        NSURL *url = [NSURL URLWithString: [NSString stringWithFormat: @"%@%@", API_HOME, postInfo.mMedia]];
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
            NSData *data = [NSData dataWithContentsOfURL:url];
            
            //Find a cache directory. You could consider using documenets dir instead (depends on the data you are fetching)
            NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
            NSString *path = [paths  objectAtIndex:0];
            
            //Save the data
            NSString *dataPath = [path stringByAppendingPathComponent:@"filename.mp4"];
            dataPath = [dataPath stringByStandardizingPath];
            NSLog(dataPath);
            
            BOOL success = [data writeToFile:dataPath atomically:YES];
            
            NSURL *movieURL = [NSURL fileURLWithPath:dataPath];
            
            ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
            [library writeVideoAtPathToSavedPhotosAlbum:movieURL
                                        completionBlock:^(NSURL *assetURL, NSError *error)
             {
                 if (error)
                 {
                     UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Failed Download"
                                                                     message:@"Video Download failed."
                                                                    delegate:self
                                                           cancelButtonTitle:@"OK"
                                                           otherButtonTitles:nil];
                     [alert show];
                 }
                 else
                 {
                     UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Success Download"
                                                                     message:@"Video Download Successed."
                                                                    delegate:self
                                                           cancelButtonTitle:@"OK"
                                                           otherButtonTitles:nil];
                     [alert show];
                     
                 }
                 
             }];
        });
        
        
    }
    
}

- (void)didTouchedReport: (HLHomeFeedTableViewCell *)tableViewCell {
    NSLog(@"This is Report Button");
    
    /*  Facebook Integration
     if ([tableViewCell.mPostInfo.mMediaType isEqualToString: @"1"]) // audio
     {
     
     }
     else if ([tableViewCell.mPostInfo.mMediaType isEqualToString: @"2"]) // photo
     {
     //        UIImage *image = tableViewCell.mImgViewPhoto.image;
     
     //        FBSDKSharePhoto *photo = [[FBSDKSharePhoto alloc] init];
     //        photo.image = image;
     //        photo.userGenerated = YES;
     //        FBSDKSharePhotoContent *content = [[FBSDKSharePhotoContent alloc] init];
     //        content.photos = @[photo];
     
     NSLog(@"%@", [NSString stringWithFormat: @"%@%@", FILE_HOME, tableViewCell.mPostInfo.mMedia]);
     FBSDKShareLinkContent *content = [[FBSDKShareLinkContent alloc] init];
     content.imageURL = [NSURL URLWithString:[NSString stringWithFormat: @"%@%@", FILE_HOME, tableViewCell.mPostInfo.mMedia]];
     
     [FBSDKShareDialog showFromViewController:self
     withContent:content
     delegate:nil];
     }
     else if ([tableViewCell.mPostInfo.mMediaType isEqualToString: @"3"]) // video
     {
     //NSURL *videoURL = [info objectForKey:UIImagePickerControllerReferenceURL];
     
     //NSURL *videoURL = tableViewCell.mPostInfo.mMedia;
     //NSURL *videoURL = [[NSURL URLWithString: [NSString stringWithFormat: @"%@%@", FILE_HOME, tableViewCell.mPostInfo.mMedia]] options:nil];
     
     //NSLog(tableViewCell.mPostInfo.mMedia);
     
     // NSURL *videoURL = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@", FILE_HOME, tableViewCell.mPostInfo.mMedia]];
     
     //FBSDKShareVideo *video = [[FBSDKShareVideo alloc] init];
     //video.videoURL = videoURL;
     ///FBSDKShareVideoContent *content = [[FBSDKShareVideoContent alloc] init];
     //content.video = video;
     
     //[FBSDKShareDialog showFromViewController:self
     withContent:content
     delegate:nil];
     
     NSLog(@"%@", [NSString stringWithFormat: @"%@%@", FILE_HOME, tableViewCell.mPostInfo.mMedia]);
     FBSDKShareLinkContent *content = [[FBSDKShareLinkContent alloc] init];
     content.imageURL = [NSURL URLWithString:[NSString stringWithFormat: @"%@%@", FILE_HOME, tableViewCell.mPostInfo.mMedia]];
     
     [FBSDKShareDialog showFromViewController:self
     withContent:content
     delegate:nil];
     } */
    
    
    // Instagram Integration
    
    
    
    UIActivityViewController *activityController = [[UIActivityViewController alloc] initWithActivityItems:@[[NSURL URLWithString:[NSString stringWithFormat: @"%@%@", API_HOME, tableViewCell.mPostInfo.mMedia]], @"sharing"] applicationActivities:nil];
    
    activityController.excludedActivityTypes = @[];
    [self presentViewController:activityController animated:YES completion:nil];
}

- (void)didTouchedHashTag: (HLHomeFeedTableViewCell *)tableViewCell hashTag: (NSString *)hashTag {
    NSLog(@"Hash tag primo touched");
    
    HLStreamViewController *streamingView = (HLStreamViewController *)[self.storyboard instantiateViewControllerWithIdentifier: @"HLStreamViewController"];
    //detailView.mPostInfo = tableViewCell.mPostInfo;
    
    streamingView.mStrHashTag = hashTag;
    [self.navigationController pushViewController: streamingView animated: YES];
    
}

- (void)didTouchedUserName: (HLHomeFeedTableViewCell *)tableViewCell userName: (NSString *)userName {
    NSLog(@"Username tag primo touched");
    NSLog(@"%@", userName);
    
    if ([[Engine gCurrentUser].mUserName isEqualToString:userName])
    {
        //HLProfileViewController *profileView = (HLProfileViewController *)[self.storyboard instantiateViewControllerWithIdentifier: @"HLProfileViewController"];
        //detailView.mPostInfo = tableViewCell.mPostInfo;
        
        //profileOtherView.mStrHashTag = hashTag;
        //profileOtherView.mStrProfileID = userID;
        //[self.navigationController pushViewController: profileView animated: YES];
        
        HLHomeViewController *homeVC = [[AppEngine getInstance] gHomeViewController];
        homeVC.selectedIndex = 4;
    }
    else
    {
        HLProfileOtherViewController *profileOtherView = (HLProfileOtherViewController *)[self.storyboard instantiateViewControllerWithIdentifier: @"HLProfileOtherViewController"];
        //detailView.mPostInfo = tableViewCell.mPostInfo;
        
        //profileOtherView.mStrHashTag = hashTag;
        profileOtherView.mStrProfileTag = userName;
        
        [self.navigationController pushViewController: profileOtherView animated: YES];
    }
    
}

- (void)didTouchedUserName: (HLHomeFeedTableViewCell *)tableViewCell userID: (NSString *)userID {
    NSLog(@"Username tag primo touched");
    NSLog(@"%@", userID);
    
    if ([[Engine gCurrentUser].mUserId isEqualToString:userID])
    {
        //HLProfileViewController *profileView = (HLProfileViewController *)[self.storyboard instantiateViewControllerWithIdentifier: @"HLProfileViewController"];
        //detailView.mPostInfo = tableViewCell.mPostInfo;
        
        //profileOtherView.mStrHashTag = hashTag;
        //profileOtherView.mStrProfileID = userID;
        //[self.navigationController pushViewController: profileView animated: YES];
        
        HLHomeViewController *homeVC = [[AppEngine getInstance] gHomeViewController];
        homeVC.selectedIndex = 4;
    }
    else
    {
        HLProfileOtherViewController *profileOtherView = (HLProfileOtherViewController *)[self.storyboard instantiateViewControllerWithIdentifier: @"HLProfileOtherViewController"];
        //detailView.mPostInfo = tableViewCell.mPostInfo;
        
        //profileOtherView.mStrHashTag = hashTag;
        profileOtherView.mStrProfileID = userID;
        [self.navigationController pushViewController: profileOtherView animated: YES];
    }
    
}

//================================================================================================================

#pragma mark -
#pragma mark - Progress Bar Showing

- (void)showLoading {
    //mProgress = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    mProgress = [MBProgressHUD showHUDAddedTo:[UIApplication sharedApplication].keyWindow animated:YES];
    mProgress.mode = MBProgressHUDModeIndeterminate;
    mProgress.labelText = @"Feeding...";
    [mProgress show:YES];
    
}

@end
