//
//  WXViewController.m
//  5.HelloCompute
//
//  Created by williamxie on 27/07/2017.
//  Copyright © 2017 williamxie. All rights reserved.
//

#import "WXViewController.h"
#import <MetalKit/MetalKit.h>
#import "WXRenderer.h"

@interface WXViewController (){
    
    WXRenderer * _renderer;
    MTKView    * _mtkView;
    
}

@end

@implementation WXViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    _mtkView = (MTKView*)self.view;
    _mtkView.device = MTLCreateSystemDefaultDevice();
    
    if (_mtkView.device == nil) {
        NSLog(@"error ");
        self.view = [[UIView alloc]initWithFrame:self.view.frame];
    }
    
    
    _renderer = [[WXRenderer alloc]initWithMetalKitView:_mtkView];
    
    if (!_renderer) {
        NSLog(@"error");
        
    }
    
    
    [_renderer mtkView:_mtkView drawableSizeWillChange:_mtkView.drawableSize];
    _mtkView.delegate = _renderer;
    


}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
