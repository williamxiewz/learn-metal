//
//  WXMetalView.m
//  HelloWorld
//
//  Created by williamxie on 14/05/2017.
//  Copyright © 2017 williamxie. All rights reserved.
//

#import "WXMetalView.h"
#import <Metal/Metal.h>
#import <MetalKit/MetalKit.h>

@interface WXMetalView ()



@end

@implementation WXMetalView

// 指定CALayer 的类型
+(Class)layerClass{
    return  [CAMetalLayer class];
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder{
    
    if ((self = [super initWithCoder:aDecoder])) {
        _metalLayer = (CAMetalLayer*)self.layer;
        _device = MTLCreateSystemDefaultDevice();
        _metalLayer.device = _device;
        _metalLayer.pixelFormat = MTLPixelFormatBGRA8Unorm;
    }
    return self;
}

- (void)didMoveToWindow{
    
    [self redraw];
}

-(void)redraw{
    
    id <CAMetalDrawable> drawable                   =  [self.metalLayer nextDrawable];
    id <MTLTexture>      texture                    =  drawable.texture;
    
    MTLRenderPassDescriptor * passDescriptor        =  [MTLRenderPassDescriptor renderPassDescriptor];
    passDescriptor.colorAttachments[0].texture      =  texture;
    passDescriptor.colorAttachments[0].loadAction   =  MTLLoadActionClear;
    passDescriptor.colorAttachments[0].storeAction  =  MTLStoreActionStore;
    passDescriptor.colorAttachments[0].clearColor   =  MTLClearColorMake(1, 0, 0, 1);
    
    //
    id <MTLCommandQueue>  commandQueue               =  [self.device newCommandQueue];
    id <MTLCommandBuffer> commandBuffer              =  [commandQueue commandBuffer];
    id <MTLRenderCommandEncoder> commandEncoder      =  [commandBuffer renderCommandEncoderWithDescriptor:passDescriptor];
    
    [commandEncoder endEncoding];
    
    [commandBuffer presentDrawable:drawable];
    [commandBuffer commit];
}


#pragma mark -- getter --

- (CAMetalLayer *)metalLayer{
    return (CAMetalLayer *)self.layer;
}



@end
