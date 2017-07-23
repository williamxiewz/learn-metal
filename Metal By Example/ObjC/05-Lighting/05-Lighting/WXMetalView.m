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

/**
 当前的可绘画对象
 */
@property(strong) id<CAMetalDrawable> currentDrawable;

/**
 前一帧的持续时间
 */
@property (assign) NSTimeInterval frameDuration;

/**
 深度纹理
 */
@property(strong) id<MTLTexture> depthTexture;

/**
 定时器
 */
@property(strong) CADisplayLink *displayLink;

@end

@implementation WXMetalView




#pragma mark - life circle -

+ (Class)layerClass{
    return [CAMetalLayer class];
}


- (instancetype)initWithCoder:(NSCoder *)aDecoder{
    
    if(self = [super initWithCoder:aDecoder]){
        // 初始化
        [self commonInit];
        //
        self.metalLayer.device = MTLCreateSystemDefaultDevice();
        
    }
    return self;
    
}


- (instancetype)initWithFrame:(CGRect)frame device:(id<MTLDevice>) device{
    
    if( self = [super initWithFrame:frame]){
        [self commonInit];
        self.metalLayer.device = device;
    }
    return self;
}



- (void)didMoveToWindow{
    // 时间
    const NSTimeInterval idealFrameDuration  = (1.0 / 60);
    // 时间
    const NSTimeInterval targetFrameDuration = (1.0 / self.preferredFramePerSecond);
    // aspect
    const NSTimeInterval frameInterval  = round(targetFrameDuration / idealFrameDuration);
    
    if(self.window) {
        
        [self.displayLink invalidate];
        self.displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(displayLinkDidFire:)];
        self.displayLink.frameInterval = frameInterval;
        [self.displayLink addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSRunLoopCommonModes];
        
    }else{
        
        [self.displayLink invalidate];
        self.displayLink = nil;
        
    }
    
    
    
}

#pragma mark - private method

-(void)displayLinkDidFire:(CADisplayLink*)displayLink{
    
    // lastest  drawable
    self.currentDrawable = [self.metalLayer nextDrawable];
    self.frameDuration = displayLink.duration;
    // 渲染
    if([self.delegate respondsToSelector:@selector(drawInView:)]){
        [self.delegate drawInView:self];
        
    }
    
    
    
}
#pragma mark - init -


/**
 通用初始化 设置
 */
-(void)commonInit{
    // 设置 60 fps
    _preferredFramePerSecond = 60;
    //
    _clearColor = MTLClearColorMake(1, 1, 1, 1);
    //
    self.metalLayer.pixelFormat = MTLPixelFormatBGRA8Unorm;
}


/**
 设置深度纹理
 */
-(void)makeDepthTexture{
    
    CGSize drawableSize =  self.metalLayer.drawableSize;
    
    if([self.depthTexture width] != drawableSize.width||
       [self.depthTexture height] != drawableSize.height){
        //1.创建纹理描述
        MTLTextureDescriptor *desc = [MTLTextureDescriptor texture2DDescriptorWithPixelFormat: MTLPixelFormatDepth32Float
                                                                                        width:drawableSize.width
                                                                                       height:drawableSize.height
                                                                                    mipmapped:NO];
        //2.创建纹理
        self.depthTexture = [self.metalLayer.device newTextureWithDescriptor:desc];
    }
}




#pragma mark - Setter -
- (void)setFrame:(CGRect)frame{
    
    [super setFrame:frame];
    // 获取scale
    CGFloat scale = [UIScreen mainScreen].scale;
    
    if (self.window){
        scale = self.window.screen.scale;
    }
    //
    CGSize drawableSize = self.bounds.size;
    // multip
    drawableSize.width  *= scale;
    drawableSize.height *= scale;
    // 主要是 设置 可绘画对象 Size
    //
    self.metalLayer.drawableSize = drawableSize;
    
    
    [self makeDepthTexture];
    
}

- (void)setColorPixelFormat:(MTLPixelFormat)colorPixelFormat{
    
    self.metalLayer.pixelFormat = colorPixelFormat;
    
}

#pragma mark - Getter -

- (CAMetalLayer *)metalLayer{
    return (CAMetalLayer*) self.layer;
}



- (MTLPixelFormat)colorPixelFormat{
    
    return self.metalLayer.pixelFormat;
}


- (MTLRenderPassDescriptor *)currentRenderPassDescriptor{
    
    MTLRenderPassDescriptor * passDescriptor = [MTLRenderPassDescriptor renderPassDescriptor];
    
    passDescriptor.colorAttachments[0].texture = [self.currentDrawable texture];
    passDescriptor.colorAttachments[0].clearColor = self.clearColor;
    passDescriptor.colorAttachments[0].storeAction = MTLStoreActionStore;
    passDescriptor.colorAttachments[0].loadAction = MTLLoadActionClear;
    
    passDescriptor.depthAttachment.texture = self.depthTexture;
    passDescriptor.depthAttachment.clearDepth = 1.0;
    passDescriptor.depthAttachment.loadAction = MTLLoadActionClear;
    passDescriptor.depthAttachment.storeAction = MTLStoreActionDontCare;
    
    
    return passDescriptor;
}


@end
