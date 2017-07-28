//
//  WXImage.h
//  4.BasicTexturing
//
//  Created by williamxie on 27/07/2017.
//  Copyright © 2017 williamxie. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WXImage : NSObject

/// Initialize this image by loading a *very* simple TGA file.  Will not load compressed, palleted,
//    flipped, or color mapped images.  Only support TGA files with 32-bits per pixels
-(nullable instancetype) initWithTGAFileAtLocation:(nonnull NSURL *)location;

// Width of image in pixels
@property (nonatomic, readonly) NSUInteger      width;

// Height of image in pixels
@property (nonatomic, readonly) NSUInteger      height;

// Image data in 32-bpp BGRA form (which is equivalent to MTLPixelFormatBGRA8Unorm)
@property (nonatomic, readonly, nonnull) NSData *data;


@end
