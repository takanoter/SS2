//
//  SKPlayScene.m
//  SS2
//
//  Created by takanoter on 14-2-13.
//  Copyright (c) 2014年 takanoter. All rights reserved.
//

#import "SKPlayScene.h"
#import "Scene.h"
#import "UILayout.h"

#define CHANNEL_EVENT_NEW_LONG_NOTE 0
#define CHANNEL_EVENT_NEW_SHORT_NOTE 1
#define CHANNEL_EVENT_OVER_LONG_NOTE 2

@interface SKPlayScene()
@property BOOL contentCreated;
@property SceneNote* sceneNote;

@property NSMutableArray *shortNotes;
@property NSMutableArray *longNotesA;
@property NSMutableArray *longNotesB;
@property int lastShortNoteId;
@property int lastLongNoteId;

@property NSMutableArray* bloom;
@property NSMutableArray* channelState;

@property int comboLast;
@property int comboNow;
@property int comboState;
@property NSMutableArray* combo;

@property NSMutableArray* num;
@property NSMutableArray* numUsedPos;
@property int numState;

@property NSMutableArray* cool;
@property int coolState;

@end

@implementation SKPlayScene

-(void)setBackground {
    NSString* fileName = [NSString stringWithFormat:@"%@%d", @UIS_BACKGROUND_PATTERN_PREFIX, UIS_BACKGROUND_PATTERN_COUNT-1];
    SKSpriteNode* bgNode = [SKSpriteNode spriteNodeWithImageNamed:fileName];
    bgNode.position = CGPointMake(LAYOUT_BG_X, LAYOUT_BG_Y);
    [self addChild:bgNode];
}
-(void)didMoveToView:(SKView *)view {
    if (!self.contentCreated) {
        self.backgroundColor = [SKColor blackColor];
        self.scaleMode = SKSceneScaleModeAspectFit;
        //[self addChild:[self newHelloNode]];
        [self setBackground];
        
        self.shortNotes = [[NSMutableArray alloc]initWithCapacity:G_SCENE_MAX_SHORT_NOTE_COUNT];
        for (int i=0; i<G_SCENE_MAX_SHORT_NOTE_COUNT; i++) {
            NSString* fileName = [NSString stringWithFormat:@"%@%d", @UIS_KEY_PATTERN_PREFIX, UIS_KEY_PATTERN_COUNT-1];
            SKSpriteNode* keyNote = [SKSpriteNode spriteNodeWithImageNamed:fileName];
            keyNote.size = CGSizeMake(SIZE_SHORT_NOTE_X,SIZE_SHORT_NOTE_Y);
            keyNote.position = CGPointMake(LAYOUT_OFFSCENE_X, LAYOUT_OFFSCENE_Y );
            self.shortNotes[i] = keyNote;
            [self addChild:keyNote];
        }
        
        self.longNotesA = [[NSMutableArray alloc]initWithCapacity:G_SCENE_MAX_LONG_NOTE_COUNT];
        for (int i=0; i<G_SCENE_MAX_SHORT_NOTE_COUNT; i++) {
            NSString* tmpName = [NSString stringWithFormat:@"%@%d", @UIS_KEY_P0_PATTERN_PREFIX, UIS_KEY_P0_PATTERN_COUNT-1];
            SKSpriteNode* keyNote = [SKSpriteNode spriteNodeWithImageNamed:tmpName];
            keyNote.size = CGSizeMake(SIZE_LONG_NOTE_X,SIZE_LONG_NOTE_Y);
            keyNote.position = CGPointMake(LAYOUT_OFFSCENE_X, LAYOUT_OFFSCENE_Y );
            self.longNotesA[i] = keyNote;
            [self addChild:keyNote];
        }
        
        self.longNotesB = [[NSMutableArray alloc]initWithCapacity:G_SCENE_MAX_LONG_NOTE_COUNT];
        for (int i=0; i<G_SCENE_MAX_SHORT_NOTE_COUNT; i++) {
            NSString* tmpName = [NSString stringWithFormat:@"%@%d", @UIS_KEY_P1_PATTERN_PREFIX, UIS_KEY_P1_PATTERN_COUNT-1];
            SKSpriteNode* keyNote = [SKSpriteNode spriteNodeWithImageNamed:tmpName];
            keyNote.size = CGSizeMake(SIZE_LONG_NOTE_X,SIZE_LONG_NOTE_Y);
            keyNote.position = CGPointMake(LAYOUT_OFFSCENE_X, LAYOUT_OFFSCENE_Y );
            self.longNotesB[i] = keyNote;
            [self addChild:keyNote];
        }
        
        
        self.bloom = [[NSMutableArray alloc]initWithCapacity:G_MAX_CHANNEL_COUNT];
        for (int i=0; i<G_MAX_CHANNEL_COUNT; i++) {
            NSMutableArray *tmpArray = [[NSMutableArray alloc]initWithCapacity:UIS_BLOOM_PATTERN_COUNT];
            self.bloom[i] = tmpArray;
            for (int j=0; j<UIS_BLOOM_PATTERN_COUNT; j++) {
                NSString* fileName = [NSString stringWithFormat:@"%@%d", @UIS_BLOOM_PATTERN_PREFIX, j];
                SKSpriteNode* node = [SKSpriteNode spriteNodeWithImageNamed:fileName];
                node.size = CGSizeMake(SIZE_BLOOM_X*2, SIZE_BLOOM_Y*2);
                node.position = CGPointMake(LAYOUT_OFFSCENE_X, LAYOUT_OFFSCENE_Y);
                tmpArray[j] = node;
                [self addChild:node];
            }
        }
        
        self.channelState = [[NSMutableArray alloc]initWithCapacity:G_MAX_CHANNEL_COUNT];
        for (int i=0; i<G_MAX_CHANNEL_COUNT; i++) {
            NSNumber* numObj = [NSNumber numberWithInt:-1];
            self.channelState[i] = numObj;
        }

        //combo
        self.comboLast = 0;
        self.comboNow = 0;
        self.comboState = 0;
        self.combo = [[NSMutableArray alloc]initWithCapacity:UIS_COMBO_PATTERN_COUNT];
        for (int i=0; i<UIS_COMBO_PATTERN_COUNT; i++) {
            NSString* fileName = [NSString stringWithFormat:@"%@%d", @UIS_COMBO_PATTERN_PREFIX, i];
            SKSpriteNode* node = [SKSpriteNode spriteNodeWithImageNamed:fileName];
            node.size = CGSizeMake(SIZE_COMBO_X, SIZE_COMBO_Y);
            node.position = CGPointMake(LAYOUT_OFFSCENE_X, LAYOUT_OFFSCENE_Y);
            self.combo[i] = node;
            [self addChild:node];
        }
        
        self.numState = 0;
        self.num = [[NSMutableArray alloc]initWithCapacity:UIS_NUM_PATTERN_COUNT];
        for (int i=0; i<UIS_NUM_PATTERN_COUNT; i++) {
            NSMutableArray* tmpArray = [[NSMutableArray alloc]initWithCapacity:G_MAX_NUM_PRESERVE];
            for (int j=0; j<G_MAX_NUM_PRESERVE; j++) {
                NSString* fileName = [NSString stringWithFormat:@"%@%d", @UIS_NUM_PATTERN_PREFIX, i];
                SKSpriteNode* node = [SKSpriteNode spriteNodeWithImageNamed:fileName];
                if (node == nil) {
                    NSLog(@"[Warning] failed to load file:%@", fileName);
                }
                node.position = CGPointMake(LAYOUT_OFFSCENE_X, LAYOUT_OFFSCENE_Y);
                node.size = CGSizeMake((1-self.comboState*1.0/UIS_COMBO_PATTERN_COUNT)*SIZE_NUM_X, (1-self.comboState*1.0/UIS_COMBO_PATTERN_COUNT)*SIZE_NUM_Y);
                tmpArray[j]=node;
                [self addChild:node];
            }
            self.num[i] = tmpArray;
        }
        
        //cool
        self.coolState = 0;
        self.cool = [[NSMutableArray alloc]initWithCapacity:UIS_COOL_PATTERN_COUNT];
        for (int i=0; i<UIS_COOL_PATTERN_COUNT; i++) {
            NSString* fileName = [NSString stringWithFormat:@"%@%d", @UIS_COOL_PATTERN_PREFIX, i];
            SKSpriteNode* node = [SKSpriteNode spriteNodeWithImageNamed:fileName];
            if (node == nil) {
                NSLog(@"[Warning] failed to load file:%@", fileName);
            }
            node.position = CGPointMake(LAYOUT_OFFSCENE_X, LAYOUT_OFFSCENE_Y);
            node.size = CGSizeMake(SIZE_COOL_X, SIZE_COOL_Y);
            self.cool[i]=node;
            [self addChild:node];
        }

        self.sceneNote = [[SceneNote alloc]init];
        self.lastShortNoteId = 0;
        self.lastLongNoteId = 0;

        self.contentCreated=YES;
    }
}

- (void)channelStateEvent:(int)event atChannel:(int)channel {
    NSNumber* numObj = self.channelState[channel];
    int state = [numObj intValue];
    if (event == CHANNEL_EVENT_NEW_LONG_NOTE) {
        if (state == -1) state = 0; //long note开始显示
        else { //long note持续显示[4,9]
            if (state>10) state = 6;
            //else do nothing ,state auto ++;
        }
    } else if (event == CHANNEL_EVENT_NEW_SHORT_NOTE) {
        if (state == -1) state = 0;
        //else state = 1;
    } else if (event == CHANNEL_EVENT_OVER_LONG_NOTE) {
        state = 2;
    } else {
        //do nothing
    }
    [self.channelState replaceObjectAtIndex:channel withObject:[NSNumber numberWithInt:state]];
}

- (void)channelStateMotive {
    for (int i=0; i<G_MAX_CHANNEL_COUNT; i++) {
        NSNumber* numObj = self.channelState[i];
        //if (i==2) NSLog(@"[Debug]channel state:%d", state);
        NSMutableArray* tmpArray = self.bloom[i];
        SKSpriteNode* node = nil;
        for (int j=0; j<UIS_BLOOM_PATTERN_COUNT; j++) {
            node = tmpArray[j];
            node.position = CGPointMake(LAYOUT_OFFSCENE_Y, LAYOUT_OFFSCENE_Y);
        }
        
        int state = [numObj intValue];
        if (state == -1) continue;
        if (state == 11) {
            state = -1;
        } else {
            state++;
        }
        if (state != -1) {
            node = tmpArray[state];
            node.position = CGPointMake(LAYOUT_CHANNEL_BASE_X + i*SIZE_SKVIEW_CHANNEL_X, LAYOUT_SKVIEW_CHANNEL_BASE_Y + SIZE_CHANNEL_Y);
        }
        
        [self.channelState replaceObjectAtIndex:i withObject:[NSNumber numberWithInt:state]];
    }
}

-(void) comboShow {
    bool changed = false;
    for (int i=0; i<UIS_COMBO_PATTERN_COUNT; i++) {
        SKSpriteNode* node = self.combo[i];
        node.position = CGPointMake(LAYOUT_OFFSCENE_X, LAYOUT_OFFSCENE_Y);
    }
    if (self.comboLast != self.comboNow) {
        changed = true;
        self.comboLast = self.comboNow;
        self.comboState = -1;
    }
    
    self.comboState++;
    if (self.comboState < UIS_COMBO_PATTERN_COUNT*3) {
        SKSpriteNode* node = self.combo[self.comboState/3];
        node.position = CGPointMake(LAYOUT_COMBO_X + SIZE_COMBO_X/2, LAYOUT_COMBO_Y);
    } else {
        self.comboState = UIS_COMBO_PATTERN_COUNT*3;
    }
    
    for (int i=0; i<UIS_NUM_PATTERN_COUNT; i++) {
        NSMutableArray* tmpArray = self.num[i];
        for (int j=0; j<G_MAX_NUM_PRESERVE; j++) {
            SKSpriteNode* node = tmpArray[j];
            node.position = CGPointMake(LAYOUT_OFFSCENE_X, LAYOUT_OFFSCENE_Y);
        }
    }

    const int totalNumState = 18;
    if (changed) self.numState = 0;
    if (self.numState > totalNumState) {
        self.numState = totalNumState;
    } else {
        self.numState++;
    }
    if (self.numState != totalNumState) { //显示数字
        int weishu = 0;
        for (int num = self.comboNow; num>0; num=num/10, weishu++);
        int num = self.comboNow;
        int pos = -1;
        while (num>0) {
            pos++;
            int curNum = num%10;
            num = num/10;
            double curPos = weishu*0.5 - pos ;
            int curAvailId = 0;
            NSMutableArray* tempArray = self.num[curNum];
            SKSpriteNode* node = nil;
            for (curAvailId=0; curAvailId<G_MAX_NUM_PRESERVE; curAvailId++) {
                node = tempArray[curAvailId];
                if (node.position.x == LAYOUT_OFFSCENE_X) break;
            }
            node.position = CGPointMake(LAYOUT_NUM_X + (curPos)*LAYOUT_NUM_DIS_X, LAYOUT_NUM_Y);
            double percent =  0;
            if (self.numState < 7) {
                percent = self.numState*1.0/totalNumState - 0.2;
            } else if (self.numState < 9) {
                percent = self.numState*1.0/totalNumState - 0.3;
            } else {
                percent = 0;
            }
            node.size = CGSizeMake((1-percent)*SIZE_NUM_X, (1-percent)*SIZE_NUM_Y);
            //NSLog(@"weishu:%d combo:%d curNum:%d pos:%d curPos:%lf", weishu, self.comboNow, curNum, pos, curPos);
        }
    }
    
    const int totalCoolState = 10;
    if (changed) {
        self.coolState = 0;
    }
    SKSpriteNode* node = self.cool[0];
    if (self.coolState > totalCoolState) {
        node.position = CGPointMake(LAYOUT_OFFSCENE_X, LAYOUT_OFFSCENE_Y);
        //do nothing
    } else { // draw something
        self.coolState++;
        node.position = CGPointMake(LAYOUT_COOL_X, LAYOUT_COOL_Y);
        node.size = CGSizeMake( (1 - self.coolState*1.0/totalCoolState*0.5)*SIZE_COOL_X, (1-self.coolState*1.0/totalCoolState*0.5)*SIZE_COOL_Y);
    }
    
}

-(void) update : (NSTimeInterval)currentTime{
    //float timeBegin = [[NSDate date] timeIntervalSince1970];

    int curShortNoteId = 0;
    int curLongNoteId = 0;
    SceneNote* scene = self.sceneNote;
    double globalTimestamp = audioPlayer.currentTime + bms->bgmFixedTs;
    [bms getCurScene:scene atTimestamp:globalTimestamp inRange:G_SCENE_RANGE];
    
    double basePos = scene->basePos;
    for (int i=0; i<G_MAX_CHANNEL_COUNT; i++) {
        bool channelDeal = false;
        for (NSObject* obj in scene->channel[i]) {
            Note* note = (Note*)obj;
            
            //FIXME: buggy since born
            if (!channelDeal) {
                if (note->type == G_LONG_NOTE) {
                    if (note->pos - basePos < 0.002) {
                        if ((note->pos > basePos)) {
                            [self channelStateEvent:CHANNEL_EVENT_NEW_LONG_NOTE atChannel:i];
                            channelDeal=true;
                        }
                        if ((note->pos < basePos) && (note->pos+note->len > basePos)) {
                            [self channelStateEvent:CHANNEL_EVENT_NEW_LONG_NOTE atChannel:i];
                            channelDeal = true;
                        }
                        if ((note->pos + note->len -basePos <= 0)) {
                            if (note->state != NOTE_STATE_SILENCE) { //状态，重入保护
                                [self channelStateEvent:CHANNEL_EVENT_OVER_LONG_NOTE atChannel:i];
                            }
                            channelDeal = true;
                            note->state = NOTE_STATE_SILENCE;
                            self.comboNow++;
                        }
                    }
                } else {
                    if (note->pos -basePos < 0.002) {
                        if (note->state!=NOTE_STATE_SILENCE) { //状态，重入保护
                            [self channelStateEvent:CHANNEL_EVENT_NEW_SHORT_NOTE atChannel:i];
                            channelDeal = true;
                            note->state = NOTE_STATE_SILENCE;
                            self.comboNow++;
                        }
                    }
                }
            }
            
            double dx = LAYOUT_CHANNEL_BASE_X + i * SIZE_CHANNEL_X *2;
            double dy = LAYOUT_SKVIEW_Y-LAYOUT_CHANNEL_BASE_Y + (note->pos - basePos) /(G_SCENE_RANGE)* SIZE_CHANNEL_Y *2;
            if (note->type == G_LONG_NOTE) {

                SKSpriteNode* nodePA = self.longNotesA[curLongNoteId];
                nodePA.size = CGSizeMake(SIZE_LONG_NOTE_X, SIZE_LONG_NOTE_Y);
                nodePA.position = CGPointMake(dx,dy);

                double length = (note->len)/(G_SCENE_RANGE)*SIZE_CHANNEL_Y*2;
                //length += length/4; //picture adjust by percent
                dy+=length/2 /*- length/20*/; //picture adjust by percent
                SKSpriteNode* nodePB = self.longNotesB[curLongNoteId];
                nodePB.size = CGSizeMake(SIZE_LONG_NOTE_X, length);
                nodePB.position = CGPointMake(dx,dy);
                
                curLongNoteId++;
            } else { //G_SHORT_NOTE
                SKSpriteNode* node = self.shortNotes[curShortNoteId++];
                node.size = CGSizeMake(SIZE_SHORT_NOTE_X,SIZE_SHORT_NOTE_Y);
                node.position = CGPointMake(dx,dy);
            }
        }
    }
    for (int i=curShortNoteId; i<self.lastShortNoteId; i++) {
        SKSpriteNode* node = self.shortNotes[i];
        node.position = CGPointMake(LAYOUT_OFFSCENE_X, LAYOUT_OFFSCENE_Y );
        node.size = CGSizeMake(SIZE_SHORT_NOTE_X,SIZE_SHORT_NOTE_Y);
    }
    self.lastShortNoteId = curShortNoteId;
    
    for (int i=curLongNoteId; i<self.lastLongNoteId; i++) {
        SKSpriteNode* node = self.longNotesA[i];
        node.position = CGPointMake(LAYOUT_OFFSCENE_X, LAYOUT_OFFSCENE_Y );
        node.size = CGSizeMake(SIZE_LONG_NOTE_X,SIZE_LONG_NOTE_Y);
        
        node = self.longNotesB[i];
        node.position = CGPointMake(LAYOUT_OFFSCENE_X, LAYOUT_OFFSCENE_Y );
        node.size = CGSizeMake(SIZE_LONG_NOTE_X,SIZE_LONG_NOTE_Y);
    }
    self.lastLongNoteId = curLongNoteId;
    
    [self channelStateMotive];
    [self comboShow];
    //float timeEnd = [[NSDate date] timeIntervalSince1970];
    //NSLog(@"[Performance]%f %f %f", timeBegin, timeEnd, timeEnd - timeBegin);
}

@end
