//
//  PlayViewController.m
//  SS2
//
//  Created by takanoter on 14-1-11.
//  Copyright (c) 2014年 takanoter. All rights reserved.
//

#import "PlayViewController.h"
#import "DataManager.h"
#import <AVFoundation/AVFoundation.h>
#import <AudioToolbox/AudioToolbox.h>
@interface PlayViewController () {
    AVAudioPlayer *audioPlayer;
}

@end

@implementation PlayViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self play];
	// Do any additional setup after loading the view.
}

- (void)viewDidAppear:(BOOL)animated {
    NSLog(@"PlayView did appear :%@", [self userConfigSongName]);
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)onTapBackButton:(id)sender {
    [self performSegueWithIdentifier:@"seguePlay2SongSelect" sender:self];
}

- (int)preparePlayWithName:(NSString*) songName {
    NSBundle *myBundle = [NSBundle mainBundle];
    // NSString *musicFilePath=[myBundle pathForResource:@"Xeus" ofType:@"mp3" ];
    SongSource* source = [gDataMgr getSourceByName:songName];
    if (source == nil) {
        NSLog(@"[Warning] failed get source by name[%@]",songName);
        return -1;
    }
    
    NSString *musicFilePath=[
                             myBundle pathForResource:songName
                             ofType:@"mp3" ];
    
    if (nil != musicFilePath) {
        NSError *error;
        NSURL *musicURL= [[NSURL alloc]initFileURLWithPath:musicFilePath];
        audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:musicURL error:&error];
        //[musicURL release];
        [audioPlayer prepareToPlay];
        [audioPlayer setVolume:1];
        audioPlayer.numberOfLoops = 1; //-1
        NSLog(@"[OK]:load mp3:%@ success. %@", songName, [error localizedDescription]);
    } else {
        NSLog(@"[Warning] failed get music[%@] file %@", songName, [source getMp3Uri]);
        return -1;
    }
    return 0;
}



- (void)play {
    int ret = 0;
    ret = [self preparePlayWithName:self.userConfigSongName];
    if (ret != 0) {
        NSLog(@"[Warning] failed to loading music:[%@]", self.userConfigSongName);
        return;
    }
    
    //loopSource [basicTimestamp, etc..]
    NSMutableDictionary *cb = [[NSMutableDictionary alloc] init];
    [cb setObject:audioPlayer forKey:@"music"];
    [cb setObject:self.userConfigSongName forKey:@"name"];
    
    [audioPlayer play];
    
    if (playTimer == nil) {
        playTimer = [NSTimer scheduledTimerWithTimeInterval:1/60.0 target:self selector:@selector(timeLoop:) userInfo:cb repeats:YES];
    }
/*
    keyTimer=[[NSTimer scheduledTimerWithTimeInterval: 0.7/60.0 target: self selector:@selector(keylineAnimate) userInfo:NULL repeats:YES] retain];
    NSTimer启动时机？ 是否audioPlay也用NSTimer控制？
    精确控制原理
 */
}

//不可重入
- (void) timeLoop:(NSTimer*)timer{
    NSDictionary *loopConf = [timer userInfo];
    AVAudioPlayer *player = [loopConf objectForKey:@"music"];
    NSLog(@"[Debug][%@] time loop:%lf duration:%lf",
          [loopConf objectForKey:@"name"],
          player.currentTime,player.duration);
    
    double globalTimestamp = player.currentTime;
    //curTimestamp
    //curSceneScoreNodes = [BmsEngine getCurScene:scene atTimestamp:curtimestamp]
    //[Scene drawWithScoreNodes:curSceneNodes]
    //NS
}


@end
