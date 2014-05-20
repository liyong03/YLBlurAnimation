//
//  StackViewController.m
//  YLBlurAnimationDemo
//
//  Created by Yong Li on 5/20/14.
//  Copyright (c) 2014 Yong Li. All rights reserved.
//

#import "StackViewController.h"
#import "YLBlurAnimation.h"

@interface StackViewController () <UINavigationControllerDelegate>

@end

@implementation StackViewController {
    UILabel* _bigLabel;
    YLBlurAnimation* _blurAnimation;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        _blurAnimation = [[YLBlurAnimation alloc] init];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
	// Do any additional setup after loading the view.
    _bigLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 100, 320, 300)];
    _bigLabel.font = [UIFont boldSystemFontOfSize:100.f];
    _bigLabel.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:_bigLabel];
    
    if (self.navigationController) {
        _bigLabel.text = [NSString stringWithFormat:@"%lu", (unsigned long)self.navigationController.viewControllers.count];
    }
    
    UIButton* button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = CGRectMake(0, 500, 320, 50);
    [button setTitle:@"Enter" forState:UIControlStateNormal];
    [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [self.view addSubview:button];
    [button addTarget:self action:@selector(enter:) forControlEvents:UIControlEventTouchUpInside];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)enter:(UIButton*)sender {
    StackViewController* vc = [[StackViewController alloc] initWithNibName:nil bundle:nil];
    self.navigationController.delegate = self;
    [self.navigationController pushViewController:vc animated:YES];
}



- (id <UIViewControllerAnimatedTransitioning>)navigationController:(UINavigationController *)navigationController
                                   animationControllerForOperation:(UINavigationControllerOperation)operation
                                                fromViewController:(UIViewController *)fromVC
                                                  toViewController:(UIViewController *)toVC {
    return _blurAnimation;
}
@end
