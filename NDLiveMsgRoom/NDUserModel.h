//
//  NDUserModel.h
//  NDLiveMsgRoom
//
//  Created by ljq on 2019/3/22.
//  Copyright © 2019年 ljq. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NDUserModel : NSObject

@property (nonatomic, copy) NSString *nickName;
@property (nonatomic, copy) NSString *userID;

@property (nonatomic, assign) NSInteger level;
// 0：男    1：女
@property (nonatomic, assign) NSInteger gender;

@end

NS_ASSUME_NONNULL_END
