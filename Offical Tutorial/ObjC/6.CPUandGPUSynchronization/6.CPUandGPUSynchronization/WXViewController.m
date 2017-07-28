
//
//  WXViewController.m
//  6.CPUandGPUSynchronization
//
//  Created by williamxie on 28/07/2017.
//  Copyright © 2017 williamxie. All rights reserved.
//

#import "WXViewController.h"
#import <MetalKit/MetalKit.h>
#import <simd/simd.h>
#import "WXRenderer.h"

@interface WXViewController (){
    
    WXRenderer * _renderer;
    MTKView * _mtkView;
    
}

@end

@implementation WXViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _mtkView = (MTKView*)self.view;
    _mtkView.device = MTLCreateSystemDefaultDevice();
    
    if (!_mtkView.device) {
        NSLog(@"");
        self.view = [[UIView alloc]initWithFrame:self.view.frame];
    }
    
    
    _renderer = [[WXRenderer alloc]initWithMetalKitView:_mtkView];
    
    if (!_renderer) {
        NSLog(@"");
        
    }
    
    _mtkView.delegate = _renderer;
    
    [_renderer mtkView:_mtkView drawableSizeWillChange:_mtkView.drawableSize];
    
}
@end
