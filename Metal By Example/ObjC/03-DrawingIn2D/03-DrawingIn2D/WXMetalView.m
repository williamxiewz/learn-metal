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

typedef struct{
    vector_float4 position;
    vector_float4 color;
}WXVertex;


@interface WXMetalView ()

@property(nonatomic,weak) CAMetalLayer * metalLayer;
@property(nonatomic,readonly)id <MTLDevice> device;
@property(nonatomic,strong) id <MTLBuffer> vertexBuffer;
@property(nonatomic,strong) id <MTLRenderPipelineState> pipline;
@property(nonatomic,strong) id <MTLCommandQueue>  commandQueue;
@property(nonatomic,strong) CADisplayLink * displayLink;

@end

@implementation WXMetalView

// 指定CALayer 的类型
+(Class)layerClass{
    return  [CAMetalLayer class];
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder{
    
    if ((self = [super initWithCoder:aDecoder])) {
        
        
        [self makeDevice];
        [self makeVertexBuffers];
        [self makePipline];
        
        
    }
    return self;
}



- (void)didMoveToSuperview{
    
    [super didMoveToSuperview];
    
    if (self.superview) {
        self.displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(displayLinkDidFire:)];
        [self.displayLink addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSRunLoopCommonModes];
        
        
        
    }else{
        
        
        [self.displayLink invalidate];
        self.displayLink = nil;
        
    }
    
    
}
-(void)displayLinkDidFire:(CADisplayLink*)displayLink{
    
    [self redraw];
    
}


-(void)makeDevice{
    
    _device = MTLCreateSystemDefaultDevice();
    _metalLayer = (CAMetalLayer*)self.layer;
    _metalLayer.device = _device;
    _metalLayer.pixelFormat = MTLPixelFormatBGRA8Unorm;
    _metalLayer.contentsScale = [UIScreen mainScreen].scale;
}

-(void)makeVertexBuffers{
    
    static const WXVertex vertices[] = {
        {.position = { 0.0,0.5,0,1},  .color = {1,0,0,1}},
        {.position = { -0.5,-0.5,0,1},.color = {0,1,0,1}},
        {.position = { 0.5,-0.5,0,1}, .color = {0,0,1,1}},
    };
    
    
    self.vertexBuffer =   [self.device newBufferWithBytes:vertices length:sizeof(vertices) options:MTLResourceOptionCPUCacheModeDefault];
    
    
    
    
    
    
}

-(void)makePipline{
    
    //获取着色器 函数
    id <MTLLibrary> library =   [self.device newDefaultLibrary];
    
    id <MTLFunction> vertexFunc =   [library newFunctionWithName:@"vertex_main"];
    id <MTLFunction> fragmentFunc  =  [library newFunctionWithName:@"fragment_main"];
    // 设置 pipline descriptor
    MTLRenderPipelineDescriptor * piplineDescriptor =  [MTLRenderPipelineDescriptor new];
    
    piplineDescriptor.vertexFunction = vertexFunc;
    piplineDescriptor.fragmentFunction = fragmentFunc;
    piplineDescriptor.colorAttachments[0].pixelFormat = self.metalLayer.pixelFormat;
    
    self.pipline = [self.device newRenderPipelineStateWithDescriptor:piplineDescriptor error:NULL];
    
    
    self.commandQueue =  [self.device newCommandQueue];
    
    
    
}


-(void)redraw{
    // 获取 MTL可绘画对象
    id <CAMetalDrawable> drawable =   [self.metalLayer nextDrawable];
    id <MTLTexture> framebufferTexture =   drawable.texture;
    
    
    MTLRenderPassDescriptor * passDescriptor =   [MTLRenderPassDescriptor renderPassDescriptor];
    passDescriptor.colorAttachments[0].texture = framebufferTexture;
    passDescriptor.colorAttachments[0].clearColor = MTLClearColorMake(0.85, 0.85, 0.85, 1);
    passDescriptor.colorAttachments[0].loadAction = MTLLoadActionClear;
    passDescriptor.colorAttachments[0].storeAction = MTLStoreActionStore;
    
    
    
    // high level to low level
    
    id <MTLCommandBuffer> commandBuffer =   [self.commandQueue commandBuffer];
    
    id <MTLRenderCommandEncoder> commandEncoder =  [commandBuffer renderCommandEncoderWithDescriptor:passDescriptor];
    [commandEncoder setRenderPipelineState:self.pipline];
    [commandEncoder setVertexBuffer:self.vertexBuffer offset:0 atIndex:0];
    [commandEncoder drawPrimitives:MTLPrimitiveTypeTriangle vertexStart:0 vertexCount:3];
    
    [commandEncoder endEncoding];
    
    //绘画
    [commandBuffer presentDrawable:drawable];
    [commandBuffer commit];
    
    
}






@end
