//
//  WXRenderer.m
//  5.HelloCompute
//
//  Created by williamxie on 27/07/2017.
//  Copyright © 2017 williamxie. All rights reserved.
//

#import "WXRenderer.h"
#import "WXShaderTypes.h"
#import <simd/simd.h>

#import "WXImage.h"


@interface WXRenderer(){
    //GPU 抽象
    id<MTLDevice> _device;
    // command queue
    id<MTLCommandQueue> _commandQueue;
    // viewportSize
    vector_uint2 _viewportSize;
    
    
    //renderer property
    id<MTLRenderPipelineState> _renderPipLineState;
    id<MTLComputePipelineState> _computePipLineState;
    id<MTLTexture> _inputTexture;
    id<MTLTexture> _outputTexture;
    
    //compute kernel parameters
    // 线程组 大小
    MTLSize _threadgroupSize;
    // 线程组 个数
    MTLSize _threadgroupCount;
    
    
}
@end

@implementation WXRenderer


#pragma mark - life cycircle -

- (instancetype)initWithMetalKitView:(MTKView *)mtkview{
    
    if (self = [super init]) {
        
        _device = mtkview.device;
        
        mtkview.colorPixelFormat = MTLPixelFormatBGRA8Unorm_sRGB;
        
        NSError * error = nil;
        //
        id<MTLLibrary> defaultLibrary = [_device newDefaultLibrary];
        
        id<MTLFunction> kernelFunction = [defaultLibrary newFunctionWithName:@"grayscaleKernel"];
        _computePipLineState = [_device newComputePipelineStateWithFunction:kernelFunction
                                                                      error:&error];
        
        if (!_computePipLineState) {
            NSLog(@"%@",error);
            
        }
        
        // renderpiplineState
        id<MTLFunction> vertexFunction = [defaultLibrary newFunctionWithName:@"vertexShader"];
        id<MTLFunction> fragmentFunction = [defaultLibrary newFunctionWithName:@"samplingShader"];
        
        MTLRenderPipelineDescriptor * piplineStateDescriptor = [[MTLRenderPipelineDescriptor alloc]init];
        
        piplineStateDescriptor.label  = @"simple pipline";
        piplineStateDescriptor.vertexFunction = vertexFunction;
        piplineStateDescriptor.fragmentFunction = fragmentFunction;
        piplineStateDescriptor.colorAttachments[0].pixelFormat = mtkview.colorPixelFormat;
        _renderPipLineState = [_device newRenderPipelineStateWithDescriptor:piplineStateDescriptor
                                                                      error:&error];
        if (!_renderPipLineState ) {
            NSLog(@"render pipline error %@",error);
            
        }
        
        NSURL * imageFileLocation = [[NSBundle mainBundle] URLForResource:@"Image"
                                                            withExtension:@"tga"];
        
        WXImage * image = [[WXImage alloc]initWithTGAFileAtLocation:imageFileLocation];
        
        if (!image) {
            return nil;
        }
        //纹理
        MTLTextureDescriptor * textureDescriptor = [[MTLTextureDescriptor alloc]init];
        textureDescriptor.textureType = MTLTextureType2D;
        textureDescriptor.pixelFormat = MTLPixelFormatBGRA8Unorm;
        textureDescriptor.width = image.width;
        textureDescriptor.height = image.height;
        // read
        textureDescriptor.usage = MTLTextureUsageShaderRead;
        
        // 输入纹理
        _inputTexture = [_device newTextureWithDescriptor:textureDescriptor];
        // 重用
        textureDescriptor.usage = MTLTextureUsageShaderWrite | MTLTextureUsageShaderRead;
        //输出纹理
        _outputTexture = [_device newTextureWithDescriptor:textureDescriptor];
        
        MTLRegion region = {
            {0,0,0},
            {textureDescriptor.width,textureDescriptor.height,1}
        };
        
        
        NSUInteger bytesPerRow = 4 * textureDescriptor.width;
        
        [_inputTexture replaceRegion:region
                         mipmapLevel:0
                           withBytes:image.data.bytes
                         bytesPerRow:bytesPerRow];
        if (!_inputTexture || error) {
            NSLog(@"%@",error.localizedDescription);
            return nil;
        }
        
        // 设置 {width,height,depth}
        //16x16
        //?
        _threadgroupSize = MTLSizeMake(16, 16, 1);
        
        _threadgroupCount.width = (_inputTexture.width + _threadgroupSize.width - 1 ) / _threadgroupSize.width;
        
        _threadgroupCount.height = (_inputTexture.height + _threadgroupSize.height - 1) / _threadgroupSize.height;
        
        // 2d depth = 1
        _threadgroupCount.depth = 1;
        
        
        _commandQueue = [_device newCommandQueue];
        
    }
    
    return self;
}


#pragma mark - MTKViewDelegate -

- (void)mtkView:(MTKView *)view drawableSizeWillChange:(CGSize)size{
    _viewportSize.x = size.width;
    _viewportSize.y = size.height;
}


// 思路就是 先使用 计算管线 进行 处理 ,然后 输出作为 渲染管线的输入 进行显示.
- (void)drawInMTKView:(MTKView *)view{
    
    static const WXVertex quadVertices[] =
    {
        //Pixel Positions, Texture Coordinates
        { {  250,  -250 }, { 1.f, 0.f } },
        { { -250,  -250 }, { 0.f, 0.f } },
        { { -250,   250 }, { 0.f, 1.f } },
        
        { {  250,  -250 }, { 1.f, 0.f } },
        { { -250,   250 }, { 0.f, 1.f } },
        { {  250,   250 }, { 1.f, 1.f } },
    };
    
    
    
    // 1. compute encoder
    
    id<MTLCommandBuffer> commandBuffer = [_commandQueue commandBuffer];
    commandBuffer.label = @"MyCommandBuffer";
    
   id<MTLComputeCommandEncoder> computerEncoder = [commandBuffer computeCommandEncoder];
    
    [computerEncoder setComputePipelineState:_computePipLineState];
    
    //设置输入
    [computerEncoder setTexture:_inputTexture
                        atIndex:WXTextureIndexInput];
    //设置输出
    [computerEncoder setTexture:_outputTexture
                        atIndex:WXTextureIndexOutPut];
    
    //
    [computerEncoder dispatchThreadgroups:_threadgroupCount
                    threadsPerThreadgroup:_threadgroupSize];
    
    [computerEncoder endEncoding];
    
    // 2. renderEncoder
    
          MTLRenderPassDescriptor * renderPassDescriptor =     view.currentRenderPassDescriptor;
    if (renderPassDescriptor != nil) {
        
        id<MTLRenderCommandEncoder> renderEnocder = [commandBuffer renderCommandEncoderWithDescriptor:renderPassDescriptor];
        
        // 1.viewportSize
        // 设置 视窗
        [renderEnocder setViewport:(MTLViewport){0.0,0.0,_viewportSize.x,_viewportSize.y,-1.0,1.0}];
        
        //设置渲染管线
        [renderEnocder setRenderPipelineState:_renderPipLineState];
        
        
        [renderEnocder setVertexBytes:quadVertices
                               length:sizeof(quadVertices)
                              atIndex:WXVertexInputIndexVertices];
        
        [renderEnocder setVertexBytes:&_viewportSize
                               length:sizeof(_viewportSize)
                              atIndex:WXVertexInputIndexViewportSize];
        
        // compute Encoder 输出 就 纹理输入
        [renderEnocder setFragmentTexture:_outputTexture
                                  atIndex:WXTextureIndexOutPut];
        
        [renderEnocder drawPrimitives:MTLPrimitiveTypeTriangle
                          vertexStart:0
                          vertexCount:6];
        [renderEnocder endEncoding];
        
        [commandBuffer presentDrawable:view.currentDrawable];
        
    }
    
    [commandBuffer commit];
    
}









@end
