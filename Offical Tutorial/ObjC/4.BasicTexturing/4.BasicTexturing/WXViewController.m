//
//  WXViewController.m
//  4.BasicTexturing
//
//  Created by williamxie on 27/07/2017.
//  Copyright © 2017 williamxie. All rights reserved.
//

#import "WXViewController.h"
#import <MetalKit/MetalKit.h>
#import "WXRenderer.h"


@interface WXViewController (){
    
    MTKView * _mtkView;
    WXRenderer * _renderer;
    
}

@end

@implementation WXViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    
    _mtkView = (MTKView*)self.view;
    _mtkView.device = MTLCreateSystemDefaultDevice();
    
    if (!_mtkView.device) {
        NSLog(@"device error");
        self.view  = [[UIView alloc]initWithFrame:self.view.frame];
    }
    
    
    _renderer = [[WXRenderer alloc]initWithMetakKitView:_mtkView];
    
    if (!_renderer) {
        NSLog(@"_render error");
    }
    
    
    
    [_renderer mtkView:_mtkView drawableSizeWillChange:_mtkView.drawableSize];
    
    _mtkView.delegate = _renderer;
    
    
}






@end
