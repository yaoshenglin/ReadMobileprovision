//
//  Tools.h
//  ReadMobileprovision
//
//  Created by xy on 16/10/19.
//  Copyright © 2016年 xy. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Tools : NSObject

+ (NSString *)getProjectPath;
+ (NSDictionary *)readMobileprovisionFromProjectPath:(NSString *)path;

#pragma mark 执行shell命令
+ (NSString *)executeShellWithScript:(NSString *)script;

@end
