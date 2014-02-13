//
//  Scene.m
//  SS2
//
//  Created by takanoter on 14-2-11.
//  Copyright (c) 2014年 takanoter. All rights reserved.
//

#import "Scene.h"
#define G_MAX_SCENE_NOTE_COUNT 256
#define LAYOUT_NOTE_X 40
#define LAYOUT_NOTE_Y 0

#define CHANNEL_EVENT_NEW_SHORT_NOTE 0
#define CHANNEL_EVENT_NEW_LONG_NOTE 1
@interface Scene() {
@public NSMutableArray* notes;
@public NSMutableArray* bloom;
@public NSMutableArray* channelState;
@public int lastImageViewId;
}
@end

@implementation Scene
- (Scene*) initWithView:(PlayView*)playView {
    if (self==[super init]) {
        view = playView;
        lastImageViewId = 0;
        notes = [[NSMutableArray alloc]initWithCapacity:G_MAX_SCENE_NOTE_COUNT];
        for (int i=0; i<G_MAX_SCENE_NOTE_COUNT; i++) {
            UIImageView* imageView = [[UIImageView alloc] initWithFrame:CGRectMake(LAYOUT_NOTE_X, LAYOUT_NOTE_Y, 32.0, 8.0)];
            imageView.image = [UIImage imageNamed:@"KEYA1.png"];
            
            imageView.center = CGPointMake(LAYOUT_NOTE_X, LAYOUT_NOTE_Y);
            notes[i] = imageView;
            [view addSubview:imageView];
        }
        bloom = [[NSMutableArray alloc]initWithCapacity:G_MAX_CHANNEL_COUNT];
        for (int i=0; i<G_MAX_CHANNEL_COUNT; i++) {
            NSMutableArray *tmpArray = [[NSMutableArray alloc]initWithCapacity:G_BLOOM_MAX_COUNT];
            bloom[i] = tmpArray;
            for (int j=0; j<G_BLOOM_MAX_COUNT; j++) {
                UIImageView* imageView = [[UIImageView alloc]initWithFrame:CGRectMake(LAYOUT_NOTE_X, LAYOUT_NOTE_Y, 32.0, 20.0)];
                NSString* fileName = [NSString stringWithFormat:@"Note_Click1_2.ojt%d.png", j];
                imageView.image = [UIImage imageNamed:fileName];
                imageView.center = CGPointMake(LAYOUT_NOTE_X, LAYOUT_NOTE_Y);
                tmpArray[j] = imageView;
                [view addSubview:imageView];
            }
        }
        
        channelState = [[NSMutableArray alloc]initWithCapacity:G_MAX_CHANNEL_COUNT];
        for (int i=0; i<G_MAX_CHANNEL_COUNT; i++) {
            NSNumber* numObj = [NSNumber numberWithInt:-1];
            channelState[i] = numObj;
        }
        
    }
    return self;
}
- (void)channelStateEvent:(int)event atChannel:(int)channel {
    NSNumber* numObj = channelState[channel];
    int state = [numObj intValue];
    if (event == CHANNEL_EVENT_NEW_LONG_NOTE) {
        if (state == -1) state = 0;
        else state = 2;
    } else if (event == CHANNEL_EVENT_NEW_SHORT_NOTE) {
        if (state == -1) state = 0;
        else state = 1;
    } else {
        //do nothing
    }
    [channelState replaceObjectAtIndex:channel withObject:[NSNumber numberWithInt:state]];
}

- (void)channelStateMotive {
    for (int i=0; i<G_MAX_CHANNEL_COUNT; i++) {
        NSNumber* numObj = channelState[i];
        int state = [numObj intValue];
        if (state == -1) continue;
        
        NSMutableArray* tmpArray = bloom[i];
        UIImageView* imageView = tmpArray[state];
        imageView.center = CGPointMake(LAYOUT_NOTE_X, LAYOUT_NOTE_Y);
        if (state == 11) {
            state = -1;
        } else {
            state++;
        }
        if (state != -1) {
            imageView = tmpArray[state];
            imageView.center = CGPointMake(LAYOUT_NOTE_X + i*LAYOUT_CHANNEL_WEIGHT, LAYOUT_NOTE_Y + LAYOUT_CHANNEL_HEIGHT+32);
        }
        
        [channelState replaceObjectAtIndex:i withObject:[NSNumber numberWithInt:state]];
    }

}


- (int) renderAs:(SceneNote*)sceneNote {
    int curImageViewId = 0;
    double basePos = sceneNote->basePos;
    for (int i=0; i<G_MAX_CHANNEL_COUNT; i++) {
        for (NSObject* obj in sceneNote->channel[i]) {
            Note* note = (Note*)obj;
            if (note->state != NOTE_STATE_TOUCHED) {
                if (note->pos - basePos < 0.01) {
                    note->state = NOTE_STATE_TOUCHED;
                    if (note->type == G_LONG_NOTE) {
                        [self channelStateEvent:CHANNEL_EVENT_NEW_LONG_NOTE atChannel:i];
                    } else {
                        [self channelStateEvent:CHANNEL_EVENT_NEW_SHORT_NOTE atChannel:i];
                    }
                }
            }
            
            if (note->type == G_LONG_NOTE) {
                
                double dx = LAYOUT_BASE_X + i * LAYOUT_CHANNEL_WEIGHT;
                double dy = LAYOUT_BASE_Y + LAYOUT_CHANNEL_HEIGHT - (note->pos - basePos) /(0.5)* LAYOUT_CHANNEL_HEIGHT;
                double length = (note->len)/(0.5)*LAYOUT_CHANNEL_HEIGHT;
                //TODO:range check
                UIImageView* imageView = (UIImageView*)notes[curImageViewId++];
                imageView.frame = CGRectMake(LAYOUT_NOTE_X,LAYOUT_NOTE_Y,32.0,length);
                imageView.center = CGPointMake(dx, dy-length/2);
            } else { //G_SHORT_NOTE
                //if (note->pos < basePos) continue; //not on scene
                double dx = LAYOUT_BASE_X + i * LAYOUT_CHANNEL_WEIGHT;
                double dy = LAYOUT_BASE_Y + LAYOUT_CHANNEL_HEIGHT - (note->pos - basePos) /(0.5)* LAYOUT_CHANNEL_HEIGHT;
                //TODO:range check
                UIImageView* imageView = (UIImageView*)notes[curImageViewId++];
                imageView.frame = CGRectMake(LAYOUT_NOTE_X, LAYOUT_NOTE_Y, 32.0, 8.0);
                imageView.center = CGPointMake(dx, dy);
            }
        }
    }
    for (int i=curImageViewId; i<lastImageViewId; i++) {
        UIImageView* imageView = (UIImageView*)notes[i];
        imageView.center = CGPointMake(LAYOUT_NOTE_X, LAYOUT_NOTE_Y);
    }
    lastImageViewId = curImageViewId;
    
    [self channelStateMotive];
    return 0;
}
@end
