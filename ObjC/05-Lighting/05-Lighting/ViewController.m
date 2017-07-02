//
//  ViewController.m
//  05-Lighting
//
//  Created by williamxie on 14/05/2017.
//  Copyright © 2017 williamxie. All rights reserved.
//

#import "ViewController.h"
#import "WXRenderer.h"
#import "WXMetalView.h"

@interface ViewController ()
@property(nonatomic,strong) WXRenderer * renderer;
@property(nonatomic,strong) WXMetalView * metalView;
@end

@implementation ViewController

- (WXRenderer *)renderer{

    if (!_renderer) {
        _renderer = [WXRenderer new];
    }
    return  _renderer;
}


- (WXMetalView *)metalView {
    return (WXMetalView *)self.view;
}



- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.metalView.delegate = self.renderer;
    
    
    
}



@end
