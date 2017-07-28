//
//  WXRenderer.h
//  6.CPUandGPUSynchronization
//
//  Created by williamxie on 28/07/2017.
//  Copyright © 2017 williamxie. All rights reserved.
//

#import <UIKit/UIKit.h>
@import MetalKit;

@interface WXRenderer : NSObject<MTKViewDelegate>

- (nonnull instancetype)initWithMetalKitView:(nonnull MTKView*)mtkview;

@end
