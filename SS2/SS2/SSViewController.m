//
//  SSViewController.m
//  SS2
//
//  Created by takanoter on 14-1-11.
//  Copyright (c) 2014年 takanoter. All rights reserved.
//

#import "SSViewController.h"
#import "DataManager.h"
/*
@interface SSViewController ()

@end
*/
@implementation SSViewController

- (void)viewDidLoad
{
    gDataMgr = [DataManager alloc];
    [gDataMgr loadFromSandboxDir:@""];
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)getStarted:(id)sender {
    NSLog(@"begin perform");
    [self performSegueWithIdentifier:@"segueKickOff2SongSelect" sender:self];
    NSLog(@"over perform");
}
@end
