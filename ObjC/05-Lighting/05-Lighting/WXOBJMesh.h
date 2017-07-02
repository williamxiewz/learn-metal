//
//  WXOBJMesh.h
//  05-Lighting
//
//  Created by williamxie on 06/06/2017.
//  Copyright © 2017 williamxie. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Metal/Metal.h>
#import "WXMesh.h"

@class WXOBJGroup;

@interface WXOBJMesh : WXMesh
- (instancetype)initWithGroup:(WXOBJGroup*)group device:(id<MTLDevice>)device;
@end
