//
//  NDMsgListTableView.h
//  TXIm
//
//  Created by ljq on 2018/5/29.
//  Copyright © 2018年 ljq. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NDMsgModel.h"


// 刷新消息方式
typedef NS_ENUM(NSUInteger, NDReloadLiveMsgRoomType) {
    NDReloadLiveMsgRoom_Time = 0, // 0.5秒刷新一次消息
    NDReloadLiveMsgRoom_Direct,   // 直接刷新
};


@protocol RoomMsgListDelegate;


@interface NDMsgListTableView : UIView
@property (nonatomic, weak) id<RoomMsgListDelegate> delegate;
@property (nonatomic, assign) NDReloadLiveMsgRoomType reloadType;
/** 消息列表 */
@property (nonatomic, strong) UITableView *tableView;

/** 添加新的消息 */
- (void)addNewMsg:(NDMsgModel *)msgModel;

// 倒计时显示的系统提示语
- (void)startDefaultMsg:(NSString *)text;

//清空消息重置
- (void)reset;
- (void)startTimer;

@end



@protocol RoomMsgListDelegate <NSObject>
@optional
- (void)startScroll;
- (void)endScroll;
- (void)touchSelfView;
// 回复
- (void)didAiTe:(NDUserModel *)user;
- (void)didUser:(NDUserModel *)user;

// 提示关注 分享 送礼物点击
- (void)didRemindFollowComplete:(void(^)(BOOL))complete;
- (void)didRemindShare;
- (void)didRemindGifts;
- (void)didCopyWithText:(NSString *)text;
@end
