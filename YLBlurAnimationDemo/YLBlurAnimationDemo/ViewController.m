//
//  ViewController.m
//  YLBlurAnimationDemo
//
//  Created by Yong Li on 4/21/14.
//  Copyright (c) 2014 Yong Li. All rights reserved.
//

#import "ViewController.h"
#import "UIImage+BoxBlur.h"
#import "StackViewController.h"
#import "YLBlurAnimation.h"

@interface ViewController () <UIViewControllerTransitioningDelegate, StackViewControllerDelegate>
@property (nonatomic, assign) BOOL isBlured;
@property (nonatomic, strong) UIImageView* blurView;
@end

@implementation ViewController {
    float _time;
    CADisplayLink* _link;
    UIImage* _screenShot;
    
    BOOL _isBlured;
    
    YLBlurAnimation* _animation;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    NSString* str = nil;
    [str UTF8String];
    
    _animation = [[YLBlurAnimation alloc] init];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)play:(id)sender {
    
    if (!_screenShot) {
        UIButton* btn = (UIButton*)sender;
        btn.hidden = YES;
        
        UIGraphicsBeginImageContext(self.view.bounds.size);
        [self.view.layer renderInContext:UIGraphicsGetCurrentContext()];
        UIImage *viewImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
        
        NSData *imageAsData = UIImageJPEGRepresentation(viewImage, 0.001);
        viewImage = [UIImage imageWithData:imageAsData];
        
        btn.hidden = NO;
        
        self.blurView = [[UIImageView alloc] initWithFrame:self.view.bounds];
        [self.view addSubview:self.blurView];
        _screenShot = viewImage;
        self.blurView.image = _screenShot;//[_screenShot uie_boxblurImageWithBlur:0.5];
        [self.view bringSubviewToFront:btn];
        _isBlured = NO;
    }
    else {
        _isBlured = YES;
    }
    
    _time = 0;
    _link = [CADisplayLink displayLinkWithTarget:self
                                        selector:@selector(blurCurrentView)];
    [_link addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSDefaultRunLoopMode];
}

- (void) blurCurrentView {
    _time += _link.duration;
    if (_time > 0.3)
    {
        [_link invalidate];
        _link = nil;
        if (_isBlured) {
            _screenShot = nil;
            [self.blurView removeFromSuperview];
        }
    }
    else {
        NSLog(@"dur = %f", _link.duration);
        NSLog(@"stamp = %f", _link.timestamp);
        if (_isBlured) {
            float fb = 1 - _time/0.3;
            self.blurView.image = [_screenShot uie_boxblurImageWithBlur:fb];
        } else {
            float fb = _time/0.3;
            self.blurView.image = [_screenShot uie_boxblurImageWithBlur:fb];
        }
    }
}


- (IBAction)navigation:(id)sender {
    StackViewController* stackVC = [[StackViewController alloc] initWithNibName:nil bundle:nil];
    stackVC.delegate = self;
    UINavigationController* nv = [[UINavigationController alloc] initWithRootViewController:stackVC];
    nv.transitioningDelegate = self;
    [self presentViewController:nv animated:YES completion:nil];
}

- (id <UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presented presentingController:(UIViewController *)presenting sourceController:(UIViewController *)source
{
    _animation.isForward = YES;
    return _animation;
}
- (id <UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(UIViewController *)dismissed {
    _animation.isForward = NO;
    return _animation;
}

- (void)cancelViewController:(StackViewController *)viewController {
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
