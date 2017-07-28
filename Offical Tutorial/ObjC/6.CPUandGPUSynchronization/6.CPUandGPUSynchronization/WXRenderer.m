
//
//  WXRenderer.m
//  6.CPUandGPUSynchronization
//
//  Created by williamxie on 28/07/2017.
//  Copyright © 2017 williamxie. All rights reserved.
//

#import "WXRenderer.h"
#import <simd/simd.h>
#import "WXShaderTypes.h"


static const NSUInteger MaxBuffersInFlight = 3;

@interface WXSprite : NSObject

@property (nonatomic)  vector_float2 position;
@property (nonatomic)  vector_float4 color;

+(const WXVertex*)vertices;

+(NSUInteger)vertexCount;

@end


@implementation WXSprite

+ (const WXVertex*)vertices{
    
    const float SpriteSize = 5;
    
    static const WXVertex spriteVertices[] = {
        //Pixel Positions,                 RGBA colors
        { { -SpriteSize,   SpriteSize },   { 0, 0, 0, 1 } },
        { {  SpriteSize,   SpriteSize },   { 0, 0, 0, 1 } },
        { { -SpriteSize,  -SpriteSize },   { 0, 0, 0, 1 } },
        
        { {  SpriteSize,  -SpriteSize },   { 0, 0, 0, 1 } },
        { { -SpriteSize,  -SpriteSize },   { 0, 0, 0, 1 } },
        { {  SpriteSize,   SpriteSize },   { 0, 0, 1, 1 } },
    };
    
    return spriteVertices;
    
}

+(NSUInteger)vertexCount{
    
    return 6;
}

@end




@interface WXRenderer(){
    
    dispatch_semaphore_t _inFlightSemaphore;
    
    id<MTLDevice> _device;
    id<MTLCommandQueue> _commandQueue;
    
    id<MTLRenderPipelineState> _piplineState;
    
    id<MTLBuffer> _vertexBuffers[MaxBuffersInFlight];
    
    vector_uint2 _viewportSize;
    
    NSUInteger _currentBuffer;
    
    NSArray<WXSprite*> *_sprites;
    
    NSUInteger _spritesPerRow;
    
    NSUInteger _rowsOfSprites;
    
    NSUInteger _totalSpriteVertexCount;
    
}

@end



@implementation WXRenderer

#pragma mark - Life Circle -

- (instancetype)initWithMetalKitView:(MTKView *)mtkview{
    
    if (self = [super init]) {
        //
        _device = mtkview.device;
        // 创建信号量
        _inFlightSemaphore = dispatch_semaphore_create(MaxBuffersInFlight);
        
        id<MTLLibrary>  defaultLibrary   = [_device newDefaultLibrary];
        id<MTLFunction> vertexFunction   = [defaultLibrary newFunctionWithName:@"vertexShader"];
        id<MTLFunction> fragmentFunction = [defaultLibrary newFunctionWithName:@"fragmentShader"];
        
        MTLRenderPipelineDescriptor *piplineStateDescriptor =  [[MTLRenderPipelineDescriptor alloc] init];
        
        piplineStateDescriptor.label = @"MyPipline";
        piplineStateDescriptor.sampleCount = mtkview.sampleCount;
        piplineStateDescriptor.vertexFunction = vertexFunction;
        piplineStateDescriptor.fragmentFunction = fragmentFunction;
        piplineStateDescriptor.colorAttachments[0].pixelFormat = mtkview.colorPixelFormat;
        piplineStateDescriptor.depthAttachmentPixelFormat = mtkview.depthStencilPixelFormat;
        piplineStateDescriptor.stencilAttachmentPixelFormat = mtkview.depthStencilPixelFormat;
        
        NSError * error = nil;
        
        _piplineState = [_device newRenderPipelineStateWithDescriptor:piplineStateDescriptor
                                                                error:&error];
        
        if (!_piplineState) {
            NSLog(@"Failed to crated pipline stated ,error %@",error);
        }
        
        _commandQueue = [_device newCommandQueue];
        
        //创建数据
        
        [self generateSprites];
        
        //
        _totalSpriteVertexCount = WXSprite.vertexCount * _sprites.count;
        
        
        NSUInteger spriteVertexBufferSize = _totalSpriteVertexCount * sizeof(WXVertex);
        
        
        for (NSUInteger bufferIndex = 0; bufferIndex < MaxBuffersInFlight ; bufferIndex++) {
            _vertexBuffers[bufferIndex] = [_device newBufferWithLength:spriteVertexBufferSize
                                                               options:MTLResourceStorageModeShared];
        }
        
        
    }
    return self;
}

-(void)generateSprites{
    
    const float XSpacing = 12;
    const float YSpacing = 16;
    
    const NSUInteger SpritesPerRow = 110;
    const NSUInteger RowsOfSprites = 50;
    const float WaveMagnitude = 30.0;
    
    const vector_float4 Colors[] =
    {
        { 1.0, 0.0, 0.0, 1.0 },  // Red
        { 0.0, 1.0, 1.0, 1.0 },  // Cyan
        { 0.0, 1.0, 0.0, 1.0 },  // Green
        { 1.0, 0.5, 0.0, 1.0 },  // Orange
        { 1.0, 0.0, 1.0, 1.0 },  // Magenta
        { 0.0, 0.0, 1.0, 1.0 },  // Blue
        { 1.0, 1.0, 0.0, 1.0 },  // Yellow
        { .75, 0.5, .25, 1.0 },  // Brown
        { 1.0, 1.0, 1.0, 1.0 },  // White
        
    };
    //颜色个数
    const NSUInteger NumColors = sizeof(Colors) / sizeof(vector_float4);
    //
    _spritesPerRow = SpritesPerRow;
    _rowsOfSprites = RowsOfSprites;
    
    NSMutableArray *sprites = [[NSMutableArray alloc] initWithCapacity:_rowsOfSprites * _spritesPerRow];
    
    // Create a grid of 'sprite' objects
    //
    for(NSUInteger row = 0; row < _rowsOfSprites; row++)
    {
        for(NSUInteger column = 0; column < _spritesPerRow; column++)
        {
            vector_float2 spritePosition;
            
            // Determine the positon of our sprite in the grid
            spritePosition.x = ((-((float)_spritesPerRow) / 2.0) + column) * XSpacing;
            spritePosition.y = ((-((float)_rowsOfSprites) / 2.0) + row) * YSpacing + WaveMagnitude;
            
            // Displace the height of this sprite using a sin wave
            spritePosition.y += (sin(spritePosition.x/WaveMagnitude) * WaveMagnitude);
            
            // Create our sprite, set its properties and add it to our list
            WXSprite * sprite = [WXSprite new];
            
            sprite.position = spritePosition;
            sprite.color = Colors[row%NumColors];
            
            [sprites addObject:sprite];
        }
    }
    _sprites = sprites;
}


#pragma mark - MTKViewDelegate -
-(void)updateState{
    
    // Change the position of the sprites by getting taking on the height of the sprite
    //  immediately to the right of the current sprite.
    
    WXVertex *currentSpriteVertices = _vertexBuffers[_currentBuffer].contents;
    NSUInteger  currentVertex = _totalSpriteVertexCount-1;
    NSUInteger  spriteIdx = (_rowsOfSprites * _spritesPerRow)-1;
    
    for(NSInteger row = _rowsOfSprites - 1; row >= 0; row--)
    {
        float startY = _sprites[spriteIdx].position.y;
        for(NSInteger spriteInRow = _spritesPerRow-1; spriteInRow >= 0; spriteInRow--)
        {
            // Update the position of our sprite
            vector_float2 updatedPosition = _sprites[spriteIdx].position;
            
            if(spriteInRow == 0)
            {
                updatedPosition.y = startY;
            }
            else
            {
                updatedPosition.y = _sprites[spriteIdx-1].position.y;
            }
            
            _sprites[spriteIdx].position = updatedPosition;
            
            // Update vertices of the current vertex buffer with the sprites new position
            
            for(NSInteger vertexOfSprite = WXSprite.vertexCount-1; vertexOfSprite >= 0 ; vertexOfSprite--)
            {
                currentSpriteVertices[currentVertex].position = WXSprite.vertices[vertexOfSprite].position + _sprites[spriteIdx].position;
                currentSpriteVertices[currentVertex].color = _sprites[spriteIdx].color;
                currentVertex--;
            }
            spriteIdx--;
        }
    }
}


- (void)mtkView:(MTKView *)view drawableSizeWillChange:(CGSize)size{
    
    _viewportSize.x = size.width;
    _viewportSize.y = size.height;
    
}

- (void)drawInMTKView:(MTKView *)view{
    
    
    // wait ensure only MaxBufferInFlight
    
    // signal -1
    //
    dispatch_semaphore_wait(_inFlightSemaphore, DISPATCH_TIME_FOREVER);
    // 循环
    // 目的更新渲染数据
    _currentBuffer = (_currentBuffer + 1 ) % MaxBuffersInFlight;
    
    [self updateState];
    
    
    
    id<MTLCommandBuffer> commandBuffer = [_commandQueue commandBuffer];
    commandBuffer.label  = @"MyCommand";
    
    //添加回调
    __block dispatch_semaphore_t block_sema = _inFlightSemaphore;
    
    [commandBuffer addCompletedHandler:^(id<MTLCommandBuffer> buffer) {
        dispatch_semaphore_signal(block_sema);
    }];
    
    MTLRenderPassDescriptor * renderPassDescriptor = view.currentRenderPassDescriptor;
    
    if (renderPassDescriptor != nil) {
        
        id<MTLRenderCommandEncoder> renderEncoder = [commandBuffer renderCommandEncoderWithDescriptor:renderPassDescriptor];
        renderEncoder.label = @"MYRenderEncoder";
        
        
        [renderEncoder setCullMode:MTLCullModeBack];
        [renderEncoder setRenderPipelineState:_piplineState];
        
        
        
        
        [renderEncoder setVertexBuffer:_vertexBuffers[_currentBuffer]
                                offset:0
                               atIndex:WXVertexInputIndexVertices];
        
        [renderEncoder setVertexBytes:&_viewportSize
                               length:sizeof(_viewportSize)
                              atIndex:WXVertexInputIndexViewportSize];
        
        
        [renderEncoder drawPrimitives:MTLPrimitiveTypeTriangle
                          vertexStart:0
                          vertexCount:_totalSpriteVertexCount];
        
        [renderEncoder endEncoding];
        
        [commandBuffer presentDrawable:view.currentDrawable];
        
        
    }
    
    [commandBuffer commit];
    
}


@end
