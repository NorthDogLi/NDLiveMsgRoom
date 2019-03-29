//
//  NDMsgModel.m
//  NDLiveMsgRoom
//
//  Created by ljq on 2019/3/22.
//  Copyright © 2019年 ljq. All rights reserved.
//

#import "NDMsgModel.h"

@implementation NDMsgModel



- (void)initMsgAttribute {
    self.attributeModel = [[NDMsgAttributeModel alloc] initWithMsgModel:self];
}

@end
