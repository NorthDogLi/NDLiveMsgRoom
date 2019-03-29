//
//  NDLiveMsgBassCell.m
//  
//
//  Created by ljq on 2018/10/8.
//  Copyright © 2018年 . All rights reserved.
//

#import "NDLiveMsgBassCell.h"
#import "NDMsgNormalCell.h"
#import "NDMsgJoinCell.h"
#import "NDMsgSynthesizeCell.h"
#import "NDMsgRemindCell.h"
#import "NDMsgCommentCell.h"
#import "NDMsgGiftCell.h"


@interface NDLiveMsgBassCell()


@end


@implementation NDLiveMsgBassCell

- (void)dealloc {
    NSLog(@"dealloc-----%@", NSStringFromClass([self class]));
}

/** cell标示 */
+ (NSString *)msgCellIdentifier {
    return NSStringFromClass([self class]);
}


+ (NDLiveMsgBassCell *)initMsgCell:(UITableView *)tableView cellForType:(NDSubMsgType)type indexPath:(NSIndexPath *)indexPath {
    NSString *identityName = [NSString stringWithFormat:@"%@_%ld", [self msgCellIdentifier], type];
    [tableView registerClass:[self class] forCellReuseIdentifier:identityName];
    
    NDLiveMsgBassCell *cell = [tableView dequeueReusableCellWithIdentifier:identityName forIndexPath:indexPath];
    if (!cell) {
        cell = [[self alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identityName];
    }
    
    return cell;
}

+ (NDLiveMsgBassCell *)tableView:(UITableView *)tableView cellForMsg:(NDMsgModel *)msg indexPath:(NSIndexPath *)indexPath delegate:(id<MsgCellGesDelegate>)delegate {

    NDLiveMsgBassCell *cell = nil;
    NDSubMsgType type = msg.subType;
    
    switch (type) {
//        case NDSubMsgType_TimeMsg:
//        { // 未知类型 客户端自己定时器触发
//            cell = [NDMsgRemindCell initMsgCell:tableView cellForType:type indexPath:indexPath];
//        }
//            break;
        case NDSubMsgType_Announcement:
        { // 公告信息
            cell = [NDMsgNormalCell initMsgCell:tableView cellForType:type indexPath:indexPath];
        }
            break;
        case NDSubMsgType_Subscription:
        { // 关注
            cell = [NDMsgSynthesizeCell initMsgCell:tableView cellForType:type indexPath:indexPath];
        }
            break;
        case NDSubMsgType_Share:
        { // 分享
            cell = [NDMsgSynthesizeCell initMsgCell:tableView cellForType:type indexPath:indexPath];
        }
            break;
        case NDSubMsgType_Comment:
        case NDSubMsgType_At:
        { // 弹幕消息
            cell = [NDMsgCommentCell initMsgCell:tableView cellForType:type indexPath:indexPath];
        }
            break;
        case NDSubMsgType_MemberEnter:
        { // 用户进入直播间
            cell = [NDMsgJoinCell initMsgCell:tableView cellForType:type indexPath:indexPath];
        }
            break;
        case NDSubMsgType_Gift_Text:
        { // 礼物弹幕(文本)消息
            cell = [NDMsgGiftCell initMsgCell:tableView cellForType:type indexPath:indexPath];
        }
            break;
        default:
            break;
    }
    cell.delegate = delegate;
    cell.msgModel = msg;
    
    return cell;
}


- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.accessoryType = UITableViewCellAccessoryNone;
        self.backgroundColor = [UIColor clearColor];
        self.selectionStyle  = UITableViewCellSelectionStyleNone;
        
        [self addSubview:self.bgLb];
        [self addSubview:self.msgLabel];
        
        [self.msgLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(8);
            make.top.mas_equalTo(cellLineSpeing+4);
            make.bottom.mas_equalTo(-2);
            make.right.mas_lessThanOrEqualTo(-8);
            //make.right.mas_equalTo(-8);
        }];

        [self.bgLb mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(cellLineSpeing);
            make.left.bottom.mas_equalTo(0);
            make.right.equalTo(self.msgLabel.mas_right).offset(8);
        }];
        
        NDViewRadius(self.bgLb, 12);
    }
    return self;
}

- (void)setMsgModel:(NDMsgModel *)msgModel {
    _msgModel = msgModel;
    _msgModel.attributeModel.delegate = self;
}


#pragma mark - NDMsgAttributeModelDelegate
- (void)attributeUpdated:(NDMsgAttributeModel *)model {
    if ([self.msgModel.msgID isEqualToString:model.msgModel.msgID]) {
        if (self.delegate && [self.delegate respondsToSelector:@selector(msgAttrbuiteUpdated:)]) {
            dispatch_async(dispatch_get_main_queue(), ^{
               [self.delegate msgAttrbuiteUpdated:self.msgModel];
            });
        }
    }
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    if (self.delegate && [self.delegate respondsToSelector:@selector(touchMsgCellView)]) {
        [self.delegate touchMsgCellView];
    }
}

// 添加长按点击事件
- (void)addLongPressGes {
    //self.userInteractionEnabled = YES;
    self.msgLabel.userInteractionEnabled = YES;
    UILongPressGestureRecognizer *longPressGes = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressGes:)];
    longPressGes.minimumPressDuration = 0.3;
    [self.msgLabel addGestureRecognizer:longPressGes];
}

// 长按手势
- (void)longPressGes:(UILongPressGestureRecognizer *)longGes {
    if (self.delegate && [self.delegate respondsToSelector:@selector(longPressGes:)]) {
        [self.delegate longPressGes:self.msgModel];
    }
}

- (YYLabel *)msgLabel {
    if (!_msgLabel) {
        _msgLabel = [[YYLabel alloc] init];
        _msgLabel.numberOfLines = 0;
        //_msgLabel.lineBreakMode = NSLineBreakByTruncatingTail;
        //_msgLabel.font = [UIFont boldSystemFontOfSize:MSG_LABEL_FONT];
        _msgLabel.backgroundColor = [UIColor clearColor];
        _msgLabel.clipsToBounds = YES;
        _msgLabel.textVerticalAlignment = YYTextVerticalAlignmentCenter;
        _msgLabel.userInteractionEnabled = YES;
        // 强制排版(从左到右)
        _msgLabel.semanticContentAttribute = UISemanticContentAttributeForceLeftToRight;
    }
    return _msgLabel;
}

- (UIImageView *)bgLb {
    if (!_bgLb) {
        _bgLb = [[UIImageView alloc] init];
        _bgLb.userInteractionEnabled = NO;
    }
    return _bgLb;
}


@end
