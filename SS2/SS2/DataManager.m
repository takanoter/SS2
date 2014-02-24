//
//  DataManager.m
//  SS2
//
//  Created by takanoter on 14-1-12.
//  Copyright (c) 2014年 takanoter. All rights reserved.
//

#import "DataManager.h"
DataManager *gDataMgr = NULL;
@implementation SongSourceItem
-(SongSourceItem*)initWithHeader:(NSString*)header byName:(NSString*)name ofType:(NSString*)type {
    if (self=[super init]) {
        self.header = header;
        self.name = name;
        self.type = type;
    }
    return self;
}
@end

@implementation SongSource
-(int)fileAnalyse {
    NSString* tmp;

    NSString *bmsFilePath=[[NSBundle mainBundle] pathForResource:self.name ofType:@"bms"];
    if (nil == bmsFilePath) {
        NSLog(@"[Warning] bms file[%@] not found.", self.name);
        return -1;
    }
    
    NSData* reader= [NSData dataWithContentsOfFile:bmsFilePath];
    if (nil == reader) {
        NSLog(@"[Warning] failed to read bms %@ file.", self.name);
        return -2;
    }
    
    NSStringEncoding gbkEncoding = CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingGB_18030_2000);
    NSString* tmpStr = [[NSString alloc]initWithBytes:[reader bytes] length:[reader length] encoding:gbkEncoding];

    NSArray* lines = [tmpStr componentsSeparatedByString:@"\n"];
    NSEnumerator* nse = [lines objectEnumerator];
    while (tmp = [nse nextObject]) {
        if (![tmp hasPrefix:@"#WAV"]) continue;
        tmp = [tmp stringByReplacingOccurrencesOfString:@"\r" withString:@""];
        //FIXME: change separatedByStr -> at some pos.
        NSArray* tinys = [tmp componentsSeparatedByString:@" "];
                
        NSArray* slips = [[tmp substringFromIndex:7] componentsSeparatedByString:@"."];
        NSLog(@"tmp:[%@][%@][%@]",tinys[0], slips[0], slips[1]);
        SongSourceItem* item = [[SongSourceItem alloc]initWithHeader:tinys[0] byName:slips[0] ofType:slips[1]];
        [self.items setObject:item forKey:tinys[0]];
    }
    return 0;
}
-(SongSource*)initWithId:(NSInteger)songId SourceName:(NSString*)songName BasePath:(NSString*)songUri {
    if (self=[super init]) {
        self.sourceId = songId;
        self.name = songName;
        self.extendJsonInfo = NULL;
        self.items = [[NSMutableDictionary alloc]init];
        //file operations
        [self fileAnalyse];
    }
    return self;
}

- (NSString*)getBaseMp3Name {
    return nil;
}

@end

@implementation DataManager

- (void)loadFromSandboxDir:(NSString*)baseDir {
    self.init = false;
    
    //  0.环境准备
    NSError *err;
    NSFileManager *fileMgr = [NSFileManager defaultManager];
    
    NSString *resPath= [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:baseDir];
    NSLog(@"path:%@", resPath);
    
    self.songsById = [[NSMutableArray alloc]init];
    self.songsByName = [[NSMutableDictionary alloc]init];
    if ((self.songsById==NULL) || (self.songsByName==NULL)) return;
    
    //  1.遍历目录,添加库索引
    NSArray* contentsInDir = [fileMgr contentsOfDirectoryAtPath:resPath error:&err];
    for (NSObject* obj in contentsInDir) {
        //  a.环境检查
        NSArray *strArray=[(NSString*)obj componentsSeparatedByString:@".bms"];
        if ([strArray count]==1) continue;
        NSString* sourceName = strArray[0];
        NSString* mp3PathName = [NSString stringWithFormat:@"%@/%@.mp3", resPath, sourceName];
        NSString* bmsPathName = [NSString stringWithFormat:@"%@/%@.bms", resPath, sourceName];
        if (([fileMgr fileExistsAtPath:mp3PathName]==NO) ||
            ([fileMgr fileExistsAtPath:bmsPathName]==NO)) continue;
        NSLog(@"[CHECK] get source:%@ of mp3:%@", sourceName, mp3PathName);
        
        //  b.建立对象
        NSInteger globalSourceId = [self.songsById count]; //0-based
        SongSource *song = [[SongSource alloc]initWithId: globalSourceId
                                              SourceName:sourceName BasePath:resPath];
        if (song==NULL) continue;
        
        //  c.添加进库
        if (![self.songsByName objectForKey:sourceName]) {
            [self.songsByName setObject:song forKey:sourceName];
            [self.songsById addObject:song];
        } else {
            NSLog(@"WARNING:exist %@", sourceName);
            continue; //TODO:roll back
        }
        
        //  d.roll back
        //TODO
    }
    
    //  2.标记完成,资源回收
    //TODO
    self.init=true; //FIXME: false when init
}

- (NSInteger)songCount {
    return [self.songsById count];
}

- (NSString*)getSourceNameById:(NSInteger)sourceId {
    SongSource* song = (SongSource*)[self.songsById objectAtIndex:sourceId];
    if (song != NULL) return song.name;
    return NULL;
}

- (SongSource*)getSourceById:(NSInteger)sourceId {
    return (SongSource*)[self.songsById objectAtIndex:sourceId];
}

- (SongSource*)getSourceByName:(NSString*)name {
    return (SongSource*) [self.songsByName objectForKey:name];
}
@end
