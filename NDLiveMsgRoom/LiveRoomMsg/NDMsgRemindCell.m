//
//  NDMsgRemindCell.m
//  
//
//  Created by ljq on 2018/10/8.
//  Copyright © 2018年 . All rights reserved.
//

#import "NDMsgRemindCell.h"

@implementation NDMsgRemindCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        
        [self addSubview:self.remindImageV];
        
        [self.msgLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(8);
            make.top.mas_equalTo(cellLineSpeing+4);
            make.bottom.mas_equalTo(-2);
        }];
        
        [self.remindImageV mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.msgLabel.mas_right).offset(2);
            //make.top.mas_equalTo(cellLineSpeing+4);
            make.centerY.mas_equalTo(self.msgLabel);
            make.size.mas_equalTo(CGSizeMake(16, 16));
        }];
        
        [self.bgLb mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(cellLineSpeing);
            make.left.bottom.mas_equalTo(0);
           make.right.equalTo(self.remindImageV.mas_right).offset(8);
        }];
        
        self.msgLabel.userInteractionEnabled = YES;
        UITapGestureRecognizer *remindCellTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(remindCellTapClick)];
        [self.msgLabel addGestureRecognizer:remindCellTap];
    }
    return self;
}

- (void)remindCellTapClick {
//    if ([self.msgModel.attributeModel.msgAttribText.string containsString:LiveMsgRemind_Follow]) {
//        if (self.delegate && [self.delegate respondsToSelector:@selector(remindCellFollow:)]) {
//            [self.delegate remindCellFollow:self.msgModel];
//        }
//        
//    }else if ([self.msgModel.attributeModel.msgAttribText.string containsString:LiveMsgRemind_Like]) {
//        if (self.delegate && [self.delegate respondsToSelector:@selector(remindCellGifts)]) {
//            [self.delegate remindCellGifts];
//        }
//        
//    }else if ([self.msgModel.attributeModel.msgAttribText.string containsString:LiveMsgRemind_Share]) {
//        if (self.delegate && [self.delegate respondsToSelector:@selector(remindCellShare)]) {
//            [self.delegate remindCellShare];
//        }
//    }
}

- (void)setMsgModel:(NDMsgModel *)msgModel {
    [super setMsgModel:msgModel];
    
    self.msgLabel.attributedText = msgModel.attributeModel.msgAttribText;
    
//    if ([msgModel.attributeModel.msgAttribText.string containsString:LiveMsgRemind_Follow] ||
//        [msgModel.attributeModel.msgAttribText.string isEqualToString:LiveMsgRemind_Followed]) {
//        self.bgLb.backgroundColor = RemindBgColor1;
//        self.remindImageV.image = [UIImage imageNamed:@"msgFollow_icon"];
//
//    }else if ([msgModel.attributeModel.msgAttribText.string containsString:LiveMsgRemind_Like]) {
//        self.bgLb.backgroundColor = RemindBgColor2;
//        self.remindImageV.image = [UIImage imageNamed:@"msgGift_icon"];
//
//    }else if ([msgModel.attributeModel.msgAttribText.string containsString:LiveMsgRemind_Share]) {
//        self.bgLb.backgroundColor = RemindBgColor3;
//        self.remindImageV.image = NDGetImage(@"msgShare_icon");
//    }
}

- (UIImageView *)remindImageV {
    if (!_remindImageV) {
        _remindImageV = [UIImageView new];
    }
    return _remindImageV;
}

@end
