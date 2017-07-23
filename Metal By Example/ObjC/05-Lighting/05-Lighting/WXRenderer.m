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
#import "WXMathUtilities.h"
#import "WXType.h"
#import "WXOBJMesh.h"
#import "WXOBJModel.h"
#import <simd/simd.h>


static const NSInteger WXInFlightBufferCount = 3;


@interface WXRenderer ()
/// gpu
@property (strong)  id<MTLDevice> device;
// 顶点缓冲区
@property (strong)  id<MTLBuffer> vertexBuffer;
// 顶点缓冲区
@property (strong)  id<MTLBuffer> indexBuffer;
/// ??缓冲区
@property (strong)  id<MTLBuffer> uniformBuffer;
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

@property(nonatomic,strong) WXMesh * mesh;
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
        [self makeResources];
        
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
    renderPiplineDes.fragmentFunction = [library newFunctionWithName:@"fragment_light"];
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
#pragma mark - resources - 

-(void)makeResources{
    /// 获取URL
    NSURL * url = [[NSBundle mainBundle] URLForResource:@"teapot" withExtension:@"obj"];
    ///
    WXOBJModel *model =  [[WXOBJModel alloc]initWithContentsOfURL:url generateNormals:YES];
    ///  选择 name 为 teapot 的 group
    WXOBJGroup * group = [model groupForName:@"teapot"];
    
    /// 获取 mesh 3D 数据
    _mesh = [[WXOBJMesh alloc] initWithGroup:group device:_device];

    
    _uniformBuffer = [self.device newBufferWithLength:sizeof(WXUniforms) * WXInFlightBufferCount options:MTLResourceCPUCacheModeDefaultCache];
    
    [_uniformBuffer setLabel:@"Uniforms"];
}

/**
 
 
 @param view <#view description#>
 @param duration <#duration description#>
 */
-(void)updateUniformsForView:(WXMetalView *)view duration:(NSTimeInterval)duration {
    
    self.time      += duration;
    self.rotationX += duration * (M_PI / 2 );
    self.rotationY += duration * (M_PI / 3 );
    
    float scaleFactor =  1;
    
    const vector_float3 xAxis = { 1, 0, 0 };
    const vector_float3 yAxis = { 0, 1, 0 };
    /// 1. model matirx
    const matrix_float4x4 xRot  =   matrix_float4x4_rotation(xAxis, self.rotationX);
    const matrix_float4x4 yRot  =   matrix_float4x4_rotation(yAxis, self.rotationY);
    const matrix_float4x4 scale =   matrix_float4x4_uniform_scale(scaleFactor);
    const matrix_float4x4 modelMatrix = matrix_multiply(matrix_multiply(xRot, yRot), scale);
    
    /// 2. view matrix
    /// 摄像头平移 {x,y,z}
    const vector_float3   cameraTranslation = { 0, 0, -1.5 };
    const matrix_float4x4 viewMatrix = matrix_float4x4_translation(cameraTranslation);
    
    ///
    const CGSize drawableSize = view.metalLayer.drawableSize;
    
    const float aspect = drawableSize.width / drawableSize.height;
    
    const float fov   = (2 * M_PI) / 5;
    const float near  = 0.1;
    const float far   = 100;
    // 3. projection matrix
    const matrix_float4x4 projectionMatrix  = matrix_float4x4_perspective(aspect, fov, near, far);
    
    ///
    WXUniforms uniforms;
    /// 4. get  MVP
    uniforms.modelViewMatrix = matrix_multiply(viewMatrix, modelMatrix);
    uniforms.modelViewProjectionMatrix = matrix_multiply(projectionMatrix, uniforms.modelViewMatrix);
    uniforms.normalMatrix = matrix_float4x4_extract_linear(uniforms.modelViewMatrix);
    
    
    const NSUInteger uniformBufferOffset = sizeof(WXUniforms) * self.bufferIndex;
    // set mvp offset
    memcpy([self.uniformBuffer contents] + uniformBufferOffset , &uniforms, sizeof(uniforms));
    
    
    
    
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
    
    [renderEncoder setVertexBuffer:self.mesh.vertexBuffer offset:0 atIndex:0];
    [renderEncoder setVertexBuffer:self.uniformBuffer offset:uniformBufferOffset atIndex:1];
    /// draw
    [renderEncoder drawIndexedPrimitives:MTLPrimitiveTypeTriangle
                              indexCount:[self.mesh.indexBuffer length] / sizeof(WXIndex)
                               indexType:WXIndexType
                             indexBuffer:self.mesh.indexBuffer
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
