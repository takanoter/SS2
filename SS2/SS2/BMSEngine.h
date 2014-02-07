//
//  BMSEngine.h
//  SS2
//
//  Created by takanoter on 14-1-15.
//  Copyright (c) 2014年 takanoter. All rights reserved.
//

#import <Foundation/Foundation.h>
#define G_MAX_CHANNEL_COUNT 5
#define G_CHANNEL_ONE_SCENE_MAX_NOTE 100
#define G_SHORT_NOTE 2
#define G_LONG_NOTE 3
//TODO: Node static
@interface Note : NSObject {
@public    int gId;
@public    double pos,len;
@public    int type, state;
}
@end


@interface SceneNote : NSObject {
int timestamp;
NSMutableArray *channel[G_MAX_CHANNEL_COUNT];
}
@end


@interface BMSEngine : NSObject
-(int)getCurScene:(SceneNote*)scene atTimestamp:(double)ts;
@end


//global-instance
extern BMSEngine *gBmsEngine;

