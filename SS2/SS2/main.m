//
//  main.m
//  SS2
//
//  Created by takanoter on 14-1-11.
//  Copyright (c) 2014年 takanoter. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "SSAppDelegate.h"

int main(int argc, char *argv[])
{
    @autoreleasepool {
        lcl_configure_by_name("*", lcl_vTrace);
        //lcl_log(lcl_cMain, lcl_vInfo, @"log message %d", 1);
        qlinfo(@"info message %d using qlog", 1);
        NSLog(@"%@",NSHomeDirectory());
        return UIApplicationMain(argc, argv, nil, NSStringFromClass([SSAppDelegate class]));
    }
}
