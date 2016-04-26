//
//  UIImage+Thumbnail.m
//  Cheekie
//
//  Created by Dragon on 12/2/14.
//  Copyright (c) 2014 TangerineStudio. All rights reserved.
//

#import "UIImage+Thumbnail.h"

@implementation UIImage (Thumbnail)
+ (UIImage *)imageWithImage:(UIImage *)image scaledToFillSize:(CGSize)size
{
    CGFloat scale = MAX(size.width/image.size.width, size.height/image.size.height);
    CGFloat width = image.size.width * scale;
    CGFloat height = image.size.height * scale;
    CGRect imageRect = CGRectMake((size.width - width)/2.0f,
                                  (size.height - height)/2.0f,
                                  width,
                                  height);
    
    UIGraphicsBeginImageContextWithOptions(size, NO, 0);
    [image drawInRect:imageRect];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}

@end
