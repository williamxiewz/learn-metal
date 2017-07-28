//
//  WXShaderTypes.h
//  4.BasicTexturing
//
//  Created by williamxie on 27/07/2017.
//  Copyright © 2017 williamxie. All rights reserved.
//

#ifndef WXShaderTypes_h
#define WXShaderTypes_h




#include <simd/simd.h>

// Buffer index values shared between shader and C code to ensure Metal shader buffer inputs match
//   Metal API buffer set calls
typedef enum WXVertexInputIndex
{
    WXVertexInputIndexVertices     = 0,
    WXVertexInputIndexViewportSize = 1,
} WXVertexInputIndex;

// Texture index values shared between shader and C code to ensure Metal shader buffer inputs match
//   Metal API texture set calls
typedef enum WXTextureIndex
{
    WXTextureIndexBaseColor = 0,
} WXTextureIndex;

//  This structre devines the layout of each vertex in the array of vertices set as an input to our
//    Metal vertex shader.  Since this header is shared between our .metal shader and C code,
//    we can be sure that the layout of the vertex array in the Ccode matches the layour that
//    our vertex shader expects
typedef struct
{
    //  Positions in pixel space (i.e. a value of 100 indicates 100 pixels from the origin/center)
    vector_float2 position;
    
    // 2D texture coordinate
    vector_float2 textureCoordinate;
} WXVertex;





#endif /* WXShaderTypes_h */
