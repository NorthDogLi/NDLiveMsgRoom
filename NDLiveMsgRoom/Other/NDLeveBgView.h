//
//  EWLeveBgView.h
//  ShowMe
//
//  Created by ljq on 2018/10/8.
//  Copyright © 2018年 yiwu. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface NDLeveBgView : UIImageView

@property (nonatomic, assign) NSInteger level;

// 文字是否显示高亮
@property (nonatomic, assign) BOOL isShadeLv;

@end

NS_ASSUME_NONNULL_END
