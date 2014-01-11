//
//  SongSelectViewController.h
//  SS2
//
//  Created by takanoter on 14-1-11.
//  Copyright (c) 2014年 takanoter. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SongSelectViewController : UIViewController
<UITableViewDataSource,UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UITableView *songSelectView;

//  when did tap, better to record its selection/influce somewhere
//  and not for data trasfer
@property NSString* curSelection;


//  source data and delegation
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView;
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section;
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath;
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath;

@end
