//
//  Tools.m
//  ReadMobileprovision
//
//  Created by xy on 16/10/19.
//  Copyright © 2016年 xy. All rights reserved.
//

#import "Tools.h"
#include <mach-o/dyld.h>

@implementation Tools

+ (NSString *)getProjectPath
{
    char buf[] = {0};
    uint32_t size = 0;
    //一般出现该问题是因为通过C调用了unix/linux 底层接口，所以需要调整c语言的编译选项，设置方法见下图：(根据实际情况选择相应的编译选项)
    
    _NSGetExecutablePath(buf,&size);
    
    char* path = (char*)malloc(size+1);
    path[size] = 0;
    _NSGetExecutablePath(path,&size);
    
    char* pCur = strrchr(path, '/');
    *pCur = 0;
    
    NSString* nsPath = [NSString stringWithUTF8String:path];
    
    free(path);
    path = NULL;
    return nsPath;
}

+ (NSDictionary *)readMobileprovisionFromName:(NSString *)fileName
{
    fileName = [NSString stringWithFormat:@"%@.mobileprovision",fileName];
    NSString *path = [@"~" stringByExpandingTildeInPath];
    NSString *profilesPath = [path stringByAppendingPathComponent:@"/Library/MobileDevice/Provisioning Profiles"];
    profilesPath = [profilesPath stringByAppendingPathComponent:fileName];
    NSData *data = [NSData dataWithContentsOfFile:profilesPath];
    NSString *currentPath = [Tools getProjectPath];
    currentPath = [currentPath stringByAppendingPathComponent:@"provision.mobileprovision"];
    [data writeToFile:currentPath atomically:YES];
    NSString *path2 = [[Tools getProjectPath] stringByAppendingPathComponent:@"provision.plist"];
    NSString *script = [NSString stringWithFormat:@"security cms -D -i %@ > %@",currentPath,path2];
    [Tools executeShellWithScript:script];
    NSDictionary *dicValue = [NSDictionary dictionaryWithContentsOfFile:path2];
    return dicValue;
}

+ (NSDictionary *)readMobileprovisionFromProjectPath:(NSString *)path
{
    if (![path hasSuffix:@".xcodeproj"]) return nil;
    path = [path stringByAppendingPathComponent:@"project.pbxproj"];
    if (![[NSFileManager defaultManager] fileExistsAtPath:path]) {
        return nil;
    }
    NSMutableDictionary *dicValue = [NSMutableDictionary dictionary];
    NSDictionary *dic = [NSDictionary dictionaryWithContentsOfFile:path];
    [dicValue setObject:dic[@"rootObject"]?:@"" forKey:@"rootObject"];
    NSMutableDictionary *dicContent = [NSMutableDictionary dictionary];
    dicContent.dictionary = dic[@"objects"];
    for (NSString *key in dicContent) {
        NSDictionary *value = dicContent[key];
        NSArray *listKeys = value.allKeys;
        if ([listKeys containsObject:@"buildSettings"]) {
            NSDictionary *dicSettings = value[@"buildSettings"];
            NSMutableDictionary *dic1 = [NSMutableDictionary dictionary];
            [dic1 setObject:value[@"name"]?:@"" forKey:@"name"];
            NSArray *list = @[@"PRODUCT_NAME",@"PRODUCT_BUNDLE_IDENTIFIER",@"IPHONEOS_DEPLOYMENT_TARGET",@"OTHER_LDFLAGS",@"VALID_ARCHS",@"PROVISIONING_PROFILE",@"CODE_SIGN_IDENTITY"];
            for (NSString *keys in list) {
                id obj = dicSettings[keys];
                if (obj) {
                    if ([keys isEqualToString:@"PROVISIONING_PROFILE"]) {
                        obj = [Tools readMobileprovisionFromName:obj][@"Name"] ?: @"";
                    }
                    [dic1 setObject:obj forKey:keys];
                }
            }
            [dicValue setObject:dic1 forKey:key];
            //NSLog(@"%@,%@",key,value);
        }
    }
    
    return dicValue;
}

#pragma mark 执行shell命令
+ (NSString *)executeShellWithScript:(NSString *)script
{
    NSDictionary *errorInfo = [NSDictionary dictionary];
    script = [NSString stringWithFormat:@"do shell script \"%@\"",script];
    NSAppleScript *appleScript = [[NSAppleScript new] initWithSource:script];
    NSAppleEventDescriptor *des = [appleScript executeAndReturnError:&errorInfo];
    NSString *stringValue = des.stringValue;
    return stringValue;
}

@end
