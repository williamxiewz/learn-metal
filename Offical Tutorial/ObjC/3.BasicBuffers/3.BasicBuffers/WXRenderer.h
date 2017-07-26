//
//  WXRenderer.h
//  3.BasicBuffers
//
//  Created by williamxie on 26/07/2017.
//  Copyright © 2017 williamxie. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MetalKit/MetalKit.h>

@interface WXRenderer : NSObject<MTKViewDelegate>

-(nonnull instancetype)initWithMTKView:(nonnull  MTKView*)mtkview;

@end
