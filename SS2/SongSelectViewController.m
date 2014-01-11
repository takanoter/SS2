//
//  SongSelectViewController.m
//  SS2
//
//  Created by takanoter on 14-1-11.
//  Copyright (c) 2014年 takanoter. All rights reserved.
//

#import "SongSelectViewController.h"
#import "PlayViewController.h"

@implementation SongSelectViewController

- (void)viewDidLoad
{
    NSLog(@"here load song select scene: view did load");
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)viewWillAppear:(BOOL)animated {
    NSLog(@"here load song select scene: view will appear");
}

//  source data and delegation
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"this this this:%d", [indexPath row]);
    UITableViewCell *cell = [self.songSelectView cellForRowAtIndexPath:indexPath];
    if (cell != nil) {
        self.curSelection = cell.textLabel.text;
        
        //we use segue instead
        [self performSegueWithIdentifier:@"segueSongSelect2Play" sender:self];
        //afterViewController *setViewController = [[afterViewController alloc]init];
        //[self presentViewController:setViewController animated:YES completion:nil];
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    NSLog(@"that that that:prepare for segue");
    if ([[segue identifier]isEqualToString:@"segueSongSelect2Play"]) {
        PlayViewController *destViewController = [segue destinationViewController];
        destViewController.userConfigName = self.curSelection;
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSLog(@"count for number of rows");
    return 3;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] ;
        NSLog(@"warning!!!");
    }
    //NSInteger section = [indexPath section];
    
    NSInteger section = [indexPath row];
    NSLog(@"call for section:%d", section);
   
    //TODO:heavy DataManager(IO) from BaseViewController,
    //1) independent thread for non-block OPEARATION, as Receiver
    //2) delegate?protocol? for close DATA-FETCH
    cell.textLabel.text = @"heheheheh";
    switch (section) {
        case 0: // First cell in section 1
            cell.textLabel.text = @"hello";
            break;
        case 1: // Second cell in section 1
            cell.textLabel.text = @"hi";
            break;
        default:
            NSLog((@"haha"));
    }
    return cell;
}







@end
