//
//  WXRenderer.m
//  3.BasicBuffers
//
//  Created by williamxie on 26/07/2017.
//  Copyright © 2017 williamxie. All rights reserved.
//

#import "WXRenderer.h"
#import "WXShaderTypes.h"
#import <simd/simd.h>

@interface WXRenderer(){
    
    id<MTLDevice> _device;
    
    id<MTLCommandQueue> _commandQueue;
    
    id<MTLRenderPipelineState> _renderPiplineState;
    
    id<MTLBuffer> _vertexBuffer;
    
    // 视窗大小
    vector_uint2 _viewportSize;
    
    // 顶点个数
    NSUInteger _numberVertices;
}
@end

@implementation WXRenderer

- (instancetype)initWithMTKView:(MTKView *)mtkview{
    
    if (self = [super init]) {
        _device = mtkview.device;
        [self loadMetal:mtkview];
    }
    return self;
    
}

/**
 设置渲染管线
 
 @param mtkView <#mtkView description#>
 */
- (void)loadMetal:(nonnull MTKView *)mtkView {
    
    
    mtkView.colorPixelFormat = MTLPixelFormatBGRA8Unorm_sRGB;
    
    //metallibrary
    id <MTLLibrary> library = [_device newDefaultLibrary];
    id<MTLFunction> vertexFunction   = [library newFunctionWithName:@"vertexShader"];
    id<MTLFunction> fragmentFunction = [library newFunctionWithName:@"fragmentShader"];
    
    MTLRenderPipelineDescriptor * renderpiplineDescriptor =   [MTLRenderPipelineDescriptor new];
    
    // 1.renderpiplinestate
    renderpiplineDescriptor.label  = @"my pipline";
    renderpiplineDescriptor.vertexFunction = vertexFunction;
    renderpiplineDescriptor.fragmentFunction = fragmentFunction;
    renderpiplineDescriptor.colorAttachments[0].pixelFormat = mtkView.colorPixelFormat;
    
    NSError * error = nil;
    _renderPiplineState = [_device newRenderPipelineStateWithDescriptor:renderpiplineDescriptor error:&error];
    
    if (!_renderPiplineState) {
        NSLog(@"没有创建成功,%@",error);
        
    }
    
    // 2.纹理数据
    NSData * vertexData = [WXRenderer generateVertexData];
    
    // CPU 和 GPU 共享
    _vertexBuffer = [_device newBufferWithLength:vertexData.length options:MTLResourceStorageModeShared];
    
    memcpy(_vertexBuffer.contents, vertexData.bytes, vertexData.length);
    _numberVertices = vertexData.length / sizeof(WXVertex);
    
    //3.command queue
    _commandQueue = [_device newCommandQueue];
    
    
}


+(NSData*)generateVertexData{
    
    static const WXVertex quadVertices[] =
    {
        // Pixel Positions, RGBA colors
        { { -20,   20 },   { 1, 0, 0, 1 } },
        { {  20,   20 },   { 0, 0, 1, 1 } },
        { { -20,  -20 },   { 0, 1, 0, 1 } },
        
        { {  20,  -20 },   { 1, 0, 0, 1 } },
        { { -20,  -20 },   { 0, 1, 0, 1 } },
        { {  20,   20 },   { 0, 0, 1, 1 } },
    };
    const NSUInteger NUM_COLUMNS = 30;
    const NSUInteger NUM_ROWS = 20;
    const NSUInteger NUM_VERTICES_PER_QUAD = sizeof(quadVertices) / sizeof(WXVertex);
    const float QUAD_SPACING = 50.0;
    
    NSUInteger dataSize = sizeof(quadVertices) * NUM_COLUMNS * NUM_ROWS;
    NSMutableData *vertexData = [[NSMutableData alloc] initWithLength:dataSize];
    
    WXVertex* currentQuad = vertexData.mutableBytes;
    
    for(NSUInteger row = 0; row < NUM_ROWS; row++)
    {
        for(NSUInteger column = 0; column < NUM_COLUMNS; column++)
        {
            vector_float2 upperLeftPosition;
            upperLeftPosition.x = ((-((float)NUM_COLUMNS) / 2.0) + column) * QUAD_SPACING + QUAD_SPACING/2.0;
            upperLeftPosition.y = ((-((float)NUM_ROWS) / 2.0) + row) * QUAD_SPACING + QUAD_SPACING/2.0;
            
            memcpy(currentQuad, &quadVertices, sizeof(quadVertices));
            
            for (NSUInteger vertexInQuad = 0; vertexInQuad < NUM_VERTICES_PER_QUAD; vertexInQuad++)
            {
                currentQuad[vertexInQuad].position += upperLeftPosition;
            }
            
            currentQuad += 6;
        }
    }
    return vertexData;
}


#pragma mark - MTKViewDelegate -

- (void)mtkView:(MTKView *)view drawableSizeWillChange:(CGSize)size{
    
    // Save the size of the drawable as we'll pass these
    //   values to our vertex shader when we draw
    
    // 存储 可绘画对象的大小,
    //当需要绘制的是传递这些值给我们的顶点着色器.
    
    _viewportSize.x = size.width;
    _viewportSize.y = size.height;
    
}

- (void)drawInMTKView:(MTKView *)view{
    
    id<MTLCommandBuffer> commandBuffer = [_commandQueue commandBuffer];
    commandBuffer.label = @"My CommandBuffer";
    //1.passdescriptor
    
    MTLRenderPassDescriptor * passDescriptor =  view.currentRenderPassDescriptor;
    
    if (passDescriptor !=nil) {
        
      id<MTLRenderCommandEncoder> encoder =   [commandBuffer renderCommandEncoderWithDescriptor:passDescriptor];
        
        [encoder setViewport:(MTLViewport){0,0,_viewportSize.x,_viewportSize.y,-1.0,1.0}];
        
        [encoder setRenderPipelineState:_renderPiplineState];
        // 设置 buffer
        [encoder setVertexBuffer:_vertexBuffer
                          offset:0
                         atIndex:WXVertexInputIndexVertices];
        // 设置
        [encoder setVertexBytes:&_viewportSize
                         length:sizeof(_viewportSize)
                        atIndex:WXVertexInputIndexViewportSize];
        
        [encoder drawPrimitives:MTLPrimitiveTypeTriangle
                    vertexStart:0
                    vertexCount:_numberVertices];
        
        
        [encoder endEncoding];
        
        [commandBuffer presentDrawable:view.currentDrawable];
        
    }
    
    [commandBuffer commit];
    
    
}

@end
