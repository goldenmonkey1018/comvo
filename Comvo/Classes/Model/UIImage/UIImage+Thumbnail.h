//
//  UIImage+Thumbnail.h
//  Cheekie
//
//  Created by Dragon on 12/2/14.
//  Copyright (c) 2014 TangerineStudio. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (Thumbnail)

+ (UIImage *)imageWithImage:(UIImage *)image scaledToFillSize:(CGSize)size;
@end
