//
//  NSObject+Block.h
//  XD_Observer
//
//  Created by xindong on 16/9/29.
//  Copyright © 2016年 xindong. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSObject (Block)

- (void)addObserverBlockForKeyPath:(NSString *)keyPath block:(void(^)(_Nonnull id obj, _Nonnull id oldValue, _Nonnull id newValue))block;

- (void)removeObserverBlockForKeyPath:(NSString *)keyPath;

- (void)removeAllObserverBlock;

@end

NS_ASSUME_NONNULL_END