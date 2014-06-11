//
//  UIImage+CIBlur.h
//  YLBlurAnimationDemo
//
//  Created by Yong Li on 6/11/14.
//  Copyright (c) 2014 Yong Li. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UIImage (CIBlur)

- (UIImage *) bluredImageWithRadius:(CGFloat)radius;

@end
