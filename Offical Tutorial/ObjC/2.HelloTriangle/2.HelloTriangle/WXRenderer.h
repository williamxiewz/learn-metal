//
//  WXRenderer.h
//  2.HelloTriangle
//
//  Created by williamxie on 24/07/2017.
//  Copyright © 2017 williamxie. All rights reserved.
//

#import <UIKit/UIKit.h>
#include <MetalKit/MetalKit.h>


@interface WXRenderer : NSObject<MTKViewDelegate>

-(nonnull instancetype)initWithMetalKitView:(nonnull MTKView*)mtkView;

@end
