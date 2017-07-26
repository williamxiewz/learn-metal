
//
//  WXViewController.m
//  3.BasicBuffers
//
//  Created by williamxie on 26/07/2017.
//  Copyright © 2017 williamxie. All rights reserved.
//

#import "WXViewController.h"
#import "WXRenderer.h"
#import <MetalKit/MetalKit.h>

@interface WXViewController (){
    WXRenderer * _renderer;
    MTKView * _mtkview;
    
    
}

@end

@implementation WXViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _mtkview = (MTKView*)self.view;
    _mtkview.device = MTLCreateSystemDefaultDevice();
    
    if (!_mtkview.device) {
        NSLog(@"error device");
        
    }
    
    
    _renderer = [[WXRenderer alloc]initWithMTKView:_mtkview];
    
    if (!_renderer) {
        NSLog(@"error renderer");
    }
    
    _mtkview.delegate = _renderer;
    
    [_renderer mtkView:_mtkview drawableSizeWillChange:_mtkview.drawableSize];
    
    
}


@end
