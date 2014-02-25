//
//  BMSEngine.m
//  SS2
//
//  Created by takanoter on 14-1-15.
//  Copyright (c) 2014年 takanoter. All rights reserved.
//

#import "BMSEngine.h"
#import "DataManager.h"


#define G_JINZHI 36
#define G_JINZHI_BPM 16

BMSEngine *gBmsEngine = nil;
@implementation Note
-(Note*)init {
    if (self=[super init]) {
    }
    return self;
}
@end

@implementation SceneNote
-(SceneNote*)init {
    if (self=[super init]) {
        basePos = 0.0;
        lastTsBpmIdx = 0;
        channel = [[NSMutableArray alloc]initWithCapacity:G_MAX_CHANNEL_COUNT];
        lastBeginIdx = [[NSMutableArray alloc]initWithCapacity:G_MAX_CHANNEL_COUNT];
        for (int i=0; i<G_MAX_CHANNEL_COUNT; i++) {
            channel[i] = [[NSMutableArray alloc]init];
            lastBeginIdx[i] = [NSNumber numberWithInt:0];
        }
        bgmChannel = [[NSMutableArray alloc]init];
        lastBgmIdx = 0;
    }
    return self;
}

@end

@interface ShiftNote : NSObject {
@public    double timestamp;
@public    double pos; //of bar/score
@public    double bpm;
@public    int noteId; //?
}
@end
@implementation ShiftNote
-(ShiftNote*)initWithId:(int)noteId bpm:(double)bpm {
    if (self=[super init]) {
        self->bpm = bpm;
        self->noteId = noteId;
    }
    return self;
}
@end


@implementation BgmNote
-(BgmNote*)initWithAudio:(AVAudioPlayer*)audioPlayer atTimestamp:(double)timestamp atPosition:(double)position{
    if (self=[super init]) {
        ts = timestamp;
        audio = audioPlayer;
        pos = position;
    }
    return self;
}
@end


@implementation Audio
-(Audio*)initAsSign:(NSString*)itemSign byAudio:(AVAudioPlayer*)itemAudio {
    if (self=[super init]) {
        sign = itemSign;
        audioPlayer = itemAudio;
    }
    return self;
}
@end

@interface BMSEngine() {
    BOOL init;
    NSString* name;
    NSMutableArray* channel; //G_MAX_CHANNEL_COUNT
    NSArray* ts2bar;
    NSMutableArray* bgmNotes;
}
@end

@implementation BMSEngine
-(int)toNum:(UInt8)v {
    if ((v>='0')&&(v<='9')) return v-'0';
    if ((v>='A')&&(v<='Z')) return v-'A'+10;
    if ((v>='a')&&(v<='z')) return v-'a'+10;
    return -1;
}

//"0A"
-(int)cal2Sign:(NSString*)sign inBinary:(int)the {
    char a = [sign characterAtIndex:0];
    char b = [sign characterAtIndex:1];
    return [self toNum:a]*the + [self toNum:b];
}

//sortedByTs:{timestamp, barId}
//sortedByPos: [channel] notes
//notes: type, startPos, length
-(BMSEngine*)initWithPathname:(NSString*)pathname {
    if (self=[super init]) {
        init=false;
        channel=nil;
        ts2bar = nil;
        sign2audio = nil;
        name = pathname;
        [self loadFromFile:pathname];
    }
    return self;
}

-(int)parseWav:(NSData*)reader {

    /*
    NSString* eachLine = nil;
    NSStringEncoding gbkEncoding = CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingGB_18030_2000);
    NSString* fileStr = [[NSString alloc]initWithBytes:[reader bytes] length:[reader length] encoding:gbkEncoding];
    NSArray* lines = [fileStr componentsSeparatedByString:@"\n"];
    NSEnumerator* lineNse = [lines objectEnumerator];
    //NSArray* extTypeNames = [NSArray arrayWithObjects:@"mp3", @"ogg", @"bmp", @"ogg", nil];
    while (eachLine = [lineNse nextObject]) {
        if (![eachLine hasPrefix:@"#WAV"]) continue;
        eachLine = [eachLine stringByReplacingOccurrencesOfString:@"\r" withString:@""];
    */
    //NSMutableDictionary* tmpSign2audio = [[NSMutableDictionary alloc]init];
    sign2audio = [[NSMutableDictionary alloc]init];
    
    NSError *error;
    NSBundle *myBundle = [NSBundle mainBundle];
    SongSource* ss = [gDataMgr getSourceByName:name];
    NSMutableDictionary* songItems = ss.items;
    NSEnumerator* wavNse = [songItems objectEnumerator];
    SongSourceItem* wavItem = nil;
    int maxMotion = 0;
    while (wavItem = [wavNse nextObject]) {
        if (![wavItem.type isEqual:@"mp3"]) continue;
        NSString* musicFilePath = [myBundle pathForResource:wavItem.name ofType:wavItem.type];
        if (musicFilePath==nil) {
            NSLog(@"[Warning] failed get music[%@]", wavItem.name);
            continue;
        }
        NSURL *musicURL= [[NSURL alloc]initFileURLWithPath:musicFilePath];
        AVAudioPlayer* audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:musicURL error:&error];
        if (audioPlayer==nil) {
            NSLog(@"[Warning] audioplayer nil for[%@] reason[%@]", musicURL, [error localizedDescription]);
            continue;
        }
        [audioPlayer prepareToPlay];
        [audioPlayer setVolume:1];
        //audioPlayer.numberOfLoops = 1;
        NSString* sign = [wavItem.header substringFromIndex:4]; //"#WAV0A" -> "0A"
        Audio* audio = [[Audio alloc]initAsSign:sign byAudio:audioPlayer];
        if (audio==nil) {
            NSLog(@"[Warning]");
            continue;
        }
        int numSign = [self cal2Sign:sign inBinary:G_JINZHI];
        if (numSign > maxMotion) maxMotion = numSign;
        [sign2audio setObject:audio forKey:[NSNumber numberWithInteger:numSign]];
        NSLog(@"[OK]:load mp3:%@ success. %@", sign, /*[error localizedDescription]*/musicURL);
    }
    
    /*
    sign2audio = [[NSMutableArray alloc]initWithCapacity:maxMotion+1];
    Audio* curAudio = nil;
    for (int i=0; i<maxMotion+1; i++) {
        sign2audio[i] = nil;  //can not setObject with "nil object"
    }
    NSEnumerator* nse = [tmpSign2audio objectEnumerator];
    while (curAudio = [nse nextObject]) {
        int sign = [self cal2Sign:curAudio->sign inBinary:G_JINZHI];
        sign2audio[sign] = curAudio;
    }
    */
    
    
    return 0;
}

-(bool)lineCheckMainData:(UInt8*)line withSize:(int)line_size {
    for (int i=1; i<line_size; i++) {
        if (line[i]!='-') {
            //let's check
            if ((line[i]==' ') && (line[i+1]=='M') && (line[i+2]=='A')) return true;
            return false;
        }
    }
    return false;
}

//判断是否是 "#BPM01 122.5" 或 "#BPM 85"，并抽取放入到bpmTable中
-(bool) lineProcessBpm:(UInt8*)line withLen:(int)len toBpmTable:(NSMutableDictionary*)table{
    if (!((line[0]=='#') && (line[1]=='B')
          && (line[2]=='P') && (line[3]=='M'))) {
        return false;
    }
    int valueStartPos = 0;
    int noteId = 0;
    if (line[4]==' ') {
        valueStartPos = 5;
        noteId = 0;
    } else {
        valueStartPos = 7;
        noteId = ([self toNum:line[4]])*G_JINZHI_BPM + ([self toNum:line[5]]);
    }
    
    bool hasPoint = false;
    double result = 0;
    double point = 0.1;
    for (int i=valueStartPos; i<=len-1; i++)  {
        if (line[i]=='.') {
            hasPoint = true;
            continue;
        }
        if (!hasPoint) {
            result = result*10 + line[i]-'0';
        } else {
            result += point*(line[i]-'0');
            point = point*0.1;
        }
    }
    
    [table setObject:[NSNumber numberWithDouble:result] forKey:[NSNumber numberWithInt:noteId]];
    return true;
}

-(void)linePrint:(UInt8*)line withLength:(int)len {
    NSLog(@"[Debug][%d][%s]", len, line);
}



//现在line[]整行内容为"#00416:0000000000020000"
-(void)lineProcess:(UInt8*)line withLength:(int)len collector:(NSMutableArray*)notes {
    int param = (line[1]-'0')*100+(line[2]-'0')*10+(line[3]-'0');
    int channel = (line[4]-'0')*10+(line[5]-'0');
    for (int j=7,i=1; j<len; j=j+2,i++) {
        int motion=0;

        if ((channel == 8) || (channel==3)) { //自定义bpm通道，进制为16进制
            motion=([self toNum:line[j]])*G_JINZHI_BPM+([self toNum:line[j+1]]);
        } else { //其他通道，进制为36进制
            motion=([self toNum:line[j]])*G_JINZHI+([self toNum:line[j+1]]);
        }
        if (motion == 0) continue;

        
        if (!((channel>=51 && channel<=58) || (channel>=11 && channel<=19))) {
            NSLog(@"oh channel:%d motion:%d",channel, motion);
        }
        
        //int keyID = param*100+channel;
        //NSString *key = [NSString stringWithFormat:@"%d", keyID];
        Note* note = [[Note alloc]init];
        note->pos = param + (i-1)*1.0/((len-7)/2);
        note->len = 0;
        note->channel = channel;
        note->type = motion;
        note->motion = motion;
        [notes addObject:note];
        /*
        ParamBar *param = [notes valueForKey:key];
        if (NULL == param) {
            param = [[ParamBar alloc]initParamBar:paramID inChannel:channelID];
            [param pushMotion:motionID];
            [notes setObject:param forKey:key];
        } else {
            [param pushMotion:motionID];
        }
         */
    }
}

-(int) processBaseBpmNote:(NSMutableDictionary*)bpmTable to:(NSMutableArray*)shiftNotes {
    double initBpm = 80.0;
    NSObject *obj = [bpmTable objectForKey:[NSNumber numberWithInt:0]];
    if (obj != nil) {
        initBpm = [(NSNumber*)obj doubleValue];
    }
    
    ShiftNote* note = [[ShiftNote alloc]initWithId:0 bpm:initBpm];
    note->pos = 0;
    //note->timestamp = 0;
    [shiftNotes addObject:note];
    return 0;
}

//11-16 18 号通道，short note for 1P
-(int) processShortNote:(Note*)note to:(NSMutableArray*)channelNotes {
    Note* curNote = [[Note alloc]init];
    curNote->gId = 0;
    curNote->pos = note->pos;
    curNote->motion = note->motion;
    curNote->len = 0;
    curNote->type = G_SHORT_NOTE;
    curNote->state = 0;
    if (note->channel < 17) {
        curNote->channel = note->channel - 11; //0-based
    } else { // note->channel == 18
        curNote->channel = 6;
    }
    [channelNotes[curNote->channel] addObject:curNote];
    return 0;
}

//51-56 58 号通道，long note for 1P
-(int) processLongNote:(Note*)note to:(NSMutableArray*)channelNotes atState:(NSMutableArray*)channelState {
    int curChannel = 0;
    if (note->channel < 57) {
        curChannel = note->channel-51; // 0-based
    } else curChannel = 6;
    
    Note* noteState = channelState[curChannel];
    if (noteState->pos == -1) {
        noteState->pos = note->pos;
        noteState->channel = note->channel;
        noteState->motion = note->motion;
    } else { //noteState->pos != -1
        Note* newNote = [[Note alloc]init];
        newNote->pos = noteState->pos;
        newNote->channel = note->channel;
        newNote->len = note->pos - noteState->pos;
        newNote->type = G_LONG_NOTE;
        newNote->motion = noteState->motion;
        [channelNotes[curChannel] addObject:newNote];
        noteState->pos = -1;
    }
    return 0;
}

-(int) processBgmNote:(Note*)note to:(NSMutableArray*)channelNotes {
    [channelNotes addObject:note];
    return 0;
}

//8号通道自定义bpm
-(int) processBpmNoteDynamic:(Note*)note as:(NSMutableDictionary*)bpmTable to:(NSMutableArray*)shiftNotes {
    int bpmId = note->type;
    NSObject *obj = [bpmTable objectForKey:[NSNumber numberWithInt:bpmId]];
    if (obj == nil) {
        NSLog(@"[Notice] failed to get bpm id:[pos:%lf channel:%d type:%d]",
              note->pos, note->channel, note->type);
        return -1;
    }
    ShiftNote* shiftNote = [[ShiftNote alloc]initWithId:0 bpm:[(NSNumber*)obj doubleValue]];
    shiftNote->pos = note->pos;
    [shiftNotes addObject:shiftNote];
    return 0;
}

//3号通道人工整数bpm
-(int) processBpmNoteStatic:(Note*)note to:(NSMutableArray*)shiftNotes {
    int bpm = note->type;
    ShiftNote* shiftNote = [[ShiftNote alloc]initWithId:0 bpm:bpm];
    shiftNote->pos = note->pos;
    [shiftNotes addObject:shiftNote];
    return 0;
}



-(int)parse:(NSData*)reader {
    UInt8 the, line[1024]; //FIXME:max char per line
    int length = [reader length];
    NSMutableArray* tmpNotes = [[NSMutableArray alloc]init];
    NSMutableDictionary* id2bpm = [[NSMutableDictionary alloc]init];
    
    NSMutableArray* tmpBgmNotes = [[NSMutableArray alloc]init];
    bgmNotes = [[NSMutableArray alloc]init];
    
    //1 read file
    bool isMainBody = false;
    for (int i=0; i<length; i++) {
        int ptr = 0;
        do {
            [reader getBytes:&the range:NSMakeRange(i, sizeof(the))];
            i++;
            if (the==13 || the==10) break;
            line[ptr]=the;
            ptr++;
        }while ((the!=13) || (the!=10)); // '/r' '/n'
        
        if (ptr==0) continue;  //EOF
        
        if (!isMainBody) {
            //初始的变奏判断，判断是否是"#BPM09 122.5"
            if ([self lineProcessBpm:line withLen:ptr toBpmTable:id2bpm]) continue;
            
            //判断是否是*--- MAIN DATA
            if (line[0]!='*') continue;
            if ([self lineCheckMainData:line withSize:ptr]) {
                isMainBody = true;
            }
            continue;
        }
        //[self linePrint:line withLength:ptr];
        [self lineProcess:line withLength:ptr collector:tmpNotes];
    }//end of global file iterator
    
    //2. parse bms notes
    for (NSObject *obj in tmpNotes) {
        Note* note = (Note*)obj;
        //NSLog(@"[Debug][pos:%lf][channel:%d][type:%d]", note->pos, note->channel, note->type);
    }
    
    
    NSMutableArray* shiftNotes = [[NSMutableArray alloc]init];
    NSMutableArray* channelNotes = [[NSMutableArray alloc]initWithCapacity:G_MAX_CHANNEL_COUNT];
    NSMutableArray* channelState = [[NSMutableArray alloc]initWithCapacity:G_MAX_CHANNEL_COUNT];
    for (int i=0; i<G_MAX_CHANNEL_COUNT; i++) {
        channelNotes[i] = [[NSMutableArray alloc]init];
        Note* note = [[Note alloc]init];
        note->pos = -1;
        channelState[i] = note;
    }
    
    [self processBaseBpmNote:id2bpm to:shiftNotes];
    double bgmPos = 0;
    for (NSObject *obj in tmpNotes) {
        Note* note = (Note*)obj;
        if (note->channel == 8) {
            [self processBpmNoteDynamic:note as:id2bpm to:shiftNotes];
        } else if (note->channel == 3) {
            [self processBpmNoteStatic:note to:shiftNotes];
        } else if (note->channel>=11 && note->channel<=18) {
            [self processShortNote:note to:channelNotes];
        } else if (note->channel>=51 && note->channel<=58) {
            [self processLongNote:note to:channelNotes atState:channelState];
        } else if (note->channel == 1) {
            [self processBgmNote:note to:tmpBgmNotes];
        } else {
            NSLog(@"[Notice] unknow note channel:[channel:%d pos:%lf type:%d]",
                  note->channel, note->pos, note->type);
        }
    }
    
    //3. channelNotes -> BmsEngine::channel
    //   shiftNotes -> BmsEngine::ts2bar
    ts2bar = [shiftNotes sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        ShiftNote* note1 = (ShiftNote*)obj1;
        ShiftNote* note2 = (ShiftNote*)obj2;
        NSNumber *num1 = [NSNumber numberWithDouble:note1->pos];
        NSNumber *num2 = [NSNumber numberWithDouble:note2->pos];
        NSComparisonResult result = [num1 compare:num2];
        return result == NSOrderedDescending;
    }];
    
    double lastBpm = 100.0; //初始迭代,不为0即可
    double lastPos = 0.0;
    double lastTs = 0.0;
    for (NSObject *obj in ts2bar) {
        ShiftNote* note = (ShiftNote*)obj;
        note->timestamp = lastTs + (note->pos - lastPos)*4*60/lastBpm;
        lastBpm = note->bpm;
        lastPos = note->pos;
        lastTs = note->timestamp;
        //NSLog(@"[Debug][pos:%lf][bpm:%lf][ts:%lf]", note->pos, note->bpm, note->timestamp);
    }
    
    channel = [[NSMutableArray alloc]initWithCapacity:G_MAX_CHANNEL_COUNT];
    for (int i=0; i<G_MAX_CHANNEL_COUNT; i++) {
        NSMutableArray * basedArray = channelNotes[i];
        channel[i] = [basedArray sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
            Note* note1 = (Note*)obj1;
            Note* note2 = (Note*)obj2;
            NSNumber *num1 = [NSNumber numberWithDouble:note1->pos];
            NSNumber *num2 = [NSNumber numberWithDouble:note2->pos];
            NSComparisonResult result = [num1 compare:num2];
            return result == NSOrderedDescending;
        }];
        for (NSObject *obj in channel[i]) {
            Note* note = (Note*)obj;
            if (note->type == G_SHORT_NOTE) continue;
            //NSLog(@"[Debug][pos:%lf][len:%lf][channel:%d]",note->pos, note->len, note->channel);
        }
    }
    for (int i=0; i<G_MAX_CHANNEL_COUNT; i++) {
        int curId = 0;
        for (NSObject* obj in channel[i]) {
            Note* note = (Note*)obj;
            note->gId = curId++;
            note->state = NOTE_STATE_SLEEP;
        }
    }
    
    //here here here
    for (NSObject* bgmObj in tmpBgmNotes) {
        Note* note = (Note*)bgmObj;
        double ts = 0;
        lastPos = 0;
        lastBpm = 0;
        lastTs = 0;
        for (NSObject* obj in ts2bar) {
            ShiftNote* shiftNote = (ShiftNote*)obj;
            if (shiftNote->pos > note->pos) break;
            lastPos = shiftNote->pos;
            lastBpm = shiftNote->bpm;
            lastTs = shiftNote->timestamp;
        }
        ts = lastTs + (note->pos - lastPos)*4*60/lastBpm;
        
        Audio* audio = [sign2audio objectForKey:[NSNumber numberWithInteger:note->motion]];
        if (audio==nil) continue;
        
        BgmNote* bgmNote = [[BgmNote alloc]initWithAudio:audio->audioPlayer atTimestamp:ts atPosition:note->pos];
        [bgmNotes addObject:bgmNote];

        NSLog(@"[Check] bgm fixed ts:%lf", ts);
    }

    //TODO:release sth.
    for (NSObject* obj in ts2bar) {
        ShiftNote* note = (ShiftNote*)obj;
        NSLog(@"pos:%lf bpm%lf ts:%lf", note->pos, note->bpm, note->timestamp);
    }
    return 0;
}

-(int)loadFromFile:(NSString*)pathname {
    int ret = 0;
    NSString *bmsFilePath=[[NSBundle mainBundle] pathForResource:pathname ofType:@"bms"];
    if (nil != bmsFilePath) {
        NSLog(@"[OK] find a bms file[%@]",pathname);
    } else {
        NSLog(@"[Warning] bms file[%@] not found.", pathname);
        return -1;
    }
    
    NSData* reader= [NSData dataWithContentsOfFile:bmsFilePath];
    if (nil != reader) {
        NSLog(@"[OK] read bms %@ content.", pathname);
    } else {
        NSLog(@"[Warning] failed to read bms %@ file.", pathname);
        return -2;
    }

    ret = [self parseWav:reader];

    ret = [self parse:reader];
    init = true;
    return ret;
}

-(int)getCurScene:(SceneNote*)scene atTimestamp:(double)curTs inRange:(double)barRange {
    if ((scene == nil) || (scene->channel == nil) || (scene->lastBeginIdx == nil)) return -1;
    
    //1.beginPos, endPos
    double beginPos = 0, endPos = 0;
    
    //cal ts.
    int curTsBpmIdx = scene->lastTsBpmIdx;
    for (int i=scene->lastTsBpmIdx; i<[ts2bar count]; i++) {
        if (curTs > ((ShiftNote*)ts2bar[i])->timestamp) {
            curTsBpmIdx = i;
            continue;
        }
        break;
    }
    ShiftNote* shiftNote = (ShiftNote*)ts2bar[curTsBpmIdx];
    beginPos = (curTs-(shiftNote->timestamp))*(shiftNote->bpm)/(4*60)+shiftNote->pos;
    endPos = beginPos + barRange;
    scene->lastTsBpmIdx = curTsBpmIdx;
    scene->basePos = beginPos;
    
    //FIXME: tiny, view more.
    beginPos -= 0.1;
    
    for (int i=0; i<G_MAX_CHANNEL_COUNT; i++) {
        NSMutableArray* baseNotes = channel[i];
        NSMutableArray* notes = scene->channel[i];
        [notes removeAllObjects];  //clear all here.
        NSInteger newBeginIdx = [baseNotes count] - 1;
        for (int j=[(NSNumber*)(scene->lastBeginIdx[i]) intValue]; j<[baseNotes count]; j++) {
            Note* note = (Note*)baseNotes[j];
            if (note->type == G_SHORT_NOTE) {
                if (note->pos>=beginPos && note->pos<=endPos) { //yes
                    [notes addObject:note];  //加入到屏幕中
                    if (j<newBeginIdx) newBeginIdx = j;
                } else if (note->pos<beginPos) { //no
                    continue;
                } else { //note->pos>endPos, no
                    break;
                }
            } else if (note->type == G_LONG_NOTE) { // note->type == G_LONG_NOTE
                if ((note->pos + note->len >= beginPos) && (note->pos<=endPos)) { //yes
                    [notes addObject:note];  //加入到屏幕中
                    if (j<newBeginIdx) newBeginIdx = j;
                } else if (note->pos + note->len < beginPos) {
                    continue;
                } else { //note->pos > endPos, no
                    break;
                }
            } else {
                continue;
            }
        }
        if ([notes count]!= 0) {
            [scene->lastBeginIdx replaceObjectAtIndex:i withObject:[NSNumber numberWithInt:newBeginIdx]];
        }
    }
    
    [scene->bgmChannel removeAllObjects];
    int newLastBgmIdx = [bgmNotes count] - 1;
    for (int i=scene->lastBgmIdx; i<[bgmNotes count]; i++) {
        BgmNote* bgmNote = (BgmNote*)bgmNotes[i];
        if (bgmNote->pos<beginPos) {
            [scene->bgmChannel addObject:bgmNote];
            bgmNote->pos = 10000;
            if (i<newLastBgmIdx) newLastBgmIdx = i;
        }
    }
    scene->lastBgmIdx = newLastBgmIdx;

    return 0;
}

@end
