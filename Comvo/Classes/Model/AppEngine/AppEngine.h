//
//  AppEngine.h
//  Phonder
//

#import <UIKit/UIKit.h>

#import <CoreLocation/CoreLocation.h>

#define Engine  [AppEngine getInstance]

#define LocalizedString(key) \
    [[Engine currentBundle] localizedStringForKey:(key) value:@"" table:nil]

@class EventInfo;
@class PrivacyInfo;
@class UserInfo;
@class UploadInfo;
@class HLHomeViewController;

@interface AppEngine : NSObject
{
   // localization
    NSArray                 * _languages;
    NSString                * _currentLang;
    NSBundle                * _currentBundle;
    
    CLLocationCoordinate2D  gCurrentLocation;
}

@property (nonatomic, retain) NSArray               * languages;
@property (nonatomic, retain) NSString              * currentLang;
@property (nonatomic, retain, readonly) NSBundle    * currentBundle;

@property (nonatomic) CLLocationCoordinate2D     gCurrentLocation;

@property (nonatomic, copy)   UserInfo              * gCurrentUser;
@property (nonatomic, copy)   EventInfo             * gNewEvent;
@property (nonatomic, copy)   PrivacyInfo           * gPrivacy4NE;
@property (nonatomic, copy)   UIImage               * gPicture4NE;

@property (nonatomic, copy)   NSString              * gSearchMode;
@property (nonatomic, copy)   NSString              * gAudioRecordingMode;
@property (nonatomic, copy)   NSString              * gFlgCommentModified;
@property (nonatomic, copy)   NSString              * gDeviceToken;

@property (nonatomic, copy)   NSString              * gNotificationMode;

@property (nonatomic, copy)   NSDictionary          * gDicCategories;
@property (nonatomic, copy)   NSDictionary          * gDicSpecialties;

@property (nonatomic, copy)   NSString              * gSrvTime;
@property (nonatomic, copy)   UploadInfo            * gUploadInfo;

@property (nonatomic, weak) HLHomeViewController *gHomeViewController;

#pragma mark singleton
+ (id)getInstance;

#pragma mark
- (void)setValue:(id)value forKey:(NSString *)key;
- (id)valueForKey:(NSString *)key;

- (void)loadLastLogin;
- (void)logout;
@end

@interface SocialInfo : NSObject

@property (nonatomic, copy) NSString    *mId;
@property (nonatomic, copy) NSString    *mName;
@property (nonatomic, copy) NSString    *mEmail;
@property (nonatomic, copy) NSString    *mPhotoUrl;

-(id)copyWithZone:(NSZone*)zone;

@end

@interface UserInfo : NSObject<NSCoding>

@property (nonatomic, copy) NSString    *mUserId;
@property (nonatomic, copy) NSString    *mUserName;
@property (nonatomic, copy) NSString    *mEmail;
@property (nonatomic, copy) NSString    *mPhotoUrl;
@property (nonatomic, copy) NSString    *mSessToken;
@property (nonatomic, copy) NSString    *mPassword;
@property (nonatomic, copy) NSString    *mFullName;
@property (nonatomic, copy) NSString    *mSpecialty;
@property (nonatomic, copy) NSString    *mMCR;
@property (nonatomic, copy) NSString    *mPhotosCount;
@property (nonatomic, copy) NSString    *mCommentsCount;
@property (nonatomic, copy) NSString    *mFollowingsCount;
@property (nonatomic, copy) NSString    *mFollowersCount;
@property (nonatomic, copy) NSString    *mStatus;
@property (nonatomic, copy) NSString    *mLastLogin;
@property (nonatomic, copy) NSString    *mRegisterDate;
@property (nonatomic, copy) NSString    *mIsFollowing;
@property (nonatomic, copy) NSString    *mLocation;
@property (nonatomic, copy) NSString    *mGreetingAudioUrl;
@property (nonatomic, copy) NSString    *mPostCount;
@property (nonatomic, copy) NSString    *mAudioCount;
@property (nonatomic, copy) NSString    *mVideoCount;

-(id)copyWithZone:(NSZone*)zone;



@end

@interface EventInfo : NSObject {
    NSString    *mWho;
    NSString    *mWhat;
    NSArray     *mArrWhatType;
    NSString    *mWhen;
    NSString    *mWhere;
    NSString    *mWhy;
    NSString    *mTittleNumber;
    PrivacyInfo *mPrivacyInfo;
    UIImage     *mPicture;
}

@property (nonatomic, copy) NSString      *mWho;
@property (nonatomic, copy) NSString      *mWhat;
@property (nonatomic, copy) NSArray       *mArrWhatType;
@property (nonatomic, copy) NSString      *mWhen;
@property (nonatomic, copy) NSString      *mWhere;
@property (nonatomic, copy) NSString      *mWhy;
@property (nonatomic, copy) NSString      *mTittleNumber;
@property (nonatomic, copy) PrivacyInfo   *mPrivacyInfo;
@property (nonatomic, copy) UIImage       *mPicture;

-(id)copyWithZone:(NSZone*)zone;

@end

@interface PrivacyInfo : NSObject {
    NSArray     *mArrPrivacy;
    NSString    *mStrName;
}

@property (nonatomic, copy) NSArray       *mArrPrivacy;
@property (nonatomic, copy) NSString      *mStrName;

@end

@interface PostInfo : NSObject

@property (nonatomic, copy) NSString        *mPostId;
@property (nonatomic, copy) NSString        *mUserId;
@property (nonatomic, copy) NSString        *mDescription;
@property (nonatomic, copy) NSString        *mMedia;
@property (nonatomic, copy) NSString        *mMediaType;
@property (nonatomic, copy) NSString        *mHashTags;
@property (nonatomic, copy) NSString        *mCategoryId;
@property (nonatomic, copy) NSString        *mCommentsCount;
@property (nonatomic, copy) NSString        *mLikesCount;
@property (nonatomic, copy) NSString        *mPostDate;
@property (nonatomic, copy) NSString        *mLiked;
@property (nonatomic, copy) NSString        *mFullName;
@property (nonatomic, copy) NSString        *mUserName;
@property (nonatomic, copy) NSString        *mProfilePhoto;
@property (nonatomic, copy) NSMutableArray  *mArrComments;
@property (nonatomic, copy) NSString        *mDuration;
@property (nonatomic, copy) NSString        *mLocation;
@property (nonatomic, copy) NSString        *mThumbnail;

-(id)copyWithZone:(NSZone*)zone;

@end

@interface CommentInfo : NSObject

@property (nonatomic, copy) NSString        *mCommentId;
@property (nonatomic, copy) NSString        *mUserId;
@property (nonatomic, copy) NSString        *mPostId;
@property (nonatomic, copy) NSString        *mComment;
@property (nonatomic, copy) NSString        *mCommentDate;
@property (nonatomic, copy) NSString        *mFullName;
@property (nonatomic, copy) NSString        *mUserName;
@property (nonatomic, copy) NSString        *mProfilePhoto;
@property (nonatomic, copy) NSString        *mCommentType;
@property (nonatomic, copy) NSString        *mDuration;

-(id)copyWithZone:(NSZone*)zone;

@end

@interface NotificationInfo : NSObject

@property (nonatomic, copy) NSString        *mNotifId;
@property (nonatomic, copy) NSString        *mUserId;
@property (nonatomic, copy) NSString        *mPostId;
@property (nonatomic, copy) NSString        *mNotifType;
@property (nonatomic, copy) NSString        *mNotifUser;
@property (nonatomic, copy) NSString        *mUserName;
@property (nonatomic, copy) NSString        *mFullName;
@property (nonatomic, copy) NSString        *mIsNew;
@property (nonatomic, copy) NSString        *mTotalCount;
@property (nonatomic, copy) NSString        *mProfilePhoto;
@property (nonatomic, copy) NSString        *mPicInfo;
@property (nonatomic, copy) NSString        *mNotifDate;
@property (nonatomic, copy) NSString        *mMediaType;
@property (nonatomic, copy) NSString        *mNewCount;

-(id)copyWithZone:(NSZone*)zone;

@end

@interface UploadInfo : NSObject

@property (nonatomic, copy) NSMutableArray  *mArrPhotos;
@property (nonatomic, copy) NSString        *mStrComment;

-(id)copyWithZone:(NSZone*)zone;

@end

@interface GroupInfo : NSObject

@property (nonatomic, copy) NSString        *mGroupId;
@property (nonatomic, copy) NSString        *mGroupName;
@property (nonatomic, copy) NSMutableArray  *mArrMembers;

-(id)copyWithZone:(NSZone*)zone;

@end