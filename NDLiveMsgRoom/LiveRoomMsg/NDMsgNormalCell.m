//
//  NDMsgNormalCell.m
//  
//
//  Created by ljq on 2018/10/8.
//  Copyright © 2018年 . All rights reserved.
//

#import "NDMsgNormalCell.h"

@implementation NDMsgNormalCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        
        
    }
    return self;
}

- (void)setMsgModel:(NDMsgModel *)msgModel {
    [super setMsgModel:msgModel];
    
    self.msgLabel.attributedText = msgModel.attributeModel.msgAttribText;
    self.bgLb.backgroundColor = msgModel.attributeModel.bgColor;
}



@end
