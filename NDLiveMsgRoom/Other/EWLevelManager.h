//
//  EWLevelManager.h
//  ShowMe
//
//  Created by mpp on 2018/12/21.
//  Copyright © 2018 yiwu. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface EWLevelManager : NSObject

+ (instancetype)sharedInstance;

/** 初始化（APP生命周期只需要执行一次） */
- (void)setup;

- (UIImage *)imageForLevel:(NSInteger)Level;

@end


