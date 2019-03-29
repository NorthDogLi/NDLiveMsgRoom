//
//  NDMsgAttributeModel.m
//  NDLiveMsgRoom
//
//  Created by ljq on 2019/3/27.
//  Copyright © 2019年 ljq. All rights reserved.
//

#import "NDMsgAttributeModel.h"
#import "NDMsgModel.h"
#import "EWLevelManager.h"

@interface NDMsgAttributeModel()

@property (nonatomic, strong) UIFont *font;
/** 附件图片（目前只有用户徽章） */
@property (nonatomic, strong) NSArray<id> *tipImages;
/** 附件图片下载结束 */
@property (nonatomic, assign) BOOL finishDownloadTipImg;
/** 礼物缩略图 */
@property (nonatomic, strong) UIImage *giftImage;
/** 礼物缩略图下载结束 */
@property (nonatomic, assign) BOOL finishDownloadGiftImg;


///////////////////////////////// 附加属性 /////////////////////////////////
/** SDwebImage的所有请求 */
@property (nonatomic, strong) NSMutableArray *tempLoads;
@end


@implementation NDMsgAttributeModel


- (instancetype)init {
    if (self = [super init]) {
        self.msgColor = MsgLbColor;
        self.bgColor = NormalBgColor;
        
        self.font = [UIFont boldSystemFontOfSize:MSG_LABEL_FONT];
        
        self.tempLoads = [NSMutableArray array];
    }
    return self;
}

- (instancetype)initWithMsgModel:(NDMsgModel *)msgModel {
    if (self = [self init]) {
        self.msgModel = msgModel;
        
        [self msgUpdateAttribute];
    }
    return self;
}

/** 重新计算属性 */
- (void)msgUpdateAttribute {
    [self getAttributedStringFromSelf];
}

- (void)getAttributedStringFromSelf {
    
    switch (self.msgModel.subType) {
        case NDSubMsgType_Subscription: { // 关注
            self.bgColor = NormalBgColor;
            [self Subscription];
        }
            break;
        case NDSubMsgType_Share: { // 分享
            self.bgColor = NormalBgColor;
            [self Share];
        }
            break;
        case NDSubMsgType_At:
        case NDSubMsgType_Comment: { // 弹幕消息
            // 下载标签图片
            [self downloadTagImage];
            self.bgColor = NormalBgColor;
            [self Comment];
        }
            break;
        case NDSubMsgType_MemberEnter: { // 用户进入直播间
            // 下载标签图片
            [self downloadTagImage];
            self.bgColor = NormalBgColor;
            [self MemberEnter];
        }
            break;
        case NDSubMsgType_Gift_Text: {   // 礼物弹幕(文本)消息
            // 下载标签图片
            [self downloadTagImage];
            // 下载礼物图片
            [self downloadGiftImage];
            self.bgColor = NormalBgColor;
            [self Gift_Text];
        }
            break;
        case NDSubMsgType_Announcement: { // 系统公告信息
            self.bgColor = NormalBgColor;
            [self Unknow];
        }
            break;
//        case NDSubMsgType_TimeMsg: { // 客户端提示消息
//            self.bgColor = RemindBgColor2;
//            [self Announcement];
//        }
//            break;
            
        default:
            break;
    }
}

// 文字阴影效果
- (YYTextShadow *)getTextShadow {
    YYTextShadow *shadow = [[YYTextShadow alloc] init];
    //shadow.shadowBlurRadius = 1;
    shadow.offset = CGSizeMake(0, 0.5);
    shadow.color = RGBAOF(0x000000, 0.5);
    
    return shadow;
}

/**
 字符串生成富文本
 @param isTap 是否添加点击事件
 @param isShadow 是否添加文字投影效果
 */
- (NSMutableAttributedString *)getAttributed:(NSString *)text font:(UIFont *)font color:(UIColor *)color tap:(BOOL)isTap shadow:(BOOL)isShadow {
    NSMutableAttributedString *attribute = [[NSMutableAttributedString alloc] initWithString:text attributes:nil];
    attribute.yy_font = font;
    attribute.yy_color = color;
    // 强制排版(从左到右)
    attribute.yy_baseWritingDirection = NSWritingDirectionLeftToRight;
    attribute.yy_writingDirection = @[@(NSWritingDirectionLeftToRight | NSWritingDirectionOverride)];
    attribute.yy_paragraphStyle = [self paragraphStyle];
    
    if (isShadow) {
        attribute.yy_textShadow = [self getTextShadow];
    }
    
    if (isTap) {
        EWWeakSelf;
        YYTextHighlight *highlight = [YYTextHighlight new];
        highlight.tapAction = ^(UIView *containerView, NSAttributedString *text, NSRange range, CGRect rect) {
            if (weakSelf.delegate && [weakSelf.delegate respondsToSelector:@selector(msgAttributeTapAction)]) {
                [weakSelf.delegate msgAttributeTapAction];
            }
        };
        [attribute yy_setTextHighlight:highlight range:attribute.yy_rangeOfAll];
    }
    
    return attribute;
}

// 图片、view生成富文本
- (NSMutableAttributedString *)getAttachText:(UIImage *)image tap:(BOOL)isTap {
    NSMutableAttributedString *attachText = [NSMutableAttributedString yy_attachmentStringWithContent:image contentMode:UIViewContentModeCenter attachmentSize:image.size alignToFont:self.font alignment:YYTextVerticalAlignmentCenter];
    // 强制排版(从左到右)
    attachText.yy_baseWritingDirection = NSWritingDirectionLeftToRight;
    attachText.yy_writingDirection = @[@(NSWritingDirectionLeftToRight | NSWritingDirectionOverride)];
    attachText.yy_paragraphStyle = [self paragraphStyle];
    
    if (isTap) {
        EWWeakSelf;
        YYTextHighlight *highlight = [YYTextHighlight new];
        highlight.tapAction = ^(UIView *containerView, NSAttributedString *text, NSRange range, CGRect rect) {
            if (weakSelf.delegate && [weakSelf.delegate respondsToSelector:@selector(msgAttributeTapAction)]) {
                [weakSelf.delegate msgAttributeTapAction];
            }
        };
        [attachText yy_setTextHighlight:highlight range:attachText.yy_rangeOfAll];
    }
    
    return attachText;
}

// 将个人标签生成富文本
- (void)addTipImage:(NSMutableAttributedString *)attachText {
    CGFloat lineH = 18;
    for (UIImage *image in self.tipImages) {
        if (![image isKindOfClass:[UIImage class]]) {
            continue;
        }
        CGFloat scale = image.size.height / lineH;
        CGSize size = CGSizeMake(image.size.width / scale, lineH);
        UIImage *newImage = [self scaleToSize:size image:image];
        NSMutableAttributedString *labs = [self getAttachText:newImage tap:YES];
        [attachText appendAttributedString:labs];
        [attachText appendAttributedString:[[NSAttributedString alloc] initWithString:@" "]];
    }
}

#pragma mark ----- 设置富文本
// 综合类型
- (NSMutableAttributedString *)UnknowCell:(NSString *)appendStr {
    //NSMutableParagraphStyle *paraStyle = [self paragraphStyle];
    
    NSString *firstStr = [NSString stringWithFormat:@"%@ ", self.msgModel.user.nickName];
    NSMutableAttributedString *attribute = [self getAttributed:firstStr font:self.font color:MsgNameColor tap:YES shadow:NO];
    
    NSMutableAttributedString *string1 = [self getAttributed:appendStr font:self.font color:MsgLbColor tap:NO shadow:YES];
    
    [attribute appendAttributedString:string1];
    
    // 获取高度 宽度
    [self YYTextLayoutSize:attribute];
    
    return attribute;
}

// 关注
- (void)Subscription {
    self.msgAttribText = [self UnknowCell:@"关注了主播"];
}

// 分享
- (void)Share {
    self.msgAttribText = [self UnknowCell:@"分享了直播间"];
}

// 聊天
- (void)Comment {
    NSMutableParagraphStyle *paraStyle = [self paragraphStyle];
    paraStyle.lineSpacing = 3.0f;//行间距
    // 首行缩进
    //paraStyle.firstLineHeadIndent = 33;
    
    // 等级
    NSMutableAttributedString *textView = [self getAttachText:[[EWLevelManager sharedInstance] imageForLevel:self.msgModel.user.level] tap:YES];
    [textView appendAttributedString:[[NSAttributedString alloc] initWithString:@" "]];
    
    /**徽章*/
    [self addTipImage:textView];
    
    // 名字
    NSString *firstStr = [NSString stringWithFormat:@"%@：",  self.msgModel.user.nickName];
    NSMutableAttributedString *name = [self getAttributed:firstStr font:self.font color:MsgNameColor tap:YES shadow:NO];
    
    // @用户
    if (self.msgModel.atUser) {
        NSString *answerStr = [NSString stringWithFormat:@"@%@ ", self.msgModel.atUser.nickName];
        NSMutableAttributedString *answerName = [self getAttributed:answerStr font:self.font color:MsgLbColor tap:NO shadow:YES];
        [name appendAttributedString:answerName];
    }
    
    // 内容
    NSMutableAttributedString *content = [self getAttributed:self.msgModel.content font:self.font color:MsgTitleColor tap:NO shadow:YES];
    
    [textView appendAttributedString:name];
    [textView appendAttributedString:content];
    textView.yy_paragraphStyle = paraStyle;
    
    self.msgAttribText = textView;
    
    [self YYTextLayoutSize:self.msgAttribText];
}

// 成员加入
- (void)MemberEnter {
    NSMutableParagraphStyle *paraStyle = [self paragraphStyle];
    paraStyle.lineSpacing = 3.0f;//行间距
    
    NSMutableAttributedString *welcomeAttribText = [self getAttributed:[NSString stringWithFormat:@"%@ ", @"欢迎"] font:self.font color:MsgLbColor tap:NO shadow:YES];
    
    NSMutableAttributedString *textView = [self getAttachText:[[EWLevelManager sharedInstance] imageForLevel:self.msgModel.user.level] tap:YES];
    [textView appendAttributedString:[[NSAttributedString alloc] initWithString:@" "]];
    
    /**徽章*/
    [self addTipImage:textView];
    
    // 显示内容
    NSMutableAttributedString *attribute = [self getAttributed:[NSString stringWithFormat:@"%@", self.msgModel.user.nickName] font:self.font color:MsgNameColor tap:YES shadow:NO];
    
    NSMutableAttributedString *str2 = [self getAttributed:[NSString stringWithFormat:@"  %@", @"来到直播间"] font:self.font color:MsgLbColor tap:NO shadow:YES];
    
    [welcomeAttribText appendAttributedString:textView];
    [welcomeAttribText appendAttributedString:attribute];
    [welcomeAttribText appendAttributedString:str2];
    
    welcomeAttribText.yy_paragraphStyle = paraStyle;
    
    self.msgAttribText = welcomeAttribText;
    
    [self YYTextLayoutSize:self.msgAttribText];
}

// 礼物消息
- (void)Gift_Text {
    int i = [self.msgModel.quantity intValue];
    
    // 等级
    NSMutableAttributedString *textView = [self getAttachText:[[EWLevelManager sharedInstance] imageForLevel:self.msgModel.user.level] tap:YES];
    [textView appendAttributedString:[[NSAttributedString alloc] initWithString:@" "]];
    
    /**徽章*/
    [self addTipImage:textView];
    
    NSMutableAttributedString *attribute = [self getAttributed:[NSString stringWithFormat:@"%@", self.msgModel.user.nickName] font:self.font color:MsgNameColor tap:YES shadow:NO];
    
    NSMutableAttributedString *giveAttText = [self getAttributed:@" 送出了" font:self.font color:MsgLbColor tap:NO shadow:YES];
    
    /**礼物图片*/
    UIImage *gifImage;// = [UIImage imageWithColor:[UIColor clearColor] widthHeight:19];
    if (self.giftImage) {
        gifImage = self.giftImage;
    }
    
    CGSize size = CGSizeMake(19, 22);
    UIImage *newImage = [self scaleToSize:size image:gifImage];
    NSMutableAttributedString *gifImageStr = [self getAttachText:newImage tap:NO];
    
    
    NSMutableAttributedString *countText;
    if (i > 1) {
        NSString *giftX = [NSString stringWithFormat:@"x%d", i];
        countText = [self getAttributed:giftX font:self.font color:MsgLbColor tap:NO shadow:YES];
    }
    
    
    [textView appendAttributedString:attribute];
    [textView appendAttributedString:giveAttText];
    [textView appendAttributedString:gifImageStr];
    // 连击数超过1才显示连击数字 应测试要求
    if (countText.string.length > 0) {
        [textView appendAttributedString:[[NSAttributedString alloc] initWithString:@" "]];
        [textView appendAttributedString:countText];
    }
    
    self.msgAttribText = textView;
    
    // 获取高度 宽度
    [self YYTextLayoutSize:self.msgAttribText];
    
    //    self.msgHeight = 24;
}

// 客户端提示消息 由客户端定时器触发
- (void)Announcement {
    NSString *msgText = self.msgModel.content;
    NSMutableAttributedString *attribute = [self getAttributed:msgText font:self.font color:MsgTitleColor tap:NO shadow:NO];
    self.msgAttribText = attribute;
    
    // 获取高度 宽度
    [self YYTextLayoutSize:self.msgAttribText];
}

// 系统提示消息
- (void)Unknow {
    NSMutableParagraphStyle *paraStyle = [self paragraphStyle];
    paraStyle.lineSpacing = 3.0f;//行间距
    
    NSMutableAttributedString *attribute = [self getAttributed:self.msgModel.content font:self.font color:MsgLbColor tap:NO shadow:YES];
    attribute.yy_paragraphStyle = paraStyle;
    
    self.msgAttribText = attribute;
    
    // 获取高度 宽度
    [self YYTextLayoutSize:self.msgAttribText];
}

#pragma mark ----- 获取cell高度
- (void)YYTextLayoutSize:(NSMutableAttributedString *)attribText {
    // 距离左边8  距离右边也为8
    CGFloat maxWidth = MsgTableViewWidth - 16;
    
    YYTextLayout *layout = [YYTextLayout layoutWithContainerSize:CGSizeMake(maxWidth, MAXFLOAT) text:attribText];
    CGSize size = layout.textBoundingSize;
    
    if (size.height && size.height < 24) {
        size.height = 24;
    } else {
        // 再加上6=文字距离上下的间距
        size.height = size.height + 6;
    }
    
    self.msgHeight = size.height;
    self.msgWidth = size.width;
}


#pragma mark ----- 方法
- (NSMutableParagraphStyle *)paragraphStyle {
    NSMutableParagraphStyle *paraStyle = [[NSMutableParagraphStyle alloc] init];
    paraStyle.lineSpacing = 0.0f;//行间距
    //paraStyle.alignment = NSTextAlignmentLeft;//对齐
    
    //参数：（字体大小17号字乘以2，34f即首行空出两个字符）
    //CGFloat emptylen = self.contentLabel.font.pointSize * 2;
    //paraStyle.headIndent = 8.0f;//行首缩进
    //paraStyle.tailIndent = -8.0f;//行尾缩进或宽度
    //paraStyle.lineBreakMode = NSLineBreakByWordWrapping;
    
    //首行缩进
    //paraStyle.firstLineHeadIndent = self.headIndent;
    // 强制排版(从左到右)
    paraStyle.alignment = NSTextAlignmentLeft;
    paraStyle.baseWritingDirection = NSWritingDirectionLeftToRight;
    
    return paraStyle;
}

#pragma mark - GETTER - SETTER
//- (void)setGiftIM:(EWGiftIMModel *)giftIM {
//    _giftIM = giftIM;
//    [self getAttributedStringFromSelf];
//}

#pragma mark - 图片标签下载
/** 下载礼物缩略图 */
- (void)downloadGiftImage {
    NSString *urlStr = self.msgModel.giftModel.thumbnailUrl;
    if (!urlStr || urlStr.length < 1) {
        return;
    }
    if (self.finishDownloadGiftImg) {
        return;
    }
    self.finishDownloadGiftImg = YES;
    
    // 1. 如果本地有图片
    self.giftImage = [self cacheImage:urlStr];
    if (self.giftImage) {
        return;
    }
    
    // 2. 下载远程图片
    NSURL *url = [NSURL URLWithString:urlStr];
    EWWeakSelf
    id sdLoad = [[SDWebImageManager sharedManager] loadImageWithURL:url options:0 progress:^(NSInteger receivedSize, NSInteger expectedSize, NSURL * _Nullable targetURL) {
        
    } completed:^(UIImage * _Nullable image, NSData * _Nullable data, NSError * _Nullable error, SDImageCacheType cacheType, BOOL finished, NSURL * _Nullable imageURL) {
        if (image){
            // 刷新UI
            weakSelf.giftImage = image;
            // 更新属性文字
            [weakSelf downloadTagImageFinish];
        }
    }];
    [self.tempLoads addObject:sdLoad];
}

/** 下载标签图片（目前只有徽章） */
- (void)downloadTagImage {
    // 这里的逻辑和下载礼物缩略图同样的逻辑
}

- (void)downloadTagImageFinish {
    // 更新属性文字
    [self msgUpdateAttribute];
    // 通知代理刷新属性文字
    if (self.delegate && [self.delegate respondsToSelector:@selector(attributeUpdated:)]) {
        [self.delegate attributeUpdated:self];
    }
}

- (void)dealloc {
    for (id<SDWebImageOperation> item in self.tempLoads) {
        [item cancel];
    }
    // NSLog(@"dealloc-----%@", NSStringFromClass([self class]));
}

#pragma mark - TOOL
- (UIImage *)cacheImage:(NSString *)urlStr {
    // 缓存的图片（内存）
    UIImage *image = [[SDImageCache sharedImageCache] imageFromMemoryCacheForKey:urlStr];
    
    // 缓存的图片（硬盘）
    if (!image) {
        image = [[SDImageCache sharedImageCache] imageFromDiskCacheForKey:urlStr];
    }
    
    return image;
}

// 像这些方法你可以提取到UIImage分类中，
- (UIImage *)scaleToSize:(CGSize)size image:(UIImage *)image
{
    // 创建一个bitmap的context
    UIGraphicsBeginImageContextWithOptions(size, NO, [[UIScreen mainScreen] scale]);
    // 绘制改变大小的图片
    [image drawInRect:CGRectMake(0, 0, size.width, size.height)];
    // 从当前context中创建一个改变大小后的图片
    UIImage * scaledImage = UIGraphicsGetImageFromCurrentImageContext();
    // 使当前的context出堆栈
    UIGraphicsEndImageContext();
    // 返回新的改变大小后的图片
    return scaledImage;
}


@end
