//
//  HLStreamViewController.m
//  Comvo
//
//  Created by DeMing Yu on 1/7/15.
//  Copyright (c) 2015 DeMing Yu. All rights reserved.
//

#import "HLStreamViewController.h"

#import <SVPullToRefresh.h>
#import <MBProgressHUD.h>

#import "AppDelegate.h"
#import "AppEngine.h"
#import "Constants_Comvo.h"
#import "HLCommunication.h"

#import "HLHomeFeedTableViewCell.h"
#import "HLCommentViewController.h"
#import "HLDetailViewController.h"
#import "HLLoginViewController.h"
#import "HLProfileOtherViewController.h"
#import "HLProfileViewController.h"

#import "HLHomeViewController.h"
#import "AppDelegate.h"

#import <SDWebImage/SDWebImageManager.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import <FBSDKShareKit/FBSDKShareKit.h>


@interface HLStreamViewController () <HLHomeFeedTableViewCellDelegate, UIDocumentInteractionControllerDelegate>

@end

@implementation HLStreamViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self initNavigation];
    
    __block HLStreamViewController *streamView = self;
    
    [mTView addPullToRefreshWithActionHandler: ^{
        [streamView insertRowAtTop];
    }];
    
    [mTView addInfiniteScrollingWithActionHandler: ^{
        [streamView insertRowAtBottom];
    }];
    
    self.view.translatesAutoresizingMaskIntoConstraints = YES;
    
    mArrPosts = [[NSMutableArray alloc] init];
    
    //mProgress = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    //mProgress.mode = MBProgressHUDModeIndeterminate;
    //[mProgress hide: NO];
    
    if ([self.mStrHashTag isEqualToString:@""] || self.mStrHashTag == nil)
    {
        NSLog(@"Hash tag is empty");
    }
    else if ([self.mSpecializedPostID isEqualToString:@""] || self.mSpecializedPostID == nil)
    {
        NSLog(@"Specialized Post ID is empty");
    }
    else
    {
        NSLog(@"Hash tag is un-empty");
    }
    
    mFeedMode = FEED_MODE_FOLLOWING;
    
    mPage = 0;
    [self getFeed: mPage];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear: animated];
    
    [self.tabBarController.tabBar setHidden: NO];
    
    NSString *strFlgCommentModified = [Engine gFlgCommentModified];
    
    if ([strFlgCommentModified isEqualToString:@"YES"])
    {
        [Engine setGFlgCommentModified:@"NO"];
        mPage = 0;
        [self getFeed: mPage];
    }
}

- (void)viewDidDisappear:(BOOL)animated{
    NSLog(@"view Did Disappear");
}

- (void)viewDidAppear:(BOOL)animated{
    NSLog(@"view Did Appear");
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
    
//    [[UINavigationBar appearance] setTintColor:[UIColor whiteColor]];
//    self.navigationController.navigationBar.barTintColor = UIColorFromRGB(0x00AFF0);
    [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed: @"common_img_bar.png"]
                                                  forBarMetrics:UIBarMetricsDefault];
    self.navigationController.navigationBar.shadowImage = [UIImage new];
    self.navigationController.navigationBar.translucent = NO;
    
    self.title = @"Stream";
    [self.navigationController.navigationBar
     setTitleTextAttributes:@{NSForegroundColorAttributeName : [UIColor whiteColor]}];
    
    UIImageView *imgView = [[UIImageView alloc] initWithImage: [[UIImage imageNamed: @"common_img_title.png"] imageWithRenderingMode: UIImageRenderingModeAlwaysOriginal]];
    
    self.navigationItem.titleView = imgView;
    
    if (([self.mStrHashTag isEqualToString:@""] || self.mStrHashTag == nil)
        && ([self.mSpecializedPostID isEqualToString:@""] || self.mSpecializedPostID == nil))
    {
        //UIButton *button =  [UIButton buttonWithType:UIButtonTypeCustom];
        //[button setBackgroundImage:[UIImage imageNamed:@"common_img_bar.png"] forState:UIControlStateNormal];
        //[button addTarget:self action:@selector(onTouchSignOut:)forControlEvents:UIControlEventTouchUpInside];
        //[button setFrame:CGRectMake(0, 0, 63, 31)];
        
        //UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(3, 5, 60, 20)];
        //[label setFont:[UIFont fontWithName:@"Arial-BoldMT" size:13]];
        //[label setText:@"Log Out"];
        //label.textAlignment = UITextAlignmentCenter;
        //[label setTextColor:[UIColor whiteColor]];
        //[label setBackgroundColor:[UIColor clearColor]];
        //[button addSubview:label];
        
        //UIBarButtonItem *barButton = [[UIBarButtonItem alloc] initWithCustomView:button];
        //self.navigationItem.leftBarButtonItem = barButton;
        
        NSLog(@"First page");
    }
    else
    {
        UIButton *btnBack = [UIButton buttonWithType: UIButtonTypeSystem];
        [btnBack setFrame: CGRectMake(0, 0, 30, 30)];
        [btnBack setTintColor: [UIColor whiteColor]];
        [btnBack setImage: [UIImage imageNamed: @"common_img_back.png"] forState: UIControlStateNormal];
        [btnBack addTarget: self action: @selector(onTouchBtnBack :) forControlEvents: UIControlEventTouchUpInside];
        
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView: btnBack];
    }
    
    [mViewTop setBackgroundColor: [UIColor colorWithPatternImage: [UIImage imageNamed: @"common_img_bar.png"]]];
    [mViewTop setHidden:YES];
}

//================================================================================================================

#pragma mark -
#pragma mark - SVPullToRefresh

- (void)insertRowAtTop {
    int64_t delayInSeconds = 2.0;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        mPage = 0;
        
        [self getFeed: mPage];
        
        [mTView.pullToRefreshView stopAnimating];
    });
}


- (void)insertRowAtBottom {
    int64_t delayInSeconds = 2.0;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){

        [self getFeed: mPage];
        
        
        [mTView.infiniteScrollingView stopAnimating];
    });
}

- (void)moveToTop {
    [mTView setContentOffset:CGPointZero animated:YES];
}

//================================================================================================================

#pragma mark -
#pragma mark - Touch Event

- (IBAction)onTouchBtnBack: (id)sender {
    [self.navigationController popViewControllerAnimated: YES];
}

- (IBAction)onTouchSignOut:(id)sender{
    NSLog(@"Touched Sign Out");
    //[self.navigationController popViewControllerAnimated: YES];

    //HLLoginViewController *loginTab = (HLLoginViewController *)[self.storyboard instantiateViewControllerWithIdentifier: @"HLLoginViewController"];
    [[AppEngine getInstance] logout];
    [(UINavigationController *)AppDel.window.rootViewController popToRootViewControllerAnimated:YES];
    
}

- (IBAction)onTouchBtnFeedMode: (id)sender {
    UIButton *btn = (UIButton *)sender;
    int tag = (int)btn.tag;
    
    mFeedMode = tag;
    
    switch (tag) {
        case FEED_MODE_FOLLOWING:
        {
            [mBtnFollowing setImage: [UIImage imageNamed: @"feed_img_indicator.png"] forState: UIControlStateNormal];
            [mBtnPopluar setImage: [UIImage new] forState: UIControlStateNormal];
            [mBtnTrending setImage: [UIImage new] forState: UIControlStateNormal];
        }
            break;
        case FEED_MODE_POPULAR:
        {
            [mBtnPopluar setImage: [UIImage imageNamed: @"feed_img_indicator.png"] forState: UIControlStateNormal];
            [mBtnFollowing setImage: [UIImage new] forState: UIControlStateNormal];
            [mBtnTrending setImage: [UIImage new] forState: UIControlStateNormal];
        }
            break;
        case FEED_MODE_TRENDING:
        {
            [mBtnTrending setImage: [UIImage imageNamed: @"feed_img_indicator.png"] forState: UIControlStateNormal];
            [mBtnPopluar setImage: [UIImage new] forState: UIControlStateNormal];
            [mBtnFollowing setImage: [UIImage new] forState: UIControlStateNormal];
        }
            break;
        default:
            break;
    }
    
    mPage = 0;
    [self getFeed: mPage];
}

//================================================================================================================

#pragma mark -
#pragma mark - Get Feed

- (void)getFeed: (int)page {
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
                postInfo.mThumbnail         = [dicPost objectForKey: @"thumbnail"];
                
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
    
    if (![self.mStrHashTag isEqualToString:@""] && self.mStrHashTag != nil)
    {
        feedType = @"hashtag";
        parameters = @{@"user_id":      [Engine gCurrentUser].mUserId,
                       @"feed_type":    feedType,
                       @"hashtag":      self.mStrHashTag,
                       @"page":         [NSString stringWithFormat: @"%d", page]};
    }
    else if (![self.mSpecializedPostID isEqualToString:@""] && self.mSpecializedPostID != nil)
    {
        feedType = @"detailview";
        parameters = @{@"user_id":      [Engine gCurrentUser].mUserId,
                       @"feed_type":    feedType,
                       @"post_id":      self.mSpecializedPostID,
                       @"page":         [NSString stringWithFormat: @"%d", page]};
    }
    else
    {
        parameters = @{@"user_id":      [Engine gCurrentUser].mUserId,
                       @"feed_type":    feedType,
                       @"page":         [NSString stringWithFormat: @"%d", page]};        
    }
    
    [[HLCommunication sharedManager] sendToService: API_GETFEED params: parameters success: successed failure: failure];
}

//================================================================================================================

#pragma mark -
#pragma mark - UITableView DataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [mArrPosts count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    PostInfo *postInfo = [mArrPosts objectAtIndex: indexPath.row];
    
    float height = 40.0f;
    
    if (IS_IPHONE6) {
        //height += 467;
        height += ([postInfo.mMediaType isEqualToString: @"1"]) ? 269 : 497;
    }
    else {
        height += ([postInfo.mMediaType isEqualToString: @"1"]) ? 219 : 427;
    }
    
    if (![postInfo.mDescription isEqualToString: @""]) {
        height += [HLHomeFeedTableViewCell messageSize: postInfo.mDescription].height;
    }
    
    height += [postInfo.mArrComments count] * 70.0f + 3.0f;
    
    long nCommentViewCnt = postInfo.mCommentsCount.integerValue;
    if (nCommentViewCnt > [postInfo.mArrComments count])
        height += 50;
    
    return height;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *tableIdentifier = @"HLHomeFeedTableViewCell";
    
    HLHomeFeedTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier: tableIdentifier];
    
    if (cell == nil) {
        cell = [HLHomeFeedTableViewCell sharedCell];
        cell.delegate = self;
    }
    
    PostInfo *postInfo = [mArrPosts objectAtIndex: indexPath.row];
    [cell setPostInfo: postInfo];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {

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
    [self getFeed: mPage];
}

- (void)didTouchedDownload:(HLHomeFeedTableViewCell *)tableViewCell
{
    NSLog(@"This is Download Button");
    
    NSIndexPath *indexPath = [mTView indexPathForCell:tableViewCell];
    
    PostInfo *postInfo = [mArrPosts objectAtIndex: indexPath.row];
    
    if ([postInfo.mMediaType isEqualToString: @"1"]) { // Audio
        
        //UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Information"
        //                                                message:@"By technical issue, audio file can't download on your music gallery."
        //                                               delegate:self
        //                                      cancelButtonTitle:@"OK"
        //                                      otherButtonTitles:nil];
        //[alert show];
        NSURL *url = [NSURL URLWithString: [NSString stringWithFormat: @"%@%@", API_HOME, postInfo.mMedia]];
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
            NSData *data = [NSData dataWithContentsOfURL:url];
            
            //Find a cache directory. You could consider using documenets dir instead (depends on the data you are fetching)
            NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
            NSString *path = [paths  objectAtIndex:0];
            
            //Save the data
            NSString *dataPath = [path stringByAppendingPathComponent:@"download.mp3"];
            dataPath = [dataPath stringByStandardizingPath];
            NSLog(dataPath);
            
            BOOL success = [data writeToFile:dataPath atomically:YES];
            
            if (success == TRUE)
            {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Success"
                                                  message:@"Successfully downloaded audio."
                                                              delegate:self
                                                     cancelButtonTitle:@"OK"
                                                     otherButtonTitles:nil];
               [alert show];
            }
            else
            {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Failed"
                                                                message:@"Failed to download audio."
                                                               delegate:self
                                                      cancelButtonTitle:@"OK"
                                                      otherButtonTitles:nil];
                [alert show];
            }
        });
        
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
