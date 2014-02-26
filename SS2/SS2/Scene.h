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
#import "utils.h"


#define G_CHANNEL_STATE_BLANK -1
@interface Scene : NSObject {
    PlayView* view;
}
- (Scene*) initWithView:(PlayView*)view;
- (int) renderAs:(SceneNote*)sceneNode;

@end
