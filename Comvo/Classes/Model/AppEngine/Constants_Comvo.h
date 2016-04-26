//
//  Contants.h
//  Mingle
//
//  Created by HanLong on 1/3/13.
//  Copyright (c) 2013 hanlonghu. All rights reserved.
//

#ifndef Secretary_Contants_h
#define Secretary_Contants_h

#define IS_IPHONE4 ( (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone && [UIScreen mainScreen].bounds.size.height < 568) ? YES : NO )
#define IS_IPHONE5 ( (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone && [UIScreen mainScreen].bounds.size.height == 568) ? YES : NO )
#define IS_IPHONE6 ( (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone && [UIScreen mainScreen].bounds.size.height > 568) ? YES : NO )
#define SYSTEM_VERSION_LESS_THAN(v) ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedAscending)

#define UIColorFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]

#define kBgQueue dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)

// user defaults
#define kUserDefaultsCurrentLanguageKey         @"_langKey"

#define APP_FONT_NAME                           @"ShowcardGothic"

// lang options
#define kLanguageCodes                          [NSArray arrayWithObjects:@"zh_CN", @"en", @"pt", nil]
#define kLanguages                              [NSArray arrayWithObjects:@"中文(简体)", @"English", @"português", nil]

#define kDefaultLanguage                        @"en"

//#define API_HOME                              @"http://comvo.goartapp.com/webservice/"
#define API_HOME                                @"http://comvo.net/web_service/"
//#define API_HOME                                @"http://192.168.0.157/comvo/webservice/"

#define FILE_HOME                               @"http://comvo.net/"
//#define FILE_HOME                               @"http://comvo.goartapp.com/"
//#define FILE_HOME                               @"http://192.168.0.157/comvo/"

#define API_REGISTER                            @"user_api/register.php"
#define API_LOGIN                               @"user_api/login.php"
#define API_LOGINWITHFACEBOOK                   @"user_api/login_facebook.php"
#define API_FORGOTPASSWORD                      @"user_api/forgotpassword.php"
#define API_NEWNOTIFICATIONCOUNT                @"user_api/check_new_notifications.php"

#define API_SUBMITPOST                          @"post_api/submit_post.php"
#define API_GETSINGLEPOST                       @"post_api/get_single_post.php"
#define API_GETFEED                             @"post_api/get_feed.php"

#define API_LIKEPOST                            @"post_api/like_post.php"
#define API_DELETEPOST                          @"post_api/delete_post.php"
#define API_GETHASHTAGS                         @"post_api/get_hashtags.php"

#define API_GETCOMMENT                          @"comment_api/get_comments.php"
#define API_SUBMITCOMMENT                       @"comment_api/submit_comment.php"
#define API_LIKECOMMENT                         @"comment_api/like_comment.php"
#define API_DELETECOMMENT                       @"comment_api/delete_comment.php"

#define API_GETSINGLEUSER                       @"user_api/get_single_user.php"
#define API_GETNOTIFICATIONS                    @"user_api/get_notifications.php"
#define API_GETNOTIFICATIONS_NEW                @"user_api/get_notifications_new.php"
#define API_GETUSERS                            @"user_api/get_users.php"
#define API_UPDATEPROFILE                       @"user_api/update_profile.php"
#define API_REPORT                              @"user_api/report.php"
#define API_FOLLOWUSER                          @"user_api/follow_user.php"
#define API_SEND_EMAIL                          @"user_api/send_email_toadmin.php"

#define API_CREATEGROUP                         @"chat_api/create_group.php"
#define API_GETCHATHISTORY                      @"chat_api/get_chat_history.php"
#define API_SENDMESSAGE                         @"chat_api/send_message.php"
#define API_READMESSAGE                         @"chat_api/read_message.php"

#define NOTIF_LOGOUT                            @"NOTIF_LOGOUT"

#define CAMERA_MODE_PHOTO                       0
#define CAMERA_MODE_VIDEO                       1
#define CAMERA_MODE_AUDIO                       2

#define NOTIF_DID_FINISH_RECORD_VIDEO           @"NOTIF_DID_FINISH_RECORD_VIDEO"
#define NOTIF_DID_ENTER_BACKGROUND              @"NOTIF_DID_ENTER_BACKGROUND"

// Streaming Page Feed Mode
#define FEED_MODE_FOLLOWING                     0
#define FEED_MODE_POPULAR                       1
#define FEED_MODE_TRENDING                      2

// Profile Page Feed Mode
#define FEED_MODE_PHOTO                         0
#define FEED_MODE_VIDEO                         1
#define FEED_MODE_AUDIO                         2

#endif
