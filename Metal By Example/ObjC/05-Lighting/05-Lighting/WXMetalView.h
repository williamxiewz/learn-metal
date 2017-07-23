//
//  WXMetalView.h
//  HelloWorld
//
//  Created by williamxie on 14/05/2017.
//  Copyright © 2017 williamxie. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Metal/Metal.h>

@protocol WXMetalViewDelegate;


@interface WXMetalView : UIView

#pragma mark - setter -
/**
 渲染代理对象
 */
@property (nonatomic,weak) id<WXMetalViewDelegate> delegate;

/**
 帧率 (15 , 30 60)
 */
@property (nonatomic) NSInteger preferredFramePerSecond;

/**
 color attachment  像素格式
 */
@property (nonatomic) MTLPixelFormat colorPixelFormat;

#pragma mark - getter  -
/**
 clear color
 */
@property(nonatomic,assign) MTLClearColor clearColor;

/**
 每一帧 持续的时间
 */
@property(nonatomic,readonly) NSTimeInterval frameDuration;

/**
 当前的 可绘画对象
 */
@property(nonatomic,readonly) id<CAMetalDrawable> currentDrawable;

/**
 当前的渲染管线描述对象
 */
@property (nonatomic,readonly) MTLRenderPassDescriptor * currentRenderPassDescriptor;

/**
 metl layer 指针
 */
@property (nonatomic,readonly) CAMetalLayer * metalLayer;




@end


// 代理
//
@protocol WXMetalViewDelegate <NSObject>

/**
 渲染
 
 @param view <#view description#>
 */
-(void)drawInView:(WXMetalView*)view;

@end
