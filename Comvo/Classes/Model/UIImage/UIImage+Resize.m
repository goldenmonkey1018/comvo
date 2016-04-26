// UIImage+Resize.m
// Created by Trevor Harmon on 8/5/09.
// Free for personal or commercial use, with or without modification.
// No warranty is expressed or implied.

#import "UIImage+Resize.h"
#import "UIImage+RoundedCorner.h"
#import "UIImage+Alpha.h"

#define SAFECOLOR(color) MIN(255,MAX(0,color))


@implementation UIImage (Resize)

// Returns a copy of this image that is cropped to the given bounds.
// The bounds will be adjusted using CGRectIntegral.
// This method ignores the image's imageOrientation setting.
- (UIImage *)croppedImage:(CGRect)bounds {
    CGImageRef imageRef = CGImageCreateWithImageInRect([self CGImage], bounds);
    UIImage *croppedImage = [UIImage imageWithCGImage:imageRef];
    CGImageRelease(imageRef);
    return croppedImage;
}

// Returns a copy of this image that is squared to the thumbnail size.
// If transparentBorder is non-zero, a transparent border of the given size will be added around the edges of the thumbnail. (Adding a transparent border of at least one pixel in size has the side-effect of antialiasing the edges of the image when rotating it using Core Animation.)

- (UIImage *)thumbnailImage:(NSInteger)thumbnailSize
          transparentBorder:(NSUInteger)borderSize
               cornerRadius:(NSUInteger)cornerRadius
       interpolationQuality:(CGInterpolationQuality)quality {
    UIImage *resizedImage = [self resizedImageWithContentMode:UIViewContentModeScaleAspectFill
                                                       bounds:CGSizeMake(thumbnailSize, thumbnailSize)
                                         interpolationQuality:quality];
    
    // Crop out any part of the image that's larger than the thumbnail size
    // The cropped rect must be centered on the resized image
    // Round the origin points so that the size isn't altered when CGRectIntegral is later invoked
    CGRect cropRect = CGRectMake(round((resizedImage.size.width - thumbnailSize) / 2),
                                 round((resizedImage.size.height - thumbnailSize) / 2),
                                 thumbnailSize,
                                 thumbnailSize);
    UIImage *croppedImage = [resizedImage croppedImage:cropRect];
    
    UIImage *transparentBorderImage = borderSize ? [croppedImage transparentBorderImage:borderSize] : croppedImage;

    return cornerRadius ? [transparentBorderImage roundedCornerImage:cornerRadius borderSize:borderSize] : transparentBorderImage;
}

- (UIImage *)resizedImage
{
    BOOL drawTransposed;
    
    CGSize newSize = [self size];
    
    switch (self.imageOrientation) {
        case UIImageOrientationLeft:
        case UIImageOrientationLeftMirrored:
        case UIImageOrientationRight:
        case UIImageOrientationRightMirrored:
            drawTransposed = YES;
            break;
            
        default:
            drawTransposed = NO;
    }
    
    return [self resizedImage:newSize
                    transform:[self transformForOrientation:newSize]
               drawTransposed:drawTransposed
         interpolationQuality:kCGInterpolationHigh];
}

- (UIImage *)resizedPhoto
{
    BOOL drawTransposed;
    
    CGSize newSize = [self size];
    
    CGFloat scale;
    if (newSize.width < newSize.height)
    {
        scale =  newSize.width / 640;
    }
    else
        scale =  newSize.height / 640;
    
    if (scale > 1)
    {
        newSize.width /= scale;
        newSize.height /= scale;
    }
    
    
    switch (self.imageOrientation) {
        case UIImageOrientationLeft:
        case UIImageOrientationLeftMirrored:
        case UIImageOrientationRight:
        case UIImageOrientationRightMirrored:
            drawTransposed = YES;
            break;
            
        default:
            drawTransposed = NO;
    }
    
    return [self resizedImage:newSize
                    transform:[self transformForOrientation:newSize]
               drawTransposed:drawTransposed
         interpolationQuality:kCGInterpolationHigh];
}

// Returns a rescaled copy of the image, taking into account its orientation
// The image will be scaled disproportionately if necessary to fit the bounds specified by the parameter
- (UIImage *)resizedImage:(CGSize)newSize interpolationQuality:(CGInterpolationQuality)quality {
    BOOL drawTransposed;
    
    switch (self.imageOrientation) {
        case UIImageOrientationLeft:
        case UIImageOrientationLeftMirrored:
        case UIImageOrientationRight:
        case UIImageOrientationRightMirrored:
            drawTransposed = YES;
            break;
            
        default:
            drawTransposed = NO;
    }
    
    return [self resizedImage:newSize
                    transform:[self transformForOrientation:newSize]
               drawTransposed:drawTransposed
         interpolationQuality:quality];
}

// Resizes the image according to the given content mode, taking into account the image's orientation
- (UIImage *)resizedImageWithContentMode:(UIViewContentMode)contentMode
                                  bounds:(CGSize)bounds
                    interpolationQuality:(CGInterpolationQuality)quality {
    CGFloat horizontalRatio = bounds.width / self.size.width;
    CGFloat verticalRatio = bounds.height / self.size.height;
    CGFloat ratio;
    
    switch (contentMode) {
        case UIViewContentModeScaleAspectFill:
            ratio = MAX(horizontalRatio, verticalRatio);
            break;
            
        case UIViewContentModeScaleAspectFit:
            ratio = MIN(horizontalRatio, verticalRatio);
            break;
            
        default:
            [NSException raise:NSInvalidArgumentException format:@"Unsupported content mode: %d", (int)contentMode];
    }
    
    CGSize newSize = CGSizeMake(self.size.width * ratio, self.size.height * ratio);
    
    return [self resizedImage:newSize interpolationQuality:quality];
}


- (UIImage *)imageWithOverlay:(UIImage *)overlay OverlayFrame:(CGRect)overlayFrame
{
    
    CGSize newSize = [self size];
    CGRect newRect = CGRectIntegral(CGRectMake(0, 0, newSize.width, newSize.height));
    CGImageRef imageRef = self.CGImage;
    CGContextRef bitmap = CGBitmapContextCreate(NULL,
                                                newRect.size.width,
                                                newRect.size.height,
                                                CGImageGetBitsPerComponent(imageRef),
                                                0,
                                                CGImageGetColorSpace(imageRef),
                                                CGImageGetBitmapInfo(imageRef));
    
    if (bitmap == NULL)
    {
        NSUInteger bytesPerPixel = 4;
        NSUInteger bytesPerRow = bytesPerPixel * newSize.width;
        NSUInteger bitsPerComponent = 8;
        CGColorSpaceRef newColorSpace = CGColorSpaceCreateDeviceRGB();
        
        bitmap = CGBitmapContextCreate(NULL,
                                       newSize.width,
                                       newSize.height,
                                       bitsPerComponent,
                                       bytesPerRow,
                                       newColorSpace,
                                       kCGBitmapByteOrderDefault | kCGImageAlphaPremultipliedFirst);
        CGColorSpaceRelease(newColorSpace);
    }
    
    CGContextDrawImage(bitmap, newRect, imageRef);
    CGContextDrawImage(bitmap, overlayFrame, [overlay CGImage]);
    
    // Get the resized image from the context and a UIImage
    CGImageRef newImageRef = CGBitmapContextCreateImage(bitmap);
    UIImage *newImage = [UIImage imageWithCGImage:newImageRef];
    
    // Clean up
    CGContextRelease(bitmap);
    CGImageRelease(newImageRef);
    
    return newImage;

}
#pragma mark -
#pragma mark Private helper methods

- (UIImage *)resizedImageforTransform:(CGAffineTransform)transform
{
    
    CGSize newSize = CGSizeApplyAffineTransform(self.size, transform);
    newSize.width = fabs(newSize.width);
    newSize.height = fabs(newSize.height);
    CGRect newRect = CGRectIntegral(CGRectMake(0, 0, newSize.width, newSize.height));
    
    CGImageRef imageRef = self.CGImage;
    
    // Build a context that's the same dimensions as the new size
    CGContextRef bitmap = CGBitmapContextCreate(NULL,
                                                newRect.size.width,
                                                newRect.size.height,
                                                CGImageGetBitsPerComponent(imageRef),
                                                0,
                                                CGImageGetColorSpace(imageRef),
                                                CGImageGetBitmapInfo(imageRef));
    
    if (bitmap == NULL)
    {
        NSUInteger bytesPerPixel = 4;
        NSUInteger bytesPerRow = bytesPerPixel *  newRect.size.width;
        NSUInteger bitsPerComponent = 8;
        CGColorSpaceRef newColorSpace = CGColorSpaceCreateDeviceRGB();
        
        bitmap = CGBitmapContextCreate(NULL,
                                       newRect.size.width,
                                       newRect.size.height,
                                       bitsPerComponent,
                                       bytesPerRow,
                                       newColorSpace,
                                       kCGBitmapByteOrderDefault | kCGImageAlphaPremultipliedFirst);
        CGColorSpaceRelease(newColorSpace);
    }
    
    // Rotate and/or flip the image if required by its orientation
    CGContextConcatCTM(bitmap, transform);
    
        
    //CGContextSetInterpolationQuality(bitmap, kCGInterpolationHigh);
    
    // Draw into the context; this scales the image
    CGContextDrawImage(bitmap, CGRectMake(0, 0, newSize.width, newSize.height), imageRef);
    
    // Get the resized image from the context and a UIImage
    CGImageRef newImageRef = CGBitmapContextCreateImage(bitmap);
    UIImage *newImage = [UIImage imageWithCGImage:newImageRef];
    
    // Clean up
    CGContextRelease(bitmap);
    CGImageRelease(newImageRef);
    
    return newImage;
}

// Returns a copy of the image that has been transformed using the given affine transform and scaled to the new size
// The new image's orientation will be UIImageOrientationUp, regardless of the current image's orientation
// If the new size is not integral, it will be rounded up
- (UIImage *)resizedImage:(CGSize)newSize
                transform:(CGAffineTransform)transform
           drawTransposed:(BOOL)transpose
     interpolationQuality:(CGInterpolationQuality)quality {
    CGRect newRect = CGRectIntegral(CGRectMake(0, 0, newSize.width, newSize.height));
    CGRect transposedRect = CGRectMake(0, 0, newRect.size.height, newRect.size.width);
    CGImageRef imageRef = self.CGImage;
    
    // Build a context that's the same dimensions as the new size
    
    
    CGContextRef bitmap;
    
    CGColorSpaceRef newColorSpace = NULL;
    
    bitmap = CGBitmapContextCreate(NULL,
                                   newRect.size.width,
                                   newRect.size.height,
                                   CGImageGetBitsPerComponent(imageRef),
                                   0,
                                   CGImageGetColorSpace(imageRef),
                                   CGImageGetBitmapInfo(imageRef));
    if (bitmap == NULL)
    {
        NSUInteger bytesPerPixel = 4;
        NSUInteger bytesPerRow = bytesPerPixel * newRect.size.width;
        NSUInteger bitsPerComponent = 8;
        newColorSpace = CGColorSpaceCreateDeviceRGB();
        
        bitmap = CGBitmapContextCreate(NULL,
                                       newRect.size.width,
                                       newRect.size.height,
                                       bitsPerComponent,
                                       bytesPerRow,
                                       newColorSpace,
                                       kCGBitmapByteOrderDefault | kCGImageAlphaPremultipliedFirst);
        CGColorSpaceRelease(newColorSpace);
    }
    
    // Rotate and/or flip the image if required by its orientation
    CGContextConcatCTM(bitmap, transform);
    
    // Set the quality level to use when rescaling
    CGContextSetInterpolationQuality(bitmap, quality);
    
    //CGContextSetInterpolationQuality(bitmap, kCGInterpolationHigh);
    
    // Draw into the context; this scales the image
    CGContextDrawImage(bitmap, transpose ? transposedRect : newRect, imageRef);
    
    // Get the resized image from the context and a UIImage
    CGImageRef newImageRef = CGBitmapContextCreateImage(bitmap);
    UIImage *newImage = [UIImage imageWithCGImage:newImageRef];
    
    // Clean up
    CGContextRelease(bitmap);
    CGImageRelease(newImageRef);
    
    return newImage;
}

// Returns an affine transform that takes into account the image orientation when drawing a scaled image
- (CGAffineTransform)transformForOrientation:(CGSize)newSize {
    CGAffineTransform transform = CGAffineTransformIdentity;
    
    if (self.imageOrientation == UIImageOrientationDown ||
        self.imageOrientation == UIImageOrientationDownMirrored)
    {
        transform = CGAffineTransformTranslate(transform, newSize.width, newSize.height);
        transform = CGAffineTransformRotate(transform, M_PI);
    }
    else if (self.imageOrientation == UIImageOrientationLeft ||
             self.imageOrientation == UIImageOrientationLeftMirrored)
    {
        transform = CGAffineTransformTranslate(transform, newSize.width, 0);
        transform = CGAffineTransformRotate(transform, M_PI_2);
    }
    else if (self.imageOrientation == UIImageOrientationRight ||
             self.imageOrientation == UIImageOrientationRightMirrored)
    {
        transform = CGAffineTransformTranslate(transform, 0, newSize.height);
        transform = CGAffineTransformRotate(transform, -M_PI_2);
    }
    
    if (self.imageOrientation == UIImageOrientationUpMirrored ||
        self.imageOrientation == UIImageOrientationDownMirrored)
    {
        transform = CGAffineTransformTranslate(transform, newSize.width, 0);
        transform = CGAffineTransformScale(transform, -1, 1);
    }
    else if (self.imageOrientation == UIImageOrientationLeftMirrored ||
             self.imageOrientation == UIImageOrientationRightMirrored)
    {
        transform = CGAffineTransformTranslate(transform, newSize.height, 0);
        transform = CGAffineTransformScale(transform, -1, 1);
    }
        
    return transform;
}


#pragma mark blur filter function 
- (UIImage*) gaussianBlur:(NSUInteger)radius
{
	// Pre-calculated kernel
	//	double dKernel[5][5]={ 
	//		{1.0f/273.0f, 4.0f/273.0f, 7.0f/273.0f, 4.0f/273.0f, 1.0f/273.0f},
	//		{4.0f/273.0f, 16.0f/273.0f, 26.0f/273.0f, 16.0f/273.0f, 4.0f/273.0f},
	//		{7.0f/273.0f, 26.0f/273.0f, 41.0f/273.0f, 26.0f/273.0f, 7.0f/273.0f},
	//		{4.0f/273.0f, 16.0f/273.0f, 26.0f/273.0f, 16.0f/273.0f, 4.0f/273.0f},             
	//		{1.0f/273.0f, 4.0f/273.0f, 7.0f/273.0f, 4.0f/273.0f, 1.0f/273.0f}};
	//	
	//	NSMutableArray *kernel = [[[NSMutableArray alloc] initWithCapacity:5] autorelease];
	//	for (int i = 0; i < 5; i++) {
	//		NSMutableArray *row = [[[NSMutableArray alloc] initWithCapacity:5] autorelease];
	//		for (int j = 0; j < 5; j++) {
	//			[row addObject:[NSNumber numberWithDouble:dKernel[i][j]]];
	//		}
	//		[kernel addObject:row];
	//	}
	return [self applyConvolve:[UIImage makeKernel:(int)((radius*2)+1)]];
}

- (UIImage*) applyConvolve:(NSArray*)kernel
{
	CGImageRef inImage = self.CGImage;
	CFDataRef m_DataRef = CGDataProviderCopyData(CGImageGetDataProvider(inImage));  
	CFDataRef m_OutDataRef = CGDataProviderCopyData(CGImageGetDataProvider(inImage));  
	UInt8 * m_PixelBuf = (UInt8 *) CFDataGetBytePtr(m_DataRef);  
	UInt8 * m_OutPixelBuf = (UInt8 *) CFDataGetBytePtr(m_OutDataRef);  
	
	int h = (int)CGImageGetHeight(inImage);
	int w = (int)CGImageGetWidth(inImage);
	
	int kh = (int)([kernel count] / 2);
	int kw = (int)([[kernel objectAtIndex:0] count] / 2);
	int i = 0, j = 0, n = 0, m = 0;
	
	for (i = 0; i < h; i++) {
		for (j = 0; j < w; j++) {
			int outIndex = (i*w*4) + (j*4);
			double r = 0, g = 0, b = 0;
			for (n = -kh; n <= kh; n++) {
				for (m = -kw; m <= kw; m++) {
					if (i + n >= 0 && i + n < h) {
						if (j + m >= 0 && j + m < w) {
							double f = [[[kernel objectAtIndex:(n + kh)] objectAtIndex:(m + kw)] doubleValue];
							if (f == 0) {continue;}
							int inIndex = ((i+n)*w*4) + ((j+m)*4);
							r += m_PixelBuf[inIndex] * f;
							g += m_PixelBuf[inIndex + 1] * f;
							b += m_PixelBuf[inIndex + 2] * f;
						}
					}
				}
			}
			m_OutPixelBuf[outIndex]     = SAFECOLOR((int)r);
			m_OutPixelBuf[outIndex + 1] = SAFECOLOR((int)g);
			m_OutPixelBuf[outIndex + 2] = SAFECOLOR((int)b);
			m_OutPixelBuf[outIndex + 3] = 255;
		}
	}
	
	CGContextRef ctx = CGBitmapContextCreate(m_OutPixelBuf,  
											 CGImageGetWidth(inImage),  
											 CGImageGetHeight(inImage),  
											 CGImageGetBitsPerComponent(inImage),
											 CGImageGetBytesPerRow(inImage),  
											 CGImageGetColorSpace(inImage),  
											 CGImageGetBitmapInfo(inImage) 
											 );
    
    if (ctx == NULL)
    {
        NSUInteger bytesPerPixel = 4;
        NSUInteger bytesPerRow = bytesPerPixel *  CGImageGetWidth(inImage);
        NSUInteger bitsPerComponent = 8;
        CGColorSpaceRef newColorSpace = CGColorSpaceCreateDeviceRGB();
        
        ctx = CGBitmapContextCreate(NULL,
                                       CGImageGetWidth(inImage),
                                       CGImageGetHeight(inImage),
                                       bitsPerComponent,
                                       bytesPerRow,
                                       newColorSpace,
                                       kCGBitmapByteOrderDefault | kCGImageAlphaPremultipliedFirst);
        CGColorSpaceRelease(newColorSpace);
    }
	
	CGImageRef imageRef = CGBitmapContextCreateImage(ctx);  
	CGContextRelease(ctx);
	UIImage *finalImage = [UIImage imageWithCGImage:imageRef];
	CGImageRelease(imageRef);	
	return finalImage;
	
}

+ (NSArray*) makeKernel:(int)length
{
	NSMutableArray *kernel = [[NSMutableArray alloc] initWithCapacity:10];
	int radius = length / 2;
	
	double m = 1.0f/(2*M_PI*radius*radius);
	double a = 2.0 * radius * radius;
	double sum = 0.0;
	
	for (int y = 0-radius; y < length-radius; y++)
	{
		NSMutableArray *row = [[NSMutableArray alloc] initWithCapacity:10] ;
        for (int x = 0-radius; x < length-radius; x++)
        {
			double dist = (x*x) + (y*y);
			double val = m*exp(-(dist / a));
			[row addObject:[NSNumber numberWithDouble:val]];			
			sum += val;
        }
		[kernel addObject:row];
	}
	
	//for Kernel-Sum of 1.0
	NSMutableArray *finalKernel = [[NSMutableArray alloc] initWithCapacity:length] ;
	for (int y = 0; y < length; y++)
	{
		NSMutableArray *row = [kernel objectAtIndex:y];
        NSMutableArray *newRow = [[NSMutableArray alloc] initWithCapacity:length] ;
        for (int x = 0; x < length; x++)
        {
			NSNumber *value = [row objectAtIndex:x];
			[newRow addObject:[NSNumber numberWithDouble:([value doubleValue] / sum)]];
        }
		[finalKernel addObject:newRow];
	}
	return finalKernel;
}

@end
