//
//  UIImage+Color.m
//  Cheekie
//
//  Created by dragon on 11/20/14.
//  Copyright (c) 2014 TangerineStudio. All rights reserved.
//

#import "UIImage+Color.h"
#import <UIKit/UIKit.h>

@implementation UIImage (Color)

- (UIColor *)averageColor
{
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    unsigned char rgba[4];
    
    CGContextRef context = CGBitmapContextCreate(rgba, 1, 1, 8, 4, colorSpace, kCGImageAlphaPremultipliedLast | kCGBitmapByteOrder32Big);
    
    CGFloat width = CGImageGetWidth(self.CGImage) * 0.2;
    CGFloat height = CGImageGetHeight(self.CGImage) * 0.2;
    
    CGContextScaleCTM(context, 1, -1);
    CGContextTranslateCTM(context, 0, -height);
    CGContextDrawImage(context, CGRectMake(0, 0, width, height), self.CGImage);
    CGColorSpaceRelease(colorSpace);
    CGContextRelease(context);
    
    if (rgba[3] > 0)
    {
        CGFloat alpha = ((CGFloat)rgba[3]) / 255.0;
        CGFloat multiplier = alpha/255.0;
        return [UIColor colorWithRed:((CGFloat)rgba[0]) * multiplier
                               green:((CGFloat)rgba[1]) * multiplier
                                blue:((CGFloat)rgba[2]) * multiplier
                               alpha:alpha];
    }
    else
    {
        return [UIColor colorWithRed:((CGFloat)rgba[0]) / 255.0
                               green:((CGFloat)rgba[1]) / 255.0
                                blue:((CGFloat)rgba[2]) / 255.0
                               alpha:((CGFloat)rgba[3]) / 255.0];
    }
}

- (UIColor *)shadowColor
{
    UIGraphicsBeginImageContextWithOptions((CGSize){1,1}, NO, 0);
    [self drawInRect:(CGRect){0,0,1,1}];
    UIImage *img = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    CGImageRef imageRef = [img CGImage];
    CGDataProviderRef dataProviderRef = CGImageGetDataProvider(imageRef);
    NSData *pixelData = (__bridge_transfer NSData *)CGDataProviderCopyData(dataProviderRef);
    
    if ([pixelData length] > 0) {
        const UInt8 *pixelBytes = [pixelData bytes];
        
        // Whether or not the image format is opaque, the first byte is always the alpha component, followed by RGB.
        uint8_t pixelR = pixelBytes[1];
        uint8_t pixelG = pixelBytes[2];
        uint8_t pixelB = pixelBytes[3];
        
        // Calculate the perceived luminance of the pixel; the human eye favors green, followed by red, then blue.
        double percievedLuminance = 1 - (((0.299 * pixelR) + (0.587 * pixelG) + (0.114 * pixelB)) / 255);
        
        return [UIColor colorWithWhite:(CGFloat)percievedLuminance alpha:1];
    }
    
    return [UIColor grayColor];
}

@end
