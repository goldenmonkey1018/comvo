//
//  HLCommentViewController.m
//  Comvo
//
//  Created by Dmitry Volzhin on 29/01/15.
//  Copyright (c) 2015 DeMing Yu. All rights reserved.
//

#import "HLCommentViewController.h"

#import <SVPullToRefresh.h>
#import <MBProgressHUD.h>
#import <CoreMedia/CoreMedia.h>

#import "AppEngine.h"
#import "Constants_Comvo.h"
#import "HLCommunication.h"

#import <SZTextView/SZTextView.h>

#import "HLCommentTableViewCell.h"
#import "HLAudioViewController.h"
#import "HLPreviewViewController.h"
#import "HLProfileOtherViewController.h"
#import "HLProfileViewController.h"
#import "HLHomeViewController.h"
#import <OHAttributedLabel.h>

#import "HLStreamViewController.h"

@interface HLCommentViewController () <HLCommentTableViewCellDelegate, HLAudioViewControllerDelegate, HLPreviewViewControllerDelegate, SWTableViewCellDelegate, UIAlertViewDelegate, UITextViewDelegate>

@property (nonatomic, weak) HLCommentTableViewCell *selectedCell;

@end

@implementation HLCommentViewController

@synthesize mPostInfo;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    mArrComment = [[NSMutableArray alloc] init];
    
    [self initNavigation];
    
    UIView *paddingView = [[UIView alloc] initWithFrame: CGRectMake(0, 0, 10, 20)];
    
    //mTextComment.leftView = paddingView;
    //mTextComment.leftViewMode = UITextFieldViewModeAlways;
    mTextComment.layer.borderWidth = 1.0f;
    mTextComment.layer.borderColor = [UIColorFromRGB(0x00AFF0) CGColor];
    [mTextComment setKeyboardType:UIKeyboardTypeTwitter];
    [mTextComment setNeedsDisplay];

    
    mProgress = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    mProgress.mode = MBProgressHUDModeIndeterminate;
    [mProgress hide: NO];
    
    __block HLCommentViewController *commentView = self;
    
    [mTView addPullToRefreshWithActionHandler: ^{
        [commentView insertRowAtTop];
    }];
    
    [mTView addInfiniteScrollingWithActionHandler: ^{
        [commentView insertRowAtBottom];
    }];
    
    mPage = 0;
    [self getComments: mPage];
    [self getHashtag];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear: animated];
    
    [self.tabBarController.tabBar setHidden: YES];
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
#pragma mark - SVPullToRefresh

- (void)insertRowAtTop {
    int64_t delayInSeconds = 2.0;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        mPage = 0;
        
        [mTView.pullToRefreshView stopAnimating];
    });
}


- (void)insertRowAtBottom {
    int64_t delayInSeconds = 2.0;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        
        [mTView.infiniteScrollingView stopAnimating];
    });
}


//==========================================================================================================================

#pragma mark -
#pragma mark - Initialize

- (void)initNavigation {
    [self.navigationController setNavigationBarHidden: NO];

    [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed: @"common_img_bar.png"]
                                                  forBarMetrics:UIBarMetricsDefault];
    self.navigationController.navigationBar.shadowImage = [UIImage new];
    self.navigationController.navigationBar.translucent = NO;
    
    self.title = @"Comments";
    [self.navigationController.navigationBar
     setTitleTextAttributes:@{NSForegroundColorAttributeName : [UIColor whiteColor]}];
    
    UIButton *btnBack = [UIButton buttonWithType: UIButtonTypeSystem];
    [btnBack setFrame: CGRectMake(0, 0, 30, 30)];
    [btnBack setTintColor: [UIColor whiteColor]];
    [btnBack setImage: [UIImage imageNamed: @"common_img_back.png"] forState: UIControlStateNormal];
    [btnBack addTarget: self action: @selector(onTouchBtnBack :) forControlEvents: UIControlEventTouchUpInside];
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView: btnBack];
}


//================================================================================================================

#pragma mark -
#pragma mark - Touch Event

- (IBAction)onTouchBtnBack: (id)sender {
    [self.navigationController popViewControllerAnimated: YES];
}

- (IBAction)onTouchBtnAudio: (id)sender {
    [Engine setGAudioRecordingMode:@"StreamingAudio"];
    
    HLAudioViewController *audioView = (HLAudioViewController *)[self.storyboard instantiateViewControllerWithIdentifier: @"HLAudioViewController"];
    audioView.delegate = self;
    
    [self.navigationController pushViewController: audioView animated: YES];
}

//================================================================================================================

#pragma mark -
#pragma mark - Get Hashtags

- (void)getHashtag {
    NSDictionary *parameters = nil;
    
    void ( ^successed )( id responseObject ) = ^( id responseObject ) {
        NSLog(@"JSON: %@", responseObject);
        
        int result = [[responseObject objectForKey: @"success"] intValue];
        if (result) {
            
            NSDictionary *dicData = [responseObject objectForKey: @"data"];
            NSArray *arrHashtags = [dicData objectForKey: @"hashtags"];
            NSArray *arrPeopletags = [dicData objectForKey: @"peopletags"];
            
            [mTextComment setHashtagsArray:arrHashtags];
            [mTextComment setUsernamesArray:arrPeopletags];
            
            //for (int i = 0; i < [arrHashtags count]; i++) {
            //    NSString *hashtag = [arrHashtags objectAtIndex: i];
            
            //[posts addObject: postInfo];
            
            //}
            
        }
        else {
        }
        
        
    };
    
    void ( ^failure )( NSError* error ) = ^( NSError* error ) {
        NSLog(@"Error: %@", error);
        
    };
    
    parameters = @{@"user_id":      [Engine gCurrentUser].mUserId};
    
    [[HLCommunication sharedManager] sendToService: API_GETHASHTAGS params: parameters success: successed failure: failure];
}

//================================================================================================================

#pragma mark -
#pragma mark - Get Comments

- (void)getComments: (int)page {
    NSDictionary *parameters = nil;
    
    [self showLoading];
    
    void ( ^successed )( id responseObject ) = ^( id responseObject ) {
        NSLog(@"JSON: %@", responseObject);
        
        
        int result = [[responseObject objectForKey: @"success"] intValue];
        if (result) {
            
            if (mPage == 0) {
                [mArrComment removeAllObjects];
            }
            
            NSDictionary *dicData = [responseObject objectForKey: @"data"];
            NSArray *arrComments = [dicData objectForKey: @"comments"];
            
            for (int i = 0; i < [arrComments count]; i++) {
                NSDictionary *dicComment = [arrComments objectAtIndex: i];
                
                CommentInfo *info = [[CommentInfo alloc] init];
                
                info.mCommentId         = [dicComment objectForKey: @"comment_id"];
                info.mUserId            = [dicComment objectForKey: @"user_id"];
                info.mPostId            = [dicComment objectForKey: @"post_id"];
                info.mComment           = [dicComment objectForKey: @"comment"];
                info.mCommentDate       = [dicComment objectForKey: @"comment_date"];
                info.mFullName          = [dicComment objectForKey: @"fullname"];
                info.mUserName          = [dicComment objectForKey: @"username"];
                info.mProfilePhoto      = [dicComment objectForKey: @"profile_photo"];
                info.mCommentType       = [dicComment objectForKey: @"comment_type"];
                
                [mArrComment addObject: info];
            }
            
            if ([arrComments count] > 0) {
                mPage ++;
            }
            
            [mTView reloadData];
            
        }
        else {
            
        }
        
        [mProgress hide: YES];
        
        
    };
    
    void ( ^failure )( NSError* error ) = ^( NSError* error ) {
        NSLog(@"Error: %@", error);
        
        [mProgress hide: YES];
        
    };    
    
    parameters = @{@"user_id":      [Engine gCurrentUser].mUserId,
                   @"post_id":      self.mPostInfo.mPostId,
                   @"page":         [NSString stringWithFormat: @"%d", page],
                   @"ordertype":    @"oldest"};
    
    [[HLCommunication sharedManager] sendToService: API_GETCOMMENT
                                            params: parameters
                                           success: successed
                                           failure: failure];
}

- (void)submitCommentWithMessage: (NSString *)comment {
    // [mProgress show: YES];
    [self showLoading];
    
    NSDictionary *parameters = nil;
    
    void ( ^successed )( id responseObject ) = ^( id responseObject ) {
        NSLog(@"JSON: %@", responseObject);
        
        int result = [[responseObject objectForKey: @"success"] intValue];
        if (result) {
            [mTextComment setText: @""];
            
            mPage = 0;
            [Engine setGFlgCommentModified:@"YES"];
            [mProgress hide: YES];
            
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle: @"Success" message: @"You've uploaded comment message successfully." delegate: nil cancelButtonTitle: @"OK" otherButtonTitles: nil];
            [alertView show];
            
            [self getComments: mPage];
        }
        else {
            
        }
        
        [mProgress hide: YES];
    };
    
    void ( ^failure )( NSError* error ) = ^( NSError* error ) {
        NSLog(@"Error: %@", error);
        
        [mProgress hide: YES];
        
    };
    
    NSLog(@"comment: %@", mTextComment.text);
    
    parameters = @{@"user_id":      [Engine gCurrentUser].mUserId,
                   @"post_id":      self.mPostInfo.mPostId,
                   @"comment":      comment,
                   @"comment_type":  @"0",
                   @"duration":     @"0"};
    
    [[HLCommunication sharedManager] sendToService: API_SUBMITCOMMENT params: parameters success: successed failure: failure];
}

- (void)submitCommentWithAudio: (NSURL *)mediaURL  :(NSData *)mediaData {
    //[mProgress show: YES];
    [self showLoading];
    
    NSDictionary *parameters = nil;
    
    void ( ^successed )( id responseObject ) = ^( id responseObject ) {
        NSLog(@"JSON: %@", responseObject);
        
        int result = [[responseObject objectForKey: @"success"] intValue];
        if (result) {
            [mTextComment setText: @""];
            [mProgress hide: YES];
            
            [Engine setGFlgCommentModified:@"YES"];
            
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle: @"Success" message: @"You've uploaded comment audio successfully." delegate: nil cancelButtonTitle: @"OK" otherButtonTitles: nil];
            [alertView show];
            
            mPage = 0;
            [self getComments: mPage];
        }
        else {
            
        }
        
        [mProgress hide: YES];
    };
    
    void ( ^failure )( NSError* error ) = ^( NSError* error ) {
        NSLog(@"Error: %@", error);
        
        [mProgress hide: YES];
        
    };
    
    NSLog(@"comment: %@", mTextComment.text);
    
    AVURLAsset* asset = [AVURLAsset URLAssetWithURL: mediaURL options:nil];
    //AVPlayerItem* item = [AVPlayerItem playerItemWithAsset:asset];
    
    parameters = @{@"user_id":      [Engine gCurrentUser].mUserId,
                   @"post_id":      self.mPostInfo.mPostId,
                   @"comment":      @"",
                   @"comment_type": @"1",
                   @"duration":     [NSString stringWithFormat: @"%f", CMTimeGetSeconds(asset.duration)]};
    
    NSString *fileName = @"attachment.aac";
    NSString *mimeType = @"audio/aac";
    
    [[HLCommunication sharedManager] sendToServiceWithMedia: API_SUBMITCOMMENT params: parameters media:  mediaData fileName: fileName mimeType: mimeType success: successed failure: failure];
}


//================================================================================================================

#pragma mark -
#pragma mark - UITableView DataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [mArrComment count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    CommentInfo *cInfo = [mArrComment objectAtIndex: indexPath.row];
    
    if ([cInfo.mCommentType isEqualToString: @"1"]) { // Audio
        return 110.0f;
    }
    
    HLCommentTableViewCell *cell = [HLCommentTableViewCell sharedCell];
    float height = [HLCommentTableViewCell messageSize: cInfo.mComment label:cell.mLblCaption].height;
    height += 45;
    
    return height;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *tableIdentifier = @"HLCommentTableViewCell";
    
    HLCommentTableViewCell *cell = (HLCommentTableViewCell *)[tableView dequeueReusableCellWithIdentifier: tableIdentifier];
    
    if (cell == nil) {
        cell = [HLCommentTableViewCell sharedCell];
        
        cell.rightUtilityButtons = [self rightButtons];
        
        cell.delegateComment = self;
        cell.delegate = self;
    }
    
    CommentInfo *cInfo = [mArrComment objectAtIndex: indexPath.row];
    
    ///////////// Delete Button Show / Hide /////////////////////
    NSString *strCommentUserID = cInfo.mUserId;
    NSString *strEngineUserID = [Engine gCurrentUser].mUserId;
    
    if ([strCommentUserID isEqualToString:strEngineUserID] ||
        [mPostInfo.mUserId isEqualToString:strEngineUserID])
    {
        cell.rightUtilityButtons = [self rightButtons];
    }
    else
    {
        cell.rightUtilityButtons = nil;
    }

    [cell setCommentInfo: cInfo];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    
}

- (NSArray *)rightButtons
{
    NSMutableArray *rightUtilityButtons = [NSMutableArray new];
    //[rightUtilityButtons sw_addUtilityButtonWithColor:
    // [UIColor colorWithRed:0.78f green:0.78f blue:0.8f alpha:1.0]
    //                                            title:@"More"];
    [rightUtilityButtons sw_addUtilityButtonWithColor:
     [UIColor colorWithRed:1.0f green:0.231f blue:0.188 alpha:1.0f]
                                                title:@"Delete"];
    
    return rightUtilityButtons;
}

//================================================================================================================

#pragma mark -
#pragma mark - UITextField DataSource

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    
    [self submitCommentWithMessage: textField.text];
    
    return YES;
}

//================================================================================================================
- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text{
    if ([text isEqualToString:@"\n"]) {
        [textView resignFirstResponder];
        
        [self submitCommentWithMessage: textView.text];
        
        return YES;
    }
    else if([[textView text] length] - range.length + text.length > 224){
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Warning"
                                                        message:@"Too many characters. Can't input any more."
                                                       delegate:self
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
        
        return NO;
    }
    return YES;
}

- (BOOL) textViewShouldEndEditing:(UITextView *)textView{
//    [self submitCommentWithMessage: textView.text];
    
    return YES;
}



//================================================================================================================
#pragma mark -
#pragma mark - HLCommentTableViewCellDelegate

- (void)didFinishedDelete: (HLCommentTableViewCell *)tableViewCell{
    NSLog(@"did Finished Delegate");
    ////////////// REFRESH PAGE ///////////////
    mPage = 0;
    [self getComments: mPage];
    [Engine setGFlgCommentModified:@"YES"];
}

- (void)didTouchHashTag: (HLCommentTableViewCell *)tableViewCell hashTag: (NSString *)hashTag {
    NSLog(@"Hash tag primo touched");
    
    HLStreamViewController *streamingView = (HLStreamViewController *)[self.storyboard instantiateViewControllerWithIdentifier: @"HLStreamViewController"];
    //detailView.mPostInfo = tableViewCell.mPostInfo;
    
    streamingView.mStrHashTag = hashTag;
    [self.navigationController pushViewController: streamingView animated: YES];
    
}

- (void)didTouchUserName: (HLCommentTableViewCell *)tableViewCell userName: (NSString *)userName {
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

- (void)didTouchUserName: (HLCommentTableViewCell *)tableViewCell userID: (NSString *)userID {
    NSLog(@"Username tag primo touched");
    NSLog(@"%@", userID);
    
    if ([[Engine gCurrentUser].mUserId isEqualToString:userID])
    {
        //HLProfileViewController *profileView = (HLProfileViewController *)[self.storyboard instantiateViewControllerWithIdentifier: @"HLProfileViewController"];
        //detailView.mPostInfo = tableViewCell.mPostInfo;
        
        //profileOtherView.mStrHashTag = hashTag;
        //profileOtherView.mStrProfileID = userID;
//        [self.navigationController pushViewController: profileView animated: YES];
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



#pragma mark - SWTableViewDelegate

- (void)swipeableTableViewCell:(SWTableViewCell *)cell didTriggerLeftUtilityButtonWithIndex:(NSInteger)index{
    
}

- (void)swipeableTableViewCell:(SWTableViewCell *)cell didTriggerRightUtilityButtonWithIndex:(NSInteger)index{
    HLCommentTableViewCell *commentCell = (HLCommentTableViewCell *)cell;
    self.selectedCell = commentCell;
    
    switch (index) {
        //case 0:
        //    NSLog(@"More button was pressed");
        //    break;
        case 0:
        {
            // Delete button was pressed
            NSLog(@"Delete button was pressed");
            
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle: @"Delete Comment" message: @"Do you want to delete comment?" delegate: self cancelButtonTitle: @"Yes" otherButtonTitles: @"No", nil];
            
            [alertView show];
            break;
        }
        default:
            break;
    }
}


//================================================================================================================

#pragma mark -
#pragma mark - HLAudioViewController DataSource

- (void)didBackedFromRecordAudio {
    [self.navigationController popViewControllerAnimated: YES];
}

- (void)didFinishedRecordAudio: (NSURL *)audioURL {
    [self.navigationController popViewControllerAnimated: NO];
    
    HLPreviewViewController *previewView = (HLPreviewViewController *)[self.storyboard instantiateViewControllerWithIdentifier: @"HLPreviewViewController"];
    previewView.delegate = self;
    previewView.mMediaType = @"1";
    previewView.mMediaURL = audioURL;
    previewView.mMediaData = [NSData dataWithContentsOfURL: audioURL];
    [self.navigationController pushViewController: previewView animated: YES];
}

//================================================================================================================

#pragma mark -
#pragma mark - HLAudioViewController DataSource DataSource

- (void)didBackFromPreview: (NSString *)mediaType {
    [self.navigationController popViewControllerAnimated: NO];
    
    [Engine setGAudioRecordingMode:@"StreamingAudio"];
    
    HLAudioViewController *audioView = (HLAudioViewController *)[self.storyboard instantiateViewControllerWithIdentifier: @"HLAudioViewController"];
    audioView.delegate = self;
    [self.navigationController pushViewController: audioView animated: YES];
}

- (void)didDonePreview: (NSString *)mediaType mediaURL: (NSURL *)mediaURL mediaData: (NSData *)mediaData {
    [self.navigationController popViewControllerAnimated: NO];
    
    [self submitCommentWithAudio: mediaURL : mediaData];
}

//==========================================================================================================================

#pragma mark -
#pragma mark - UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 0) {
        if ([alertView.title isEqualToString:@"Delete Comment"])
        {
            [self.selectedCell onBtnDelete:nil];
        }
        
    }
}

- (void)showLoading {
    //mProgress = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    mProgress = [MBProgressHUD showHUDAddedTo:[UIApplication sharedApplication].keyWindow animated:YES];
    mProgress.mode = MBProgressHUDModeIndeterminate;
    mProgress.labelText = @"Waiting...";
    [mProgress show:YES];
    
}

@end
