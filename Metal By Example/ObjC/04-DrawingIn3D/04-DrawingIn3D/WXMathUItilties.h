//
//  WXMathUItilties.h
//  04-DrawingIn3D
//
//  Created by williamxie on 05/06/2017.
//  Copyright © 2017 williamxie. All rights reserved.
//

#import <simd/simd.h>
/// Builds a translation matrix that translates by the supplied vector
// 平移
matrix_float4x4 matrix_float4x4_translation(vector_float3 t);

/// Builds a scale matrix that uniformly scales all axes by the supplied factor
// 放大缩小
matrix_float4x4 matrix_float4x4_uniform_scale(float scale);

/// Builds a rotation matrix that rotates about the supplied axis by an
/// angle (given in radians). The axis should be normalized.
// 旋转
matrix_float4x4 matrix_float4x4_rotation(vector_float3 axis, float angle);

/// Builds a symmetric perspective projection matrix with the supplied aspect ratio,
/// vertical field of view (in radians), and near and far distances
// a symmetric perspective projection matrix
//
matrix_float4x4 matrix_float4x4_perspective(float aspect, float fovy, float near, float far);
