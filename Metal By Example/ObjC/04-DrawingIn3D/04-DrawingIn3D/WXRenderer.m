//
//  WXRenderer.m
//  04-DrawingIn3D
//
//  Created by williamxie on 04/06/2017.
//  Copyright © 2017 williamxie. All rights reserved.
//

#import "WXRenderer.h"
#import <Metal/Metal.h>
#import <simd/simd.h>
#import "WXMathUItilties.h"

///
static const NSInteger WXInFlightBufferCount = 3;

/// 顶点
typedef uint16_t WXIndex;

/// 索引类型
const MTLIndexType WXIndexType = MTLIndexTypeUInt16;


/// 顶点数据
typedef struct {
    vector_float4 position;
    vector_float4 color;
}WXVertex;

///
typedef struct {
    
    matrix_float4x4 modelViewProjectionMatrix;
    
}WXUniforms;


@interface WXRenderer ()
/// gpu
@property (strong)  id<MTLDevice> device;
// 顶点缓冲区
@property (strong)  id<MTLBuffer> vertexBuffer;
// 顶点缓冲区
@property (strong)  id<MTLBuffer> indexBuffer;
/// ??缓冲区
@property (strong)  id<MTLBuffer> uniformsBuffer;
/// 命令队列
@property(strong)   id<MTLCommandQueue> commandQueue;
/// 渲染管线 状态
@property (strong)  id<MTLRenderPipelineState> renderPipelineState;
/// 深度 状态
@property (strong)  id <MTLDepthStencilState> depthStencilState;
///
@property (strong)  dispatch_semaphore_t displaySemaphore;
///
@property (assign)  NSInteger bufferIndex;
/// x,y 时间
@property (assign)  float rotationX,rotationY,time;


@end

@implementation WXRenderer

- (instancetype)init{
    
    if (self = [super init]){
        // GPU
        _device = MTLCreateSystemDefaultDevice();
        /// 信号
        _displaySemaphore = dispatch_semaphore_create(WXInFlightBufferCount);
        ///  创建渲染管线
        [self makePipline];
        ///  创建缓冲区
        [self makeBuffers];
        
    }
    return self;
}


#pragma mark - PipLine -

-(void)makePipline{
    
    /// 
    self.commandQueue = [self.device newCommandQueue];
    ///  获取mtl library
    id<MTLLibrary> library = [self.device newDefaultLibrary];
    
    // 1.渲染管线
    MTLRenderPipelineDescriptor * renderPiplineDes = [MTLRenderPipelineDescriptor new];
    //
    renderPiplineDes.vertexFunction = [library newFunctionWithName:@"vertex_project"];
    //
    renderPiplineDes.fragmentFunction = [library newFunctionWithName:@"fragment_flatcolor"];
    //
    renderPiplineDes.colorAttachments[0].pixelFormat = MTLPixelFormatBGRA8Unorm;
    //
    renderPiplineDes.depthAttachmentPixelFormat = MTLPixelFormatDepth32Float;
    
    NSError * error = nil;
    
    self.renderPipelineState = [self.device newRenderPipelineStateWithDescriptor:renderPiplineDes
                                                                           error:&error];
    
    ///2.深度
    MTLDepthStencilDescriptor * depthStencilDes =  [MTLDepthStencilDescriptor new];
    ///
    depthStencilDes.depthCompareFunction = MTLCompareFunctionLess;
    ///
    depthStencilDes.depthWriteEnabled = YES;
    ///
    self.depthStencilState = [self.device newDepthStencilStateWithDescriptor:depthStencilDes];
    
    if (!self.renderPipelineState) {
        NSLog(@"Error occured when crateing render pipline state :%@",error);
    }
    
    ///3.
    self.commandQueue = [self.device newCommandQueue];
}


#pragma mark - Buffers -

/**
 Data Buffer
 */
-(void)makeBuffers{
    //顶点数组
    static const WXVertex vertices[] = {
        
        { .position = { -1,  1,  1, 1 }, .color = { 0, 1, 1, 1 } },
        { .position = { -1, -1,  1, 1 }, .color = { 0, 0, 1, 1 } },
        { .position = {  1, -1,  1, 1 }, .color = { 1, 0, 1, 1 } },
        { .position = {  1,  1,  1, 1 }, .color = { 1, 1, 1, 1 } },
        { .position = { -1,  1, -1, 1 }, .color = { 0, 1, 0, 1 } },
        { .position = { -1, -1, -1, 1 }, .color = { 0, 0, 0, 1 } },
        { .position = {  1, -1, -1, 1 }, .color = { 1, 0, 0, 1 } },
        { .position = {  1,  1, -1, 1 }, .color = { 1, 1, 0, 1 } }
        
    };
    // 索引数组
    static const WXIndex indices[] =
    {
        3, 2, 6, 6, 7, 3,
        4, 5, 1, 1, 0, 4,
        4, 0, 3, 3, 7, 4,
        1, 5, 6, 6, 2, 1,
        0, 1, 2, 2, 3, 0,
        7, 6, 5, 5, 4, 7
    };
    // 1. 顶点
    _vertexBuffer = [self.device newBufferWithBytes:vertices
                                 length:sizeof(vertices)
                                 options:MTLResourceCPUCacheModeDefaultCache];
    
    
    [_vertexBuffer setLabel:@"Vertices"];
    // 2. 索引
    _indexBuffer = [self.device newBufferWithBytes:indices
                                length:sizeof(indices)
                                options:MTLResourceCPUCacheModeDefaultCache];
    
    [_indexBuffer setLabel:@"Indices"];
    
    // 3. uniforms
    _uniformsBuffer = [self.device newBufferWithLength:sizeof(WXUniforms) * WXInFlightBufferCount
                                   options:MTLResourceCPUCacheModeDefaultCache];
    
    [_uniformsBuffer setLabel:@"Uniforms"];
    
}

/**
 

 @param view <#view description#>
 @param duration <#duration description#>
 */
-(void)updateUniformsForView:(WXMetalView *)view duration:(NSTimeInterval)duration {
    
    self.time      += duration;
    self.rotationX += duration * (M_PI /2 );
    self.rotationY += duration * (M_PI /3 );
    
    float scaleFactor = sinf(5 * self.time) * 0.25 + 1;
    
    const vector_float3 xAxis = { 1, 0, 0 };
    const vector_float3 yAxis = { 0, 1, 0 };
    /// 1. model matirx
    const matrix_float4x4 xRot  =   matrix_float4x4_rotation(xAxis, self.rotationX);
    const matrix_float4x4 yRot  =   matrix_float4x4_rotation(yAxis, self.rotationY);
    const matrix_float4x4 scale =   matrix_float4x4_uniform_scale(scaleFactor);
    const matrix_float4x4 modelMatrix = matrix_multiply(matrix_multiply(xRot, yRot), scale);
    
    /// 2. view matrix
    /// 摄像头平移 {x,y,z}
    const vector_float3   cameraTranslation = { 0, 0, -5 };
    const matrix_float4x4 viewMatrix = matrix_float4x4_translation(cameraTranslation);
    
    ///
    const CGSize drawableSize = view.metalLayer.drawableSize;
    
    const float aspect = drawableSize.width / drawableSize.height;
    
    const float fov   = (2 * M_PI) / 5;
    const float near  = 1;
    const float far   = 100;
    // 3. projection matrix
    const matrix_float4x4 projectionMatrix  = matrix_float4x4_perspective(aspect, fov, near, far);
    
    ///
    WXUniforms uniforms;
    /// 4. get  MVP
    uniforms.modelViewProjectionMatrix = matrix_multiply(projectionMatrix, matrix_multiply(viewMatrix, modelMatrix));
    //
    
    const NSUInteger uniformBufferOffset = sizeof(WXUniforms) * self.bufferIndex;
    // set mvp offset
    memcpy([self.uniformsBuffer contents] + uniformBufferOffset , &uniforms, sizeof(uniforms));
    
    
    
    
}

#pragma mark - WXMetalViewDelegate -

- (void)drawInView:(WXMetalView *)view{
    
    // 等待信号
    dispatch_semaphore_wait(self.displaySemaphore, DISPATCH_TIME_FOREVER);
    
    view.clearColor = MTLClearColorMake(0.95, 0.95, 0.95, 1);
    // 1.
    // upadte uniforms
    // update  MVP
    [self updateUniformsForView:view duration:view.frameDuration];
    //
    // 2. encoder
    id <MTLCommandBuffer> commandBuffer = [self.commandQueue commandBuffer];
    //
    MTLRenderPassDescriptor * passDescriptor = [view currentRenderPassDescriptor];
    //
    id<MTLRenderCommandEncoder> renderEncoder = [commandBuffer renderCommandEncoderWithDescriptor:passDescriptor];
    /// state
    [renderEncoder setRenderPipelineState:self.renderPipelineState];
    ///
    [renderEncoder setDepthStencilState:self.depthStencilState];
    ///
    [renderEncoder setFrontFacingWinding:MTLWindingCounterClockwise];
    ///
    [renderEncoder setCullMode:MTLCullModeBack];
    
    
    // buffer
    
    const NSUInteger uniformBufferOffset = sizeof(WXUniforms) * self.bufferIndex;
    
    [renderEncoder setVertexBuffer:self.vertexBuffer offset:0 atIndex:0];
    [renderEncoder setVertexBuffer:self.uniformsBuffer offset:uniformBufferOffset atIndex:1];
    /// draw
    [renderEncoder drawIndexedPrimitives:MTLPrimitiveTypeTriangle
                   indexCount:[self.indexBuffer length] / sizeof(WXIndex)
                   indexType:WXIndexType
                   indexBuffer:self.indexBuffer
                   indexBufferOffset:0];
    
    
    [renderEncoder endEncoding];
    
    
    [commandBuffer presentDrawable:view.currentDrawable];
    
    
    [commandBuffer addCompletedHandler:^(id<MTLCommandBuffer> commandBuffer) {
        self.bufferIndex = (self.bufferIndex + 1) % WXInFlightBufferCount;
        
        dispatch_semaphore_signal(self.displaySemaphore);
    }];
    
    [commandBuffer commit];
    
}


@end
