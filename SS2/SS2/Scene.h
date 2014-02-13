//
//  Scene.h
//  SS2
//
//  Created by takanoter on 14-2-11.
//  Copyright (c) 2014年 takanoter. All rights reserved.
//

#import "PlayView.h"
#import "BMSEngine.h"
#import <Foundation/Foundation.h>

#define LAYOUT_CHANNEL_WEIGHT 32
#define LAYOUT_CHANNEL_HEIGHT 512
#define LAYOUT_BASE_X 50
#define LAYOUT_BASE_Y 50

#define G_CHANNEL_STATE_BLANK -1
#define G_BLOOM_MAX_COUNT 12
@interface Scene : NSObject {
    PlayView* view;
}
- (Scene*) initWithView:(PlayView*)view;
- (int) renderAs:(SceneNote*)sceneNode;

@end
