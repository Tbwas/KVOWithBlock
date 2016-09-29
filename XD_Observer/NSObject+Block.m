//
//  NSObject+Block.m
//  XD_Observer
//
//  Created by xindong on 16/9/29.
//  Copyright © 2016年 xindong. All rights reserved.
//

#import "NSObject+Block.h"
#import <objc/runtime.h>

static char const target_key;

/**
 每个KVO都要对应一个block,故每注册一个KVO都要创建一个ObserverTarget.
 */
@interface ObserverTarget : NSObject

- (instancetype)initWithBlock:(void(^)(id object, id oldValue, id newValue))block;

@property (nonatomic, copy) void(^block)(id object, id oldValue, id newValue);

@end

@implementation ObserverTarget

- (instancetype)initWithBlock:(void (^)(id object, id oldValue, id newValue))block {
    if (self = [super init]) {
        self.block = block;
    }
    return self;
}

//// observer block called
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context {
    
    /**
     当包含这个参数的时候，在被观察的property的值改变前和改变后，系统各会给观察者发送一个change
     notification；在property的值改变之前发送的change notification中，change参数会包含
     NSKeyValueChangeNotificationIsPriorKey并且值为@YES，但不会包含NSKeyValueChangeNewKey
     和它对应的值。
     */
    BOOL isPrior = [[change objectForKey:NSKeyValueChangeNotificationIsPriorKey] boolValue];
    if (isPrior) return; //值改变前的notification
    
    /**
     NSKeyValueChangeSetting     被观察对象的值改变
     NSKeyValueChangeInsertion   对象被执行插入
     NSKeyValueChangeRemoval     对象被执行删除
     NSKeyValueChangeReplacement 对象被执行替换
     */
    NSKeyValueChange changeKind = [[change objectForKey:NSKeyValueChangeKindKey] integerValue];
    if (changeKind != NSKeyValueChangeSetting) return;
    
    id oldValue = [change objectForKey:NSKeyValueChangeOldKey];
    if (oldValue == [NSNull null]) oldValue = nil;
    
    id newValue = [change objectForKey:NSKeyValueChangeNewKey];
    if (newValue == [NSNull null]) newValue = nil;
    
    if (self.block) self.block(object, oldValue, newValue);
}

@end


@implementation NSObject (Block)

////每个被观察的keyPath可能对应多个object,故字典中的@key: keyPath - @value: object数组
- (NSMutableDictionary *)allObserverDictionary {
    NSMutableDictionary *observerDic = objc_getAssociatedObject(self, &target_key);
    if (!observerDic) {
        observerDic = [NSMutableDictionary dictionary];
        objc_setAssociatedObject(self, &target_key, observerDic, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    return observerDic;
}

//// add observer block
- (void)addObserverBlockForKeyPath:(NSString *)keyPath block:(void(^)(_Nonnull id obj, _Nonnull id oldValue, _Nonnull id newValue))block {
    if (!keyPath || !block) return;
    ObserverTarget *_observerTarget = [[ObserverTarget alloc] initWithBlock:block];
    NSMutableDictionary *dic = [self allObserverDictionary];
    NSMutableArray *targets = dic[keyPath];
    if (!targets) {
        targets = [NSMutableArray array];
        dic[keyPath] = targets; //对targets强引用,也即对target进行强引用.
    }
    [targets addObject:_observerTarget];
    [self addObserver:_observerTarget forKeyPath:keyPath options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld context:NULL]; //add system observer.
}

//// remove observer block
- (void)removeObserverBlockForKeyPath:(NSString *)keyPath {
    if (!keyPath) return;
    NSMutableDictionary *dic = [self allObserverDictionary];
    NSMutableArray *targets = dic[keyPath];
    [targets enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [self removeObserver:obj forKeyPath:keyPath]; //remove system observer.
    }];
    [dic removeObjectForKey:keyPath];
}

//// remove all observer blocks
- (void)removeAllObserverBlock {
    NSMutableDictionary *dic = [self allObserverDictionary];
    [dic enumerateKeysAndObjectsUsingBlock:^(NSString *key, NSArray *targets, BOOL * _Nonnull stop) {
        [targets enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            [self removeObserver:obj forKeyPath:key]; //remove system observer.
        }];
    }];
    [dic removeAllObjects];
}

@end
