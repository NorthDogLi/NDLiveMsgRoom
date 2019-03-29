//
//  NDLiveMsgBassCell.h
//  
//
//  Created by ljq on 2018/10/8.
//  Copyright © 2018年 . All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NDMsgModel.h"
#import "NDLeveBgView.h"

@protocol MsgCellGesDelegate;

NS_ASSUME_NONNULL_BEGIN

/**
 *  TCMsgListCell 类说明：
 *  用户消息列表cell，用于展示消息信息
 */

@interface NDLiveMsgBassCell : UITableViewCell <NDMsgAttributeModelDelegate>

@property (nonatomic, weak) id<MsgCellGesDelegate> delegate;
@property (nonatomic, strong) YYLabel *msgLabel;
@property (nonatomic, strong) UIImageView *bgLb;
@property (nonatomic, strong) NDMsgModel *msgModel;

/** cell标示 */
+ (NSString *)msgCellIdentifier;

+ (NDLiveMsgBassCell *)tableView:(UITableView *)tableView cellForMsg:(NDMsgModel *)msg indexPath:(NSIndexPath *)indexPath delegate:(id<MsgCellGesDelegate>)delegate;

// 添加长按点击事件
- (void)addLongPressGes;

@end

@protocol MsgCellGesDelegate <NSObject>
- (void)longPressGes:(NDMsgModel *)MsgModel;
- (void)userClick:(NDUserModel *)user;
- (void)touchMsgCellView;

// 提示关注 分享 送礼物点击
- (void)remindCellFollow:(NDMsgModel *)msgModel;
- (void)remindCellShare;
- (void)remindCellGifts;

/** 消息属性文字发生变化（更新对应cell） */
- (void)msgAttrbuiteUpdated:(NDMsgModel *)msgModel;

@end


NS_ASSUME_NONNULL_END
