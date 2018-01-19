//
//  UIButton+LF.m
//  APPBaseSDK
//
//  Created by 张林峰 on 16/6/4.
//  Copyright © 2016年 张林峰. All rights reserved.
//

#import "UIButton+LF.h"
#import <objc/runtime.h>

static void *currentTimeKey = &currentTimeKey;
static void *resendTimerKey = &resendTimerKey;
static void *btnActionKey = &btnActionKey;

@implementation UIButton (LF)

#pragma mark - 获取验证码倒计时

- (NSNumber *)currentTime {
    return objc_getAssociatedObject(self, &currentTimeKey);
}

-(void)setCurrentTime:(NSNumber *)currentTime {
    objc_setAssociatedObject(self, & currentTimeKey, currentTime, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}


- (NSTimer *)resendTimer {
    return objc_getAssociatedObject(self, &resendTimerKey);
}

-(void)setResendTimer:(NSTimer *)resendTimer {
    objc_setAssociatedObject(self, & resendTimerKey, resendTimer, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (LFBtnAction)btnAction {
    return objc_getAssociatedObject(self, &btnActionKey);
}

-(void)setBtnAction:(LFBtnAction)btnAction {
    objc_setAssociatedObject(self, & btnActionKey, btnAction, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    [self addTarget:self action:@selector(onClick) forControlEvents:UIControlEventTouchUpInside];
}

- (void)el_setArrangeStyle:(LFButtonArrangeStyle)style space:(CGFloat)space {
    CGFloat imageWith = self.imageView.image.size.width;
    CGFloat imageHeight = self.imageView.image.size.height;
    CGFloat labelWidth = 0.0;
    CGFloat labelHeight = 0.0;
    
    if ([UIDevice currentDevice].systemVersion.floatValue >= 8.0) {
        // 由于iOS8中titleLabel的size为0，用下面的这种设置
        labelWidth = self.titleLabel.intrinsicContentSize.width;
        labelHeight = self.titleLabel.intrinsicContentSize.height;
    } else {
        labelWidth = self.titleLabel.frame.size.width;
        labelHeight = self.titleLabel.frame.size.height;
    }
    
    if (style == LFButtonStyleImageTop) {
        self.imageEdgeInsets = UIEdgeInsetsMake(-(labelHeight + space)/2, labelWidth/2, (labelHeight + space)/2, -labelWidth/2);
        self.titleEdgeInsets = UIEdgeInsetsMake((imageHeight+space)/2, -imageWith/2, -(imageHeight + space)/2, imageWith/2);
        
    } else if (style == LFButtonStyleImageLeft) {
        self.imageEdgeInsets = UIEdgeInsetsMake(0, -space/2, 0, space/2);
        self.titleEdgeInsets = UIEdgeInsetsMake(0, space/2, 0, -space/2);
    } else if (style == LFButtonStyleImageRight) {
        self.imageEdgeInsets = UIEdgeInsetsMake(0, labelWidth + space/2, 0, -labelWidth - space/2);
        self.titleEdgeInsets = UIEdgeInsetsMake(0, -imageWith - space/2, 0, imageWith + space/2);
        
    } else if (style == LFButtonStyleImageBottom) {
        self.imageEdgeInsets = UIEdgeInsetsMake((labelHeight + space)/2, labelWidth/2, -(labelHeight + space)/2, -labelWidth/2);
        self.titleEdgeInsets = UIEdgeInsetsMake(-(imageHeight+space)/2, -imageWith/2, (imageHeight + space)/2, imageWith/2);
    }
}

- (void)startWithTime:(NSInteger)second title:(NSString *)title subTitle:(NSString *)subTitle mainColor:(UIColor *)mColor grayColor:(UIColor *)gColor{
    
    self.backgroundColor = gColor;
    NSString *time = [NSString stringWithFormat:@"%zi",second];
    NSString *sTitle = [subTitle stringByReplacingOccurrencesOfString:@"ss" withString:time];
    [self setTitle:sTitle forState:UIControlStateNormal];
    
    if (subTitle.length < 1) {
        subTitle = kDefaultSubTitle;
    }
    self.currentTime = @(second);
    NSDictionary *info = @{@"second":@(second),
                           @"title":title,
                           @"subTitle":subTitle,
                           @"mColor":mColor,
                           @"gColor":gColor};
    
    [self.resendTimer invalidate];
    self.resendTimer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(handleTimer:) userInfo:info repeats:YES];
}

- (void)handleTimer:(NSTimer *)timer {
    NSDictionary *info = timer.userInfo;
    if (self.currentTime.integerValue <= 0) { // 当i<=0了，停止Timer
        [self.resendTimer invalidate];
        self.backgroundColor = info[@"mColor"];
        [self setTitle:info[@"title"] forState:UIControlStateNormal];
        self.enabled = YES;
    } else {
        self.backgroundColor = info[@"gColor"];
        self.currentTime = @(self.currentTime.integerValue - 1);
        NSString *title = info[@"subTitle"];
        NSString *time = [NSString stringWithFormat:@"%li",(long)self.currentTime.integerValue];
        title = [title stringByReplacingOccurrencesOfString:@"ss" withString:time];
        [self setTitle:title forState:UIControlStateNormal];
        self.enabled = NO;
    }
}

- (void)removeTimer {
    if (self.resendTimer) {
        [self.resendTimer invalidate];
        self.resendTimer = nil;
    }
}


//- (void)addBlockAction:(LFBtnAction)action {
//    self.btnAction = action;
//    [self addTarget:self action:@selector(onClick) forControlEvents:UIControlEventTouchUpInside];
//}

- (void)onClick {
    if (self.btnAction) {
        self.btnAction(self);
    }
}


@end
