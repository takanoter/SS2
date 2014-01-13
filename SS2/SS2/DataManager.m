//
//  DataManager.m
//  SS2
//
//  Created by takanoter on 14-1-12.
//  Copyright (c) 2014年 takanoter. All rights reserved.
//

#import "DataManager.h"
DataManager *gDataMgr = NULL;

@implementation SongSource
-(SongSource*)initWithId:(NSInteger)songId SourceName:(NSString*)songName BasePath:(NSString*)songUri {
    if (self=[super init]) {
        self.sourceId = songId;
        self.name = songName;
        self.extendJsonInfo = NULL;
        self.uri1 = [NSString stringWithFormat:@"%@/%@.bms", songUri, songName];
        self.uri1Type =[NSString stringWithFormat:@"bms"];
        self.uri2 =[NSString stringWithFormat:@"%@/%@.mp3", songUri, songName];
        self.uri2Type = [NSString stringWithFormat:@"mp3"];
    }
    return self;
}

- (NSString*)getMp3Uri {
    return self.uri2;
}

- (NSString*)getBmsUri {
    return self.uri1;
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
        NSLog(@"[CHECK] get source:%@", sourceName);
        
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
