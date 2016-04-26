//
//  AppDelegate.m
//  Comvo
//
//  Created by DeMing Yu on 12/22/14.
//  Copyright (c) 2014 DeMing Yu. All rights reserved.
//

#import "AppDelegate.h"
#import "AppEngine.h"

#import <IQKeyboardManager.h>


#import "HLLoginViewController.h"
#import "HLBroadcastViewController.h"
#import "Constants_Comvo.h"

#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <PubNub/PubNub.h>
#import <Fabric/Fabric.h>
#import <TwitterKit/TwitterKit.h>

@import AVFoundation;

@interface AppDelegate () <PNObjectEventListener>

// Stores reference on PubNub client to make sure what it won't be released.
@property (nonatomic) PubNub *client;

@end

@implementation AppDelegate

@synthesize callback;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    [[Twitter sharedInstance] startWithConsumerKey:@"XvlZM8Vngtkwm3UEaB7mbmcyV" consumerSecret:@"FifbBtywfZdhwILtYKg8lg2EU0gdgCEthxsfyObtWEL0rzVzSf"];
    [Fabric with:@[[Twitter sharedInstance]]];
    
    // Override point for customization after application launch.
    //Enabling keyboard manager
    [[IQKeyboardManager sharedManager] setEnable:YES];
    
    [[IQKeyboardManager sharedManager] setKeyboardDistanceFromTextField:15];
    //Enabling autoToolbar behaviour. If It is set to NO. You have to manually create UIToolbar for keyboard.
    [[IQKeyboardManager sharedManager] setEnableAutoToolbar:YES];
    
    //Setting toolbar behavious to IQAutoToolbarBySubviews. Set it to IQAutoToolbarByTag to manage previous/next according to UITextField's tag property in increasing order.
    [[IQKeyboardManager sharedManager] setToolbarManageBehaviour:IQAutoToolbarBySubviews];
    
    //Resign textField if touched outside of UITextField/UITextView.
    [[IQKeyboardManager sharedManager] setShouldResignOnTouchOutside:YES];
    
    //Giving permission to modify TextView's frame
    [[IQKeyboardManager sharedManager] setCanAdjustTextView:YES];

    
    // Whenever a person opens the app, check for a cached session
    if (FBSession.activeSession.state == FBSessionStateCreatedTokenLoaded) {
        
        // If there's one, just open the session silently, without showing the user the login UI
        [FBSession openActiveSessionWithReadPermissions:@[@"public_profile", @"email"]
                                           allowLoginUI:NO
                                      completionHandler:^(FBSession *session, FBSessionState state, NSError *error) {
                                          // Handler for session state changes
                                          // This method will be called EACH time the session state changes,
                                          // also for intermediate states and NOT just when the session open
                                          [self sessionStateChanged:session state:state error:error];
                                      }];
    }
    
    [self registerNotification];
    
    /////////////////////////////////////////////////////////////////////////////////////////////
    // PubNub Configuration
    
    PNConfiguration *configuration = [PNConfiguration configurationWithPublishKey:
                                                    @"pub-c-187568dd-d400-45ad-978a-1cd1df6282f3"
                                          subscribeKey:@"sub-c-bd2323ea-82a2-11e5-a643-02ee2ddab7fe"];
    self.client = [PubNub clientWithConfiguration:configuration];
    [self.client addListener:self];
    [self.client subscribeToChannels: @[@"my_channel"] withPresence:YES];
    [self.client unsubscribeFromChannels:@[@"my channel1", @"my channel2"] withPresence:NO];
    
    /////////////////////////////////////////////////////////////////////////////////////////////
    
    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayAndRecord error:nil];
    [[AVAudioSession sharedInstance] overrideOutputAudioPort:AVAudioSessionPortOverrideSpeaker error:NULL];
    
    [[FBSDKApplicationDelegate sharedInstance] application:application
                                    didFinishLaunchingWithOptions:launchOptions];
    
    return YES;
    
}

- (void)showHomeViewController {
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    
    UINavigationController *streamNavigationVC = (UINavigationController *)[storyboard instantiateViewControllerWithIdentifier:@"StreamNavigationVC"];
    UINavigationController *searchNavigationVC = (UINavigationController *)[storyboard instantiateViewControllerWithIdentifier:@"SearchNavigationVC"];
    UINavigationController *broadcastNavigationVC = (UINavigationController *)[storyboard instantiateViewControllerWithIdentifier:@"BroadCastNavigationController"];
    UINavigationController *notificationNavigationVC = (UINavigationController *)[storyboard instantiateViewControllerWithIdentifier:@"NotificationNavigationVC"];
    UINavigationController *profileNavigationVC = (UINavigationController *)[storyboard instantiateViewControllerWithIdentifier:@"ProfileNavigationVC"];
    
    
    HLHomeViewController *tabBarController = [[HLHomeViewController alloc] init];
    [tabBarController setViewControllers:@[streamNavigationVC, searchNavigationVC,
                                           broadcastNavigationVC, notificationNavigationVC, profileNavigationVC]];
    tabBarController.delegate = tabBarController;
    [(UINavigationController *)self.window.rootViewController pushViewController:tabBarController animated:YES];
    
    UIImage *finishedImage = [UIImage imageNamed:@"tabbar_selected_background"];
    UIImage *unfinishedImage = [UIImage imageNamed:@"tabbar_normal_background"];
    NSArray *tabBarItemImages = @[@"tab_img_stream_iphone6", @"tab_img_search_iphone6", @"tab_img_broadcast_iphone6", @"tab_img_notification_iphone6", @"tab_img_profile_iphone6"];
    NSArray *tabBarItemSelectedImages = @[@"tab_img_stream_selected_iphone6", @"tab_img_search_selected_iphone6", @"tab_img_broadcast_selected_iphone6", @"tab_img_notification_selected_iphone6", @"tab_img_profile_selected_iphone6"];
    
    RDVTabBar *tabBar = [tabBarController tabBar];
    
    [tabBar setFrame:CGRectMake(CGRectGetMinX(tabBar.frame), CGRectGetMinY(tabBar.frame), CGRectGetWidth(tabBar.frame), 63)];
    
    NSInteger index = 0;
    for (RDVTabBarItem *item in [[tabBarController tabBar] items]) {
        [item setBackgroundSelectedImage:finishedImage withUnselectedImage:unfinishedImage];
        
        UIImage *selectedimage = [UIImage imageNamed:tabBarItemSelectedImages[index]];
        UIImage *unselectedimage = [UIImage imageNamed:tabBarItemImages[index]];
        [item setFinishedSelectedImage:selectedimage withFinishedUnselectedImage:unselectedimage];

        index++;
    }
}

- (void)registerNotification {
    
    UIApplication *application = [UIApplication sharedApplication];
    
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 80000
    if ([UIApplication instancesRespondToSelector:@selector(registerUserNotificationSettings:)]) {
        [application registerUserNotificationSettings:[UIUserNotificationSettings settingsForTypes:(UIUserNotificationTypeSound | UIUserNotificationTypeAlert | UIUserNotificationTypeBadge) categories:nil]];
        [application registerForRemoteNotifications];
    } else {
        [application registerForRemoteNotificationTypes:
         (UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeAlert | UIRemoteNotificationTypeSound)];
    }
#else
    // use registerForRemoteNotifications
    [[UIApplication sharedApplication] registerForRemoteNotificationTypes:
     (UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound | UIRemoteNotificationTypeAlert)];
#endif
}

- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url{
    NSString *host = url.host;
    
    BOOL success = [host isEqualToString:@"success"];
    BOOL cancelled = [host isEqualToString:@"cancelled"];
    
    if (success || cancelled) {
        [[[UIAlertView alloc] initWithTitle:success ? @"Posted to Tumblr" : @"Tumblr post cancelled"
                                    message:success ? @"Your post was successful" : @"Your post was cancelled"
                                   delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil] show];
        
        return YES;
    }
    
    return NO;
}

- (void)application:(UIApplication*)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData*)deviceToken
{
    NSMutableString *tokenString = [NSMutableString stringWithString:[[deviceToken description] uppercaseString]];
    
    [tokenString replaceOccurrencesOfString:@"<" withString:@"" options:0 range:NSMakeRange(0, tokenString.length)];
    
    [tokenString replaceOccurrencesOfString:@">" withString:@"" options:0 range:NSMakeRange(0, tokenString.length)];
    
    [tokenString replaceOccurrencesOfString:@" " withString:@"" options:0 range:NSMakeRange(0, tokenString.length)];
    
    [[NSUserDefaults standardUserDefaults] setValue:tokenString forKey:@"devToken"];
    
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    [Engine setGDeviceToken: tokenString];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"UpdateDeviceToken" object:nil];
    
    // Save tokenString to web server DB
    
    NSLog(@"My token is: %@", deviceToken);
}

- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
    NSLog(@"%@", error.localizedDescription);
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
    NSLog(@"%@", userInfo);
    
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle: @"Received" message:userInfo[@"aps"][@"alert"] delegate: self cancelButtonTitle: @"Ok" otherButtonTitles: nil];
    [alertView show];
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    
    [[NSNotificationCenter defaultCenter] postNotificationName: NOTIF_DID_ENTER_BACKGROUND object: nil];
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    [FBSDKAppEvents activateApp];
    
    [FBAppCall handleDidBecomeActive];
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

- (BOOL)application:(UIApplication *)application
            openURL:(NSURL *)url
            sourceApplication:(NSString *)sourceApplication
            annotation:(id)annotation
{
    BOOL result = [[FBSDKApplicationDelegate sharedInstance] application:application
                                                                 openURL:url
                                                       sourceApplication:sourceApplication
                                                              annotation:annotation
                   ];
    
    if (result) {
        return result;
    }
    return [FBAppCall handleOpenURL:url sourceApplication:sourceApplication];
}
    
// This method will handle ALL the session state changes in the app
- (void)sessionStateChanged:(FBSession *)session state:(FBSessionState) state error:(NSError *)error
{
    // If the session was opened successfully
    if (!error && state == FBSessionStateOpen){
        NSLog(@"Session opened");
        // Show the user the logged-in UI
        [self userLoggedIn];
        return;
    }
    if (state == FBSessionStateClosed || state == FBSessionStateClosedLoginFailed){
        // If the session is closed
        NSLog(@"Session closed");
        // Show the user the logged-out UI
        [self userLoggedOut];
    }
    
    // Handle errors
    if (error){
        NSLog(@"Error");
        NSString *alertText;
        NSString *alertTitle;
        // If the error requires people using an app to make an action outside of the app in order to recover
        if ([FBErrorUtility shouldNotifyUserForError:error] == YES){
            alertTitle = @"Something went wrong";
            alertText = [FBErrorUtility userMessageForError:error];
            [self showMessage:alertText withTitle:alertTitle];
        } else {
            
            // If the user cancelled login, do nothing
            if ([FBErrorUtility errorCategoryForError:error] == FBErrorCategoryUserCancelled) {
                NSLog(@"User cancelled login");
                
                // Handle session closures that happen outside of the app
            } else if ([FBErrorUtility errorCategoryForError:error] == FBErrorCategoryAuthenticationReopenSession){
                alertTitle = @"Session Error";
                alertText = @"Your current session is no longer valid. Please log in again.";
                [self showMessage:alertText withTitle:alertTitle];
                
                // Here we will handle all other errors with a generic error message.
                // We recommend you check our Handling Errors guide for more information
                // https://developers.facebook.com/docs/ios/errors/
            } else {
                //Get more error information from the error
                NSDictionary *errorInformation = [[[error.userInfo objectForKey:@"com.facebook.sdk:ParsedJSONResponseKey"] objectForKey:@"body"] objectForKey:@"error"];
                
                // Show the user an error message
                alertTitle = @"Something went wrong";
                alertText = [NSString stringWithFormat:@"Please retry. \n\n If the problem persists contact us and mention this error code: %@", [errorInformation objectForKey:@"message"]];
                [self showMessage:alertText withTitle:alertTitle];
            }
        }
        // Clear this token
        [FBSession.activeSession closeAndClearTokenInformation];
        // Show the user the logged-out UI
        [self userLoggedOut];
    }
}

// Show the user the logged-out UI
- (void)userLoggedOut
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if ([defaults objectForKey:@"FBAccessTokenKey"]) {
        [defaults removeObjectForKey:@"FBAccessTokenKey"];
        [defaults removeObjectForKey:@"FBExpirationDateKey"];
        [defaults synchronize];
    }
}

// Show the user the logged-in UI
- (void)userLoggedIn
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:[[FBSession.activeSession accessTokenData] accessToken] forKey:@"FBAccessTokenKey"];
    [defaults setObject:[[FBSession.activeSession accessTokenData] expirationDate] forKey:@"FBExpirationDateKey"];
    [defaults synchronize];
    
    [(HLLoginViewController*)self.callback facebookLoaded];
}

// Show an alert message
- (void)showMessage:(NSString *)text withTitle:(NSString *)title
{
    [[[UIAlertView alloc] initWithTitle:title
                                message:text
                               delegate:self
                      cancelButtonTitle:@"OK!"
                      otherButtonTitles:nil] show];
}

/**********************************************************************************************************************/

#pragma mark -
#pragma mark - PubNub Delegate


//////////////////////////////   PubNub  Delegate //////////////////////////////////////////
- (void) client:(PubNub *)client didReceiveMessage:(PNMessageResult *)message{
    // Handle new message stored in message.data.message
    
    if (message.data.actualChannel) {
        
        // Message has been received on channel group stored in
        // message.data.subscribedChannel
    }
    else {
        // Message has been received on channel stored in
        // message.data.subscribedChannel
    }
    
    NSLog(@"Received message: %@ on channel %@ at %@", message.data.message,
          message.data.subscribedChannel, message.data.timetoken);
}

- (void) client:(PubNub *)client didReceiveStatus:(PNSubscribeStatus *)status{
    if (status.category == PNUnexpectedDisconnectCategory) {
        // This event happens when radio / connectivity is lost
    }
    
    else if (status.category == PNConnectedCategory) {
        
        // Connect event. You can do stuff like publish, and know you'll get it.
        // Or just use the connected event to confirm you are subscribed for
        // UI / internal notifications, etc
        
        [self.client publish: @"Hello from the PubNub Objective-C SDK" toChannel:@"my_channel"
              withCompletion:^(PNPublishStatus *status) {
                  
                  // Check whether request successfully completed or not.
                  if (!status.isError) {
                      
                      // Message successfully published to specified channel.
                  }
                  // Request processing failed.
                  else {
                      
                      // Handle message publish error. Check 'category' property to find out possible issue
                      // because of which request did fail.
                      //
                      // Request can be resent using: [status retry];
                  }
              }];
        
        /////////////////////////// timeWithCompletion //////////////////////////////////
        [self.client timeWithCompletion:^(PNTimeResult *result, PNErrorStatus *status) {
            // Check whether request successfully completed or not.
            if (!status.isError) {
                
                // Handle downloaded server time token using: result.data.timetoken
            }
            // Request processing failed.
            else {
                
                // Handle time token download error. Check 'category' property to find
                // out possible issue because of which request did fail.
                //
                // Request can be resent using: [status retry];
            }
        }];
        
        //////////////////////////////////// Publish ////////////////////////////////////////
        [self.client publish:@"Hello from PubNub iOS!" toChannel:@"my_channel" storeInHistory:YES withCompletion:^(PNPublishStatus *status) {
            // Check whether request successfully completed or not.
            if (!status.isError) {
                
                // Message successfully published to specified channel.
            }
            // Request processing failed.
            else {
                
                // Handle message publish error. Check 'category' property to find out possible issue
                // because of which request did fail.
                //
                // Request can be resent using: [status retry];
            }
        }];
        
        /////////////////////////////////// Here Now //////////////////////////////////////
        [self.client hereNowForChannel: @"my_channel" withVerbosity:PNHereNowUUID
                            completion:^(PNPresenceChannelHereNowResult *result,
                                         PNErrorStatus *status) {
                                
            // Check whether request successfully completed or not.
            if (!status.isError) {
                                    
            // Handle downloaded presence information using:
            //   result.data.uuids - list of uuids.
            //   result.data.occupancy - total number of active subscribers.
            }
            // Request processing failed.
            else {
                // Handle presence audit error. Check 'category' property to find
                // out possible issue because of which request did fail.
                //
                // Request can be resent using: [status retry];
            }
        }];
        
        /////////////////////////// Stoarge and Playback ////////////////////////////
        [self.client historyForChannel:@"my channel" start:nil end:nil limit:100 withCompletion:^(PNHistoryResult *result, PNErrorStatus *status) {
            // Check whether request successfully completed or not.
            if (!status.isError) {
                
                // Handle downloaded history using:
                //   result.data.start - oldest message time stamp in response
                //   result.data.end - newest message time stamp in response
                //   result.data.messages - list of messages
            }
            // Request processing failed.
            else {
                
                // Handle message history download error. Check 'category' property to find
                // out possible issue because of which request did fail.
                //
                // Request can be resent using: [status retry];
            }
        }];
    }
    else if (status.category == PNReconnectedCategory) {
        
        // Happens as part of our regular operation. This event happens when
        // radio / connectivity is lost, then regained.
    }
    else if (status.category == PNDecryptionErrorCategory) {
        
        // Handle messsage decryption error. Probably client configured to
        // encrypt messages and on live data feed it received plain text.
    }
}

- (void) client:(PubNub *)client didReceivePresenceEvent:(PNPresenceEventResult *)event{
    // Handle presence event event.data.presenceEvent (one of: join, leave, timeout,
    // state-change).
    
    if (event.data.actualChannel) { //message.data.actualChannel
        
        // Presence event has been received on channel group stored in
        // event.data.subscribedChannel
    }
    else {
        
        // Presence event has been received on channel stored in
        // event.data.subscribedChannel
    }
    NSLog(@"Did receive presence event: %@", event.data.presenceEvent);
}

@end
