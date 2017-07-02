//
//  WXMesh.h
//  05-Lighting
//
//  Created by williamxie on 06/06/2017.
//  Copyright © 2017 williamxie. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Metal/Metal.h>


@interface WXMesh : NSObject
/**
 顶点 缓冲区
 */
@property(nonatomic,readonly) id<MTLBuffer> vertexBuffer;

/**
 索引缓冲区
 */
@property(nonatomic,readonly) id<MTLBuffer> indexBuffer;

@end
