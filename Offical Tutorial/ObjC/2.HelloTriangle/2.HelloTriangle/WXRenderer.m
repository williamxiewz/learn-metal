//
//  WXRenderer.m
//  2.HelloTriangle
//
//  Created by williamxie on 24/07/2017.
//  Copyright © 2017 williamxie. All rights reserved.
//

#import "WXRenderer.h"
#import <simd/simd.h>
#import "WXShaderTypes.h"

@interface WXRenderer(){
    
    id<MTLDevice> _device;
    id<MTLCommandQueue> _commandQueue;
    id<MTLRenderPipelineState> _renderPipLineState;
    
    vector_uint2 _viewportSize;
}

@end



@implementation WXRenderer

- (instancetype)initWithMetalKitView:(MTKView *)mtkView{
    
    if (self = [super init]) {
        // 初始化设置
        _device = mtkView.device;
        
        mtkView.colorPixelFormat = MTLPixelFormatBGRA8Unorm_sRGB;
        
        _commandQueue = [_device newCommandQueue];
        
        MTLRenderPipelineDescriptor * descriptor = [MTLRenderPipelineDescriptor new];
        
        descriptor.label = @"renderPipLine";
        
        id<MTLLibrary> library = [_device newDefaultLibrary];
        
        id <MTLFunction> vertexFunction  = [library newFunctionWithName:@"vertexShader"];
        
        id<MTLFunction> fragmentFunction = [library newFunctionWithName:@"fragmentShader"];
        
        descriptor.vertexFunction = vertexFunction;
        descriptor.fragmentFunction = fragmentFunction;
        descriptor.colorAttachments[0].pixelFormat = mtkView.colorPixelFormat;
        
        
        NSError *error = nil;
        
        _renderPipLineState = [_device newRenderPipelineStateWithDescriptor:descriptor error:&error];
        
        if (!_renderPipLineState) {
            
            NSLog(@"失败 %@",error);
            return  nil;
            
        }
        
    }
    return self;
}



#pragma mark - MTKViewDelegate -


- (void)drawInMTKView:(MTKView *)view{
    
    static const WXVertex triangleVertices[] =
    {
        // 2D Positions,    RGBA colors
        { {  250,  -250 }, { 1, 0, 0, 1 } },
        { { -250,  -250 }, { 0, 1, 0, 1 } },
        { {    0,   250 }, { 0, 0, 1, 1 } },
    };
    
    
    id <MTLCommandBuffer> commandBuffer = [_commandQueue commandBuffer];
    commandBuffer.label = @"MyCBuffer";
    
    //encoder
    
    MTLRenderPassDescriptor* renderPassDescriptor = view.currentRenderPassDescriptor;
    
    if (renderPassDescriptor != nil) {
        
        id<MTLRenderCommandEncoder> renderEncoder =  [commandBuffer renderCommandEncoderWithDescriptor:renderPassDescriptor];
        
        renderEncoder.label = @"renderEncoder";
        //    double originX, originY, width, height, znear, zfar;
        //
        [renderEncoder setViewport:(MTLViewport){0.0, 0.0, _viewportSize.x, _viewportSize.y, -1.0, 1.0 }];
        
        [renderEncoder setRenderPipelineState:_renderPipLineState];
        
        [renderEncoder setVertexBytes:triangleVertices
                               length:sizeof(triangleVertices)
                              atIndex:WXVertexInputIndexVertices];
        //?
        [renderEncoder setVertexBytes:&_viewportSize
                               length:sizeof(_viewportSize)
                              atIndex:WXVertexInputIndexViewportSize];
        
        //
        [renderEncoder drawPrimitives:MTLPrimitiveTypeTriangle
                          vertexStart:0
                          vertexCount:3];
        
        [renderEncoder endEncoding];
        //
        [commandBuffer presentDrawable:view.currentDrawable];
        
    }
    
    [commandBuffer commit];
    
    
}

- (void)mtkView:(MTKView *)view drawableSizeWillChange:(CGSize)size{
    
    _viewportSize.x = size.width;
    _viewportSize.y = size.height;
    
}

@end
