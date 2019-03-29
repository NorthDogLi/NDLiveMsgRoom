//
//  EWLeveBgView.m
//  ShowMe
//
//  Created by ljq on 2018/10/8.
//  Copyright © 2018年 yiwu. All rights reserved.
//

#import "NDLeveBgView.h"

@interface NDLeveBgView()
@property (nonatomic, strong) UIImageView *leveImage;
@property (nonatomic, strong) UILabel *leveLabel;
@end

@implementation NDLeveBgView

- (instancetype)init {
    if (self = [super init]) {
        [self addSubview:self.leveImage];
        [self addSubview:self.leveLabel];
        
        self.leveImage.frame = CGRectMake(2, 2, 10, 10);
        self.leveLabel.frame = CGRectMake(12, 0, 16, 14);
    }
    return self;
}


- (void)setLevel:(NSInteger)level {
    _level = level;
    UIColor *color;
    NSString *imageName;
    self.image = nil;
    self.leveLabel.font = [UIFont boldSystemFontOfSize:10];
    
    if (level <= 7) {
        color = RGBA_OF(0xA6D259);
        imageName = @"icon_rank_1_7";
    }else if (level > 7 && level <= 16) {
        color = RGBA_OF(0x40BFF9);
        imageName = @"icon_rank_8_16";
    }else if (level > 16 && level <= 30) {
        color = RGBA_OF(0xFFBE0F);
        imageName = @"icon_rank_17_30";
    }else if (level > 30 && level <= 63) {
        color = RGBA_OF(0x8D28F1);
        imageName = @"icon_rank_31_63";
    }else {
        color = [UIColor clearColor];
        imageName = @"icon_rank_64_99";
        self.image = [UIImage imageNamed:@"icon_rank_bg_64"];
        if ([NSString stringWithFormat:@"%ld", level].length >= 3) {
            self.leveLabel.font = [UIFont boldSystemFontOfSize:7.8];
        }
    }
    
    self.backgroundColor = color;
    // 渐变色
    //[self.leveBgImage.layer addSublayer:[YWUtils setGradualChangingColor:self.leveBgImage fromColor:MLHexColor(@"8E45EC") toColor:MLHexColor(@"FD085E")]];//color;
    self.leveImage.image = [UIImage imageNamed:imageName];
    if (level <= 0) level = 0;
    
    if (self.isShadeLv) {
        NSMutableAttributedString *str1 = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%ld", level] attributes:@{NSShadowAttributeName:[self getTextShadow]}];
        
        self.leveLabel.attributedText = str1;
    } else {
        self.leveLabel.text = [NSString stringWithFormat:@"%ld", level];
    }
}

// 文字阴影效果
- (NSShadow *)getTextShadow {
    NSShadow *shadow = [[NSShadow alloc] init];
    //shadow.shadowBlurRadius = 1;
    shadow.shadowOffset = CGSizeMake(0, 0.5);
    shadow.shadowColor = RGBAOF(0x000000, 0.5);
    
    return shadow;
}

- (UILabel *)leveLabel {
    if (!_leveLabel) {
        _leveLabel = [UILabel new];
        _leveLabel.textColor = RGBA_OF(0xffffff);
        _leveLabel.font = [UIFont boldSystemFontOfSize:10];
        _leveLabel.textAlignment = NSTextAlignmentCenter;
//        _leveLabel.shadowOffset = CGSizeMake(0, 0.5);
//        _leveLabel.shadowColor = RGBAOF(0x000000, 0.5);
    }
    return _leveLabel;
}

- (UIImageView *)leveImage {
    if (!_leveImage) {
        _leveImage = [UIImageView new];
    }
    return _leveImage;
}
@end
