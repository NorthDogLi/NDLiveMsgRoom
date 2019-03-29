//
//  NDMsgModel.h
//  NDLiveMsgRoom
//
//  Created by ljq on 2019/3/22.
//  Copyright © 2019年 ljq. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NDUserModel.h"
#import "NDGiftModel.h"
#import "NDMsgAttributeModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface NDMsgModel : NSObject

@property (nonatomic, assign) NDSubMsgType subType;

@property (nonatomic, strong) NDUserModel *user;
/// 直播间文本内容
@property (nonatomic, copy) NSString *content;
// 礼物数量
@property (nonatomic, copy) NSString *quantity;
@property (nonatomic, copy) NSString *msgID;
/// 被@的用户
@property (nonatomic, strong) NDUserModel *atUser;

@property (nonatomic, strong) NDGiftModel *giftModel;

@property (nonatomic, strong) NDMsgAttributeModel *attributeModel;


- (void)initMsgAttribute;

@end

NS_ASSUME_NONNULL_END
