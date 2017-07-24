//
//  WXViewController.m
//  1.DevicesAndCommands
//
//  Created by williamxie on 24/07/2017.
//  Copyright © 2017 williamxie. All rights reserved.
//

#import "WXViewController.h"
#import <MetalKit/MetalKit.h>
#import "WXRenderer.h"
@interface WXViewController ()

@end



@implementation WXViewController
{
    MTKView *_mtkview;
    
    WXRenderer *_renderer;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Set the view to use the default device
    _mtkview = (MTKView *)self.view;
    // iOS 默认一个
    _mtkview.device = MTLCreateSystemDefaultDevice();
    
    if(!_mtkview.device)
    {
        NSLog(@"Metal is not supported on this device");
        self.view = [[UIView alloc] initWithFrame:self.view.frame];
    }
    
    _renderer = [[WXRenderer alloc] initWithMetalKitView:_mtkview];
    
    if(!_renderer)
    {
        NSLog(@"Renderer failed initialization");
        return;
    }
    
    _mtkview.delegate = _renderer;
    
    // Indicate that we would like the view to call our -[AAPLRender drawInMTKView:] 60 times per
    //   second.  This rate is not guaranteed: the view will pick a closest framerate that the
    //   display is capable of refreshing (usually 30 or 60 times per second).  Also if our renderer
    //   spends more than 1/60th of a second in -[AAPLRender drawInMTKView:] the view will skip
    //   further calls until the renderer has returned from that long -[AAPLRender drawInMTKView:]
    //   call.  In other words, the view will drop frames.  So we should set this to a frame rate
    //   that we think our renderer can consistently maintain.
    _mtkview.preferredFramesPerSecond = 60;
}

@end

