//
//  SwipeUpInteractiveTransition.m
//  AnimationTransitions
//
//  Created by 蓝云 on 2017/5/18.
//  Copyright © 2017年 yangzhi. All rights reserved.
//

#import "SwipeUpInteractiveTransition.h"
@interface SwipeUpInteractiveTransition()
@property (nonatomic, assign) BOOL shouldComplete;
@property (nonatomic, strong) UIViewController *presentingVC;
@end
@implementation SwipeUpInteractiveTransition

-(void)wireToViewController:(UIViewController *)viewController
{
    self.presentingVC = viewController;
    [self prepareGestureRecognizerInView:viewController.view];
}

- (void)prepareGestureRecognizerInView:(UIView*)view {
    UIPanGestureRecognizer *gesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handleGesture:)];
    [view addGestureRecognizer:gesture];
}

-(CGFloat)completionSpeed
{
    return 1 - self.percentComplete;
}

- (void)handleGesture:(UIPanGestureRecognizer *)gestureRecognizer {
    CGPoint translation = [gestureRecognizer translationInView:gestureRecognizer.view.superview];
    switch (gestureRecognizer.state) {
        case UIGestureRecognizerStateBegan:
            // 1. Mark the interacting flag. Used when supplying it in delegate.
            self.interacting = YES;
            [self.presentingVC dismissViewControllerAnimated:YES completion:nil];
            break;
        case UIGestureRecognizerStateChanged: {
            // 2. Calculate the percentage of guesture
            BOOL isH = [self commitTranslation:translation];
            
            CGFloat fraction;
            if (isH) {
                fraction = translation.x / SCREENWIDTH;
            }else{
                fraction = translation.y / (SCREENHEIGHT-20);
            }
            //Limit it between 0 and 1
            fraction = fminf(fmaxf(fraction, 0.0), 1);
            self.shouldComplete = (fraction > 0.5);
            [self updateInteractiveTransition:fraction];
            break;
        }
        case UIGestureRecognizerStateEnded:
        case UIGestureRecognizerStateCancelled: {
            // 3. Gesture over. Check if the transition should happen or not
            self.interacting = NO;
            if (!self.shouldComplete || gestureRecognizer.state == UIGestureRecognizerStateCancelled) {
                [self cancelInteractiveTransition];
            } else {
                [self finishInteractiveTransition];
            }
            break;
        }
        default:
            break;
    }
}
/**
 *   判断手势方向
 *
 *  @param translation translation description
 */
- (BOOL)commitTranslation:(CGPoint)translation
{

    CGFloat absX = fabs(translation.x);
    CGFloat absY = fabs(translation.y);
    // 设置滑动有效距离
    if (MAX(absX, absY) < 10)
    return NO;
    
    if (absX > absY ) {
        if (translation.x<0) {
            //向左滑动
        }else{
            //向右滑动
            if (_direction) {
                _direction(YES);
            }
            return NO;
        }
    } else if (absY > absX) {
        if (translation.y<0) {
            //向上滑动
        }else{
            //向下滑动
            if (_direction) {
                _direction(NO);
            }
        }
    }
    return NO;

    
}

@end
