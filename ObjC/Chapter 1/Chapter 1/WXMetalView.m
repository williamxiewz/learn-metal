\
//
//  WXMetalView.m
//  Chapter 1
//
//  Created by williamxie on 12/04/2017.
//  Copyright © 2017 williamxie. All rights reserved.
//

#import "WXMetalView.h"


@interface WXMetalView()

@end

@implementation WXMetalView

#pragma mark -- Life
+ (Class)layerClass{
    return [CAMetalLayer class];
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder{

    if (self = [super initWithCoder:aDecoder]) {
    
        _metalLayer = (CAMetalLayer*)[self layer];
        _device  = MTLCreateSystemDefaultDevice();
        _metalLayer.device = _device;
        _metalLayer.pixelFormat = MTLPixelFormatRGBA8Unorm;
    }
    
    return self;

}

    
#pragma mark  -- 
// this method will be called once as the app starts.
-(void)didMoveToWindow{
    [self redraw];

}


-(void)redraw{



}
    
    
    
#pragma mark  --
- (CAMetalLayer *)metalLayer{

    return (CAMetalLayer*)self.layer;

}
    

@end
