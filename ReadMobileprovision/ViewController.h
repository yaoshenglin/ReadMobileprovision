//
//  ViewController.h
//  ReadMobileprovision
//
//  Created by xy on 16/10/19.
//  Copyright © 2016年 xy. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface ViewController : NSViewController<NSTextFieldDelegate,NSTableViewDelegate,NSTableViewDataSource,NSOpenSavePanelDelegate>
{
    NSTextView *txtView;
}


@property (weak) IBOutlet NSTextField *txtPath;
@property (weak) IBOutlet NSScrollView *txtContent;

@end

