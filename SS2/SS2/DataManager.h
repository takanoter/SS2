//
//  DataManager.h
//  SS2
//
//  Created by takanoter on 14-1-12.
//  Copyright (c) 2014年 takanoter. All rights reserved.
//

#import <Foundation/Foundation.h>


//  {sourceId, sourceName, extendInfo, [uri, sourceType]}
@interface SongSourceItem: NSObject
@property NSString* header;
@property NSString* name;
@property NSString* type;
-(SongSourceItem*)initWithHeader:(NSString*)header byName:(NSString*)name ofType:(NSString*)type;
@end

@interface SongSource : NSObject
@property NSInteger sourceId;
@property NSString *name;
@property NSString *extendJsonInfo;
@property NSMutableDictionary *items; // WAV0A -> SongSourceItem*

-(SongSource*)initWithId:(NSInteger)sourceId SourceName:(NSString*)name BasePath:(NSString*)uri;
- (NSString*)getBaseMp3Name;
//- (NSString*)getBmsUri;
@end

//  TODO:thread-safe, global-instance
@interface DataManager : NSObject
//  contents
@property Boolean init; //TODO:thread-safe fm-state
@property NSMutableArray *songsById;  //id->source
@property NSMutableDictionary *songsByName;  //name->source

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

