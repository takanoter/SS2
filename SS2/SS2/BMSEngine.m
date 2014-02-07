//
//  BMSEngine.m
//  SS2
//
//  Created by takanoter on 14-1-15.
//  Copyright (c) 2014年 takanoter. All rights reserved.
//

#import "BMSEngine.h"
BMSEngine *gBmsEngine = nil;

@implementation BMSEngine

//sorted:{timestamp, bar}
//sorted: [channel] notes
//notes: type, startPos, length

-(int)loadFromFile:(NSString*)pathname {
    
}

-(int)getCurScene:(SceneNote*)scene atTimestamp:(double)ts {
/*
    if (scene != nil) {
        Note* note = [Note alloc];
        note->pos = (ts % 100 ) * 1.0 / 100;
        note->type = G_SHORT_NOTE;
//        [scene->channel[0] addObject:note];
    }
 */
   // Note* note = [Note alloc];
    

 return 0;
}

@end
