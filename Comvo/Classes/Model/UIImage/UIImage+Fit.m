//
//  UIImage+Fit.m
//  Cheekie
//
//  Created by dragon on 11/20/14.
//  Copyright (c) 2014 TangerineStudio. All rights reserved.
//

#import "UIImage+Fit.h"

@implementation UIImage (Fit)

- (CGRect)viewFrameToFit:(CGSize)bounds
{
    
    CGFloat ratio = MIN(bounds.width / self.size.width, bounds.height / self.size.height);
    
    CGSize nSize = CGSizeMake(ratio * self.size.width, ratio * self.size.height);
    
    CGRect frame = CGRectMake((bounds.width - nSize.width) * 0.5,
                              (bounds.height - nSize.height) * 0.5, nSize.width, nSize.height);
    
    
    return frame;
}
@end
