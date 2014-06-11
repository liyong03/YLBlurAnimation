//
//  UIImage+CIBlur.m
//  YLBlurAnimationDemo
//
//  Created by Yong Li on 6/11/14.
//  Copyright (c) 2014 Yong Li. All rights reserved.
//

#import "UIImage+CIBlur.h"
#import <CoreImage/CoreImage.h>

@implementation UIImage(CIBlur)

- (UIImage *) bluredImageWithRadius:(CGFloat)radius {
    @autoreleasepool {
        CIImage* ciImage = [[CIImage alloc] initWithCGImage:self.CGImage];
        CIFilter* filter = [CIFilter filterWithName:@"CIGaussianBlur"
                                      keysAndValues:kCIInputImageKey, ciImage, @"inputRadius", @(radius), nil];
        CIImage* resultImage = filter.outputImage;
        
        CIContext *context = [CIContext contextWithOptions:nil];
        CGImageRef outImage = [context createCGImage:resultImage fromRect:[resultImage extent]];
        UIImage* img = [UIImage imageWithCGImage: outImage];
        CFRelease(outImage);
        return img;
    }
}

@end
