//
//  WXRenderer.h
//  5.HelloCompute
//
//  Created by williamxie on 27/07/2017.
//  Copyright © 2017 williamxie. All rights reserved.
//

#import <UIKit/UIKit.h>

@import MetalKit;

@interface WXRenderer : NSObject<MTKViewDelegate>

/**
 <#Description#>

 @param mtkview <#mtkview description#>
 @return <#return value description#>
 */
-(nonnull instancetype)initWithMetalKitView:(nonnull  MTKView*)mtkview;
@end
