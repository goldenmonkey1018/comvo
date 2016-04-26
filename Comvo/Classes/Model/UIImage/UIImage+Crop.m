//
//  UIImage+Crop.m
//  PicBounce2
//
//  Created by Brad Smith on 11/27/11.
//  Copyright (c) 2011 Clixtr, Inc. All rights reserved.
//
//  Based on public domain source code found here: http://stackoverflow.com/q/7704399/42323 

#import "UIImage+Crop.h"

@implementation UIImage (Crop)


- (UIImage *)imageCroppedToRect:(CGRect)rect {
    
    UIGraphicsBeginImageContext(rect.size);
    
    CGRect drawRect;
    
    if (self.scale != 1)
        drawRect.size = CGSizeMake(self.size.width * self.scale, self.size.height * self.scale);
    else
        drawRect.size = self.size;
    
    drawRect.origin.x = -rect.origin.x;
    drawRect.origin.y = -rect.origin.y;
    
    [self drawInRect:drawRect];
    
    UIImage *result = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return result;
}

@end
