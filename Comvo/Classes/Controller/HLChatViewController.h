//
//  HLMessagesViewController.h
//  TheReveal
//
//  Created by Max Broeckel on 1/5/15.
//  Copyright (c) 2015 Max Broeckel. All rights reserved.
//

#import <JSQMessages.h>

@class GroupInfo;

@interface HLChatViewController : JSQMessagesViewController {
    NSMutableArray              *mArrMessages;
    NSString                    *mLastPointer;
    NSMutableDictionary         *mDicUsers;
    
    NSTimer                     *mTimer;
    BOOL                        mIsFirst;
    BOOL                        mIsMessageSending;
}

@property (nonatomic, copy) GroupInfo    *mGroupInfo;

@end
