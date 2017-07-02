//
//  Shaders.metal
//  MetalTriangles
//
//  Created by williamxie on 14/05/2017.
//  Copyright © 2017 williamxie. All rights reserved.
//

#include <metal_stdlib>
using namespace metal;

struct Vertex
{
    float4 position [[position]];
    float4 color;
};

//
// 顶点
vertex Vertex vertex_main(device Vertex * vertices [[buffer(0)]],
                          uint vid [[vertex_id]])
{

    return vertices[vid];

}

// 片段
fragment float4 fragment_main(Vertex inVertex [[stage_in]])
{
    return inVertex.color;
}

