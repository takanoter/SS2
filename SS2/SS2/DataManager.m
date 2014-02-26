//
//  DataManager.m
//  SS2
//
//  Created by takanoter on 14-1-12.
//  Copyright (c) 2014年 takanoter. All rights reserved.
//

#import "DataManager.h"
#define G_JINZHI 36

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
    NSArray* extTypeNames = [NSArray arrayWithObjects:@"mp3", @"ogg", @"bmp", @"wav", nil];
    while (tmp = [nse nextObject]) {
        if (![tmp hasPrefix:@"#WAV"]) continue;
        tmp = [tmp stringByReplacingOccurrencesOfString:@"\r" withString:@""];

        NSArray* tinys = [tmp componentsSeparatedByString:@" "];
        NSString* totalName = [tmp substringFromIndex:7];
        NSEnumerator* typeNse = [extTypeNames objectEnumerator];
        NSString* typeName = nil;
        while (typeName = [typeNse nextObject]) {
            if ([totalName hasSuffix:typeName]) break;
        }
        if (typeName == nil) {
            NSLog(@"[Warning] failed to get typename for [%@]", tmp);
            continue;
        }
        NSString* pureName = [totalName substringToIndex:(totalName.length - typeName.length - 1)];
        
        SongSourceItem* item = [[SongSourceItem alloc]initWithHeader:tinys[0] byName:pureName ofType:typeName];
        [self.items setObject:item forKey:tinys[0]];
        qltrace(@"[Song][Parse] [%@]'s pre-define-element found into DataManager:[%@][%@][%@]", self.name, tinys[0], pureName, typeName);

    }
    return 0;
}

/*
- (NSString*)getBaseMp3Name {
    SongSourceItem* cur;
    NSString* bigName = nil;
    NSNumber* bigSize = [[NSNumber alloc]initWithInt:0];
    NSFileManager* fm = [NSFileManager defaultManager];
    NSEnumerator* nse = [self.items objectEnumerator];
    NSError* error;
    NSString *directoryPath= [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@""];

    //NSString* directoryPath =NSHomeDirectory();
    while (cur = [nse nextObject]) {
        if (![cur.type isEqual:@"mp3"]) continue;
        NSString* pathname=[NSString stringWithFormat:@"%@/%@.%@", directoryPath, cur.name, cur.type];
        NSDictionary *attr = [fm attributesOfItemAtPath:pathname error:&error];
        if (attr==nil) {
            NSLog(@"[Warning]get base mp3[%@] attr failed:%@",pathname, error);
            continue;
        }
        if ([attr objectForKey:NSFileSize] > bigSize) {
            bigSize = [attr objectForKey:NSFileSize];
            bigName = cur.name;
        }
    }
    return bigName;
}
 */

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
       // NSString* mp3PathName = [NSString stringWithFormat:@"%@/%@.mp3", resPath, sourceName];
        NSString* bmsPathName = [NSString stringWithFormat:@"%@/%@.bms", resPath, sourceName];
        /*
        if (([fileMgr fileExistsAtPath:mp3PathName]==NO) ||
            ([fileMgr fileExistsAtPath:bmsPathName]==NO)) continue;
        */
        if ([fileMgr fileExistsAtPath:bmsPathName]==NO) {
            NSLog(@"[Warning] get source name:%@.bms not exist", sourceName);
            continue;
        }
        
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
        qlinfo(@"[Song] found new song into DataManager:[%@]", sourceName);
        
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
