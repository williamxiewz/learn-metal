//
//  Shaders.metal
//  MetalTriangles
//
//  Created by williamxie on 14/05/2017.
//  Copyright © 2017 williamxie. All rights reserved.
//

#include <metal_stdlib>
using namespace metal;


/// 顶点
struct Vertex
{   //位置
    float4 position [[position]];
    //颜色
    float4 color;
};
/// 参数
struct Uniforms{
    /// MVP 
    float4x4 modelViewProjectionMatrix;

};


// 顶点着色器
vertex Vertex vertex_project(device Vertex * vertices [[buffer(0)]],
                             constant Uniforms *uniforms [[buffer(1)]],
                             uint vid [[vertex_id]])
{

    Vertex vertexOut;
    
    vertexOut.position = uniforms->modelViewProjectionMatrix * vertices[vid].position;
    vertexOut.color = vertices[vid].color;
    
    return vertexOut;
    

}

// 片段 着色器
fragment half4 fragment_flatcolor(Vertex inVertex [[stage_in]])
{
    return  half4(inVertex.color);
}

