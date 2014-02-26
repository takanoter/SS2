//
//  BMSEngine.h
//  SS2
//
//  Created by takanoter on 14-1-15.
//  Copyright (c) 2014年 takanoter. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import <AudioToolbox/AudioToolbox.h>
#import "utils.h"

#define G_MAX_CHANNEL_COUNT 7
#define G_SHORT_NOTE 2
#define G_LONG_NOTE 3

#define NOTE_STATE_SLEEP 0
#define NOTE_STATE_ONSCENE 1
#define NOTE_STATE_TOUCHED 2
#define NOTE_STATE_SILENCE 3

//TODO: Node static
@interface Note : NSObject {
@public    int gId;
@public    double pos,len;
@public    int channel;
@public    int type, state;
@public    int motion;
//@public    AVAudioPlayer* audio;
}
-(Note*)init;
@end


@interface SceneNote : NSObject {
@public double basePos;
@public NSMutableArray* channel;//[G_MAX_CHANNEL_COUNT];
@public NSMutableArray* lastBeginIdx; //[G_MAX_CHANNEL_COUNT]; //迭代加速，闭区间
//@public NSMutableArray* lastEndIdx; //[G_MAX_CHANNEL_COUNT]; //迭代加速，闭区间
@public int lastTsBpmIdx; //迭代加速

@public NSMutableArray* bgmChannel;
@public int lastBgmIdx;
}
-(SceneNote*)init;
@end

@interface BgmNote : NSObject {
@public double ts;
@public AVAudioPlayer* audio;
@public double pos;
}
@end

@interface Audio : NSObject {
@public    NSString* sign;
@public    AVAudioPlayer* audioPlayer;
}
@end



@interface BMSEngine : NSObject {
@public NSMutableDictionary* sign2audio;

}
-(BMSEngine*)initWithPathname:(NSString*)pathname;
-(int)getCurScene:(SceneNote*)scene atTimestamp:(double)curTs inRange:(double)barRange;

@end


//global-instance
extern BMSEngine *gBmsEngine;

