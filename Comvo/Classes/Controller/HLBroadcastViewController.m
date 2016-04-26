//
//  HLBroadcastViewController.m
//  Comvo
//
//  Created by DeMing Yu on 1/8/15.
//  Copyright (c) 2015 DeMing Yu. All rights reserved.
//

#import "HLBroadcastViewController.h"

#import <SZTextView.h>
#import <MBProgressHUD.h>
#import <AVFoundation/AVFoundation.h>
#import <CoreMedia/CoreMedia.h>

#import "AppEngine.h"
#import <SZTextView/SZTextView.h>
#import "Constants_Comvo.h"
#import "HLCommunication.h"

#import <FBSDKShareKit/FBSDKShareKit.h>
#import <FBSDKLoginKit/FBSDKLoginKit.h>
#import <FBSDKCoreKit/FBSDKCoreKit.h>

#import <TwitterKit/TwitterKit.h>
#import <TwitterCore/TwitterCore.h>

#import <Fabric/Fabric.h>


#import <Social/Social.h>
#import <Accounts/Accounts.h>
#import "TMAPIClient.h"
#import "TMTumblrAppClient.h"

typedef enum {
    TMAppClientActionViewInAppStore,
    TMAppClientActionViewDashboard,
    TMAppClientActionViewExplore,
    TMAppClientActionViewActivity,
    TMAppClientActionViewTag,
    TMAppClientActionViewBlog,
    TMAppClientActionViewPost,
    TMAppClientActionCreateTextPost,
    TMAppClientActionCreateLinkPost,
    TMAppClientActionCreateQuotePost,
    TMAppClientActionCreateChatPost,
    TMAppClientActionCount
} TMAppClientActions;

@interface HLBroadcastViewController () <UIAlertViewDelegate, UITextViewDelegate, UIDocumentInteractionControllerDelegate >

@property (nonatomic, strong) UIDocumentInteractionController *interactionController;


@end

@implementation HLBroadcastViewController

@synthesize docFile = _docFile;

@synthesize delegate;
@synthesize mMediaType;
@synthesize mMediaURL;
@synthesize mMediaData;
@synthesize mMediaThumbnail;

SLComposeViewController *mySLComposerSheet;
static NSString *cellIdentifier = @"cellIdentifier";


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    mTextCaption.placeholder = @"Description here";
    mTextCaption.placeholderTextColor =  UIColorFromRGB(0x00AFF0);
    
    //[self getFullAddress: [NSString stringWithFormat: @"%f", [Engine gCurrentLocation].latitude] :[NSString stringWithFormat: @"%f", [Engine gCurrentLocation].longitude]];
    
    NSArray *sampleUsernames = @[ @"adambco", @"muradosmann", @"hecktictravels", @"bipolaire61", @"fourjandals", @"yeatoeh", @"packsandbunks", @"sharolyn_w", @"1step2theleft", @"nineteenfiftyone", @"uncornered_market", @"pataexplorer", @"wildjunket", @"drewkelly", @"nomadicnotes", @"chmlh", @"natgeotraveler", @"ahmadziya", @"beersandbeans", @"bradtully", @"legalnomads", @"theodorekaye", @"theblondegypsy", @"_mihi", @"adventurouskate", @"adanvelez", @"theplanetd", @"fosterhunting", @"pausethemoment", @"seattlestravels", @"everythingeverywhere", @"landingstanding", @"MatadorNetwork", @"hostelbookers", @"traveling9to5"];
    
//    NSArray *sampleHashtags = @[ @"fashion", @"friends", @"smile", @"like4like", @"instamood", @"nofilter", @"family", @"amazing", @"style", @"sun", @"follow4follow", @"tflers", @"beach", @"lol", @"hair", @"followforfollow", @"iphoneonly", @"cool", @"webstagram", @"girls", @"iphonesia", @"funny", @"tweegram", @"my", @"black", @"igdaily", @"instacool", @"instagramhub", @"makeup", @"awesome", @"bored", @"nice", @"instafollow", @"eyes", @"all_shots"];
    
    [self getHashtag];
    //[mTextCaption setUsernamesArray:sampleUsernames];
    //[mTextCaption setHashtagsArray:sampleHashtags];
    
    [TMAPIClient sharedInstance].OAuthConsumerKey = @"";
    [TMAPIClient sharedInstance].OAuthConsumerSecret = @"";
    [TMAPIClient sharedInstance].OAuthToken = @"";
    [TMAPIClient sharedInstance].OAuthTokenSecret = @"";
    
    /*[self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:cellIdentifier];
    
    self.navigationController.toolbarHidden = NO;
    
    UIBarButtonItem *flexibleSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
                                                                                   target:nil action:nil];
    
    self.toolbarItems = @[
                          flexibleSpace,
                          [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self
                                                                        action:@selector(action:)],
                          flexibleSpace
                          ];*/
    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear: animated];
    
    [self initNavigation];
    [self.tabBarController.tabBar setHidden: NO];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - UITableViewController

- (id)initWithStyle:(UITableViewStyle)style {
    if (self = [super initWithStyle:UITableViewStyleGrouped])
        self.title = @"Tumblr app client";
    
    return self;
}

#pragma mark - Actions

- (void)action:(UIBarButtonItem *)item {
    // Tumblr can be used to open images and video files for creating photo and video posts respectively.
    
    NSURL *URL = [[NSBundle bundleForClass:[HLBroadcastViewController class]] URLForResource:@"tumblr" withExtension:@"png"];
    
    UIDocumentInteractionController *controller = [UIDocumentInteractionController interactionControllerWithURL:URL];
    controller.annotation = @{ @"TumblrCaption" : @"Caption for photo or video post.", @"TumblrTags" : @[ @"foo", @"bar" ] };
    controller.UTI = @"com.tumblr.photo";
    
    self.interactionController = controller;
    [controller presentOpenInMenuFromBarButtonItem:item animated:YES];
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return TMAppClientActionCount;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
    
    switch (indexPath.row) {
        case TMAppClientActionViewInAppStore:
            cell.textLabel.text = @"View in App Store";
            break;
        case TMAppClientActionViewDashboard:
            cell.textLabel.text = @"View dashboard";
            break;
        case TMAppClientActionViewExplore:
            cell.textLabel.text = @"View explore";
            break;
        case TMAppClientActionViewActivity:
            cell.textLabel.text = @"View activity";
            break;
        case TMAppClientActionViewTag:
            cell.textLabel.text = @"View GIF tag";
            break;
        case TMAppClientActionViewBlog:
            cell.textLabel.text = @"View Tumblr developers blog";
            break;
        case TMAppClientActionViewPost:
            cell.textLabel.text = @"View Tumblr developers blog post";
            break;
        case TMAppClientActionCreateTextPost:
            cell.textLabel.text = @"Create text post";
            break;
        case TMAppClientActionCreateLinkPost:
            cell.textLabel.text = @"Create link post";
            break;
        case TMAppClientActionCreateQuotePost:
            cell.textLabel.text = @"Create quote post";
            break;
        case TMAppClientActionCreateChatPost:
            cell.textLabel.text = @"Create chat post";
            break;
    }
    
    return cell;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSURL *successURL = [NSURL URLWithString:@"tumblrappclientexample://success"];
    NSURL *cancelURL = [NSURL URLWithString:@"tumblrappclientexample://cancelled"];
    
    switch (indexPath.row) {
        case TMAppClientActionViewInAppStore:
            [TMTumblrAppClient viewInAppStore];
            break;
        case TMAppClientActionViewDashboard:
            [TMTumblrAppClient viewDashboard];
            break;
        case TMAppClientActionViewExplore:
            [TMTumblrAppClient viewExplore];
            break;
        case TMAppClientActionViewActivity:
            [TMTumblrAppClient viewActivityForPrimaryBlog];
            break;
        case TMAppClientActionViewTag:
            [TMTumblrAppClient viewTag:@"gif"];
            break;
        case TMAppClientActionViewBlog:
            [TMTumblrAppClient viewBlog:@"developers"];
            break;
        case TMAppClientActionViewPost:
            [TMTumblrAppClient viewPost:@"43515916425" blogName:@"developers"];
            break;
        case TMAppClientActionCreateTextPost:
            [TMTumblrAppClient createTextPost:@"Title" body:@"Body" tags:@[@"gif", @"lol"] success:successURL
                                       cancel:cancelURL];
            break;
        case TMAppClientActionCreateLinkPost:
            [TMTumblrAppClient createLinkPost:@"Tumblr" URLString:@"http://tumblr.com"
                                  description:@"Follow the world's creators" tags:@[@"gif", @"lol"] success:successURL
                                       cancel:cancelURL];
            break;
        case TMAppClientActionCreateQuotePost:
            [TMTumblrAppClient createQuotePost:@"Fellas, don't drink that coffee! You'd never guess. There was a fish..."
             "in the percolator! Sorry..." source:@"Pete" tags:@[@"gif", @"lol"] success:successURL cancel:cancelURL];
            break;
        case TMAppClientActionCreateChatPost:
            [TMTumblrAppClient createChatPost:@"Chat" body:@"Peter: I'm like a sweet peach on a hot summer day.\nMegan:"
             "You're like a sour pickle on a windy day." tags:@[@"gif", @"lol"] success:successURL cancel:cancelURL];
            break;
    }
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}
*/

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
    
    self.title = @"Broadcast";
    [self.navigationController.navigationBar
     setTitleTextAttributes:@{NSForegroundColorAttributeName : [UIColor whiteColor]}];
    
    UIButton *btnBack = [UIButton buttonWithType: UIButtonTypeSystem];
    [btnBack setFrame: CGRectMake(0, 0, 30, 30)];
    [btnBack setTintColor: [UIColor whiteColor]];
    [btnBack setImage: [UIImage imageNamed: @"common_img_back.png"] forState: UIControlStateNormal];
    [btnBack addTarget: self action: @selector(onTouchBtnBack :) forControlEvents: UIControlEventTouchUpInside];
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView: btnBack];
    
    UIButton *btnDone = [UIButton buttonWithType: UIButtonTypeSystem];
    [btnDone setFrame: CGRectMake(0, 0, 30, 30)];
    [btnDone setTintColor: [UIColor whiteColor]];
    [btnDone setImage: [UIImage imageNamed: @"broadcast_img_done.png"] forState: UIControlStateNormal];
    [btnDone addTarget: self action: @selector(onTouchBtnDone:) forControlEvents: UIControlEventTouchUpInside];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView: btnDone];
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
            
            [mTextCaption setHashtagsArray:arrHashtags];
            [mTextCaption setUsernamesArray:arrPeopletags];
            [mTextCaption setKeyboardType:UIKeyboardTypeTwitter];
            
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

//==========================================================================================================================

#pragma mark -
#pragma mark - Touch Event

- (IBAction)onTouchBtnBack: (id)sender {
    [delegate didBackToCameraView: self];
}

- (IBAction)onTouchBtnDone: (id)sender {
    if (self.mMediaData == nil) {
        return;
    }    
    
    [mTextCaption resignFirstResponder];
//  [self submitPost: self.mMediaType mediaURL: self.mMediaURL mediaData: self.mMediaData];
    [self submitPost: self.mMediaType mediaURL: self.mMediaURL mediaData: self.mMediaData thumbnail:self.mMediaThumbnail];
}

#pragma mark -
#pragma mark - TextView Delegate
//===============================================================================================================
- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text{
    if ([text isEqualToString:@"#"]) {
        //[textView resignFirstResponder];
        NSLog(@"hash tag");
        //[self submitCommentWithMessage: textView.text];
        
        return YES;
    }
    
    if ([text isEqualToString:@"@"]) {
        //[textView resignFirstResponder];
        NSLog(@"people tag");
        //[self submitCommentWithMessage: textView.text];
        
        return YES;
    }
    
    if ([text isEqualToString:@"\n"]) {
        [textView resignFirstResponder];
        NSLog(@"send key");
        //[self submitCommentWithMessage: textView.text];
        
        return YES;
    }
    
    return YES;
}

- (BOOL) textViewShouldEndEditing:(UITextView *)textView{
    //    [self submitCommentWithMessage: textView.text];
    
    return YES;
}

//===========================================================================================================================================

#pragma mark -
#pragma mark - User Function

-(NSDictionary *)detectMentionsAndHashtags: (NSString *)statusString {
    
    NSMutableArray *arrUsers = [[NSMutableArray alloc] init];
    NSMutableArray *arrHashtags = [[NSMutableArray alloc] init];
    
    // Detect any "@" tags in the status using the "@\w+" regular expression and add to user mentions array
    NSRegularExpression* userRegex1 = [NSRegularExpression regularExpressionWithPattern:@"\\B@\\w+" options:0 error:nil];
    [userRegex1 enumerateMatchesInString:statusString options:0 range:NSMakeRange(0,statusString.length)
                              usingBlock:^(NSTextCheckingResult *match, NSMatchingFlags flags, BOOL *stop)
     {
         // For each user mentioned, add username to userMentions array
         NSString* user = [[statusString substringWithRange:match.range] substringFromIndex:1]; // get the matched user name, removing the "@"
         [arrUsers addObject:user];
     }];
    
    
    // Detect any "#" tags in the status using the "@\w+" regular expression and add to hashtags array
    NSRegularExpression* userRegex2 = [NSRegularExpression regularExpressionWithPattern:@"\\B#\\w+" options:0 error:nil];
    [userRegex2 enumerateMatchesInString:statusString options:0 range:NSMakeRange(0,statusString.length)
                              usingBlock:^(NSTextCheckingResult *match, NSMatchingFlags flags, BOOL *stop)
     {
         // For each user mentioned, add username to userMentions array
         NSString* hashtag = [[statusString substringWithRange:match.range] substringFromIndex:1]; // get the string the hashtag mentions
         hashtag = [hashtag lowercaseString]; // Make hashtag we store in array all lowercase to optimize searches
         [arrHashtags addObject:hashtag];
         NSLog(@"Found hashtag: %@", hashtag);
     }];
    
    NSDictionary *dicResult = @{@"users": arrUsers,
                                @"hashtags": arrHashtags};

    return dicResult;
}

#pragma mark -
#pragma mark - Upload Photo

- (void)submitPost: (NSString *)mediaType
          mediaURL: (NSURL *)mediaURL
         mediaData: (NSData *)mediaData
         thumbnail: (UIImage *)thumbnailImage{
    
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.mode = MBProgressHUDModeIndeterminate;
    hud.labelText = @"Uploading...";
    
    NSDictionary *userAndHashtag = [self detectMentionsAndHashtags: mTextCaption.text];
    
    NSArray *hashtags = [userAndHashtag objectForKey: @"hashtags"];
    NSArray *profile_users = [userAndHashtag objectForKey: @"users"];
    
    NSString *tags = @"";
    NSString *users = @"";
    
    for (int i = 0; i < [hashtags count]; i++)
    {
        tags = [tags stringByAppendingString: [NSString stringWithFormat: @"#%@", [hashtags objectAtIndex: i]]];
        
        if (i != [hashtags count] - 1)
        {
            tags = [tags stringByAppendingString: @","];
        }
    }
    
    for (int j = 0; j < [profile_users count]; j++)
    {
        users = [users stringByAppendingString: [NSString stringWithFormat: @"@%@", [profile_users objectAtIndex: j]]];
        
        if (j != [profile_users count] - 1)
        {
            users = [users stringByAppendingString: @","];
        }
    }
    
    NSDictionary *parameters = nil;
    
    void ( ^successed )( id responseObject ) = ^( id responseObject ) {
        NSLog(@"JSON: %@", responseObject);
        
        int result = [[responseObject objectForKey: @"success"] intValue];
        if (result) {
            NSDictionary *dicData = [responseObject objectForKey: @"data"];
            NSDictionary *dicPost = [dicData objectForKey: @"post"];
            
            PostInfo *postInfo = [[PostInfo alloc] init];
            
            postInfo.mCommentsCount     = [dicPost objectForKey: @"comments_count"];
            postInfo.mDescription       = [dicPost objectForKey: @"description"];
            postInfo.mDuration          = [dicPost objectForKey: @"duration"];
            postInfo.mLikesCount        = [dicPost objectForKey: @"likes_count"];
            postInfo.mMedia             = [dicPost objectForKey: @"media"];
            postInfo.mMediaType         = [dicPost objectForKey: @"media_type"];
            postInfo.mPostDate          = [dicPost objectForKey: @"post_date"];
            postInfo.mPostId            = [dicPost objectForKey: @"post_id"];
            postInfo.mThumbnail         = [dicPost objectForKey: @"thumbnail"];
            postInfo.mUserId            = [dicPost objectForKey: @"user_id"];
            
            
            ////////////// Facebook Posting ///////////////////
            if ([[FBSDKAccessToken currentAccessToken] hasGranted:@"publish_actions"]) {
                [[[FBSDKGraphRequest alloc]
                  initWithGraphPath:@"me/feed"
                      parameters: @{ @"message" : postInfo.mDescription,
                                     @"link":     [NSString stringWithFormat: @"%@%@", API_HOME,
                                           postInfo.mMedia]}
                                    HTTPMethod:@"POST"]
             startWithCompletionHandler:^(FBSDKGraphRequestConnection *connection, id result, NSError *error) {
                 if (!error) {
                     NSLog(@"Post id:%@", result[@"id"]);
                 }
             }];
            }
            ////////////////////////////////////////////////////
            
            ///////////// Twitter Posting ////////////////////
            if (([self.mMediaType isEqualToString: @"2"])){ // photo
                if([[Twitter sharedInstance] session])
                {
                    [self sharePhotoTwitter];
                }
            }
            else if (([self.mMediaType isEqualToString: @"3"])){ // video
                if([[Twitter sharedInstance] session])
                {
                    [self shareVideoTwitter];
                }
            }
            //////////////////////////////////////////////////
            
            ///////////////// Instragram Sharing ////////////
            UIAlertView *alertInstagramView = [[UIAlertView alloc] initWithTitle: @"Confirm" message: @"Will you post this media to Instagram?" delegate: self cancelButtonTitle:@"Yes" otherButtonTitles: @"No", nil];
            alertInstagramView.delegate = self;
            alertInstagramView.tag = 1;
            [alertInstagramView show];
            
            ////////////////////////////////////////////////////
            
            
        }
        else {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle: @"Warning" message: [responseObject valueForKey: @"message"] delegate: nil cancelButtonTitle: @"Ok" otherButtonTitles: nil];
            [alertView show];
        }
        
        [hud hide: YES];
    };
    
    void ( ^failure )( NSError* error ) = ^( NSError* error ) {
        NSLog(@"Error: %@", error);
        
        [hud hide: YES];
    };
    
    float duration = 0.0f;
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:mediaURL.path]) {
        NSLog(@"File existg");
    }
    
    if ([mediaType isEqualToString: @"1"]) { // Audio Type
        AVURLAsset* asset = [AVURLAsset URLAssetWithURL: mediaURL options:nil];
        duration = CMTimeGetSeconds(asset.duration);
    }
    
    parameters = @{@"user_id":       [Engine gCurrentUser].mUserId,
                   @"description":   mTextCaption.text,
                   @"media_type":    mediaType,
                   @"hashtags":      tags,
                   @"profile_users": users,
                   @"duration":     [NSString stringWithFormat: @"%f", duration]};
    
    NSString *fileName = @"";
    NSString *mimeType = @"";
    
    if ([mediaType isEqualToString: @"2"]) {
        fileName = @"attachment.jpg";
        mimeType = @"image/jpg";
    }
    else if ([mediaType isEqualToString: @"3"]) {
        fileName = @"attachment.mov";
        mimeType = @"video/quicktime";
    }
    else if ([mediaType isEqualToString: @"1"]) {
        fileName = @"attachment.aac";
        mimeType = @"audio/aac";
    }
    
    if (thumbnailImage == nil)
    {
        [[HLCommunication sharedManager] sendToServiceWithMedia: API_SUBMITPOST params: parameters media: mediaData fileName: fileName mimeType: mimeType success: successed failure: failure];
    }
    else
    {
        [[HLCommunication sharedManager] sendToServiceWithMedia: API_SUBMITPOST params: parameters media: mediaData fileName: fileName thumbnail:UIImageJPEGRepresentation(thumbnailImage, 0.8) mimeType:mimeType success:successed failure:failure];
    }
    
}


//============================================================================================================================

-(void)getFullAddress:(NSString*)latitude :(NSString*)longitude {
    //[mProgress show: YES];
    [self showLoading];
    
    //[self onActionSignup: @"US"];
    
    NSString *url = [NSString stringWithFormat:@"http://maps.googleapis.com/maps/api/geocode/json?latlng=%@,%@&sensor=true",latitude,longitude];
    NSURL *RequestURL=[NSURL URLWithString:url];
    
    dispatch_async(kBgQueue, ^{
        NSData* data = [NSData dataWithContentsOfURL: RequestURL];
        [self performSelectorOnMainThread:@selector(fetchedFullMyAddress:) withObject:data waitUntilDone:YES];
    });
    
}

-(void)fetchedFullMyAddress:(NSData *)responseData {
    NSError* error;
    
    if (responseData.length > 0) {
        NSDictionary* json = [NSJSONSerialization
                              JSONObjectWithData:responseData
                              options:kNilOptions
                              error:&error];
        
        NSArray *arr = [json objectForKey:@"results"];
        
        if ([arr count] > 0) {
            NSDictionary *dict = [arr objectAtIndex: 0];
            
            NSLog(@"address: %@", dict);
            
            NSString *country = @"";
            
            //NSArray *arrComponents = [dict objectForKey: @"formatted_address"];
            NSString *strAddress = dict[@"formatted_address"];
            mlblLocation.text = strAddress;
            
            /*for (int i = 0; i < [arrComponents count]; i++) {
                NSDictionary *dicComp = [arrComponents objectAtIndex: i];
                
                NSArray *types = [dicComp objectForKey: @"types"];
                
                if ([types containsObject: @"country"]) {
                    country = [dicComp objectForKey: @"short_name"];
                    
                    break;
                }
                else if ([types containsObject: @"administrative_area_level_1"]) {
                    
                }
                else if ([types containsObject: @"locality"]) {
                    
                }
            }*/
        }
        else {
            [mProgress hide: YES];
        }
        
        [mProgress hide: YES];
    }
    else {
        [mProgress hide: YES];
    }
}

- (void)showLoading {
    //mProgress = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    mProgress = [MBProgressHUD showHUDAddedTo:[UIApplication sharedApplication].keyWindow animated:YES];
    mProgress.mode = MBProgressHUDModeIndeterminate;
    mProgress.labelText = @"Connecting...";
    [mProgress show:YES];
    
}


- (IBAction)onTouchFacebookSharing:(id)sender{
    
    NSLog(@"Facebook Sharing");
    
    if ([[FBSDKAccessToken currentAccessToken] hasGranted:@"publish_actions"]) {
        // TODO: publish content.
    } else {
        FBSDKLoginManager *loginManager = [[FBSDKLoginManager alloc] init];
        [loginManager logInWithPublishPermissions:@[@"publish_actions"]
                               handler:^(FBSDKLoginManagerLoginResult *result, NSError *error) {
                                              //TODO: process error or result.
                                              NSLog(@"Login Manager Login Failed");
                                          }];
        
    }
    
    //if ([self.mMediaType isEqualToString: @"2"]) // photo
    //{
        //        UIImage *image = tableViewCell.mImgViewPhoto.image;
        
        //        FBSDKSharePhoto *photo = [[FBSDKSharePhoto alloc] init];
        //        photo.image = image;
        //        photo.userGenerated = YES;
        //        FBSDKSharePhotoContent *content = [[FBSDKSharePhotoContent alloc] init];
        //        content.photos = @[photo];
        
        //NSLog(@"%@", [NSString stringWithFormat: @"%@", self.mMediaURL ]);
        //FBSDKShareLinkContent *content = [[FBSDKShareLinkContent alloc] init];
        //content.imageURL = [NSURL URLWithString:[NSString stringWithFormat: @"%@%@", FILE_HOME, tableViewCell.mPostInfo.mMedia]];
        //content.imageURL = self.mMediaURL;
        //content
        
        //UIImage *image = self.mMediaData;
    
    
    
        
        //UIImage *image = [UIImage imageWithData:self.mMediaData];
        
        //FBSDKSharePhoto *photo = [[FBSDKSharePhoto alloc] init];
        //photo.image = image;
        
        //photo.userGenerated = YES;
        //FBSDKSharePhotoContent *content = [[FBSDKSharePhotoContent alloc] init];
        //content.photos = @[photo];
        
        //[FBSDKShareDialog showFromViewController:self
        //                              withContent:content
        //                                 delegate:nil];
    //}
    //else if ([self.mMediaType isEqualToString: @"3"]) // video
    //{
    //    NSURL *videoURL = self.mMediaURL;
        //NSURL *videoURL = [[NSURL URLWithString: [NSString stringWithFormat: @"%@%@", FILE_HOME, tableViewCell.mPostInfo.mMedia]] options:nil];
        
    //    NSLog(@"%@", videoURL);
        
        //NSURL *videoURL = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@", FILE_HOME, tableViewCell.mPostInfo.mMedia]];
        
    //    FBSDKShareVideo *video = [[FBSDKShareVideo alloc] init];
    //    video.videoURL = videoURL;
        
   //     FBSDKShareVideoContent *content = [[FBSDKShareVideoContent alloc] init];
   //     content.video = video;
        
   //     [FBSDKShareDialog showFromViewController:self
   //                             withContent:content
   //                                     delegate:nil];
   // }
}

- (IBAction)onTouchTwitterSharing:(id)sender
{
    NSLog(@"Twitter Sharing");
    
    [[Twitter sharedInstance] logInWithViewController:self completion:^(TWTRSession * _Nullable session, NSError * _Nullable error) {
        //[self shareVideoTwitter];
        NSLog(@"Completion");
    }];
    
    
    //if ([self.mMediaType isEqualToString: @"2"]) // photo & video
    //{
//        if([SLComposeViewController isAvailableForServiceType:SLServiceTypeTwitter])//SLServiceTypeTwitter
//            //check if Twitter Account is linked
//        {
//            mySLComposerSheet = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeTwitter]; //Tell him with what social plattform to use it, e.g. facebook or twitter
//            [mySLComposerSheet setInitialText:[NSString stringWithFormat: @"%@, Test", mySLComposerSheet.serviceType]]; //the message you want to post
//            
//            [mySLComposerSheet addURL:self.mMediaURL];
//            //[mySLComposerSheet addImage:(UIImage *)self.mMediaData];
//            UIImage *img = [UIImage imageWithData:self.mMediaData];
//            [mySLComposerSheet addImage:img];
//            
//            [mySLComposerSheet setCompletionHandler:^(SLComposeViewControllerResult result) {
//                NSString *output;
//                switch (result) {
//                    case SLComposeViewControllerResultCancelled:
//                        output = @"Action Cancelled";
//                        break;
//                    case SLComposeViewControllerResultDone:
//                        output = @"Post Successfull";
//                        break;
//                    default:
//                        break;
//                } //check if everything worked properly. Give out a message on the state.
//                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Twitter" message:output delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
//                [alert show];
//            }];
//            
//            //[mySLComposerSheet addImage:yourimage]; //an image you could post
//            //for more instance methodes,
//            //go here:
//            //  https://developer.apple.com/library/ios/#documentation/NetworkingInternet/Reference/SLComposeViewController_Class/Reference/Reference.html#//apple_ref/doc/uid/TP40012205
//            [self presentViewController:mySLComposerSheet animated:YES completion:nil];
//        } else
//        {
//            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Twitter" message:@"Twitter donesn't support audio sharing." delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
//            [alert show];
//        }
        
        //TWTRComposer *composer = [[TWTRComposer alloc] init];
        
        //[composer setText:@"Share an image to Twitter"];
        //[composer setText:mTextCaption.text];
        //[composer setImage:[UIImage imageWithData:self.mMediaData]];
        
        // Called from a UIViewController
        //[composer showFromViewController:self completion:^(TWTRComposerResult result) {
        //    if (result == TWTRComposerResultCancelled) {
        //        NSLog(@"Tweet composition cancelled");
        //    }
        //    else {
        //        NSLog(@"Sending Tweet!");
        //        [[[UIAlertView alloc] initWithTitle:@"Comvo" message:@"Successfully shared an image to twitter." delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil] show];
        //    }
        //}];
        
        //if([[Twitter sharedInstance] session])
        //{
        //    [self sharePhotoTwitter];
        //} else {
        //    [[Twitter sharedInstance] logInWithViewController:self completion:^(TWTRSession * _Nullable session, NSError * _Nullable error) {
        //        [self sharePhotoTwitter];
        //    }];
        //}
    //}
    
    //else if (([self.mMediaType isEqualToString: @"3"]))
    //{
    //    if([[Twitter sharedInstance] session])
    //    {
    //        [self shareVideoTwitter];
    //    } else {
    //        [[Twitter sharedInstance] logInWithViewController:self completion:^(TWTRSession * _Nullable session, NSError * _Nullable error) {
    //            [self shareVideoTwitter];
    //        }];
    //    }
    //}
}

- (void)sharePhotoTwitter {
    //mProgress = [MBProgressHUD showHUDAddedTo:[UIApplication sharedApplication].keyWindow animated:YES];
    //mProgress.mode = MBProgressHUDModeIndeterminate;
    //mProgress.labelText = @"Sharing a photo...";
    //[mProgress show:YES];
    
    //NSString *text = @"Twitter share video";
    NSString *text = mTextCaption.text;
    NSData* dataPhoto = self.mMediaData;
    
    NSString *lengthPhoto = [NSString stringWithFormat:@"%d", (int)dataPhoto.length];
    NSString* url = @"https://upload.twitter.com/1.1/media/upload.json";
    
    __block NSString *mediaID;
    
    __block TWTRAPIClient *client = [[Twitter sharedInstance] APIClient];
    NSError *error;
    // First call with command INIT
    __block NSDictionary *message =  @{ @"status":text,
                                        @"command":@"INIT",
                                        @"media_type":@"image/jpg",
                                        @"total_bytes":lengthPhoto};
    NSURLRequest *preparedRequest = [client URLRequestWithMethod:@"POST" URL:url parameters:message error:&error];
    
    [client sendTwitterRequest:preparedRequest completion:^(NSURLResponse *urlResponse, NSData *responseData, NSError *error){
        
        if(!error){
            NSError *jsonError;
            NSDictionary *json = [NSJSONSerialization
                                  JSONObjectWithData:responseData
                                  options:0
                                  error:&jsonError];
            
            mediaID = [json objectForKey:@"media_id_string"];
            client = [[Twitter sharedInstance] APIClient];
            NSError *error;
            NSString *photoString = [dataPhoto base64EncodedStringWithOptions:0];
            // Second call with command APPEND
            message = @{@"command" : @"APPEND",
                        @"media_id" : mediaID,
                        @"segment_index" : @"0",
                        @"media" : photoString};
            
            NSURLRequest *preparedRequest = [client URLRequestWithMethod:@"POST" URL:url parameters:message error:&error];
            
            [client sendTwitterRequest:preparedRequest completion:^(NSURLResponse *urlResponse, NSData *responseData, NSError *error){
                
                if(!error){
                    client = [[Twitter sharedInstance] APIClient];
                    NSError *error;
                    // Third call with command FINALIZE
                    message = @{@"command" : @"FINALIZE",
                                @"media_id" : mediaID};
                    
                    NSURLRequest *preparedRequest = [client URLRequestWithMethod:@"POST" URL:url parameters:message error:&error];
                    
                    [client sendTwitterRequest:preparedRequest completion:^(NSURLResponse *urlResponse, NSData *responseData, NSError *error)
                     {
                         
                         if(!error)
                         {
                             client = [[Twitter sharedInstance] APIClient];
                             NSError *error;
                             // publish video with status
                             NSString *url = @"https://api.twitter.com/1.1/statuses/update.json";
                             NSMutableDictionary *message = [[NSMutableDictionary alloc] initWithObjectsAndKeys:text,@"status",@"true",@"wrap_links",mediaID, @"media_ids", nil];
                             NSURLRequest *preparedRequest = [client URLRequestWithMethod:@"POST" URL:url parameters:message error:&error];
                             
                             [client sendTwitterRequest:preparedRequest completion:^(NSURLResponse *urlResponse, NSData *responseData, NSError *error)
                              {
                                  //[mProgress hide: YES];
                                  if(!error)
                                  {
                                      NSError *jsonError;
                                      NSDictionary *json = [NSJSONSerialization
                                                            JSONObjectWithData:responseData
                                                            options:0
                                                            error:&jsonError];
                                      NSLog(@"%@", json);
                                      
                                      [[[UIAlertView alloc] initWithTitle:@"Comvo" message:@"Successfully shared a photo to twitter." delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil] show];
                                  }
                                  else
                                  {
                                      NSLog(@"Error: %@", error);
                                  }
                              }];
                         }else{
                             //[mProgress hide: YES];
                             NSLog(@"Error command FINALIZE: %@", error);
                         }
                     }];
                    
                }else{
                    //[mProgress hide: YES];
                    NSLog(@"Error command APPEND: %@", error);
                }
            }];
            
        }else{
            //[mProgress hide: YES];
            NSLog(@"Error command INIT: %@", error);
        }
        
    }];
}


- (void)shareVideoTwitter {
    //mProgress = [MBProgressHUD showHUDAddedTo:[UIApplication sharedApplication].keyWindow animated:YES];
    //mProgress.mode = MBProgressHUDModeIndeterminate;
    //mProgress.labelText = @"Sharing a video...";
    //[mProgress show:YES];
    
    //NSString *text = @"Twitter share video";
    NSString *text = mTextCaption.text;
    NSData* dataVideo = self.mMediaData;
    
    NSString *lengthVideo = [NSString stringWithFormat:@"%d", (int)dataVideo.length];
    NSString* url = @"https://upload.twitter.com/1.1/media/upload.json";
    
    __block NSString *mediaID;
    
    __block TWTRAPIClient *client = [[Twitter sharedInstance] APIClient];
    NSError *error;
    // First call with command INIT
    __block NSDictionary *message =  @{ @"status":text,
                                        @"command":@"INIT",
                                        @"media_type":@"video/mp4",
                                        @"total_bytes":lengthVideo};
    NSURLRequest *preparedRequest = [client URLRequestWithMethod:@"POST" URL:url parameters:message error:&error];
    
    [client sendTwitterRequest:preparedRequest completion:^(NSURLResponse *urlResponse, NSData *responseData, NSError *error){
        
        if(!error){
            NSError *jsonError;
            NSDictionary *json = [NSJSONSerialization
                                  JSONObjectWithData:responseData
                                  options:0
                                  error:&jsonError];
            
            mediaID = [json objectForKey:@"media_id_string"];
            client = [[Twitter sharedInstance] APIClient];
            NSError *error;
            NSString *videoString = [dataVideo base64EncodedStringWithOptions:0];
            // Second call with command APPEND
            message = @{@"command" : @"APPEND",
                        @"media_id" : mediaID,
                        @"segment_index" : @"0",
                        @"media" : videoString};
            
            NSURLRequest *preparedRequest = [client URLRequestWithMethod:@"POST" URL:url parameters:message error:&error];
            
            [client sendTwitterRequest:preparedRequest completion:^(NSURLResponse *urlResponse, NSData *responseData, NSError *error){
                
                if(!error){
                    client = [[Twitter sharedInstance] APIClient];
                    NSError *error;
                    // Third call with command FINALIZE
                    message = @{@"command" : @"FINALIZE",
                                @"media_id" : mediaID};
                    
                    NSURLRequest *preparedRequest = [client URLRequestWithMethod:@"POST" URL:url parameters:message error:&error];
                    
                    [client sendTwitterRequest:preparedRequest completion:^(NSURLResponse *urlResponse, NSData *responseData, NSError *error)
                     {
                         
                         if(!error)
                         {
                             client = [[Twitter sharedInstance] APIClient];
                             NSError *error;
                             // publish video with status
                             NSString *url = @"https://api.twitter.com/1.1/statuses/update.json";
                             NSMutableDictionary *message = [[NSMutableDictionary alloc] initWithObjectsAndKeys:text,@"status",@"true",@"wrap_links",mediaID, @"media_ids", nil];
                             NSURLRequest *preparedRequest = [client URLRequestWithMethod:@"POST" URL:url parameters:message error:&error];
                             
                             [client sendTwitterRequest:preparedRequest completion:^(NSURLResponse *urlResponse, NSData *responseData, NSError *error)
                              {
                                  //[mProgress hide: YES];
                                  if(!error)
                                  {
                                      NSError *jsonError;
                                      NSDictionary *json = [NSJSONSerialization
                                                            JSONObjectWithData:responseData
                                                            options:0
                                                            error:&jsonError];
                                      NSLog(@"%@", json);
                                      
                                      [[[UIAlertView alloc] initWithTitle:@"Comvo" message:@"Successfully shared a video to twitter." delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil] show];
                                  }
                                  else
                                  {
                                      NSLog(@"Error: %@", error);
                                  }
                              }];
                         }else{
                             //[mProgress hide: YES];
                             NSLog(@"Error command FINALIZE: %@", error);
                         }
                     }];
                    
                }else{
                    //[mProgress hide: YES];
                    NSLog(@"Error command APPEND: %@", error);
                }
            }];
            
        }else{
            //[mProgress hide: YES];
            NSLog(@"Error command INIT: %@", error);
        }
        
    }];
}

- (void)shareInstagram{
    if ([self.mMediaType isEqualToString: @"2"])
    {
        //        CGRect rect = CGRectMake(0 ,0 , 0, 0);
        //        NSString  *jpgPath = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/Test.ig"];
        
        //NSURL *igImageHookFile = [[NSURL alloc] initWithString:[[NSString alloc] initWithFormat:@"file://%@", jpgPath]];
        
        NSURL *igImageHookFile = nil;
        if (self.mMediaData) {
            NSString  *jpgPath = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/Test.ig"];
            [self.mMediaData writeToFile:jpgPath atomically:YES];
            igImageHookFile = [NSURL fileURLWithPath:jpgPath];
        } else {
            igImageHookFile = self.mMediaURL;
        }
        
        //        NSLog(@"JPG path %@", jpgPath);
        NSLog(@"URL Path %@", igImageHookFile);
        
        self.docFile.UTI = @"com.instagram.photo";
        self.docFile = [self setupControllerWithURL:igImageHookFile usingDelegate:self];
        self.docFile=[UIDocumentInteractionController interactionControllerWithURL:igImageHookFile];
        
        [self.docFile presentOpenInMenuFromRect: CGRectZero inView: self.view animated: YES ];
    } else if([self.mMediaType isEqualToString: @"3"]) {
        NSString *caption = @"Some Preloaded Caption";
        NSURL *instagramURL = [NSURL URLWithString:[NSString stringWithFormat:@"instagram://library?AssetPath=%@&InstagramCaption=%@",[self.mMediaURL absoluteString],caption]];
        if ([[UIApplication sharedApplication] canOpenURL:instagramURL]) {
            [[UIApplication sharedApplication] openURL:instagramURL];
        }
    }
    else
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Instagram" message:@"Instagram doesn't supports audio sharing." delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
        [alert show];
    }
}

- (IBAction)onTouchInstagramSharing:(id)sender{
    NSLog(@"Instagram Sharing");
    
    [self shareInstagram];
}


- (IBAction)onTouchTumblrSharing:(id)sender{
    NSLog(@"Tumblr Sharing");
    
    //[TMTumblrAppClient createLinkPost:@"Tumblr" URLString:@"http://tumblr.com"
    //                      description:@"Follow the world's creators" tags:@[@"gif", @"lol"] success:successURL
    //                           cancel:cancelURL];
    
    /*[[TMAPIClient sharedInstance] photo:@""
                          filePathArray:@[[[NSBundle mainBundle] pathForResource:@"blue" ofType:@"png"]]
                       contentTypeArray:@[@"image/png"]
                          fileNameArray:@[@"blue.png"]
                             parameters:@{@"caption" : @"Caption"}
                               callback:^(id response, NSError *error) {
                                   if (error)
                                       NSLog(@"Error posting to Tumblr");
                                   else
                                       NSLog(@"Posted to Tumblr");
                               }];*/
    
    [TMTumblrAppClient viewInAppStore];
    
    
}

- (UIDocumentInteractionController *) setupControllerWithURL: (NSURL*) fileURL usingDelegate: (id <UIDocumentInteractionControllerDelegate>) interactionDelegate {
    UIDocumentInteractionController *interactionController = [UIDocumentInteractionController interactionControllerWithURL: fileURL];
    interactionController.delegate = interactionDelegate;
    return interactionController;
}

- (void)documentInteractionControllerWillPresentOpenInMenu:(UIDocumentInteractionController *)controller {
    
}

//===========================================================================================================================================

#pragma mark -
#pragma mark - UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (alertView.tag == 1)
    {
        if (buttonIndex == 0)
        {
            [self shareInstagram];
        }
        
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle: @"Success" message: @"Uploaded a post." delegate: self cancelButtonTitle:@"Ok" otherButtonTitles: nil];
        [Engine setGFlgCommentModified:@"YES"];
        alertView.delegate = self;
        alertView.tag = 2;
        [alertView show];
    }
    if (alertView.tag == 2)
    {
        [self.navigationController popViewControllerAnimated: YES];
    }
    
}
             


@end
