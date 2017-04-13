//
//  WXMetalView.h
//  Chapter 1
//
//  Created by williamxie on 12/04/2017.
//  Copyright © 2017 williamxie. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MetalKit/MetalKit.h>
@interface WXMetalView : UIView
@property(nonatomic,weak) CAMetalLayer * metalLayer;
@property(nonatomic,readonly)id <MTLDevice> device;
@end
