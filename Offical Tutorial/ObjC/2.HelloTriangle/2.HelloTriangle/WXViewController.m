//
//  WXViewController.m
//  2.HelloTriangle
//
//  Created by williamxie on 24/07/2017.
//  Copyright © 2017 williamxie. All rights reserved.
//

#import "WXViewController.h"
#import <MetalKit/MetalKit.h>
#import "WXRenderer.h"

@interface WXViewController (){
    
    MTKView * _mtkview;
    
    WXRenderer * _renderer;
    
    
}

@end

@implementation WXViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    _mtkview = (MTKView*)self.view;
    _mtkview.device = MTLCreateSystemDefaultDevice();
    
    if (!_mtkview.device ) {
        NSLog(@"出错了");
        
        self.view = [[UIView alloc]initWithFrame:self.view.frame];
    }
    
    _renderer = [[WXRenderer alloc]initWithMetalKitView:_mtkview];
    
    if (!_renderer) {
        NSLog(@"出错了");
        return ;
    }
    
    //初始化 渲染器 视图的可绘画大小
    [_renderer mtkView:_mtkview drawableSizeWillChange:_mtkview.drawableSize];
    
    _mtkview.delegate = _renderer;
    
    
    
}


@end
