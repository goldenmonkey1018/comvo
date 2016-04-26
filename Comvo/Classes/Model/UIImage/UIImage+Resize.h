// UIImage+Resize.h
// Created by Trevor Harmon on 8/5/09.
// Free for personal or commercial use, with or without modification.
// No warranty is expressed or implied.

// Extends the UIImage class to support resizing/cropping

#import <UIKit/UIKit.h>

@interface UIImage (Resize)
- (UIImage *)imageWithOverlay:(UIImage *)overlay OverlayFrame:(CGRect)overlayFrame;
- (UIImage *)croppedImage:(CGRect)bounds;
- (UIImage *)thumbnailImage:(NSInteger)thumbnailSize
          transparentBorder:(NSUInteger)borderSize
               cornerRadius:(NSUInteger)cornerRadius
       interpolationQuality:(CGInterpolationQuality)quality;
- (UIImage *)resizedPhoto;
- (UIImage *)resizedImage;
- (UIImage *)resizedImage:(CGSize)newSize
     interpolationQuality:(CGInterpolationQuality)quality;
- (UIImage *)resizedImageWithContentMode:(UIViewContentMode)contentMode
                                  bounds:(CGSize)bounds
                    interpolationQuality:(CGInterpolationQuality)quality;

//blur filter function
+ (NSArray*) makeKernel:(int)length;
- (UIImage*) gaussianBlur:(NSUInteger)radius;
- (UIImage*) applyConvolve:(NSArray*)kernel;

- (UIImage *)resizedImageforTransform:(CGAffineTransform)transform;
- (UIImage *)resizedImage:(CGSize)newSize
                transform:(CGAffineTransform)transform
           drawTransposed:(BOOL)transpose
     interpolationQuality:(CGInterpolationQuality)quality;
- (CGAffineTransform)transformForOrientation:(CGSize)newSize;

@end
