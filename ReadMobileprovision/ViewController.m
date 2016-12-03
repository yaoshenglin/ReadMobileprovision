//
//  ViewController.m
//  ReadMobileprovision
//
//  Created by xy on 16/10/19.
//  Copyright © 2016年 xy. All rights reserved.
//

#import "ViewController.h"
#import "Tools.h"

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Do any additional setup after loading the view.
}

#pragma mark 选择文件
- (IBAction)selectFileEvents:(NSButton *)sender
{
    //选择文件
    NSOpenPanel *panel = [NSOpenPanel openPanel];
    panel.delegate = self;
    panel.canChooseDirectories = YES;
    [panel runModal];
}

#pragma mark 读取数据
- (IBAction)readData:(NSButton *)sender
{
    NSString *path = _txtPath.stringValue;
    NSString *filePath = [self readXcodeprojFilePathFromDir:path];
    NSDictionary *dic = [Tools readMobileprovisionFromProjectPath:filePath];
    if (dic) {
        NSString *content = dic.description;
        NSTextView *textView = _txtContent.documentView;
        textView.string = content;
    }else{
        NSError *error = [NSError errorWithDomain:@"该路径下没有找到工程文件" code:0 userInfo:@{NSLocalizedDescriptionKey:@"the content is nil"}];
        NSLog(@"%@",error.localizedDescription);
        NSAlert *alert = [NSAlert alertWithError:error];
        alert.messageText = @"请选择后缀为xcodeproj的文件路径";
        [alert addButtonWithTitle:@"确定"];
        [alert beginSheetModalForWindow:self.view.window completionHandler:^(NSModalResponse returnCode) {
            NSLog(@"%ld",(long)returnCode);
        }];
    }
}

- (NSString *)readXcodeprojFilePathFromDir:(NSString *)path
{
    BOOL isDir;
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if ([fileManager fileExistsAtPath:path isDirectory:&isDir]) {
        if (isDir && ![path hasSuffix:@".xcodeproj"]) {
            BOOL isExist = NO;
            NSArray *listDir = [fileManager contentsOfDirectoryAtPath:path error:nil];
            NSString *filePath = path;
            for (NSString *name in listDir) {
                if ([name hasSuffix:@".xcodeproj"]) {
                    isExist = YES;
                    filePath = [path stringByAppendingPathComponent:name];
                    break;
                }
            }
            
            if (isExist) {
                return filePath;
            }else{
                for (NSString *name in listDir) {
                    filePath = [path stringByAppendingPathComponent:name];
                    NSString *newPath = [self readXcodeprojFilePathFromDir:filePath];
                    if (newPath) {
                        return newPath;
                    }
                }
            }
            
        }
        else if (isDir) {
            if ([path hasSuffix:@".xcodeproj"]) {
                return path;
            }
        }
    }
    
    return nil;
}

#pragma mark - --------选择文件事件回调------------------------
- (BOOL)panel:(id)sender shouldEnableURL:(NSURL *)url
{
    //将要选择的文件
    //NSLog(@"shouldEnableURL,%@",url.path);
    return YES;
}

#pragma mark 已经选择了文件
- (BOOL)panel:(id)sender validateURL:(NSURL *)url error:(NSError **)outError
{
    //选定后并点击打开的文件
    _txtPath.stringValue = url.path;
    
    return YES;
}


- (void)panel:(id)sender didChangeToDirectoryURL:(nullable NSURL *)url
{
    //改变文件夹时的回调
    //NSLog(@"didChangeToDirectoryURL,%@",url.path);
}


- (nullable NSString *)panel:(id)sender userEnteredFilename:(NSString *)filename confirmed:(BOOL)okFlag;
{
    NSLog(@"userEnteredFilename,%@",filename);
    return filename;
}

- (void)panel:(id)sender willExpand:(BOOL)expanding;
{
    NSLog(@"willExpand,%@",sender);
}

- (void)panelSelectionDidChange:(nullable id)sender;
{
    //选中的目标已经改变时的回调
    //NSLog(@"panelSelectionDidChange,%@",sender);
}

#pragma mark - --------压缩目录文件------------------------
/**
 * -q 表示不显示压缩进度状态
 * -r 表示子目录子文件全部压缩为zip  //这部比较重要，不然的话只有something这个文件夹被压缩，里面的没有被压缩进去
 * -e 表示你的压缩文件需要加密，终端会提示你输入密码的
 * 还有种加密方法，这种是直接在命令行里做的，比如zip -r -P Password01! modudu.zip SomeDir, 就直接用Password01!来加密modudu.zip了。
 
 * -m 表示压缩完删除原文件
 * -o 表示设置所有被压缩文件的最后修改时间为当前压缩时间
**/
- (IBAction)CompressDir:(NSButton *)sender
{
    NSString *path = _txtPath.stringValue;
    BOOL isDir;
    if ([[NSFileManager defaultManager] fileExistsAtPath:path isDirectory:&isDir]) {
        if (isDir) {
            NSString *fileName = [path.lastPathComponent stringByDeletingPathExtension];
            fileName = [fileName stringByAppendingString:@".zip"];
            NSString *filePath = [path.stringByDeletingLastPathComponent stringByAppendingPathComponent:fileName];
            NSString *script = [NSString stringWithFormat:@"zip -q -r %@ %@",filePath,path];
            NSLog(@"%@",[Tools executeShellWithScript:script]);
        }
    }
}

#pragma mark -

- (void)setRepresentedObject:(id)representedObject
{
    [super setRepresentedObject:representedObject];

    // Update the view, if already loaded.
}

@end
