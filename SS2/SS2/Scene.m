//
//  Scene.m
//  SS2
//
//  Created by takanoter on 14-2-11.
//  Copyright (c) 2014年 takanoter. All rights reserved.
//

#import "Scene.h"
#import "UILayout.h"

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
        notes = [[NSMutableArray alloc]initWithCapacity:G_SCENE_MAX_SHORT_NOTE_COUNT];
        for (int i=0; i<G_SCENE_MAX_SHORT_NOTE_COUNT; i++) {
            UIImageView* imageView = [[UIImageView alloc] initWithFrame:CGRectMake(LAYOUT_OFFSCENE_X, LAYOUT_OFFSCENE_Y, SIZE_ANOTHER_KEY_X, SIZE_ANOTHER_KEY_Y)];
            NSString* tmpName = [NSString stringWithFormat:@"%@%d",@UIS_ANOTHER_KEY_PATTERN_PREFIX,UIS_ANOTHER_KEY_PATTERN_COUNT-1];
            imageView.image = [UIImage imageNamed:tmpName];
            if (imageView.image == nil) {
                NSLog(@"[Warning] failed to load image %@", tmpName);
            }
            imageView.center = CGPointMake(LAYOUT_OFFSCENE_X, LAYOUT_OFFSCENE_Y);
            notes[i] = imageView;
            [view addSubview:imageView];
        }
        bloom = [[NSMutableArray alloc]initWithCapacity:G_MAX_CHANNEL_COUNT];
        for (int i=0; i<G_MAX_CHANNEL_COUNT; i++) {
            NSMutableArray *tmpArray = [[NSMutableArray alloc]initWithCapacity:UIS_BLOOM_PATTERN_COUNT];
            bloom[i] = tmpArray;
            for (int j=0; j<UIS_BLOOM_PATTERN_COUNT; j++) {
                UIImageView* imageView = [[UIImageView alloc]initWithFrame:CGRectMake(LAYOUT_OFFSCENE_Y, LAYOUT_OFFSCENE_Y, SIZE_BLOOM_X, SIZE_BLOOM_Y)];
                NSString* fileName = [NSString stringWithFormat:@"%@%d", @UIS_BLOOM_PATTERN_PREFIX, j];
                imageView.image = [UIImage imageNamed:fileName];
                if (imageView.image == nil) {
                    NSLog(@"[Warning] failed to load image %@", fileName);
                }
                imageView.center = CGPointMake(LAYOUT_OFFSCENE_X, LAYOUT_OFFSCENE_Y);
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
        imageView.center = CGPointMake(LAYOUT_OFFSCENE_Y, LAYOUT_OFFSCENE_Y);
        if (state == 11) {
            state = -1;
        } else {
            state++;
        }
        if (state != -1) {
            imageView = tmpArray[state];
            imageView.center = CGPointMake(LAYOUT_CHANNEL_BASE_X + i*SIZE_CHANNEL_X, LAYOUT_CHANNEL_BASE_Y + SIZE_CHANNEL_Y);
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
                if (note->pos - basePos < 0.002) {
                    note->state = NOTE_STATE_TOUCHED;
                    if (note->type == G_LONG_NOTE) {
                        [self channelStateEvent:CHANNEL_EVENT_NEW_LONG_NOTE atChannel:i];
                    } else {
                        [self channelStateEvent:CHANNEL_EVENT_NEW_SHORT_NOTE atChannel:i];
                    }
                }
            }
            
            if (note->type == G_LONG_NOTE) {
                
                double dx = LAYOUT_CHANNEL_BASE_X + i * SIZE_CHANNEL_X;
                double dy = LAYOUT_CHANNEL_BASE_Y + SIZE_CHANNEL_Y - (note->pos - basePos) /(G_SCENE_RANGE)* SIZE_CHANNEL_Y;
                double length = (note->len)/(G_SCENE_RANGE)*SIZE_CHANNEL_Y;
                //TODO:range check
                UIImageView* imageView = (UIImageView*)notes[curImageViewId++];
                imageView.frame = CGRectMake(dx,dy,SIZE_ANOTHER_KEY_X,length);
                imageView.center = CGPointMake(dx, dy-length/2);
            } else { //G_SHORT_NOTE
                //if (note->pos < basePos) continue; //not on scene
                double dx = LAYOUT_CHANNEL_BASE_X+ i * SIZE_CHANNEL_X;
                double dy = LAYOUT_CHANNEL_BASE_Y+SIZE_CHANNEL_Y - (note->pos - basePos) /(G_SCENE_RANGE)* SIZE_CHANNEL_Y;
                //TODO:range check
                UIImageView* imageView = (UIImageView*)notes[curImageViewId++];
                imageView.frame = CGRectMake(dx, dy, SIZE_ANOTHER_KEY_X, SIZE_ANOTHER_KEY_Y);
                imageView.center = CGPointMake(dx, dy);
            }
        }
    }
    for (int i=curImageViewId; i<lastImageViewId; i++) {
        UIImageView* imageView = (UIImageView*)notes[i];
        imageView.center = CGPointMake(LAYOUT_OFFSCENE_X, LAYOUT_OFFSCENE_Y);
        imageView.frame = CGRectMake(LAYOUT_OFFSCENE_X, LAYOUT_OFFSCENE_Y, SIZE_ANOTHER_KEY_X, SIZE_ANOTHER_KEY_Y);
    }
    lastImageViewId = curImageViewId;
    
    [self channelStateMotive];
    return 0;
}
@end
