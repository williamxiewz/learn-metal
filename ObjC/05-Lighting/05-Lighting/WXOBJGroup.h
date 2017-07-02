//
//  WXOBJGroup.h
//  05-Lighting
//
//  Created by williamxie on 06/06/2017.
//  Copyright © 2017 williamxie. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface WXOBJGroup : NSObject


/**
 <#Description#>

 @param name <#name description#>
 @return <#return value description#>
 */
- (instancetype)initWithName:(NSString*)name;


/**
 名称
 */
@property(nonatomic,copy) NSString * name;

/**
 顶点数据
 */
@property(nonatomic,strong) NSData * vertexData;

/**
 索引数据
 */
@property(nonatomic,strong) NSData * indexData;

@end
