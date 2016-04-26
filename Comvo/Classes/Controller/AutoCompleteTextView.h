//
//  AutoCompleteTextView.h
//  Comvo
//
//  Created by Max Brian on 18/11/15.
//  Copyright (c) 2015 DeMing Yu. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AutoCompleteTextView : UITextView

//Data Arrays
@property (nonatomic, strong) NSArray *usernamesArray;
@property (nonatomic, strong) NSArray *hashtagsArray;

@end
