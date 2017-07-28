//
//  WXRenderer.m
//  4.BasicTexturing
//
//  Created by williamxie on 27/07/2017.
//  Copyright © 2017 williamxie. All rights reserved.
//

#import "WXRenderer.h"
#import <simd/simd.h>
#import "WXShaderTypes.h"
#import "WXImage.h"


@interface WXRenderer(){
    
    id<MTLDevice> _device;
    
    id<MTLCommandQueue> _commandQueue;
    
    id<MTLRenderPipelineState> _piplineState;
    
    id<MTLTexture> _texture;
    
    id<MTLBuffer> _vertices;
    
    NSUInteger _numVertices;
    
    vector_uint2 _viewportSize;
    
    
}
@end


@implementation WXRenderer

- (instancetype)initWithMetakKitView:(MTKView *)mtkview{
    
    if (self = [super init]) {
        _device = mtkview.device;
        //加载图片数据
        NSURL *imageFileLocation = [[NSBundle mainBundle] URLForResource:@"Image" withExtension:@"tga"];
        
        WXImage * image = [[WXImage alloc]initWithTGAFileAtLocation:imageFileLocation];
        
        if (!image) {
            NSLog(@"error now image");
            return nil;
        }
        // 创建纹理容器
        MTLTextureDescriptor * textureDescriptor = [[MTLTextureDescriptor alloc]init];
        textureDescriptor.pixelFormat = MTLPixelFormatBGRA8Unorm;
        textureDescriptor.width  = image.width;
        textureDescriptor.height = image.height;
        
        _texture = [_device newTextureWithDescriptor:textureDescriptor];
        
        NSUInteger bytesPerRow = 4 * image.width;
        
        MTLRegion region = {
            {0,0,0}, // MTLOrigin
            {image.width,image.height,1} //MTLSize
            
        };
        
        //对 纹理复制
        [_texture replaceRegion:region
                    mipmapLevel:0
                      withBytes:image.data.bytes
                    bytesPerRow:bytesPerRow];
        
        
        
        static const WXVertex quadVertices[] = {
            // Pixel Positions, Texture Coordinates
            { {  250,  -250 }, { 1.f, 0.f } },
            { { -250,  -250 }, { 0.f, 0.f } },
            { { -250,   250 }, { 0.f, 1.f } },
            
            { {  250,  -250 }, { 1.f, 0.f } },
            { { -250,   250 }, { 0.f, 1.f } },
            { {  250,   250 }, { 1.f, 1.f } },
        };
        
        _vertices = [_device newBufferWithBytes:quadVertices
                                         length:sizeof(quadVertices)
                                        options:MTLResourceStorageModeShared];
        
        _numVertices  = sizeof(quadVertices) / sizeof(WXVertex);
        
        id<MTLLibrary> defaultLibrary = [_device newDefaultLibrary];
        id<MTLFunction> vertexFunction = [defaultLibrary newFunctionWithName:@"vertexShader"];
        id<MTLFunction> fragmentFunction = [defaultLibrary newFunctionWithName:@"samplingShader"];
        
        
        MTLRenderPipelineDescriptor * renderpiplineDescriptor = [[MTLRenderPipelineDescriptor alloc]init];
        
        renderpiplineDescriptor.label = @"Texture Pipline";
        renderpiplineDescriptor.vertexFunction = vertexFunction;
        renderpiplineDescriptor.fragmentFunction = fragmentFunction;
        renderpiplineDescriptor.colorAttachments[0].pixelFormat = mtkview.colorPixelFormat;
        
        NSError * error = nil;
        _piplineState = [_device newRenderPipelineStateWithDescriptor:renderpiplineDescriptor error:&error];
        
        
        if (!_piplineState) {
            NSLog(@"error %@",error);
        }
        
        _commandQueue = [_device newCommandQueue];
        
    }
    return self;
    
}



#pragma mark - MTKViewDelegate -

- (void)mtkView:(MTKView *)view drawableSizeWillChange:(CGSize)size{
    
    _viewportSize.x  = size.width;
    _viewportSize.y  = size.height;
}

- (void)drawInMTKView:(MTKView *)view{
    
    
    id<MTLCommandBuffer> commandBuffer = [_commandQueue commandBuffer];
    commandBuffer.label = @"MyCommand";
    
    //encoder
    
    MTLRenderPassDescriptor* renderPassDescriptor =  view.currentRenderPassDescriptor;
    
    if (renderPassDescriptor != nil) {
        id<MTLRenderCommandEncoder> renderEncoder =
        [commandBuffer renderCommandEncoderWithDescriptor:renderPassDescriptor];
        renderEncoder.label = @"My Encoder";
        
        //1.viewport
        // 设置region
        [renderEncoder setViewport:(MTLViewport){0.0,0.0,_viewportSize.x,_viewportSize.y,-1.0,1.0}];
        
        // 设置渲染管线状态
        [renderEncoder setRenderPipelineState:_piplineState];
        
        //设置Buffer
        // 顶点数据
        // 创建正方形
        // 使用enum 来设置index
        [renderEncoder setVertexBuffer:_vertices
                                offset:0
                               atIndex:WXVertexInputIndexVertices];
        
        //设置ViewPortSize
        
        [renderEncoder setVertexBytes:&_viewportSize
                               length:sizeof(_viewportSize)
                              atIndex:WXVertexInputIndexViewportSize];
        
        //设置Texture
        //
        
        [renderEncoder setFragmentTexture:_texture
                                  atIndex:WXTextureIndexBaseColor];
        
        
        
        //绘制的基础形状
        // 三角形
        // 正方形 or ??
        [renderEncoder drawPrimitives:MTLPrimitiveTypeTriangle
                          vertexStart:0
                          vertexCount:_numVertices];
        
        
        [renderEncoder endEncoding];
        
        [commandBuffer presentDrawable:view.currentDrawable];
    }
    
    
    [commandBuffer commit];
    
}


@end
