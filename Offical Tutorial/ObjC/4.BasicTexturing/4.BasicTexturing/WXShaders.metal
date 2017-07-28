//
//  WXShaders.metal
//  4.BasicTexturing
//
//  Created by williamxie on 27/07/2017.
//  Copyright © 2017 williamxie. All rights reserved.
//

#include <metal_stdlib>
#include <simd/simd.h>

using namespace metal;

#import "WXShaderTypes.h"

// vertex Shader output
// Rasterizer input (光栅化的输入)
//
typedef struct {
    // The [[position]] attribute qualifier of this member indicates this value is the clip space
    //   position of the vertex wen this structure is returned from the vertex shader
    float4 clipSpacePosition [[position]];
    
    // Since this member does not have a special attribute qualifier, the rasterizer will
    //   interpolate its value with values of other vertices making up the triangle and
    //   pass that interpolated value to the fragment shader for each fragment in that triangle;
    float2 textureCoordinate;
    
} RasterizerData;

//Vertex Shader Function
vertex RasterizerData vertexShader(uint vertexID [[ vertex_id ]],
                                   constant WXVertex *vertexArray [[ buffer(WXVertexInputIndexVertices) ]],
                                   constant vector_uint2 *viewportSizePointer  [[ buffer(WXVertexInputIndexViewportSize) ]])
{
    
    RasterizerData out;
    
    //获取position
    float2 pixelSpacePosition = vertexArray[vertexID].position.xy;
    // 指针
    float2 viewportSize = float2(*viewportSizePointer);
    
    out.clipSpacePosition.xy = pixelSpacePosition / (viewportSize / 2.0);
    
    out.clipSpacePosition.z = 0.0;
    out.clipSpacePosition.w = 1.0;
    out.textureCoordinate = vertexArray[vertexID].textureCoordinate;
    return out;
    
}


fragment float4 samplingShader(RasterizerData in [[stage_in]],
                               texture2d <half> colorTexture [[ texture(WXTextureIndexBaseColor )]]){
    
    constexpr sampler textureSampler (mag_filter::linear,
                                      min_filter::linear);
    
    const half4 colorSample =  colorTexture.sample (textureSampler,in.textureCoordinate);
    
    return float4(colorSample);
}
