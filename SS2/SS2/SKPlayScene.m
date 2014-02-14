//
//  SKPlayScene.m
//  SS2
//
//  Created by takanoter on 14-2-13.
//  Copyright (c) 2014年 takanoter. All rights reserved.
//

#import "SKPlayScene.h"
#import "Scene.h"
@interface SKPlayScene()
@property BOOL contentCreated;
@property SceneNote* sceneNote;

@property NSMutableArray *notes;
@property int lastNoteId;

@end

@implementation SKPlayScene
-(SKLabelNode*)newHelloNode {
    SKLabelNode* helloNode = [SKLabelNode labelNodeWithFontNamed:@"Chalkduster"];
    helloNode.text = @"Hello, world!";
    helloNode.fontSize = 42;
    helloNode.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame));
    helloNode.name=@"helloNode";
    return helloNode;
}

-(void)helloNodeAction {
    SKNode* helloNode = [self childNodeWithName:@"helloNode"];
    SKAction* moveUp=[SKAction moveByX:0 y:100.0 duration:0.5];
    SKAction* zoom=[SKAction scaleTo:2.0 duration:0.25];
    SKAction* pause=[SKAction waitForDuration:0.5];
    SKAction* fadeAway=[SKAction fadeOutWithDuration:0.25];
    SKAction* remove=[SKAction removeFromParent];
    SKAction* moveSequence=[SKAction sequence:@[moveUp,zoom,pause,fadeAway,remove]];
    [helloNode runAction:moveSequence];
}


-(SKSpriteNode*)newSmoothLight {
    SKSpriteNode *hull = [[SKSpriteNode alloc] initWithColor:[SKColor
                                                              greenColor] size:CGSizeMake(3,3)];
    SKAction *hover = [SKAction sequence:@[
                                           [SKAction waitForDuration:0.5],
                                           [SKAction moveByX:100 y:0 duration:0.6/2.6],
                                           [SKAction moveByX:100 y:0 duration:0.6/2.8],
                                           [SKAction moveByX:100 y:0 duration:0.6/3],
                                           [SKAction moveByX:100 y:0 duration:0.6/3.4],
                                           [SKAction moveByX:400 y:0 duration:0.6/3],
                                           [SKAction waitForDuration:0.5],
                                           [SKAction moveByX:-800 y:0 duration:0.2],
                                           //[SKAction speedBy:0.01 duration:0.2],
                                           ]];
    [hull runAction: [SKAction repeatActionForever:hover]];
    return hull;
}

-(void)didMoveToView:(SKView *)view {
    if (!self.contentCreated) {
        self.backgroundColor = [SKColor blackColor];
        self.scaleMode = SKSceneScaleModeAspectFit;
        //[self addChild:[self newHelloNode]];
        
        
        SKSpriteNode* smoothLight = [self newSmoothLight];
        smoothLight.position = CGPointMake(CGRectGetMinX(self.frame), CGRectGetMinY(self.frame)+150);
        [self addChild:smoothLight];
        
        self.notes = [[NSMutableArray alloc]initWithCapacity:G_CHANNEL_ONE_SCENE_MAX_NOTE];
        for (int i=0; i<G_CHANNEL_ONE_SCENE_MAX_NOTE; i++) {
            SKSpriteNode* keyNote = [[SKSpriteNode alloc] initWithColor:[SKColor whiteColor] size:CGSizeMake(64,8)];
            keyNote.position = CGPointMake(CGRectGetMinX(self.frame), CGRectGetMinY(self.frame));
            self.notes[i] = keyNote;
            [self addChild:keyNote];
        }
        
        self.sceneNote = [[SceneNote alloc]init];
        self.lastNoteId = 0;
        self.contentCreated=YES;
    }
}
-(void) update : (NSTimeInterval)currentTime{
    //NSLog(@"[Performance]");
    float timeBegin = [[NSDate date] timeIntervalSince1970];
    //double globalPos = audioPlayer.currentTime;

    //self.node.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame)-((int)globalPos*100 % LAYOUT_CHANNEL_HEIGHT));
    //NSLog(@"here %lf %d", self.node.position.y, (int)globalPos%LAYOUT_CHANNEL_HEIGHT);
    int curNoteId = 0;
    SceneNote* scene = self.sceneNote;
    double globalTimestamp = audioPlayer.currentTime + bms->bgmFixedTs;
    [bms getCurScene:scene atTimestamp:globalTimestamp inRange:G_SCENE_RANGE];
    
    double basePos = scene->basePos;
    for (int i=0; i<G_MAX_CHANNEL_COUNT; i++) {
        for (NSObject* obj in scene->channel[i]) {
            Note* note = (Note*)obj;
            double dx = LAYOUT_BASE_X + i * LAYOUT_CHANNEL_WEIGHT *2;
            double dy = -LAYOUT_BASE_Y /*- LAYOUT_CHANNEL_HEIGHT*/ + (note->pos - basePos) /(G_SCENE_RANGE)* LAYOUT_CHANNEL_HEIGHT *2;
            SKSpriteNode* node = self.notes[curNoteId++];
            if (note->type == G_LONG_NOTE) {
                double length = (note->len)/(G_SCENE_RANGE)*LAYOUT_CHANNEL_HEIGHT*2;
                node.size = CGSizeMake(64, length);
                dy+=length/2;
            } else {
                node.size = CGSizeMake(64,8);
            }
            node.position = CGPointMake(dx,dy);
        }
    }
    for (int i=curNoteId; i<self.lastNoteId; i++) {
        SKSpriteNode* node = self.notes[i];
        node.position = CGPointMake(CGRectGetMinX(self.frame), CGRectGetMinY(self.frame));
        node.size = CGSizeMake(64,8);
    }
    self.lastNoteId = curNoteId;
    
    float timeEnd = [[NSDate date] timeIntervalSince1970];
    //NSLog(@"[Performance]%f %f %f", timeBegin, timeEnd, timeEnd - timeBegin);

}

-(void)render{
    [self helloNodeAction];
}
@end
