//
//  YLBlurAnimation.m
//  YLBlurAnimation
//
//  Created by Yong Li on 5/20/14.
//  Copyright (c) 2014 Yong Li. All rights reserved.
//

#import "YLBlurAnimation.h"
#import "UIImage+BoxBlur.h"

#define BLUR_DURATION 0.3

@implementation YLBlurAnimation {
    float              _time;
    CADisplayLink     *_link;
    UIImage           *_screenShot;
    UIImageView       *_blurView;
    
    UIViewController  *_toViewController;
    id <UIViewControllerContextTransitioning> _transitionContext;
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
    
    //  // 4. Do animate now
    //  NSTimeInterval duration = [self transitionDuration:transitionContext];
    //  [UIView animateWithDuration:duration
    //                        delay:0.0
    //       usingSpringWithDamping:0.6
    //        initialSpringVelocity:0.0
    //                      options:UIViewAnimationOptionCurveLinear
    //                   animations:^{
    //                     toVC.view.frame = finalFrame;
    //                   } completion:^(BOOL finished) {
    //                     // 5. Tell context that we completed.
    //                     [transitionContext completeTransition:YES];
    //                   }];
    
    
    UIGraphicsBeginImageContext(fromVC.view.bounds.size);
    [fromVC.view.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *viewImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    
    NSData *imageAsData = UIImageJPEGRepresentation(viewImage, 0.01);
    viewImage = [UIImage imageWithData:imageAsData];
    
    _blurView = [[UIImageView alloc] initWithFrame:containerView.bounds];
    [containerView addSubview:_blurView];
    _screenShot = viewImage;
    _blurView.image = _screenShot;
    
    _time = 0;
    _link = [CADisplayLink displayLinkWithTarget:self
                                        selector:@selector(blurCurrentView)];
    [_link addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSDefaultRunLoopMode];
    
    [containerView addSubview:toVC.view];
    toVC.view.alpha = 0;
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
        _toViewController.view.alpha = 1.0;
        //_toViewController.view.transform = CGAffineTransformIdentity;
        [_transitionContext completeTransition:YES];
    }
    else {
        NSLog(@"dur = %f", _link.duration);
        NSLog(@"stamp = %f", _link.timestamp);
        float fb = _time/BLUR_DURATION;
        _blurView.image = [_screenShot uie_boxblurImageWithBlur:fb];
        _toViewController.view.alpha = fb*fb;
        //_toViewController.view.transform = CGAffineTransformMakeScale(2-fb, 2-fb);
        _blurView.transform = CGAffineTransformMakeScale(1+0.3f*fb, 1+0.3f*fb);
    }
}


@end