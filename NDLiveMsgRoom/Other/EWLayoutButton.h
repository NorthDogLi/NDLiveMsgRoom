//
//  EWLayoutButton.h
//
//
//  Created by oygj on 2018/6/27.
//  Copyright © 2018年 . All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, EWLayoutButtonStyle) {
    EWLayoutButtonStyleLeftImageRightTitle,
    EWLayoutButtonStyleLeftTitleRightImage,
    EWLayoutButtonStyleUpImageDownTitle,
    EWLayoutButtonStyleUpTitleDownImage
};


/// 重写layoutSubviews的方式实现布局，忽略imageEdgeInsets、titleEdgeInsets和contentEdgeInsets

@interface EWLayoutButton : UIButton
/// 布局方式
@property (nonatomic, assign) EWLayoutButtonStyle layoutStyle;
/// 图片和文字的间距，默认值8
@property (nonatomic, assign) CGFloat midSpacing;
/// 指定图片size
@property (nonatomic, assign) CGSize imageSize;

@end
