//
//  AppDelegate.h
//  Comvo
//
//  Created by DeMing Yu on 12/22/14.
//  Copyright (c) 2014 DeMing Yu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <FacebookSDK/FacebookSDK.h>
#import "HLHomeViewController.h"

#define AppDel (AppDelegate *)[[UIApplication sharedApplication] delegate]

#define shareAppDelegate [AppDelegate sharedInstance]

#define NOTIFICATION_AZURE_VERSION_CHECKED @"notification azure version checked"

#define theAppDelegate ((AppDelegate *)[[UIApplication sharedApplication] delegate])


@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) UIViewController *callback;

- (void)showHomeViewController;
- (void)sessionStateChanged:(FBSession *)session state:(FBSessionState) state error:(NSError *)error;

@end

