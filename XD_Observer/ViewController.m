//
//  ViewController.m
//  XD_Observer
//
//  Created by xindong on 16/9/29.
//  Copyright © 2016年 xindong. All rights reserved.
//

#import "ViewController.h"
#import "NSObject+Block.h"

@interface ViewController ()
@property (nonatomic, assign) NSInteger numberValue;
@property (nonatomic, assign) CGFloat floatValue;
@end

@implementation ViewController

#pragma mark - don't forget to remove observer block.
- (void)dealloc {
    [self removeAllObserverBlock];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    NSLog(@"%@", NSStringFromSelector(_cmd));

    
    [self addObserverBlockForKeyPath:@"numberValue" block:^(id  _Nonnull obj, id  _Nonnull oldValue, id  _Nonnull newValue) {
        NSLog(@"objc----%@\noldValue---%@\nnewValue----%@", obj, oldValue, newValue);
    }];
    
    [self addObserverBlockForKeyPath:@"floatValue" block:^(id  _Nonnull obj, id  _Nonnull oldValue, id  _Nonnull newValue) {
        NSLog(@"objc----%@\noldValue---%@\nnewValue----%@", obj, oldValue, newValue);
    }];

}


- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    self.view.backgroundColor = [UIColor colorWithRed:(arc4random()%256/255.0) green:(arc4random()%256/255.0) blue:(arc4random()%256/255.0) alpha:1.0];
    self.numberValue = arc4random() % 101;
    self.floatValue = arc4random() % 11;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
