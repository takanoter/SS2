//
//  DataManager.h
//  SS2
//
//  Created by takanoter on 14-1-12.
//  Copyright (c) 2014年 takanoter. All rights reserved.
//

#import <Foundation/Foundation.h>


//  {sourceId, sourceName, extendInfo, [uri, sourceType]}
@interface SongSource : NSObject
@property NSInteger sourceId;
@property NSString *name;
@property NSString *extendJsonInfo;
@property NSString *uri1, *uri1Type; //for bms
@property NSString *uri2, *uri2Type; //for mp3

-(SongSource*)initWithId:(NSInteger)sourceId SourceName:(NSString*)name BasePath:(NSString*)uri;
- (NSString*)getMp3Uri;
- (NSString*)getBmsUri;
@end

//  TODO:thread-safe, global-instance
@interface DataManager : NSObject
//  contents
@property Boolean init; //TODO:thread-safe fm-state
@property NSMutableArray *songsById;
@property NSMutableDictionary *songsByName;

//  outer
- (void)loadFromSandboxDir:(NSString*)baseDir;
- (NSInteger)songCount;
- (NSString*)getSourceNameById:(NSInteger)sourceId;
- (SongSource*)getSourceById:(NSInteger)sourceId;
- (SongSource*)getSourceByName:(NSString*)name;


//  inner

@end




//global-instance
extern DataManager *gDataMgr;

