//
//  PlayViewController.h
//  SS2
//
//  Created by takanoter on 14-1-11.
//  Copyright (c) 2014年 takanoter. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PlayViewController : UIViewController {
    NSTimer *playTimer;
}
- (IBAction)onTapBackButton:(id)sender;
//- (void) timeLoop;
- (void)play;


@property NSString *userConfigSongName;
//@property NSTimer *playTimer;
@end
