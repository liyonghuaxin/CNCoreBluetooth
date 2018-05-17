//
//  SwipeUpInteractiveTransition.h
//  AnimationTransitions
//
//  Created by 蓝云 on 2017/5/18.
//  Copyright © 2017年 yangzhi. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SwipeUpInteractiveTransition : UIPercentDrivenInteractiveTransition

@property (nonatomic, assign) BOOL interacting;
@property (nonatomic, copy)void (^direction)(BOOL isHorizontal);

- (void)wireToViewController:(UIViewController*)viewController;

@end
