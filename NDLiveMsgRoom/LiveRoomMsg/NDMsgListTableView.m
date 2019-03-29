//
//  NDMsgListTableView.m
//  TXIm
//
//  Created by ljq on 2018/5/29.
//  Copyright © 2018年 ljq. All rights reserved.
//

#import "NDMsgListTableView.h"
#import "NDLiveMsgBassCell.h"
#import "EWLayoutButton.h"
#import <pthread/pthread.h>


// 最小刷新时间间隔
#define reloadTimeSpan 0.5
// 每次追加爬楼消息的上线（大于这个值时，更早的消息会被抛弃）
#define tempCount 1000
// 消息上线
#define totalMaxCount 5000
// 消息下线
#define totalMinCount 1000

#define RoomMsgScroViewTag      1002

@interface NDMsgListTableView()<UITableViewDelegate, UITableViewDataSource, MsgCellGesDelegate> {
    /** 正在滚动(滚动时禁止执行插入动画) */
    BOOL _inAnimation;
    CGFloat _AllHeight;
    pthread_mutex_t _mutex; // 互斥锁 
}
/** 消息数组(数据源) */
@property (nonatomic, strong) NSMutableArray<NDMsgModel *> *msgArray;
/** 用于存储消息还未刷新到tableView的时候接收到的消息 */
@property (nonatomic, strong) NSMutableArray<NDMsgModel *> *tempMsgArray;
/** 底部更多未读按钮 */
@property (nonatomic, strong) EWLayoutButton *moreButton;

/** 是否处于爬楼状态 */
@property (nonatomic, assign) BOOL inPending;

/** 刷新定时器 */
@property (nonatomic, strong) NSTimer *refreshTimer;
@end

@implementation NDMsgListTableView

- (instancetype)init{
    if(self = [super init]){
        //_mutex = PTHREAD_MUTEX_INITIALIZER;
        pthread_mutex_init(&_mutex, NULL);
        _AllHeight = 15;
        
        [self setupTableView];
        [self startTimer];
    }
    return self;
}

- (void)removeFromSuperview {
    [super removeFromSuperview];
    [self reset];
}

- (void)dealloc {
    NSLog(@"dealloc-----%@", NSStringFromClass([self class]));
}

- (void)setReloadType:(NDReloadLiveMsgRoomType)reloadType {
    _reloadType = reloadType;
    if (_reloadType == NDReloadLiveMsgRoom_Direct) {
        [self stopTimer];
    }
}

#pragma mark - 消息追加
- (void)addNewMsg:(NDMsgModel *)msgModel {
    if (!msgModel) return;
    
    pthread_mutex_lock(&_mutex);
    // 消息不直接加入到数据源
    [self.tempMsgArray addObject:msgModel];
    pthread_mutex_unlock(&_mutex);
    
    if (_reloadType == NDReloadLiveMsgRoom_Direct) {
        [self tryToappendAndScrollToBottom];
    }
}

/** 添加数据并滚动到底部 */
- (void)tryToappendAndScrollToBottom {
    // 处于爬楼状态更新更多按钮
    [self updateMoreBtnHidden];
    if (!self.inPending) {
        // 如果不处在爬楼状态，追加数据源并滚动到底部
        [self appendAndScrollToBottom];
    }
}

/** 追加数据源 */
- (void)appendAndScrollToBottom {
    if (self.tempMsgArray.count < 1) {
        return;
    }
    pthread_mutex_lock(&_mutex);
    // 执行插入
    NSMutableArray *indexPaths = [NSMutableArray array];
    for (NDMsgModel *item in self.tempMsgArray) {
        _AllHeight += item.attributeModel.msgHeight;
        
        [self.msgArray addObject:item];
        [indexPaths addObject:[NSIndexPath indexPathForRow:self.msgArray.count - 1 inSection:0]];
    }
    [self.tableView insertRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationNone];
    [self.tempMsgArray removeAllObjects];
    
    pthread_mutex_unlock(&_mutex);
    
    if (_AllHeight > MsgTableViewHeight) {
        if (self.tableView.height < MsgTableViewHeight) {
            self.tableView.y = 0;
            self.tableView.height = MsgTableViewHeight;
        }
    } else {
        self.tableView.y = MsgTableViewHeight - _AllHeight;
        self.tableView.height = _AllHeight;
    }
    
    //执行插入动画并滚动
    [self scrollToBottom:NO];
}

/** 执行插入动画并滚动 */
- (void)scrollToBottom:(BOOL)animated {
    NSInteger s = [self.tableView numberOfSections];  //有多少组
    if (s<1) return;
    NSInteger r = [self.tableView numberOfRowsInSection:s-1]; //最后一组行
    if (r<1) return;
    NSIndexPath *ip = [NSIndexPath indexPathForRow:r-1 inSection:s-1];  //取最后一行数据
    [self.tableView scrollToRowAtIndexPath:ip atScrollPosition:UITableViewScrollPositionBottom animated:animated]; //滚动到最后一行
}

- (void)setInPending:(BOOL)inPending {
    _inPending = inPending;
    
    // 新消息按钮可见状态
    [self updateMoreBtnHidden];
}

/** 新消息按钮可见状态 */
- (void)updateMoreBtnHidden {
    if (self.inPending && self.tempMsgArray.count > 0) {
        self.moreButton.hidden = NO;
    } else {
        self.moreButton.hidden = YES;
    }
}

#pragma mark - Timer
- (void)startTimer {
    [self stopTimer];
    self.refreshTimer = [NSTimer scheduledTimerWithTimeInterval:reloadTimeSpan target:self selector:@selector(timerEvent) userInfo:nil repeats:YES];
}

- (void)timerEvent {
    [self tryToappendAndScrollToBottom];
}

- (void)stopTimer {
    [self.refreshTimer invalidate];
    [self setRefreshTimer:nil];
}

#pragma mark - Functions
// 新消息按钮
- (void)moreClick:(EWLayoutButton *)button {
    [self appendAndScrollToBottom];
    self.inPending = NO;
}

// 倒计时显示的系统提示语
- (void)startDefaultMsg:(NSString *)text {
//    NDGroupMsgModel *msgModel = [[NDGroupMsgModel alloc] init];
//    msgModel.resource.content = text;
//    msgModel.subType = NDSubMsgType_TimeMsg;
//    [msgModel updateAttribute];
//
//    [self addNewMsg:msgModel];
}


//清空消息重置
- (void)reset {
    pthread_mutex_lock(&_mutex);
    
    _AllHeight = 15;
    [self stopTimer];
    [self.msgArray removeAllObjects];
    [self.tempMsgArray removeAllObjects];
    [self.tableView reloadData];
    self.moreButton.hidden = YES;
    
    pthread_mutex_unlock(&_mutex);
}


#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    if (scrollView.tag != RoomMsgScroViewTag) return;
    // 开始滚动（自动|手动）
    _inAnimation = YES;
}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView {
    // 静止（自动）
    _inAnimation = NO;
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    // 手动拖拽开始
    self.inPending = YES;
    if (self.delegate && [self.delegate respondsToSelector:@selector(startScroll)]) {
        [self.delegate startScroll];
    }
}
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    // 手动拖拽结束（decelerate：0松手时静止；1松手时还在运动,会触发DidEndDecelerating方法）
    if (!decelerate) {
        [self finishDraggingWith:scrollView];
    }
}
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    // 静止后触发（手动）
    [self finishDraggingWith:scrollView];
}

/** 手动拖拽动作彻底完成(减速到零) */
- (void)finishDraggingWith:(UIScrollView *)scrollView {
    if (self.delegate && [self.delegate respondsToSelector:@selector(endScroll)]) {
        [self.delegate endScroll];
    }
    
    _inAnimation = NO;
    CGFloat contentSizeH = scrollView.contentSize.height;
    CGFloat contentOffsetY = scrollView.contentOffset.y;
    CGFloat sizeH = scrollView.frame.size.height;
    
    self.inPending = contentSizeH - contentOffsetY - sizeH > 20.0;
    // 如果不处在爬楼状态，追加数据源并滚动到底部
    [self tryToappendAndScrollToBottom];
    NSLog(@"Offset：%f，contentSize：%f, frame：%f", contentOffsetY, contentSizeH, sizeH);
}



#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.msgArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NDMsgModel *msgModel = self.msgArray[indexPath.row];
    
    NDLiveMsgBassCell *cell = [NDLiveMsgBassCell tableView:tableView cellForMsg:msgModel indexPath:indexPath delegate:self];

    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    NDMsgModel *msgModel = self.msgArray[indexPath.row];
    return msgModel.attributeModel.msgHeight + cellLineSpeing;
}


#pragma mark - MsgCellGesDelegate
- (void)longPressGes:(NDMsgModel *)msgModel {
    
}

- (void)userClick:(NDUserModel *)user {
    if (user) {
        if (self.delegate && [self.delegate respondsToSelector:@selector(didUser:)]) {
            [self.delegate didUser:user];
        }
    }
}

- (void)touchMsgCellView {
    if (self.delegate && [self.delegate respondsToSelector:@selector(touchSelfView)]) {
        [self.delegate touchSelfView];
    }
}
// 提示关注 分享 送礼物点击
- (void)remindCellFollow:(NDMsgModel *)msgModel {

}
- (void)remindCellShare {
    if (self.delegate && [self.delegate respondsToSelector:@selector(didRemindShare)]) {
        [self.delegate didRemindShare];
    }
}
- (void)remindCellGifts {
    if (self.delegate && [self.delegate respondsToSelector:@selector(didRemindGifts)]) {
        [self.delegate didRemindGifts];
    }
}

/** 消息属性文字发生变化（更新对应cell） */
- (void)msgAttrbuiteUpdated:(NDMsgModel *)msgModel {
    NSInteger row = [self.msgArray indexOfObject:msgModel];
    if (row >= 0) {
        [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:row inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
        if (row == self.msgArray.count - 1) {
            [self scrollToBottom:YES];
        }
    }
}

#pragma mark - UI
- (void)layoutSubviews {
    [super layoutSubviews];
    
    [self setTableGradientLayer];
}

- (void)setupTableView {
    self.backgroundColor = [UIColor clearColor];
    self.tableView.backgroundColor = [UIColor clearColor];
    
    [self addSubview:self.tableView];
    [self addSubview:self.moreButton];
    
    self.tableView.frame = CGRectMake(0, 0, MsgTableViewWidth, MsgTableViewHeight);
    
    [self.moreButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.mas_equalTo(0);
        make.left.mas_equalTo(0);
        make.height.mas_equalTo(25);
    }];
    NDViewRadius(self.moreButton, 25/2);
}

- (void)setTableGradientLayer {
    // 渐变蒙层
    CAGradientLayer *layer = [[CAGradientLayer alloc] init];
    layer.colors = @[
                     (__bridge id)[UIColor colorWithWhite:0 alpha:0.05f].CGColor,
                     (__bridge id)[UIColor colorWithWhite:0 alpha:1.0f].CGColor
                     ];
    layer.locations = @[@0.0, @0.4]; // 设置颜色的范围
    layer.startPoint = CGPointMake(0, 0); // 设置颜色渐变的起点
    layer.endPoint = CGPointMake(0, 0.30); // 设置颜色渐变的终点,与 startPoint 形成一个颜色渐变方向
    layer.frame = self.bounds;
    
    self.layer.mask = layer;
}

#pragma mark - GETTER - SETTER
- (UITableView *)tableView {
    if (!_tableView ) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _tableView.showsVerticalScrollIndicator = NO;
        //_tableView.estimatedRowHeight = 40;
        _tableView.keyboardDismissMode = UIScrollViewKeyboardDismissModeInteractive|UIScrollViewKeyboardDismissModeOnDrag;
        _tableView.bounces = NO;
        _tableView.tableFooterView = [UIView new];
        _tableView.sectionFooterHeight = 0;
        _tableView.sectionHeaderHeight = 0;
        
        _tableView.delegate = self;
        _tableView.dataSource = self;
        
        _tableView.tag = RoomMsgScroViewTag;
    }
    return _tableView;
}

- (NSMutableArray<NDMsgModel *> *)msgArray {
    if(!_msgArray){
        _msgArray = [NSMutableArray array];
    }
    return _msgArray;
}

- (NSMutableArray<NDMsgModel *> *)tempMsgArray {
    if(!_tempMsgArray){
        _tempMsgArray = [NSMutableArray array];
    }
    return _tempMsgArray;
}

- (EWLayoutButton *)moreButton {
    if (!_moreButton) {
        _moreButton = [EWLayoutButton buttonWithType:UIButtonTypeCustom];
        _moreButton.layoutStyle = EWLayoutButtonStyleLeftTitleRightImage;
        [_moreButton setTitle:@"新消息" forState:UIControlStateNormal];
        [_moreButton setImage:[UIImage imageNamed:@"message_more"] forState:UIControlStateNormal];
        _moreButton.titleLabel.font = [UIFont systemFontOfSize:12];
        [_moreButton setTitleColor:RGBA_OF(0xfee324) forState:normal];
        _moreButton.backgroundColor = [UIColor purpleColor];
        _moreButton.contentEdgeInsets = UIEdgeInsetsMake(0, 15, 0, 15);
        _moreButton.hidden = YES;
        [_moreButton addTarget:self action:@selector(moreClick:) forControlEvents:UIControlEventTouchUpInside];
        
    }
    return _moreButton;
}


#pragma mark - TOOL



@end
