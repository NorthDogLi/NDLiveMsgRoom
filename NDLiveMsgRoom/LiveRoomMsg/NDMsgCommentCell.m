//
//  NDMsgCommentCell.m
//  
//
//  Created by ljq on 2018/10/8.
//  Copyright © 2018年 . All rights reserved.
//

#import "NDMsgCommentCell.h"


@interface NDMsgCommentCell ()
@property (nonatomic, strong) UIImage *bgImage;

@end


@implementation NDMsgCommentCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        
        [self addLongPressGes];
    }
    return self;
}

- (void)msgAttributeTapAction {
    if (self.delegate && [self.delegate respondsToSelector:@selector(userClick:)]) {
        [self.delegate userClick:self.msgModel.user];
    }
}

- (void)setMsgModel:(NDMsgModel *)msgModel {
    [super setMsgModel:msgModel];
    
    self.msgLabel.attributedText = msgModel.attributeModel.msgAttribText;

    // 被@用户
    if (msgModel.atUser) {
        // 渐变背景颜色
        self.bgLb.image = self.bgImage;
        self.bgLb.backgroundColor = [UIColor clearColor];
        self.bgLb.layer.borderColor = RGBAOF(0xE7D7F2, 0.6).CGColor;
        self.bgLb.layer.borderWidth = 1.0;
    } else { // @用户
        self.bgLb.image = nil;
        self.bgLb.backgroundColor = msgModel.attributeModel.bgColor;
        self.bgLb.layer.borderColor = [UIColor clearColor].CGColor;
        self.bgLb.layer.borderWidth = 0.0;
    }
}



- (UIImage *)bgImage {
    if (!_bgImage) {
        UIView *view = [[UIView alloc] init];
        view.frame = CGRectMake(0, 0, 10, self.msgModel.attributeModel.msgHeight);
        [view.layer addSublayer:[self setGradualChangingColor:view fromColor:RGBAOF(0x947EFE, 0.6) toColor:RGBAOF(0xFF6FC5, 0.6)]];
        _bgImage = [self convertCreateImageWithUIView:view];
    }
    return _bgImage;
}


/** 将 UIView 转换成 UIImage */
- (UIImage *)convertCreateImageWithUIView:(UIView *)view {
    
    //UIGraphicsBeginImageContext(view.bounds.size);
    UIGraphicsBeginImageContextWithOptions(view.bounds.size, NO, [UIScreen mainScreen].scale);
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    [view.layer renderInContext:ctx];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return newImage;
}

// 绘制渐变色颜色的方法
- (CAGradientLayer *)setGradualChangingColor:(UIView *)view fromColor:(UIColor *)fromHexColorStr toColor:(UIColor *)toHexColorStr {
    
    //CAGradientLayer类对其绘制渐变背景颜色、填充层的形状(包括圆角)
    CAGradientLayer *gradientLayer = [CAGradientLayer layer];
    gradientLayer.frame = view.bounds;
    
    // 创建渐变色数组，需要转换为CGColor颜色
    gradientLayer.colors = @[(__bridge id)fromHexColorStr.CGColor,(__bridge id)toHexColorStr.CGColor];
    
    // 设置渐变颜色方向，左上点为(0,0), 右下点为(1,1)
    gradientLayer.startPoint = CGPointMake(0, 0.5);
    gradientLayer.endPoint = CGPointMake(1, 0.5);
    
    // 设置颜色变化点，取值范围 0.0~1.0
    gradientLayer.locations = @[@0, @1];
    
    return gradientLayer;
}

@end
