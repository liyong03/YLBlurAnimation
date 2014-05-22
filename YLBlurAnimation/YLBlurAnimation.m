//
//  YLBlurAnimation.m
//  YLBlurAnimation
//
//  Created by Yong Li on 5/20/14.
//  Copyright (c) 2014 Yong Li. All rights reserved.
//

#import "YLBlurAnimation.h"
#import "UIImage+BoxBlur.h"
#import "RSTimingFunction.h"
#import "UIImage+ImageEffects.h"


#define BLUR_DURATION 0.3f

#define USE_BOX

@implementation YLBlurAnimation {
    float               _time;
    RSTimingFunction    *_outTimingFunc;
    RSTimingFunction    *_inTimingFunc;
    CADisplayLink       *_link;
    UIImage             *_screenShot;
    UIImage             *_inScreenShot;
    UIImageView         *_blurView;
    UIImageView         *_inBlurView;
    
    UIViewController    *_toViewController;
    id <UIViewControllerContextTransitioning>   _transitionContext;
}

- (id)init
{
    self = [super init];
    if (self) {
        _isForward = YES;
    }
    return self;
}

//BouncePresentAnimation.m
- (NSTimeInterval)transitionDuration:(id <UIViewControllerContextTransitioning>)transitionContext
{
    return BLUR_DURATION;
}

- (void)animateTransition:(id <UIViewControllerContextTransitioning>)transitionContext
{
    // 1. Get controllers from transition context
    UIViewController *toVC = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    UIViewController *fromVC = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    
    // 2. Set init frame for toVC
    //CGRect screenBounds = [[UIScreen mainScreen] bounds];
    CGRect finalFrame = [transitionContext finalFrameForViewController:toVC];
    toVC.view.frame = finalFrame;
    
    // 3. Add toVC's view to containerView
    UIView *containerView = [transitionContext containerView];
    
    [containerView addSubview:toVC.view];
    
    // get screenshot of out view
    UIGraphicsBeginImageContext(fromVC.view.bounds.size);
    [fromVC.view.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *viewImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
#ifdef USE_BOX
    NSData *imageAsData = UIImageJPEGRepresentation(viewImage, 0.5);
    viewImage = [UIImage imageWithData:imageAsData];
#endif
    
    // get screenshot of in view
    UIGraphicsBeginImageContext(toVC.view.bounds.size);
    [toVC.view.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *toViewImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
#ifdef USE_BOX
    imageAsData = UIImageJPEGRepresentation(toViewImage, 0.5);
    toViewImage = [UIImage imageWithData:imageAsData];
#endif
    
    _outTimingFunc = [RSTimingFunction timingFunctionWithName:kRSTimingFunctionEaseIn];
    _inTimingFunc = [RSTimingFunction timingFunctionWithName:kRSTimingFunctionEaseIn];
    
    _blurView = [[UIImageView alloc] initWithFrame:containerView.bounds];
    _inBlurView  = [[UIImageView alloc] initWithFrame:containerView.bounds];
    _screenShot = viewImage;
    _blurView.image = _screenShot;
    _inBlurView.image = toViewImage;
    _inScreenShot = toViewImage;
    
    toVC.view.alpha = 0;
    
    if (self.isForward) {
        [containerView addSubview:_blurView];
        [containerView addSubview:_inBlurView];
        _inBlurView.alpha = 0;
    }
    else {
        [containerView addSubview:_inBlurView];
        [containerView addSubview:_blurView];
    }
    
    _time = 0;
    _link = [CADisplayLink displayLinkWithTarget:self
                                        selector:@selector(blurCurrentView)];
    [_link addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSDefaultRunLoopMode];
    
    [containerView bringSubviewToFront:toVC.view];
    _toViewController = toVC;
    _transitionContext = transitionContext;
}


- (void) blurCurrentView {
    _time += _link.duration;
    if (_time > BLUR_DURATION)
    {
        [_link invalidate];
        _link = nil;
        [_blurView removeFromSuperview];
        [_inBlurView removeFromSuperview];
        _toViewController.view.alpha = 1.0;
        _toViewController.view.transform = CGAffineTransformIdentity;
        [_transitionContext completeTransition:YES];
    }
    else {
        float fb = _time/BLUR_DURATION;
        float outP = [_outTimingFunc valueForX:fb];
        float inP = [_inTimingFunc valueForX:fb];
        if (self.isForward) {
            // old view
#ifdef USE_BOX
            _blurView.image = [_screenShot uie_boxblurImageWithBlur:outP];
#else
            _blurView.image = [_screenShot applyBlurEffectWithRadius:outP*40 reflectImage:NO];
#endif
            
            // new view
            float scale = 1.0 + 0.2*(1-inP);
            NSLog(@"progress = %f, scale = %f", inP, scale);
#ifdef USE_BOX
            _inBlurView.image = [_inScreenShot uie_boxblurImageWithBlur:1-inP];
#else
            _inBlurView.image = [_inScreenShot applyBlurEffectWithRadius:40*(1-inP) reflectImage:NO];
#endif
            _inBlurView.alpha = inP;
            _inBlurView.transform = CGAffineTransformMakeScale(scale, scale);
        } else {
            // old view
#ifdef USE_BOX
            _blurView.image = [_screenShot uie_boxblurImageWithBlur:outP];
#else
            _blurView.image = [_screenShot applyBlurEffectWithRadius:40*outP reflectImage:NO];
#endif
            float scale = 1.0 + 0.2*(outP);
            _blurView.transform = CGAffineTransformMakeScale(scale, scale);
            _blurView.alpha = 1-outP;
            
            // new view
#ifdef USE_BOX
            _inBlurView.image = [_inScreenShot uie_boxblurImageWithBlur:1-inP];
#else
            _inBlurView.image = [_inScreenShot applyBlurEffectWithRadius:40*(1-inP) reflectImage:NO];
#endif
        }
    }
}


@end
