//
//  WXOBJModel.h
//  05-Lighting
//
//  Created by williamxie on 06/06/2017.
//  Copyright © 2017 williamxie. All rights reserved.
//

#import <Foundation/Foundation.h>

@class WXOBJGroup;

@interface WXOBJModel : NSObject


- (instancetype)initWithContentsOfURL:(NSURL*)fileURL  generateNormals:(BOOL)generateNormals;

/// Index 0 corresponds to an unnamed group that collects all the geometry
/// declared outside of explicit "g" statements. Therefore, if your file
/// contains explicit groups, you'll probably want to start from index 1,
/// which will be the group beginning at the first group statement.
@property(nonatomic,readonly) NSArray * groups;


/**
 Retrieve a group from the OBJ file by name

 @param groupName <#groupName description#>
 @return <#return value description#>
 */
-(WXOBJGroup*)groupForName:(NSString*)groupName;

@end
