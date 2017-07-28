//
//  WXRenderer.h
//  4.BasicTexturing
//
//  Created by williamxie on 27/07/2017.
//  Copyright © 2017 williamxie. All rights reserved.
//

#import <UIKit/UIKit.h>
@import MetalKit;

@interface WXRenderer : NSObject<MTKViewDelegate>

-(nonnull instancetype)initWithMetakKitView:(nonnull MTKView*)mtkview;

@end
