//
//  HLHomeFeedTableViewCell.m
//  BlueLetters
//
//  Created by DeMing Yu on 11/27/14.
//  Copyright (c) 2014 DeMing Yu. All rights reserved.
//

#import "HLCommentTableViewCell.h"

#import "AppEngine.h"
#import "Constants_Comvo.h"

#import <OHAttributedLabel.h>

#import <SDWebImage/UIImageView+WebCache.h>
#import <SDWebImage/UIButton+WebCache.h>

#import <DDProgressView.h>
#import <MediaPlayer/MediaPlayer.h>
#import <CoreMedia/CoreMedia.h>
#import <AVFoundation/AVFoundation.h>

#import <MBProgressHUD.h>

#import "HLCommunication.h"
#import "HLAudioView.h"

static CGFloat messageTextSize = 13.0f;
static CGFloat messageWidth = 323;

@interface HLCommentTableViewCell () <OHAttributedLabelDelegate, AVAudioPlayerDelegate>

@end

@implementation HLCommentTableViewCell

@synthesize delegateComment;
@synthesize mLblCaption;


+(id) sharedCell
{
    HLCommentTableViewCell* cell = nil;
    
    if (IS_IPHONE5) {
        cell = [[[ NSBundle mainBundle ] loadNibNamed:@"HLCommentTableViewCell~iPhone5" owner:nil options:nil] objectAtIndex:0] ;
    }
    else if (IS_IPHONE6) {
        cell = [[[ NSBundle mainBundle ] loadNibNamed:@"HLCommentTableViewCell~iPhone6" owner:nil options:nil] objectAtIndex:0] ;
    }
    else {
        cell = [[[ NSBundle mainBundle ] loadNibNamed:@"HLCommentTableViewCell~iPhone5" owner:nil options:nil] objectAtIndex:0] ;
    }
    
    return cell ;
}

- (void)awakeFromNib {
    // Initialization code
    
    mBtnPhoto.layer.cornerRadius = 20.0f;
    mBtnPhoto.clipsToBounds = YES;
    
    mLblCaption.centerVertically = YES;
    mLblCaption.catchTouchesOnLinksOnTouchBegan = YES;
    mLblCaption.linkColor = [UIColor colorWithRed:52.0/256.0 green:170.0/256.0 blue:220.0/256.0 alpha:1.0];
    mLblCaption.linkUnderlineStyle = 0;
    mLblCaption.backgroundColor = [UIColor clearColor];
    mLblCaption.highlightedLinkColor = [UIColor clearColor];
    mLblCaption.delegate = self;
    
    mProgressView = [[DDProgressView alloc] initWithFrame: CGRectMake(0,
                                                                      4,
                                                                      200.0f,
                                                                      10.0f)];
    [mProgressView setOuterColor: UIColorFromRGB(0x989898)];
    [mProgressView setInnerColor: UIColorFromRGB(0x989898)];
    [mProgressView setProgress: 0.0f];
    [mViewProgress addSubview: mProgressView];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

+ (CGSize)messageSize:(NSString*)message {
    CGRect textRect = [message boundingRectWithSize: CGSizeMake(messageWidth, CGFLOAT_MAX)
                                            options: NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading
                                         attributes: @{NSFontAttributeName: [UIFont fontWithName: @"HelveticaNeue-Medium" size: messageTextSize]}
                                            context: nil];
    
    CGSize size = textRect.size;
    size.height += 5.0f;
    
    return size;
}

+ (CGSize)messageSize:(NSString*)message label:(UILabel *)label {
    CGRect textRect = [message boundingRectWithSize: CGSizeMake(label.frame.size.width, CGFLOAT_MAX)
                                            options: NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading
                                         attributes: @{NSFontAttributeName: label.font}
                                            context: nil];
    
    CGSize size = textRect.size;
    size.height += 5.0f;
    
    return size;
}

- (void)setCommentInfo: (CommentInfo *)cInfo {
    [self setMCommentInfo: cInfo];
    
    [mViewAudio setHidden: YES];
    
    // 1. Photo and User name
    if ([cInfo.mProfilePhoto isEqualToString: @""]) {
        //[mImgViewPhoto setImage: [UIImage imageNamed: @"profile_img_default_regular.png"]];
        [mBtnPhoto setBackgroundImage:[UIImage imageNamed: @"profile_img_default_regular.png"] forState:UIControlStateNormal];
    }
    else {
        //[mImgViewPhoto sd_setImageWithURL: [NSURL URLWithString: [NSString stringWithFormat: @"%@%@", API_HOME, cInfo.mProfilePhoto]] placeholderImage: [UIImage imageNamed: @"profile_img_default_regular.png"]];
        
        [mBtnPhoto sd_setImageWithURL:[NSURL URLWithString: [NSString stringWithFormat: @"%@%@", API_HOME, cInfo.mProfilePhoto]] forState:UIControlStateNormal placeholderImage:[UIImage imageNamed: @"profile_img_default_regular.png"]];
    }
    [mLblUserName setText: cInfo.mFullName];
    
    NSDate *post_date = [NSDate dateWithTimeIntervalSince1970: [cInfo.mCommentDate intValue]];
    NSDate *current_date  = [NSDate date];
    
    
    [mlblTimeAgo setText: [self stringFromTimeInterval: post_date toDate: current_date]];
    
    
    if ([self.mCommentInfo.mCommentType isEqualToString: @"0"]) { // Text
        // 2. adjust caption
        [mLblCaption setAttributedText: [self attributedStringWithUsername: cInfo.mUserName userId: cInfo.mUserId andComment: cInfo.mComment]];
        
        //NSString *str = @"\U0001F431";
        //str = cInfo.mComment;
        
        //NSData *data = [str dataUsingEncoding:NSNonLossyASCIIStringEncoding];
        //NSString *valueUnicode = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        
        
        //NSData *dataa = [valueUnicode dataUsingEncoding:NSUTF8StringEncoding];
        //NSString *valueEmoj = [[NSString alloc] initWithData:dataa encoding:NSNonLossyASCIIStringEncoding];
        
//        _lbl.text = valueEmoj;
//        mLblCaption.text = valueEmoj;
        
        [mLblCaption setFrame: CGRectMake(mLblCaption.frame.origin.x,
                                          mLblCaption.frame.origin.y,
                                          mLblCaption.frame.size.width,
                                          [HLCommentTableViewCell messageSize: cInfo.mComment label:mLblCaption].height + 5)];
        // 3. adjust view
        [self setFrame: CGRectMake(0,
                                   0,
                                   self.frame.size.width,
                                   mLblCaption.frame.origin.y + mLblCaption.frame.size.height)];
    }
    else if ([self.mCommentInfo.mCommentType isEqualToString: @"1"]) { // Audio
        [mViewAudio setHidden: NO];
        [mViewProgress setHidden:YES];
        [mBtnPlay setHidden:YES];
        
        HLAudioView *audioView = [[HLAudioView alloc] initWithFrame:CGRectMake(10.0f, 5.0f, mViewAudio.frame.size.width - 20.0f, 50.0f)];
        audioView.audioURL = [NSURL URLWithString: [NSString stringWithFormat: @"%@%@", API_HOME, self.mCommentInfo.mComment]];
        [mViewAudio addSubview:audioView];
    }
    
    [mBtnDelete setHidden:YES];
    ///////////// Delete Button Show / Hide /////////////////////
    //NSString *strCommentUserID = self.mCommentInfo.mUserId;
    //NSString *strEngineUserID = [Engine gCurrentUser].mUserId;
    
    //if ([strCommentUserID isEqualToString:strEngineUserID]){
    //    [mBtnDelete setHidden:NO];
    //}
    //else
    //{
    //    [mBtnDelete setHidden:YES];
    //}
    /////////////////////////////////////////////////////////////
}

- (NSString *)stringFromTimeInterval: (NSDate *)fromDate toDate: (NSDate *)toDate
{
    NSCalendar *sysCalendar = [NSCalendar currentCalendar];
    unsigned int unitFlags = NSHourCalendarUnit | NSMinuteCalendarUnit | NSDayCalendarUnit | NSMonthCalendarUnit;
    
    NSDateComponents *breakdownInfo = [sysCalendar components: unitFlags fromDate: fromDate toDate: toDate options: 0];
    
    if ([breakdownInfo month] > 0)
    {
        if ([breakdownInfo month] == 1)
            return [NSString stringWithFormat: @"a month ago"];
        else
            return [NSString stringWithFormat: @"%d months ago", (int)[breakdownInfo month]];
    }
    
    if ([breakdownInfo day] > 0)
    {
        if ([breakdownInfo day] == 1)
            return [NSString stringWithFormat: @"a day ago"];
        else
            return [NSString stringWithFormat: @"%d days ago", (int)[breakdownInfo day]];
    }
    
    
    if ([breakdownInfo hour] > 0)
    {
        if ([breakdownInfo hour] == 1)
        {
            return [NSString stringWithFormat: @"an hour ago"];
        }
        else
        {
            return [NSString stringWithFormat: @"%d hours ago", (int)[breakdownInfo hour]];
        }
    }
    
    if ([breakdownInfo minute] > 0)
    {
        if ([breakdownInfo minute] == 1)
        {
            return [NSString stringWithFormat: @"a min ago"];
        }
        else
        {
            return [NSString stringWithFormat: @"%d mins ago", (int)[breakdownInfo minute]];
        }
    }
    
    return @"a min ago";
}

- (NSMutableAttributedString *)attributedStringWithUsername: (NSString *)username userId:(NSString *)userid andComment:(NSString *)comment
{
    NSString *usernameAndComment = [NSString stringWithFormat:@"%@", comment];
    NSMutableAttributedString *fullComment = [NSMutableAttributedString attributedStringWithString:usernameAndComment];
    
    // Set link for username of comment
//    NSString* linkURLString = [NSString stringWithFormat:@"user:%@", userid];
//    if ([username rangeOfString:@" "].location != NSNotFound)
//    {
//        
//    }
//    
//    [fullComment setLink:[NSURL URLWithString:linkURLString] range:NSMakeRange(0, username.length + 1)];
    
    
    // 1. Detect any "@" tags in the comment using the "@\w+" regular expression
    NSRegularExpression* userRegex1 = [NSRegularExpression regularExpressionWithPattern:@"\\B@\\w+" options:0 error:nil];
    [userRegex1 enumerateMatchesInString:usernameAndComment options:0 range:NSMakeRange(0,usernameAndComment.length)
                              usingBlock:^(NSTextCheckingResult *match, NSMatchingFlags flags, BOOL *stop)
     {
         // For each "@xxx" user mention found, add a custom link:
         NSString* user = [[usernameAndComment substringWithRange:match.range] substringFromIndex:1]; // get the matched user name, removing the "@"
         NSString* linkURLString = [NSString stringWithFormat:@"user:%@", user]; // build the "user:" link
         [fullComment setLink:[NSURL URLWithString:linkURLString] range:match.range]; // add it
     }];
    
    
    // 2. Detect any "#" tags in the comment using the "#\w+" regular expression
    NSRegularExpression* userRegex2 = [NSRegularExpression regularExpressionWithPattern:@"\\B#\\w+" options:0 error:nil];
    [userRegex2 enumerateMatchesInString:usernameAndComment options:0 range:NSMakeRange(0,usernameAndComment.length)
                              usingBlock:^(NSTextCheckingResult *match, NSMatchingFlags flags, BOOL *stop)
     {
         // For each "@xxx" user mention found, add a custom link:
         NSString* tagString = [[usernameAndComment substringWithRange:match.range] substringFromIndex:1]; // get the tagged word, removing the "#"
         NSString* linkURLString = [NSString stringWithFormat:@"hashtag:%@", tagString]; // build the "hashtag:" link
         [fullComment setLink:[NSURL URLWithString:linkURLString] range:match.range]; // add it
     }];
    
    // 3. Set font attributes
    [fullComment setFont: [UIFont fontWithName: @"HelveticaNeue" size: 15.0f]];
    [fullComment setTextColor: UIColorFromRGB(0x989898)];
    
    return fullComment;
}

//==========================================================================================================================

#pragma mark -
#pragma mark - Timer

- (void)refreshTimer {
    if ([self.mCommentInfo.mDuration isEqualToString: @"0"]) {
        return;
    }
    
    AVPlayerItem *currentItem = mAudioPlayer.currentItem;
    float currentTime = CMTimeGetSeconds(mAudioPlayer.currentTime);
    float duration = [self.mCommentInfo.mDuration floatValue];
    
    float progress = currentTime / duration;
    
    [mProgressView setProgress: progress];
}


//===============================================================================

#pragma mark -
#pragma mark - Touch Event

- (IBAction)onTouchBtnPlay: (id)sender {
    mFlgPlay = !mFlgPlay;
    
    if (mFlgPlay) {
        AVPlayerItem *playerItem=[[AVPlayerItem alloc] initWithURL: [NSURL URLWithString: [NSString stringWithFormat: @"%@%@", API_HOME, self.mCommentInfo.mComment]]];
        
        mAudioPlayer = [[AVPlayer alloc] initWithPlayerItem:playerItem];
        mAudioPlayer.actionAtItemEnd = AVPlayerActionAtItemEndNone;
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(playerItemDidReachEnd:)
                                                     name:AVPlayerItemDidPlayToEndTimeNotification
                                                   object:[mAudioPlayer currentItem]];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(playerItemPlaybackStalled:)
                                                     name:AVPlayerItemPlaybackStalledNotification
                                                   object:mAudioPlayer];
        
        [mAudioPlayer play];
        
//        mDuringTimer = [NSTimer scheduledTimerWithTimeInterval: 0.1f
//                                                        target: self
//                                                      selector: @selector(refreshTimer)
//                                                      userInfo: nil
//                                                       repeats: YES];
        
        [mProgressView setOuterColor: UIColorFromRGB(0x00AFF0)];
        [mProgressView setInnerColor: UIColorFromRGB(0x00AFF0)];
        [mProgressView setNeedsDisplay];
        
        [mBtnPlay setImage: [UIImage imageNamed: @"comment_img_pause.png"] forState: UIControlStateNormal];
    }
    else {
        [mAudioPlayer pause];
        
        [mProgressView setOuterColor: UIColorFromRGB(0x989898)];
        [mProgressView setInnerColor: UIColorFromRGB(0x989898)];
        [mProgressView setNeedsDisplay];
        
        [mBtnPlay setImage: [UIImage imageNamed: @"comment_img_play.png"] forState: UIControlStateNormal];
    }
}

- (IBAction)onBtnPhotoImg:(id)sender{
    NSLog(@"touched photo image");
    
    [delegateComment didTouchUserName:self userID: self.mCommentInfo.mUserId];
}

- (IBAction)onBtnDelete:(id)sender {
    NSLog(@"Toggled Delete Button");
    
    NSLog(@"Touched Photo Delete Button");
    
    [self showLoading];
    
    NSDictionary *parameters = nil;
    
    void ( ^successed )( id responseObject ) = ^( id responseObject ) {
        NSLog(@"JSON: %@", responseObject);
        
        int result = [[responseObject objectForKey: @"success"] intValue];
        if (result) {
            //NSDictionary *dicData = [responseObject objectForKey: @"data"];
            //NSDictionary *dicUser = [dicData objectForKey: @"user"];
            
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle: @"Comments has been deleted successfully." message: [responseObject valueForKey: @"Success"] delegate: nil cancelButtonTitle: @"Ok" otherButtonTitles: nil];
            [alertView show];
            
            [delegateComment didFinishedDelete: self];
        }
        else {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle: @"Warning" message: [responseObject valueForKey: @"message"] delegate: nil cancelButtonTitle: @"Ok" otherButtonTitles: nil];
            [alertView show];
        }
        
        [mProgress hide: YES];
    };
    
    void ( ^failure )( NSError* error ) = ^( NSError* error ) {
        NSLog(@"Error: %@", error);
        
        [mProgress hide: YES];
    };
    
    NSString *strCommentUserID = self.mCommentInfo.mUserId;
    NSString *strCommentID = self.mCommentInfo.mCommentId;
    
    parameters = @{@"user_id":      strCommentUserID,
                   @"comment_id":   strCommentID};   // Delete Comment ID
    
    [[HLCommunication sharedManager] sendToService: API_DELETECOMMENT params: parameters success: successed failure: failure];
    
}


//===================================================================================

#pragma mark -
#pragma mark - OHAttributedLabelDelegate

-(BOOL)attributedLabel:(OHAttributedLabel *)attributedLabel shouldFollowLink:(NSTextCheckingResult *)linkInfo
{
    if ([[linkInfo.URL scheme] isEqualToString:@"user"])
    {
        // URLs like "user:xxx" will be handled here instead of opening in Safari.
        // Note: in the above example, "xxx" is the 'resourceSpecifier' part of the URL
        NSString* user = [linkInfo.URL resourceSpecifier];
        
        // Prevent the URL from opening in Safari, as we handled it here manually instead
        //        [[NSNotificationCenter defaultCenter] postNotificationName: VIEW_PROFILE
        //                                                            object:user];
        if ([(id)delegateComment respondsToSelector: @selector(didTouchUserName :userName:)])
        {
            [delegateComment didTouchUserName: self userName: user];
        }
        
        // Prevent link from opening in safari, making a call, etc.hashtag
        return NO;
    }
    else if ([[linkInfo.URL scheme] isEqualToString:@"hashtag"])
    {
        // Get storyID from link and pass to notification that view controller will receive
        NSString* hashtag = [linkInfo.URL resourceSpecifier];
        
        if ([(id)delegateComment respondsToSelector: @selector(didTouchHashTag:hashTag:)])
        {
            [delegateComment didTouchHashTag: self hashTag: hashtag];
        }
        
        return NO;
    }
    
    return NO;
}

//==========================================================================================================================

#pragma mark -
#pragma mark - AVPlayer Notification

- (void)playerItemDidReachEnd:(NSNotification *)notification {
    [mProgressView setOuterColor: UIColorFromRGB(0x989898)];
    [mProgressView setInnerColor: UIColorFromRGB(0x989898)];
    [mProgressView setNeedsDisplay];
    
    [mBtnPlay setImage: [UIImage imageNamed: @"comment_img_play.png"] forState: UIControlStateNormal];
}

- (void)playerItemPlaybackStalled: (NSNotification *)notification {
    
}

//==========================================================================================================================

#pragma mark -
#pragma mark - Progress Bar

- (void)showLoading {
    mProgress = [MBProgressHUD showHUDAddedTo:[UIApplication sharedApplication].keyWindow animated:YES];
    mProgress.mode = MBProgressHUDModeIndeterminate;
    mProgress.labelText = @"Deleting...";
    [mProgress show:YES];
}

@end
