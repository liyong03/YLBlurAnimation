//
//  StackViewController.h
//  YLBlurAnimationDemo
//
//  Created by Yong Li on 5/20/14.
//  Copyright (c) 2014 Yong Li. All rights reserved.
//

#import <UIKit/UIKit.h>

@class StackViewController;
@protocol StackViewControllerDelegate <NSObject>

- (void)cancelViewController:(StackViewController*)viewController;

@end

@interface StackViewController : UIViewController
@property (nonatomic, weak) id<StackViewControllerDelegate> delegate;
@end
