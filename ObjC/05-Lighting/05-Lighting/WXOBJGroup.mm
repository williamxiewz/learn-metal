

//
//  WXOBJGroup.m
//  05-Lighting
//
//  Created by williamxie on 06/06/2017.
//  Copyright © 2017 williamxie. All rights reserved.
//

#import "WXOBJGroup.h"
#import "WXType.h"


@interface WXOBJGroup ()

@end


@implementation WXOBJGroup

- (instancetype)initWithName:(NSString *)name{

    if(self = [super init]){
    
        _name = [name copy];
    
    }
    
    return  self;
}


- (NSString *)description{

    size_t vertCount = self.vertexData.length / sizeof(WXVertex);
    size_t indexCount = self.indexData.length / sizeof(WXIndex);
    return [NSString stringWithFormat:@"<WXOBJMesh %p> (\"%@\", %d vertices, %d indices)",
            self, self.name, (int)vertCount, (int)indexCount];

}

@end
