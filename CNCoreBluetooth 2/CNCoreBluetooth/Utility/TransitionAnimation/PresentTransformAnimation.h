//
//  PresentTransformAnimation.h
//  AnimationTransitions
//
//  Created by 蓝云 on 2017/5/18.
//  Copyright © 2017年 yangzhi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
typedef NS_ENUM(NSInteger, PresentTransformAnimationType) {
    PresentTransformAnimationTypePresent,
    PresentTransformAnimationTypeDismissed
};

@interface PresentTransformAnimation : NSObject<UIViewControllerAnimatedTransitioning>

@property (nonatomic, assign) BOOL isHorizontal;

+ (instancetype)makeWithTransitionType:(PresentTransformAnimationType)type isHorizontal:(BOOL)isH;
- (instancetype)initWithTransitionType:(PresentTransformAnimationType)type isHorizontal:(BOOL)isH;

@end
