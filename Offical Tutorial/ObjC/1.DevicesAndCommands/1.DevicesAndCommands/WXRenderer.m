//
//  WXRenderer.m
//  1.DevicesAndCommands
//
//  Created by williamxie on 24/07/2017.
//  Copyright © 2017 williamxie. All rights reserved.
//

#import "WXRenderer.h"

@import simd;
@import MetalKit;


/// Main class performing the rendering
@implementation WXRenderer
{   // GPU
    id <MTLDevice> _device;
    // cqueue
    id <MTLCommandQueue> _commandQueue;
}

typedef struct {
    float red, green, blue, alpha;
} Color;

/// Initialize with the MetalKit view from which we'll obtain our Metal device.  We'll also use this
/// mtkView object to set the pixelformat and other properties of our drawable
- (nonnull instancetype)initWithMetalKitView:(nonnull MTKView *)mtkView
{
    self = [super init];
    if(self)
    {
        _device = mtkView.device;
        
        _commandQueue = [_device newCommandQueue];
    }
    
    return self;
}


/// Gradually cycles through different colors on each invocation.  Generally you would just pick
///   a single clear color color, set it once and forget, but since that would make this sample
///   very boring we'll just return a different clear color each frame :)
- (Color)makeFancyColor
{
    static BOOL       growing = YES;
    static NSUInteger primaryChannel = 0;
    static float      colorChannels[] = {1.0, 0.0, 0.0, 1.0};
    
    const float DynamicColorRate = 0.015;
    
    if(growing)
    {   //
        NSUInteger dynamicChannelIndex = (primaryChannel+1)%3;
        //
        colorChannels[dynamicChannelIndex] += DynamicColorRate;
        //
        if(colorChannels[dynamicChannelIndex] >= 1.0)
        {
            growing = NO;
            primaryChannel = dynamicChannelIndex;
        }
    }
    else
    {   //
        NSUInteger dynamicChannelIndex = (primaryChannel+2)%3;
        //
        colorChannels[dynamicChannelIndex] -= DynamicColorRate;
        //
        if(colorChannels[dynamicChannelIndex] <= 0.0)
        {
            growing = YES;
        }
    }
    
    Color color;
    
    color.red   = colorChannels[0];
    color.green = colorChannels[1];
    color.blue  = colorChannels[2];
    color.alpha = colorChannels[3];
    
    return color;
}

#pragma mark - MTKViewDelegate methods -

// 60 fps 调用
/// Called whenever the view needs to render
- (void)drawInMTKView:(nonnull MTKView *)view
{
    
    // 预处理数据
    Color color = [self makeFancyColor];
    
    view.clearColor = MTLClearColorMake(color.red, color.green, color.blue, color.alpha);
    
    id <MTLCommandBuffer> commandBuffer = [_commandQueue commandBuffer];
    commandBuffer.label = @"MyCommand";
    
    // render passdescriptor
    MTLRenderPassDescriptor * renderPassDescriptor  = view.currentRenderPassDescriptor;
    
    
    // 存在
    if (renderPassDescriptor != nil) {
        
        
       //
       id <MTLRenderCommandEncoder> renderEncoder =  [commandBuffer renderCommandEncoderWithDescriptor:renderPassDescriptor];
        
        [renderEncoder endEncoding];
   
        
        [commandBuffer presentDrawable:view.currentDrawable];
        
    }
    
    
    
    
    
    
    
    
    
    
    [commandBuffer commit];
    
    
    
    
}

/// Called whenever the view size changes or a relayout occurs (such as changing from landscape to
///   portrait mode)
- (void)mtkView:(MTKView *)view drawableSizeWillChange:(CGSize)size
{
}

@end

