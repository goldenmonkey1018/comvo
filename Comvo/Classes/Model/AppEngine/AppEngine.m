//
//  AppEngine.m
//  Phonder
//

#import "AppEngine.h"
#import "Constants_Comvo.h"

@implementation AppEngine

@synthesize languages       = _languages;
@synthesize currentLang     = _currentLang;
@synthesize currentBundle   = _currentBundle;

@synthesize gCurrentLocation;

#pragma mark singleton

+ (id)getInstance
{
    static AppEngine * instance = nil;
    if (!instance)
    {
        instance = [[AppEngine alloc] init];
    }
    return instance;
}

#pragma mark getters/setters

- (void)setGCurrentUser:(UserInfo *)gCurrentUser
{
    _gCurrentUser = [gCurrentUser copy];
    if (_gCurrentUser) {
        [[NSUserDefaults standardUserDefaults] setObject:[NSKeyedArchiver archivedDataWithRootObject:_gCurrentUser] forKey:@"CurrentUser"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    //
}

- (void)loadLastLogin
{
    NSData *loginData = [[NSUserDefaults standardUserDefaults] objectForKey:@"CurrentUser"];
    _gCurrentUser = [NSKeyedUnarchiver unarchiveObjectWithData:loginData];
}
- (void)logout
{
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"CurrentUser"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    _gCurrentUser = nil;
}

- (void)setCurrentLang:(NSString *)lang
{
    _currentLang = lang;
    
    _currentBundle = [[NSBundle alloc] initWithPath:[[NSBundle mainBundle] pathForResource:self.currentLang ofType:@"lproj"]];
    
    [[NSUserDefaults standardUserDefaults] setObject:self.currentLang forKey:kUserDefaultsCurrentLanguageKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

#pragma mark init

- (id)init
{
    if (self = [super init])
    {
        self.languages = kLanguageCodes;
        NSString * lang = [[NSUserDefaults standardUserDefaults] valueForKey:kUserDefaultsCurrentLanguageKey];
        self.currentLang = lang ? lang : kDefaultLanguage;
    }
    return self;
}

#pragma mark -
#pragma mark BLL general

- (void)setValue:(id)value forKey:(NSString *)key
{
    [[NSUserDefaults standardUserDefaults] setValue:value forKey:key];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (id)valueForKey:(NSString *)key
{
    return [[NSUserDefaults standardUserDefaults] valueForKey:key];
}

@end

@implementation SocialInfo

@synthesize mId;
@synthesize mName;
@synthesize mEmail;
@synthesize mPhotoUrl;

-(id)copyWithZone:(NSZone*)zone
{
    SocialInfo *socialCopy = [[SocialInfo allocWithZone: zone] init];
    
    socialCopy.mId            = self.mId;
    socialCopy.mName          = self.mName;
    socialCopy.mEmail         = self.mEmail;
    socialCopy.mPhotoUrl      = self.mPhotoUrl;
    
    return socialCopy;
}

@end

@implementation UserInfo

@synthesize mUserId;
@synthesize mUserName;
@synthesize mEmail;
@synthesize mPhotoUrl;
@synthesize mSessToken;
@synthesize mPassword;
@synthesize mFullName;
@synthesize mSpecialty;
@synthesize mMCR;
@synthesize mPhotosCount;
@synthesize mCommentsCount;
@synthesize mFollowingsCount;
@synthesize mFollowersCount;
@synthesize mStatus;
@synthesize mLastLogin;
@synthesize mRegisterDate;
@synthesize mIsFollowing;
@synthesize mLocation;
@synthesize mGreetingAudioUrl;
@synthesize mPostCount;
@synthesize mAudioCount;
@synthesize mVideoCount;

-(id)copyWithZone:(NSZone*)zone
{
    UserInfo *userCopy = [[UserInfo allocWithZone: zone] init];
    
    userCopy.mUserId            = self.mUserId;
    userCopy.mUserName          = self.mUserName;
    userCopy.mEmail             = self.mEmail;
    userCopy.mPhotoUrl          = self.mPhotoUrl;
    userCopy.mSessToken         = self.mSessToken;
    userCopy.mPassword          = self.mPassword;
    userCopy.mFullName          = self.mFullName;
    userCopy.mSpecialty         = self.mSpecialty;
    userCopy.mMCR               = self.mMCR;
    userCopy.mPhotosCount       = self.mPhotosCount;
    userCopy.mCommentsCount     = self.mCommentsCount;
    userCopy.mFollowingsCount   = self.mFollowingsCount;
    userCopy.mFollowersCount    = self.mFollowersCount;
    userCopy.mStatus            = self.mStatus;
    userCopy.mLastLogin         = self.mLastLogin;
    userCopy.mRegisterDate      = self.mRegisterDate;
    userCopy.mIsFollowing       = self.mIsFollowing;
    userCopy.mLocation          = self.mLocation;
    userCopy.mGreetingAudioUrl  = self.mGreetingAudioUrl;
    userCopy.mPostCount       = self.mPostCount;
    userCopy.mAudioCount        = self.mAudioCount;
    userCopy.mVideoCount        = self.mVideoCount;
    
    return userCopy;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
#warning TODO:
    [aCoder encodeObject:self.mUserId forKey:@"mUserId"];
    [aCoder encodeObject:self.mUserName forKey:@"mUserName"];
    [aCoder encodeObject:self.mEmail forKey:@"mEmail"];
    [aCoder encodeObject:self.mPhotoUrl forKey:@"mPhotoUrl"];
    [aCoder encodeObject:self.mSessToken forKey:@"mSessToken"];
    [aCoder encodeObject:self.mPassword forKey:@"mPassword"];
    [aCoder encodeObject:self.mFullName forKey:@"mFullName"];
    [aCoder encodeObject:self.mSpecialty forKey:@"mSpecialty"];
    [aCoder encodeObject:self.mMCR forKey:@"mMCR"];
    [aCoder encodeObject:self.mPhotosCount forKey:@"mPhotosCount"];
    [aCoder encodeObject:self.mCommentsCount forKey:@"mCommentsCount"];
    [aCoder encodeObject:self.mFollowingsCount forKey:@"mFollowingsCount"];
    [aCoder encodeObject:self.mFollowersCount forKey:@"mFollowersCount"];
    [aCoder encodeObject:self.mStatus forKey:@"mStatus"];
    [aCoder encodeObject:self.mLastLogin forKey:@"mLastLogin"];
    [aCoder encodeObject:self.mRegisterDate forKey:@"mRegisterDate"];
    [aCoder encodeObject:self.mIsFollowing forKey:@"mIsFollowing"];
    [aCoder encodeObject:self.mLocation forKey:@"mLocation"];
    [aCoder encodeObject:self.mGreetingAudioUrl forKey:@"mGreetingAudioUrl"];
    [aCoder encodeObject:self.mPostCount forKey:@"mPostCount"];
    [aCoder encodeObject:self.mAudioCount forKey:@"mAudioCount"];
    [aCoder encodeObject:self.mVideoCount forKey:@"mVideoCount"];
    
}
- (id)initWithCoder:(NSCoder *)aDecoder
{
#warning TODO:
    self = [super init];
    
    self.mUserId =      [aDecoder decodeObjectForKey:@"mUserId"];
    self.mUserName =    [aDecoder decodeObjectForKey:@"mUserName"];
    self.mEmail =       [aDecoder decodeObjectForKey:@"mEmail"];
    self.mPhotoUrl =    [aDecoder decodeObjectForKey:@"mPhotoUrl"];
    self.mSessToken =   [aDecoder decodeObjectForKey:@"mSessToken"];
    self.mPassword =    [aDecoder decodeObjectForKey:@"mPassword"];
    self.mFullName =    [aDecoder decodeObjectForKey:@"mFullName"];
    self.mSpecialty =   [aDecoder decodeObjectForKey:@"mSpecialty"];
    self.mMCR =         [aDecoder decodeObjectForKey:@"mMCR"];
    self.mPhotosCount = [aDecoder decodeObjectForKey:@"mPhotosCount"];
    self.mCommentsCount = [aDecoder decodeObjectForKey:@"mCommentsCount"];
    self.mFollowingsCount = [aDecoder decodeObjectForKey:@"mFollowingsCount"];
    self.mFollowersCount = [aDecoder decodeObjectForKey:@"mFollowersCount"];
    self.mLastLogin =   [aDecoder decodeObjectForKey:@"mLastLogin"];
    self.mRegisterDate = [aDecoder decodeObjectForKey:@"mRegisterDate"];
    self.mIsFollowing = [aDecoder decodeObjectForKey:@"mIsFollowing"];
    self.mLocation =    [aDecoder decodeObjectForKey:@"mLocation"];
    self.mGreetingAudioUrl = [aDecoder decodeObjectForKey:@"mGreetingAudioUrl"];
    self.mPostCount =   [aDecoder decodeObjectForKey:@"mPostCount"];
    self.mAudioCount =  [aDecoder decodeObjectForKey:@"mAudioCount"];
    self.mVideoCount =  [aDecoder decodeObjectForKey:@"mVideoCount"];
    
    return self;
}


@end

@implementation EventInfo

@synthesize mWho;
@synthesize mWhat;
@synthesize mArrWhatType;
@synthesize mWhen;
@synthesize mWhere;
@synthesize mWhy;
@synthesize mTittleNumber;
@synthesize mPrivacyInfo;
@synthesize mPicture;

-(id)copyWithZone:(NSZone*)zone
{
    EventInfo *eventCopy = [[EventInfo allocWithZone: zone] init];
    
    eventCopy.mWho      = self.mWho;
    eventCopy.mWhat     = self.mWhat;
    eventCopy.mArrWhatType = self.mArrWhatType;
    eventCopy.mWhen     = self.mWhen;
    eventCopy.mWhere    = self.mWhere;
    eventCopy.mWhy      = self.mWhy;
    eventCopy.mTittleNumber = self.mTittleNumber;
    eventCopy.mPrivacyInfo = self.mPrivacyInfo;
    eventCopy.mPicture  = self.mPicture;
    
    return eventCopy;
}

@end

@implementation PrivacyInfo

@synthesize mArrPrivacy;
@synthesize mStrName;

-(id)copyWithZone:(NSZone*)zone
{
    PrivacyInfo *privacyCopy = [[PrivacyInfo allocWithZone: zone] init];
    
    privacyCopy.mArrPrivacy = self.mArrPrivacy;
    privacyCopy.mStrName = self.mStrName;
    
    return privacyCopy;
}

@end

@implementation PostInfo

@synthesize mPostId;
@synthesize mUserId;
@synthesize mDescription;
@synthesize mMedia;
@synthesize mMediaType;
@synthesize mHashTags;
@synthesize mCategoryId;
@synthesize mCommentsCount;
@synthesize mLikesCount;
@synthesize mPostDate;
@synthesize mLiked;
@synthesize mFullName;
@synthesize mUserName;
@synthesize mProfilePhoto;
@synthesize mArrComments;
@synthesize mDuration;
@synthesize mLocation;
@synthesize mThumbnail;


-(id)copyWithZone:(NSZone*)zone {
    PostInfo *postCopy = [[PostInfo allocWithZone: zone] init];
    
    postCopy.mPostId            = self.mPostId;
    postCopy.mUserId            = self.mUserId;
    postCopy.mDescription       = self.mDescription;
    postCopy.mMedia             = self.mMedia;
    postCopy.mMediaType         = self.mMediaType;
    postCopy.mHashTags          = self.mHashTags;
    postCopy.mCategoryId        = self.mCategoryId;
    postCopy.mCommentsCount     = self.mCommentsCount;
    postCopy.mLikesCount        = self.mLikesCount;
    postCopy.mPostDate          = self.mPostDate;
    postCopy.mLiked             = self.mLiked;
    postCopy.mFullName          = self.mFullName;
    postCopy.mUserName          = self.mUserName;
    postCopy.mProfilePhoto      = self.mProfilePhoto;
    postCopy.mArrComments       = self.mArrComments;
    postCopy.mDuration          = self.mDuration;
    postCopy.mLocation          = self.mLocation;
    postCopy.mThumbnail         = self.mThumbnail;
    
    return postCopy;
}

@end

@implementation CommentInfo

@synthesize mCommentId;
@synthesize mUserId;
@synthesize mPostId;
@synthesize mComment;
@synthesize mCommentDate;
@synthesize mFullName;
@synthesize mUserName;
@synthesize mProfilePhoto;
@synthesize mCommentType;
@synthesize mDuration;

-(id)copyWithZone:(NSZone*)zone {
    CommentInfo *commentCopy = [[CommentInfo allocWithZone: zone] init];
    
    commentCopy.mCommentId      = self.mCommentId;
    commentCopy.mUserId         = self.mUserId;
    commentCopy.mPostId         = self.mPostId;
    commentCopy.mComment        = self.mComment;
    commentCopy.mCommentDate    = self.mCommentDate;
    commentCopy.mFullName       = self.mFullName;
    commentCopy.mUserName       = self.mUserName;
    commentCopy.mProfilePhoto   = self.mProfilePhoto;
    commentCopy.mCommentType    = self.mCommentType;
    commentCopy.mDuration       = self.mDuration;
    
    return commentCopy;
}


@end

@implementation NotificationInfo

@synthesize mNotifId;
@synthesize mUserId;
@synthesize mPostId;
@synthesize mNotifType;
@synthesize mNotifUser;
@synthesize mUserName;
@synthesize mFullName;
@synthesize mIsNew;
@synthesize mNewCount;
@synthesize mTotalCount;
@synthesize mProfilePhoto;
@synthesize mPicInfo;
@synthesize mNotifDate;
@synthesize mMediaType;

-(id)copyWithZone:(NSZone*)zone {
    NotificationInfo *notifCopy = [[NotificationInfo allocWithZone: zone] init];
    
    notifCopy.mNotifId          = self.mNotifId;
    notifCopy.mUserId           = self.mUserId;
    notifCopy.mPostId           = self.mPostId;
    notifCopy.mNotifType        = self.mNotifType;
    notifCopy.mNotifUser        = self.mNotifUser;
    notifCopy.mUserName         = self.mUserName;
    notifCopy.mFullName         = self.mFullName;
    notifCopy.mIsNew            = self.mIsNew;
    notifCopy.mTotalCount       = self.mTotalCount;
    notifCopy.mProfilePhoto     = self.mProfilePhoto;
    notifCopy.mPicInfo          = self.mPicInfo;
    notifCopy.mNotifDate        = self.mNotifDate;
    notifCopy.mMediaType        = self.mMediaType;
    notifCopy.mNewCount         = self.mNewCount;
    
    return notifCopy;
}

@end

@implementation UploadInfo

@synthesize mArrPhotos;
@synthesize mStrComment;

-(id)copyWithZone:(NSZone*)zone {
    UploadInfo *uploadCopy = [[UploadInfo allocWithZone: zone] init];
    
    uploadCopy.mArrPhotos          = self.mArrPhotos;
    uploadCopy.mStrComment           = self.mStrComment;
    
    return uploadCopy;
}

@end

@implementation GroupInfo

@synthesize mGroupId;
@synthesize mGroupName;
@synthesize mArrMembers;

-(id)copyWithZone:(NSZone*)zone {
    GroupInfo *groupCopy = [[GroupInfo allocWithZone: zone] init];
    
    groupCopy.mGroupId      = self.mGroupId;
    groupCopy.mGroupName    = self.mGroupName;
    groupCopy.mArrMembers   = self.mArrMembers;
    
    return groupCopy;
}

@end