//
//  PlayViewController.m
//  SS2
//
//  Created by takanoter on 14-1-11.
//  Copyright (c) 2014年 takanoter. All rights reserved.
//

#import "PlayViewController.h"
#import "DataManager.h"
#import "BMSEngine.h"
#import "PlayView.h"
#import "Scene.h"
#import <AVFoundation/AVFoundation.h>
#import <AudioToolbox/AudioToolbox.h>
#import <SpriteKit/SpriteKit.h>
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
    //self.window.rootViewController.view
    [super viewDidLoad];
    
    CGRect viewRect=CGRectMake(0, 0, 550, LAYOUT_BASE_Y+LAYOUT_CHANNEL_HEIGHT);
    PlayView *playView=[[PlayView alloc] initWithFrame:viewRect];
    
    CGRect skViewRect=CGRectMake(50, 300, 200, 100);
    SKView* skView=[[SKView alloc]initWithFrame:skViewRect];
    skView.showsDrawCount=YES;
    skView.showsFPS=YES;
    SKScene* hello = [[SKScene alloc] initWithSize:CGSizeMake(768,1024)];
    [skView presentScene:hello];
    
    [self.view addSubview:playView];
    //[self.view addSubview:skView];
    //self.view = playView;
    
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
    
    BMSEngine* bms = [[BMSEngine alloc]initWithPathname:self.userConfigSongName];
    SceneNote* sceneNote = [[SceneNote alloc]init];
    Scene* scene = [[Scene alloc]initWithView:self.view];
    
    //loopSource [basicTimestamp, etc..]
    NSMutableDictionary *cb = [[NSMutableDictionary alloc] init];
    [cb setObject:self.userConfigSongName forKey:@"name"];
    [cb setObject:audioPlayer forKey:@"audio"];
    [cb setObject:bms forKey:@"bms"];
    [cb setObject:sceneNote forKey:@"scene notes"];
    [cb setObject:scene forKey:@"scene"];
    
    [audioPlayer play];
    
    if (playTimer == nil) {
        playTimer = [NSTimer scheduledTimerWithTimeInterval:1/60.0 target:self selector:@selector(timeLoop:) userInfo:cb repeats:YES];
    }

}

//不可重入
- (void) timeLoop:(NSTimer*)timer{
    NSDictionary *loopConf = [timer userInfo];
    NSString *name = [loopConf objectForKey:@"name"];
    AVAudioPlayer *player = [loopConf objectForKey:@"audio"];
    BMSEngine* bms = [loopConf objectForKey:@"bms"];
    SceneNote* sceneNote = [loopConf objectForKey:@"scene notes"];
    Scene* scene = [loopConf objectForKey:@"scene"];
    

//    NSLog(@"[Debug][%@] time loop:%lf duration:%lf",[loopConf objectForKey:@"name"],player.currentTime,player.duration);
    
    double globalTimestamp = player.currentTime + bms->bgmFixedTs;
    [bms getCurScene:sceneNote atTimestamp:globalTimestamp inRange:0.5];
    //NSLog(@"[Check][timeloop:%@][ts:%lf pos:%lf][%d %d %d]",name, globalTimestamp, sceneNote->basePos, [sceneNote->channel[0] count], [sceneNote->channel[1] count], [sceneNote->channel[2] count]);
    [scene renderAs:sceneNote];
    //curSceneScoreNodes = [BmsEngine getCurScene:scene atTimestamp:curtimestamp]
    //[Scene drawWithScoreNodes:curSceneNodes]
    
}


@end
