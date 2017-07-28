//
//  WXShaderTypes.h
//  5.HelloCompute
//
//  Created by williamxie on 27/07/2017.
//  Copyright © 2017 williamxie. All rights reserved.
//

#ifndef WXShaderTypes_h
#define WXShaderTypes_h


#include <simd/simd.h>

// 顶点输入索引 枚举

typedef enum WXVertexInputIndex
{
    
    WXVertexInputIndexVertices     = 0,
    WXVertexInputIndexViewportSize = 1,
    
}WXVertexInputIndex;

typedef enum WXTextureIndex
{
    
    WXTextureIndexInput  = 0,
    WXTextureIndexOutPut = 1,
    
}WXTextureIndex;

typedef struct {
    vector_float2 position;
    
    vector_float2 textureCoordinate;
    
}WXVertex;




#endif /* WXShaderTypes_h */
