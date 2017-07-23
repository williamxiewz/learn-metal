//
//  ViewController.m
//  04-DrawingIn3D
//
//  Created by williamxie on 14/05/2017.
//  Copyright © 2017 williamxie. All rights reserved.
//

#import "ViewController.h"
#import "WXRenderer.h"
#import "WXMetalView.h"

@interface ViewController ()

@property(nonatomic,strong) WXRenderer * renderer;

@property(nonatomic,strong)WXMetalView * metalView;
@end

@implementation ViewController

-(WXMetalView*)metalView{

    return (WXMetalView*) self.view;
}

- (WXRenderer *)renderer{
    if (!_renderer) {
        _renderer = [WXRenderer new];
    }
    return _renderer;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // 指定 metalView的 渲染代理
    
    ///metlaView 负责 展示 内容
    ///render    负责 渲染 内容
    self.metalView.delegate =  self.renderer;
}

- (BOOL)prefersStatusBarHidden{

    return YES;
}

@end
