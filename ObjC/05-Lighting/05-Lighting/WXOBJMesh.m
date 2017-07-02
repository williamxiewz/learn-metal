

//
//  WXOBJMesh.m
//  05-Lighting
//
//  Created by williamxie on 06/06/2017.
//  Copyright © 2017 williamxie. All rights reserved.
//

#import "WXOBJMesh.h"
#import "WXOBJGroup.h"

@implementation WXOBJMesh

@synthesize indexBuffer = _indexBuffer;
@synthesize vertexBuffer = _vertexBuffer;


- (instancetype)initWithGroup:(WXOBJGroup *)group device:(id<MTLDevice>)device{

    if(self= [super init]){
        _vertexBuffer = [device newBufferWithBytes:[group.vertexData bytes]
                                            length:[group.vertexData length]
                                           options:MTLResourceOptionCPUCacheModeDefault];
        [_vertexBuffer setLabel:[NSString stringWithFormat:@"Vertices (%@)", group.name]];
        
        _indexBuffer = [device newBufferWithBytes:[group.indexData bytes]
                                           length:[group.indexData length]
                                          options:MTLResourceOptionCPUCacheModeDefault];
        [_indexBuffer setLabel:[NSString stringWithFormat:@"Indices (%@)", group.name]];
    }
    return self;
}



@end
