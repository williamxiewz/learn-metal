//
//  WXType.h
//  05-Lighting
//
//  Created by williamxie on 06/06/2017.
//  Copyright © 2017 williamxie. All rights reserved.
//


#import <simd/simd.h>
#import <Metal/Metal.h>

/// 索引
typedef uint16_t WXIndex;

/// 索引类型
const MTLIndexType WXIndexType = MTLIndexTypeUInt16;

typedef struct __attribute((packed))
{
    vector_float4 position;
    vector_float4 normal;
} WXVertex;

typedef struct __attribute((packed))
{   /// MVP
    matrix_float4x4 modelViewProjectionMatrix;
    // MV
    matrix_float4x4 modelViewMatrix;
    // NM
    matrix_float3x3 normalMatrix;
} WXUniforms;

