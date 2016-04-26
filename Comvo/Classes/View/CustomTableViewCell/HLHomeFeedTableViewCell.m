//
//  HLHomeFeedTableViewCell.m
//  BlueLetters
//
//  Created by DeMing Yu on 11/27/14.
//  Copyright (c) 2014 DeMing Yu. All rights reserved.
//

#import "HLHomeFeedTableViewCell.h"

#import <OHAttributedLabel.h>
#import <AVFoundation/AVFoundation.h>

#import "AppEngine.h"
#import "Constants_Comvo.h"

#import <SDWebImage/UIImageView+WebCache.h>
#import <SDWebImage/UIButton+WebCache.h>
#import <DDProgressView.h>
#import <QuartzCore/QuartzCore.h>

#import "HLCommunication.h"
#import "HLAudioView.h"

#import <MBProgressHUD.h>

static CGFloat messageTextSize = 15.0f;
static CGFloat messageWidth = 253;

@interface HLHomeFeedTableViewCell () <OHAttributedLabelDelegate, UIAlertViewDelegate>

@end

@implementation HLHomeFeedTableViewCell

@synthesize delegate;
@synthesize mPostInfo;


+(id) sharedCell
{
    HLHomeFeedTableViewCell* cell = nil;
    
    if (IS_IPHONE5) {
        cell = [[[ NSBundle mainBundle ] loadNibNamed:@"HLHomeFeedTableViewCell~iPhone5" owner:nil options:nil] objectAtIndex:0] ;
    }
    else if (IS_IPHONE6) {
        cell = [[[ NSBundle mainBundle ] loadNibNamed:@"HLHomeFeedTableViewCell~iPhone6" owner:nil options:nil] objectAtIndex:0] ;
    }
    else {
        cell = [[[ NSBundle mainBundle ] loadNibNamed:@"HLHomeFeedTableViewCell~iPhone5" owner:nil options:nil] objectAtIndex:0] ;
    }
    
    [[NSNotificationCenter defaultCenter] addObserver: cell selector: @selector(didEnterBackground) name: NOTIF_DID_ENTER_BACKGROUND object: nil];
    
    return cell ;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)awakeFromNib {
    // Initialization code
    
    mLblCaption.centerVertically = YES;
    mLblCaption.catchTouchesOnLinksOnTouchBegan = YES;
    mLblCaption.linkColor = UIColorFromRGB(0x00aff0);
    mLblCaption.linkUnderlineStyle = 0;
    mLblCaption.backgroundColor = [UIColor clearColor];
    mLblCaption.highlightedLinkColor = [UIColor clearColor];
    mLblCaption.delegate = self;

    self.mImgViewProfilePhoto.layer.cornerRadius = 20.0f;
    
    mBtnProfilePhoto.layer.cornerRadius = 20.0f;
    mBtnProfilePhoto.clipsToBounds = YES;
    
    mProgressView = [[DDProgressView alloc] initWithFrame: CGRectMake(0,
                                                                      0,
                                                                      mViewProgress.frame.size.width,
                                                                      mViewProgress.frame.size.height)];
    [mProgressView setOuterColor: UIColorFromRGB(0x00AFF0)];
    [mProgressView setInnerColor: UIColorFromRGB(0x00AFF0)];
    [mProgressView setProgress: 0.0f];
    [mViewProgress addSubview: mProgressView];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}


- (void)viewDidLayoutSubviews
{
    if (mAVPlayerLayer) {
        mAVPlayerLayer.frame = mViewVideo.bounds;
    }
}

- (void)setPostInfo:(PostInfo *)postInfo {
    [self setMPostInfo: postInfo];
    
    
    // initialize
    if (mAVPlayer) {
        [mAVPlayer pause];
        [[mViewVideo.layer.sublayers lastObject] removeFromSuperlayer];
        mAVPlayer = nil;
    }
    
    [mBtnAudioPlay setImage: [UIImage imageNamed: @"feed_img_audio_play.png"] forState: UIControlStateNormal];
    
    [mViewAudio setHidden: YES];
    [mViewPhoto setHidden: NO];
    [mBtnPlay setHidden: YES];
    
    //if ([postInfo.mMediaType isEqualToString:@"1"])     // Audio Type
    // {
    //    [mBtnThumbnail setHidden: YES];
    //}
    //else
    //{
    //    [mBtnThumbnail setHidden: NO];
    //}
    
    [mBtnThumbnail setHidden:YES];
    
    [mViewComment.subviews makeObjectsPerformSelector: @selector(removeFromSuperview)];
    
    [mViewOption setFrame: CGRectMake(mViewOption.frame.origin.x,
                                      mViewPhoto.frame.origin.y + mViewPhoto.frame.size.height + 10.0f,
                                      mViewOption.frame.size.width,
                                      mViewOption.frame.size.height)];
    
    // 1. display user photo and name, photo count
    //[mBtnProfilePhoto sd_setImageWithURL: [NSURL URLWithString: [NSString stringWithFormat: @"%@%@", API_HOME, postInfo.mProfilePhoto]] placeholderImage: [UIImage imageNamed: @"profile_img_default_regular.png"]];
    
    [mBtnProfilePhoto sd_setImageWithURL:[NSURL URLWithString: [NSString stringWithFormat: @"%@%@", API_HOME, postInfo.mProfilePhoto]] forState:UIControlStateNormal placeholderImage:[UIImage imageNamed: @"profile_img_default_regular.png"]];
    
    [mBtnUsername setTitle:postInfo.mFullName forState:UIControlStateNormal];
    //[mLblUserName setText: postInfo.mFullName];
    
    NSDate *post_date = [NSDate dateWithTimeIntervalSince1970: [postInfo.mPostDate intValue]];
    NSDate *current_date  = [NSDate date];
    
    //[mLblLocation setText: postInfo.mLocation];
    [mLblLocation setHidden:YES];
    [mLblTime setText: [self stringFromTimeInterval: post_date toDate: current_date]];
    
    // 2. display photo & video thumbnail
    if ([postInfo.mMediaType isEqualToString: @"1"]) { // Audio
        [mViewAudio setHidden: NO];
        [mViewPhoto setHidden: YES];
        
        [mViewOption setFrame: CGRectMake(mViewOption.frame.origin.x,
                                          mViewAudio.frame.origin.y + mViewAudio.frame.size.height + 10.0f,
                                          mViewOption.frame.size.width,
                                          mViewOption.frame.size.height)];
    }
    else if ([postInfo.mMediaType isEqualToString: @"2"]) { // Photo
        [self.mImgViewPhoto sd_setImageWithURL: [NSURL URLWithString: [NSString stringWithFormat: @"%@%@", API_HOME, postInfo.mMedia]]
                         placeholderImage: [UIImage imageNamed: @"common_img_placehold_photo.png"]];
    }
    else if ([postInfo.mMediaType isEqualToString: @"3"]) { // Video
        [self.mImgViewPhoto sd_cancelCurrentImageLoad];
        //self.mImgViewPhoto.image = [UIImage imageNamed: @"common_img_placehold_photo.png"];
        
        [self.mImgViewPhoto sd_setImageWithURL: [NSURL URLWithString: [NSString stringWithFormat: @"%@%@", API_HOME, postInfo.mThumbnail]]
                              placeholderImage: [UIImage imageNamed: @"common_img_placehold_photo.png"]];
        [mBtnPlay setHidden: NO];

        AVURLAsset* asset = [AVURLAsset URLAssetWithURL: [NSURL URLWithString: [NSString stringWithFormat: @"%@%@", API_HOME, postInfo.mMedia]] options:nil];
        
        AVPlayerItem* item = [AVPlayerItem playerItemWithAsset:asset];
        mAVPlayer = [AVPlayer playerWithPlayerItem:item];
        //mAVPlayer.actionAtItemEnd = AVPlayerActionAtItemEndPause;
        mAVPlayer.actionAtItemEnd = AVPlayerActionAtItemEndNone;
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(videoPlayerItemDidReachEnd:)
                                                     name:AVPlayerItemDidPlayToEndTimeNotification
                                                   object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(videoPlayerItemPlaybackStalled:)
                                                     name:AVPlayerItemPlaybackStalledNotification
                                                   object:nil];
        
        AVPlayerLayer* lay = [AVPlayerLayer playerLayerWithPlayer: mAVPlayer];
        lay.frame = mViewVideo.bounds;
        lay.videoGravity = AVLayerVideoGravityResize;
        lay.borderColor = [UIColorFromRGB(0x00AFF0) CGColor];
        [mViewVideo.layer addSublayer:lay];
        mAVPlayerLayer = lay;
    }
    
    if ([self.mPostInfo.mLiked isEqualToString: @"1"]) {
        [mBtnLikesCount setImage: [UIImage imageNamed: @"feed_img_liked.png"] forState: UIControlStateNormal];
        [mBtnLikesCount setTitleColor: UIColorFromRGB(0x00aff0) forState: UIControlStateNormal];
    }
    else {
        [mBtnLikesCount setImage: [UIImage imageNamed: @"feed_img_like.png"] forState: UIControlStateNormal];
        [mBtnLikesCount setTitleColor: UIColorFromRGB(0x989898) forState: UIControlStateNormal];
    }
    
    // 3. Likes and Comments Count  && Delete Button Enabled / Disabled
    [mBtnLikesCount setTitle: [NSString stringWithFormat: @"%@", postInfo.mLikesCount] forState: UIControlStateNormal];
    [mBtnCommentsCount setTitle: [NSString stringWithFormat: @"%@", postInfo.mCommentsCount] forState: UIControlStateNormal];
    
    if (IS_IPHONE6)
    {
        if ([[Engine gCurrentUser].mUserId isEqualToString:mPostInfo.mUserId])
        {
        
            [mBtnDelete setHidden:NO];
            
            [mBtnLikesCount setFrame:CGRectMake(18.0f, 0.0f, 68.0f, 36.0f)];
            [mBtnCommentsCount setFrame:CGRectMake(95.0f, 0.0f, 64.0f, 36.0f)];
            [mBtnDownload setFrame:CGRectMake(175.0f, 0.0f, 33.0f, 33.0f)];
            [mBtnShare setFrame:CGRectMake(250.0f, 0.0f, 33.0f, 33.0f)];
            [mBtnDelete setFrame:CGRectMake(326.0f, 0.0f, 33.0f, 33.0f)];
        }
        else
        {
            [mBtnDelete setHidden:YES];
            
            [mBtnLikesCount setFrame:CGRectMake(18.0f, 0.0f, 68.0f, 36.0f)];
            [mBtnCommentsCount setFrame:CGRectMake(120.0f, 0.0f, 64.0f, 36.0f)];
            [mBtnDownload setFrame:CGRectMake(230.0f, 0.0f, 33.0f, 33.0f)];
            [mBtnShare setFrame:CGRectMake(326.0f, 0.0f, 33.0f, 33.0f)];
        }
    }
    else
    {
        if ([[Engine gCurrentUser].mUserId isEqualToString:mPostInfo.mUserId])
        {
            
            [mBtnDelete setHidden:NO];
            
            [mBtnLikesCount setFrame:CGRectMake(10.0f, 0.0f, 66.0f, 36.0f)];
            [mBtnCommentsCount setFrame:CGRectMake(82.0f, 0.0f, 68.0f, 36.0f)];
            [mBtnDownload setFrame:CGRectMake(154.0f, 0.0f, 33.0f, 33.0f)];
            [mBtnShare setFrame:CGRectMake(212.0f, 0.0f, 33.0f, 33.0f)];
            [mBtnDelete setFrame:CGRectMake(273.0f, 0.0f, 33.0f, 33.0f)];
        }
        else
        {
            [mBtnDelete setHidden:YES];
            
            [mBtnLikesCount setFrame:CGRectMake(10.0f, 0.0f, 66.0f, 36.0f)];
            [mBtnCommentsCount setFrame:CGRectMake(90.0f, 0.0f, 68.0f, 36.0f)];
            [mBtnDownload setFrame:CGRectMake(190.0f, 0.0f, 33.0f, 33.0f)];
            [mBtnShare setFrame:CGRectMake(273.0f, 0.0f, 33.0f, 33.0f)];
        }
    }
    


    // 4. adjust caption and comment view frame
    if ([postInfo.mDescription isEqualToString: @""]) {
        [mLblCaption setFrame: CGRectMake(mLblCaption.frame.origin.x,
                                          mViewOption.frame.origin.y + mViewOption.frame.size.height + 3.0f,
                                          mLblCaption.frame.size.width,
                                          0.0f)];
    }
    else {
        
        CGRect lblFrame = CGRectMake(mLblCaption.frame.origin.x,
                                     mViewOption.frame.origin.y + mViewOption.frame.size.height + 3.0f,
                                     mLblCaption.frame.size.width,
                                     [HLHomeFeedTableViewCell messageSize: postInfo.mDescription].height);
        
        [mLblCaption setFrame: lblFrame];
        
        [mLblCaption setAttributedText: [self attributeStringForCaption: postInfo.mDescription]];
    }
    
    // 5. Comment Frame
    [mViewComment setFrame: CGRectMake(mViewComment.frame.origin.x,
                                       mLblCaption.frame.origin.y + mLblCaption.frame.size.height,
                                       mViewComment.frame.size.width,
                                       [postInfo.mArrComments count] * 80.0f)];
    
    // 6. Comment Items
    CGFloat itemFrameY = 0;
    
    for (long i = 0; i < [postInfo.mArrComments count]; i++)
    {
        CommentInfo *cInfo = [postInfo.mArrComments objectAtIndex: i];
        
        UIView *itemView = [[UIView alloc] initWithFrame: CGRectMake(30.0f,
                                                                     itemFrameY,
                                                                     mViewComment.frame.size.width - 20.0f,
                                                                     80.0f)];
    
        UILabel *lblName = [[UILabel alloc] initWithFrame: CGRectMake(0.0f,                                                                      0.0f, 200.0f, 30.0f)];
        [lblName setFont: [UIFont fontWithName: @"HelveticaNeue-Medium" size: 13.0f]];
        [lblName setTextColor: UIColorFromRGB(0x00aff0)];
        //[lblName setTextColor: UIColorFromRGB(0xee0000)];
        //[lblName setText: cInfo.mFullName];
        [lblName setAttributedText: [self attributeStringForCaption: cInfo.mFullName]];
        [itemView addSubview: lblName];
        
        if ([cInfo.mCommentType isEqualToString: @"0"]) { // Text
            
            OHAttributedLabel *lblComment = [[OHAttributedLabel alloc] initWithFrame: CGRectMake(10.0f,
                                                                                                 30.0f,
                                                                    itemView.frame.size.width - 50.0f,
                                                                                                 50.0f)];
            
            NSLog(@"%f", lblComment.frame.origin.x);
            NSLog(@"%f", lblComment.frame.origin.y);
            NSLog(@"%f", lblComment.frame.size.width);
            NSLog(@"%f", lblComment.frame.size.height);
            
            lblComment.centerVertically = YES;
            lblComment.catchTouchesOnLinksOnTouchBegan = YES;
            lblComment.linkColor = UIColorFromRGB(0x00aff0);
            lblComment.linkUnderlineStyle = 0;
            lblComment.backgroundColor = [UIColor clearColor];
            lblComment.highlightedLinkColor = [UIColor clearColor];
            lblComment.delegate = self;
            
            [lblComment setFont: [UIFont fontWithName: @"HelveticaNeue-Medium" size: 15.0f]];
            [lblComment setTextColor: UIColorFromRGB(0x989898)];
            
            if (cInfo.mComment.length > 150) {
                NSString *abbrevString = [cInfo.mComment substringToIndex:147];
                abbrevString = [abbrevString stringByAppendingString:@"..."];
                cInfo.mComment = abbrevString;
            }
            
            //[lblComment setAttributedText: [self attributeStringForCaption: cInfo.mComment]];
            
            CGRect lblFrame = CGRectMake(lblComment.frame.origin.x,
                                         lblComment.frame.origin.y,
                                         lblComment.frame.size.width,
                                         [HLHomeFeedTableViewCell messageSize: cInfo.mComment label:lblComment].height + 5);
            
            [lblComment setFrame: lblFrame];
            
            [lblComment setAttributedText: [self attributeStringForCaption: cInfo.mComment]];
            [itemView addSubview: lblComment];
            
            CGRect itemFrame = itemView.frame;
            itemFrame.size.height = lblComment.frame.origin.y + lblComment.frame.size.height + 3;
            [itemView setFrame:itemFrame];
            
            itemFrameY = itemFrame.origin.y + itemFrame.size.height;
        }
        
        else if ([cInfo.mCommentType isEqualToString: @"1"]) { // Audio
            
            
            HLAudioView *audioView = [[HLAudioView alloc] initWithFrame:CGRectMake(10.0f, 30.0f, itemView.frame.size.width - 50.0f, 50.0f)];
            audioView.audioURL = [NSURL URLWithString: [NSString stringWithFormat: @"%@%@", API_HOME, cInfo.mComment]];
            [itemView addSubview:audioView];
            
            itemFrameY += 80;
           
//            UIButton *btnPlay = [UIButton buttonWithType: UIButtonTypeCustom];
//            [btnPlay setFrame: CGRectMake(120.0f, 5.0f, 20.0f, 20.0f)];
//            [btnPlay setImage: [UIImage imageNamed: @"comment_img_play.png"] forState: UIControlStateNormal];
//            [itemView addSubview: btnPlay];
//            btnPlay.tag = i;
//            
//            [btnPlay addTarget:self action:@selector(onPlayCommentAudio:) forControlEvents:UIControlEventTouchUpInside];
//            
//            DDProgressView *commentProgressView = [[DDProgressView alloc] initWithFrame: CGRectMake(150.0f, 5.0f, itemView.frame.size.width - 130.0f, 20.0f)];
//            
//            [commentProgressView setOuterColor: UIColorFromRGB(0x989898)];
//            [commentProgressView setInnerColor: UIColorFromRGB(0x989898)];
//            [commentProgressView setProgress: 0.0f];
//            [itemView addSubview: commentProgressView];
        }
        
        [mViewComment addSubview: itemView];
        
        if (itemView.frame.origin.y + itemView.frame.size.height > mViewComment.frame.size.height) {
            CGRect commentFrame = mViewComment.frame;
            commentFrame.size.height += itemView.frame.origin.y + itemView.frame.size.height - mViewComment.frame.size.height;
            mViewComment.frame = commentFrame;
        }
    }
    
    long nCommentViewCnt = postInfo.mCommentsCount.integerValue;
    if (nCommentViewCnt > [postInfo.mArrComments count])
    {
        UIButton *btnViewMore = [[UIButton alloc] initWithFrame:  CGRectMake(10.0f,
                                                                           itemFrameY + 10.0f,
                                                                           200.0f,
                                                                           25.0f)];
        
        [btnViewMore setTitle:@"View More Comments" forState:UIControlStateNormal];
        [btnViewMore setBackgroundColor:[UIColor clearColor]];
        [btnViewMore setTitleColor:UIColorFromRGB(0x00AFF0) forState:UIControlStateNormal];
        [btnViewMore addTarget:self action:@selector(onTouchBtnViewComment:) forControlEvents:UIControlEventTouchUpInside];
        
            CGRect commentFrame = mViewComment.frame;
            commentFrame.size.height = btnViewMore.frame.origin.y + btnViewMore.frame.size.height + 5;
            mViewComment.frame = commentFrame;
        
       
        [mViewComment addSubview: btnViewMore];
    }
    
    [self setFrame: CGRectMake(0,
                               0,
                               self.frame.size.width,
                               mViewComment.frame.origin.y + mViewComment.frame.size.height + 20.0f)];
}

- (NSMutableAttributedString *)attributeStringForCaption: (NSString *)strCaption {
    NSMutableAttributedString *titleAttributedString = [NSMutableAttributedString attributedStringWithString:strCaption];
    
    
    // 1. Detect any "@" tags in the comment using the "@\w+" regular expression
    NSRegularExpression* userRegex1 = [NSRegularExpression regularExpressionWithPattern:@"\\B@\\w+" options:0 error:nil];
    [userRegex1 enumerateMatchesInString:strCaption options:0 range:NSMakeRange(0,strCaption.length)
                              usingBlock:^(NSTextCheckingResult *match, NSMatchingFlags flags, BOOL *stop)
     {
         // For each "@xxx" user mention found, add a custom link:
         NSString* user = [[strCaption substringWithRange:match.range] substringFromIndex:1]; // get the matched user name, removing the "@"
         NSString* linkURLString = [NSString stringWithFormat:@"user:%@", user]; // build the "user:" link
         [titleAttributedString setLink:[NSURL URLWithString:linkURLString] range:match.range]; // add it
     }];
    
    
    // 2. Detect any "#" tags in the comment using the "#\w+" regular expression
    NSRegularExpression* userRegex2 = [NSRegularExpression regularExpressionWithPattern:@"\\B#\\w+" options:0 error:nil];
    [userRegex2 enumerateMatchesInString:strCaption options:0 range:NSMakeRange(0,strCaption.length)
                              usingBlock:^(NSTextCheckingResult *match, NSMatchingFlags flags, BOOL *stop)
     {
         // For each "@xxx" user mention found, add a custom link:
         NSString* tagString = [[strCaption substringWithRange:match.range] substringFromIndex:1]; // get the tagged word, removing the "#"
         NSString* linkURLString = [NSString stringWithFormat:@"hashtag:%@", tagString]; // build the "hashtag:" link
         [titleAttributedString setLink:[NSURL URLWithString:linkURLString] range:match.range]; // add it
     }];
    
    // 3. Set font attributes
    [titleAttributedString setFont: [UIFont fontWithName: @"HelveticaNeue" size: 15.0f]];
    [titleAttributedString setTextColor: UIColorFromRGB(0x989898)];
    
    return titleAttributedString;
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
                                         attributes: @{NSFontAttributeName: [UIFont fontWithName: @"HelveticaNeue-Medium" size: 15.0f]}
                                            context: nil];
    
    CGSize size = textRect.size;
    size.height += 5.0f;
    
    return size;
}

- (void)actionDeletePhoto{
    NSLog(@"Touched Photo Delete Button");
    
    NSLog(@"%@", mPostInfo.mPostId);
    
    [self showLoading];
    
    NSDictionary *parameters = nil;
    
    void ( ^successed )( id responseObject ) = ^( id responseObject ) {
        NSLog(@"JSON: %@", responseObject);
        
        int result = [[responseObject objectForKey: @"success"] intValue];
        if (result) {
            // NSDictionary *dicData = [responseObject objectForKey: @"data"];
            // NSDictionary *dicUser = [dicData objectForKey: @"user"];
            
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle: @"Posting data has been deleted successfully." message: [responseObject valueForKey: @"Success"] delegate: nil cancelButtonTitle: @"Ok" otherButtonTitles: nil];
            [alertView show];
            
            [delegate didTouchedDeleteButton:self];
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
    
    parameters = @{@"user_id":      [Engine gCurrentUser].mUserId,
                   @"post_id":      self.mPostInfo.mPostId,
                   @"media_type":   self.mPostInfo.mMediaType};              // Photo Type
    
    //parameters = @{@"user_id":      [Engine gCurrentUser].mUserId,
    //               @"post_id":      self.mPostInfo.mPostId};
    
    [[HLCommunication sharedManager] sendToService: API_DELETEPOST params: parameters success: successed failure: failure];
}


//===============================================================================

#pragma mark -
#pragma mark - Touch Event

- (IBAction)onTouchBtnViewComment: (id)sender {
    NSLog(@"Btn View Comment");
    [delegate didTouchedComment: self];
}
- (IBAction)onTouchBtnPlay: (id)sender {
    [mBtnPlay setHidden: YES];

    [mAVPlayer play];
}

- (IBAction)onTouchBtnAudioPlay: (id)sender {
    mFlgPlay = !mFlgPlay;
    
    if (mFlgPlay) {
        AVPlayerItem *playerItem=[[AVPlayerItem alloc] initWithURL: [NSURL URLWithString: [NSString stringWithFormat: @"%@%@", API_HOME, self.mPostInfo.mMedia]]];
        
        mAudioPlayer = [[AVPlayer alloc] initWithPlayerItem:playerItem];
        mAudioPlayer.actionAtItemEnd = AVPlayerActionAtItemEndNone;
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(audioPlayerItemDidReachEnd:)
                                                     name:AVPlayerItemDidPlayToEndTimeNotification
                                                   object:[mAudioPlayer currentItem]];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(audioPlayerItemPlaybackStalled:)
                                                     name:AVPlayerItemPlaybackStalledNotification
                                                   object:mAudioPlayer];
        
        [mAudioPlayer play];
        
        mDuringTimer = [NSTimer scheduledTimerWithTimeInterval: 0.05f
                                                        target: self
                                                      selector: @selector(refreshTimer)
                                                      userInfo: nil
                                                       repeats: YES];
        
        [mProgressView setOuterColor: UIColorFromRGB(0x00AFF0)];
        [mProgressView setInnerColor: UIColorFromRGB(0x00AFF0)];
        [mProgressView setNeedsDisplay];
        
        [mBtnAudioPlay setImage: [UIImage imageNamed: @"feed_img_audio_pause.png"] forState: UIControlStateNormal];
    }
    else {
        [mAudioPlayer pause];
        
        [mDuringTimer invalidate];
        
        [mProgressView setOuterColor: UIColorFromRGB(0x989898)];
        [mProgressView setInnerColor: UIColorFromRGB(0x989898)];
        [mProgressView setNeedsDisplay];
        
        [mBtnAudioPlay setImage: [UIImage imageNamed: @"feed_img_audio_play.png"] forState: UIControlStateNormal];
    }
}

- (IBAction)onTouchBtnLike: (id)sender {
    
    
    NSDictionary *parameters = nil;
    [self showLoading];
    
    void ( ^successed )( id responseObject ) = ^( id responseObject ) {
        NSLog(@"JSON: %@", responseObject);
        
        int result = [[responseObject objectForKey: @"success"] intValue];
        if (result) {
            NSDictionary *dicData = [responseObject objectForKey: @"data"];
            
            self.mPostInfo.mLiked = [dicData objectForKey: @"like_state"];
            self.mPostInfo.mLikesCount = [dicData objectForKey: @"likes_count"];
            
            [mBtnLikesCount setTitle: [NSString stringWithFormat: @"%@", self.mPostInfo.mLikesCount] forState: UIControlStateNormal];
            
            if ([self.mPostInfo.mLiked isEqualToString: @"1"]) {
                [mBtnLikesCount setImage: [UIImage imageNamed: @"feed_img_liked.png"] forState: UIControlStateNormal];
                [mBtnLikesCount setTitleColor: UIColorFromRGB(0x00aff0) forState: UIControlStateNormal];
            }
            else {
                [mBtnLikesCount setImage: [UIImage imageNamed: @"feed_img_like.png"] forState: UIControlStateNormal];
                [mBtnLikesCount setTitleColor: UIColorFromRGB(0x989898) forState: UIControlStateNormal];
            }
            
            [mProgress hide: YES];
            [delegate didTouchedLike: self];
        }
        else {
            [mProgress hide: YES];
        }
        [mProgress hide: YES];
    };
    
    void ( ^failure )( NSError* error ) = ^( NSError* error ) {
        NSLog(@"Error: %@", error);
        [mProgress hide: YES];
        
    };
    
    parameters = @{@"user_id":      [Engine gCurrentUser].mUserId,
                   @"post_id":      self.mPostInfo.mPostId};
    
    [[HLCommunication sharedManager] sendToService: API_LIKEPOST params: parameters success: successed failure: failure];
}

- (IBAction)onTouchBtnComment: (id)sender {
    // pause when comment button clicked
    if (mAVPlayer) {
        [self.mImgViewPhoto sd_setImageWithURL: [NSURL URLWithString: [NSString stringWithFormat: @"%@%@", API_HOME, self.mPostInfo.mThumbnail]]
                              placeholderImage: [UIImage imageNamed: @"common_img_placehold_photo.png"]];
        [mAVPlayer pause];
        
        [mAVPlayer seekToTime:CMTimeMakeWithSeconds(0, NSEC_PER_SEC)];
        [mBtnPlay setHidden: NO];
    }
    
    [delegate didTouchedComment: self];
}

- (IBAction)onTouchBtnReport: (id)sender {
    // pause when report button clicked
    if (mAVPlayer) {
        [self.mImgViewPhoto sd_setImageWithURL: [NSURL URLWithString: [NSString stringWithFormat: @"%@%@", API_HOME, self.mPostInfo.mThumbnail]]
                              placeholderImage: [UIImage imageNamed: @"common_img_placehold_photo.png"]];
        [mAVPlayer pause];
        
        [mAVPlayer seekToTime:CMTimeMakeWithSeconds(0, NSEC_PER_SEC)];
        [mBtnPlay setHidden: NO];
    }
    
    [delegate didTouchedReport: self];
}

- (IBAction)onTouchBtnDownload: (id)sender {
    //[delegate didTouchedDownload:self];
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle: @"Download" message: @"Do you want to download?" delegate: self cancelButtonTitle: @"Yes" otherButtonTitles: @"No", nil];
    [alertView show];

}

- (IBAction)onTouchDeleteButton:(id)sender{
    //[delegate didTouchedDeleteButton:self];
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle: @"Delete" message: @"Do you want to really delete your own posting data?" delegate: self cancelButtonTitle: @"Yes" otherButtonTitles: @"No", nil];
    [alertView show];
}

- (IBAction)onPlayCommentAudio:(UIButton *)sender
{
    CommentInfo *comment = mPostInfo.mArrComments[sender.tag];
    
    mFlgCommentPlay = !mFlgCommentPlay;
    
    if (mFlgCommentPlay) {
        
        AVPlayerItem *playerItem=[[AVPlayerItem alloc] initWithURL: [NSURL URLWithString: [NSString stringWithFormat: @"%@%@", API_HOME, comment.mComment]]];
        
        mAudioPlayer = [[AVPlayer alloc] initWithPlayerItem:playerItem];
        mAudioPlayer.actionAtItemEnd = AVPlayerActionAtItemEndNone;
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(audioCommentPlayerItemDidReachEnd:)
                                                     name:AVPlayerItemDidPlayToEndTimeNotification
                                                   object:[mAudioPlayer currentItem]];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(audioCommentPlayerItemPlaybackStalled:)
                                                     name:AVPlayerItemPlaybackStalledNotification
                                                   object:mAudioPlayer];
        
        [mAudioPlayer play];
        
        mDuringTimer = [NSTimer scheduledTimerWithTimeInterval: 0.1f
                                                        target: self
                                                      selector: @selector(refreshCommentTimer)
                                                      userInfo: nil
                                                       repeats: YES];
        
        //[mProgressView setOuterColor: UIColorFromRGB(0x00AFF0)];
        //[mProgressView setInnerColor: UIColorFromRGB(0x00AFF0)];
        //[mProgressView setNeedsDisplay];
        
        [sender setImage: [UIImage imageNamed: @"comment_img_pause.png"] forState: UIControlStateNormal];
    }
    else
    {
        [mAudioPlayer pause];
        
        [mDuringTimer invalidate];
        
        //[mProgressView setOuterColor: UIColorFromRGB(0x989898)];
        //[mProgressView setInnerColor: UIColorFromRGB(0x989898)];
        //[mProgressView setNeedsDisplay];
        
        [sender setImage: [UIImage imageNamed: @"comment_img_play.png"] forState: UIControlStateNormal];
    }
}

- (IBAction)onTouchThumbnail:(id)sender{
    NSLog(@"Touched Thumbnail Button");
    [delegate didTouchedThumbnail: self];
}

- (IBAction)onTouchUsername:(id)sender{
    // pause when username button clicked
    if (mAVPlayer) {
        [self.mImgViewPhoto sd_setImageWithURL: [NSURL URLWithString: [NSString stringWithFormat: @"%@%@", API_HOME, self.mPostInfo.mThumbnail]]
                              placeholderImage: [UIImage imageNamed: @"common_img_placehold_photo.png"]];
        [mAVPlayer pause];
        
        [mAVPlayer seekToTime:CMTimeMakeWithSeconds(0, NSEC_PER_SEC)];
        [mBtnPlay setHidden: NO];
    }
    
    NSLog(@"touched username");
    
    [delegate didTouchedUserName: self userID: mPostInfo.mUserId];
}
- (IBAction)onTouchProfilePhoto:(id)sender{
    // pause when profile photo clicked
    if (mAVPlayer) {
        [self.mImgViewPhoto sd_setImageWithURL: [NSURL URLWithString: [NSString stringWithFormat: @"%@%@", API_HOME, self.mPostInfo.mThumbnail]]
                              placeholderImage: [UIImage imageNamed: @"common_img_placehold_photo.png"]];
        [mAVPlayer pause];
        
        [mAVPlayer seekToTime:CMTimeMakeWithSeconds(0, NSEC_PER_SEC)];
        [mBtnPlay setHidden: NO];
    }
    
    NSLog(@"touched profile photo");
    
    [delegate didTouchedUserName: self userID: mPostInfo.mUserId];
}

//==========================================================================================================================

#pragma mark -
#pragma mark - Timer

- (void)refreshTimer {
    if ([self.mPostInfo.mDuration isEqualToString: @"0"]) {
        return;
    }
    
    float currentTime = CMTimeGetSeconds(mAudioPlayer.currentTime);
    float duration = [self.mPostInfo.mDuration floatValue];
    
    float progress = currentTime / duration;
    
    if (progress > 100.0f)
        [mProgressView setProgress: 0.0f];
    else
        [mProgressView setProgress: progress];
}

- (void)refreshCommentTimer{
    NSLog(@"this");
}



- (void)didEnterBackground {
    if (mFlgPlay) {
        [mAudioPlayer pause];
        
        [mDuringTimer invalidate];
    }
}

//==========================================================================================================================

#pragma mark -
#pragma mark - AVPlayer Notification

- (void)audioPlayerItemDidReachEnd:(NSNotification *)notification {
    [mProgressView setOuterColor: UIColorFromRGB(0x989898)];
    [mProgressView setInnerColor: UIColorFromRGB(0x989898)];
    [mProgressView setNeedsDisplay];
    
    mFlgPlay = !mFlgPlay;
    
    [mBtnAudioPlay setImage: [UIImage imageNamed: @"feed_img_audio_play.png"] forState: UIControlStateNormal];
    
    if (mAudioPlayer && mAudioPlayer.status == AVPlayerItemStatusReadyToPlay) {
        [mAudioPlayer pause];
        [mAudioPlayer seekToTime:CMTimeMakeWithSeconds(0, NSEC_PER_SEC)];
    }
}

- (void)audioPlayerItemPlaybackStalled: (NSNotification *)notification {
    
}


- (void)audioCommentPlayerItemDidReachEnd:(NSNotification *)notification {
    
}

- (void)audioCommentPlayerItemPlaybackStalled: (NSNotification *)notification {
    
}


//===============================================================================

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
        if ([(id)delegate respondsToSelector: @selector(didTouchedUserName:userName:)])
        {
            // pause when username clicked
            if (mAVPlayer) {
                [self.mImgViewPhoto sd_setImageWithURL: [NSURL URLWithString: [NSString stringWithFormat: @"%@%@", API_HOME, self.mPostInfo.mThumbnail]]
                                      placeholderImage: [UIImage imageNamed: @"common_img_placehold_photo.png"]];
                [mAVPlayer pause];
                
                [mAVPlayer seekToTime:CMTimeMakeWithSeconds(0, NSEC_PER_SEC)];
                [mBtnPlay setHidden: NO];
            }
            
            [delegate didTouchedUserName: self userName: user];
        }
        
        // Prevent link from opening in safari, making a call, etc.hashtag
        return NO;
    }
    else if ([[linkInfo.URL scheme] isEqualToString:@"hashtag"])
    {
        // Get storyID from link and pass to notification that view controller will receive
        NSString* hashtag = [linkInfo.URL resourceSpecifier];
        
        if ([(id)delegate respondsToSelector: @selector(didTouchedHashTag:hashTag:)])
        {
            // pause when hashtag clicked
            if (mAVPlayer) {
                [self.mImgViewPhoto sd_setImageWithURL: [NSURL URLWithString: [NSString stringWithFormat: @"%@%@", API_HOME, self.mPostInfo.mThumbnail]]
                                      placeholderImage: [UIImage imageNamed: @"common_img_placehold_photo.png"]];
                [mAVPlayer pause];
                
                [mAVPlayer seekToTime:CMTimeMakeWithSeconds(0, NSEC_PER_SEC)];
                [mBtnPlay setHidden: NO];
            }
            [delegate didTouchedHashTag: self hashTag: hashtag];
        }
        
        return NO;
    }
    
    return NO;
}

//==========================================================================================================================

#pragma mark -
#pragma mark - AVPlayer Notification

- (void)videoPlayerItemDidReachEnd:(NSNotification *)notification {
    //AVPlayerItem *p = [notification object];
    //[p seekToTime:kCMTimeZero];
    //[mAVPlayer pause];
    
    if (mAVPlayer && mAVPlayer.currentItem == notification.object) {
        [self.mImgViewPhoto sd_setImageWithURL: [NSURL URLWithString: [NSString stringWithFormat: @"%@%@", API_HOME, self.mPostInfo.mThumbnail]]
                              placeholderImage: [UIImage imageNamed: @"common_img_placehold_photo.png"]];
        [mAVPlayer pause];
        
        [mAVPlayer seekToTime:CMTimeMakeWithSeconds(0, NSEC_PER_SEC)];
        [mBtnPlay setHidden: NO];
    }
}

- (void)videoPlayerItemPlaybackStalled: (NSNotification *)notification {
    if (mAVPlayer && mAVPlayer.currentItem == notification.object) {
        [mAVPlayer play];
    }
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

- (void)showLoading {
    mProgress = [MBProgressHUD showHUDAddedTo:[UIApplication sharedApplication].keyWindow animated:YES];
    mProgress.mode = MBProgressHUDModeIndeterminate;
    mProgress.labelText = @"";
    [mProgress show:YES];
}

//==========================================================================================================================

#pragma mark -
#pragma mark - UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 0) {
        if ([alertView.title isEqualToString:@"Download"])
        {
            [delegate didTouchedDownload:self];
        }
        else if ([alertView.title isEqualToString:@"Delete"])
        {
            //[delegate didTouchedDeleteButton:self];
            [self actionDeletePhoto];
        }
        
    }
}

@end
