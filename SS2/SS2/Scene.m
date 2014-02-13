//
//  Scene.m
//  SS2
//
//  Created by takanoter on 14-2-11.
//  Copyright (c) 2014年 takanoter. All rights reserved.
//

#import "Scene.h"
#define G_MAX_SCENE_NOTE_COUNT 256
#define LAYOUT_NOTE_X 0
#define LAYOUT_NOTE_Y 0

@interface Scene() {
@public NSMutableArray* notes;
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
        
    }
    return self;
}

- (int) renderAs:(SceneNote*)sceneNote {
    int curImageViewId = 0;
    double basePos = sceneNote->basePos;
    for (int i=0; i<G_MAX_CHANNEL_COUNT; i++) {
        for (NSObject* obj in sceneNote->channel[i]) {
            Note* note = (Note*)obj;
            if (note->type == G_LONG_NOTE) {
                
                double dx = LAYOUT_BASE_X + i * LAYOUT_CHANNEL_WEIGHT;
                double dy = LAYOUT_BASE_Y + LAYOUT_CHANNEL_HEIGHT - (note->pos - basePos) /(0.5)* LAYOUT_CHANNEL_HEIGHT;
                double length = (note->len)/(0.5)*LAYOUT_CHANNEL_HEIGHT;
                //TODO:range check
                UIImageView* imageView = (UIImageView*)notes[curImageViewId++];
                imageView.frame = CGRectMake(LAYOUT_NOTE_X,LAYOUT_NOTE_Y,32.0,length);
                imageView.center = CGPointMake(dx, dy-length/2);

                
            } else { //G_SHORT_NOTE
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
    return 0;
}
@end
