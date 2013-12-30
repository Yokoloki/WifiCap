//
//  DatabaseOperation.h
//  WifiCap
//
//  Created by Junfeng Shen on 30/1/12.
//  Copyright (c) 2012 SYSU. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <sqlite3.h>
#import "mapInfo.h"
#import "pointInfo.h"
#import "sampleInfo.h"
#import "signalInfo.h"

@interface DatabaseOperation : NSObject{
	sqlite3 *database;
}

- (BOOL) openDatabase;
- (BOOL) closeDatabase;

- (NSMutableArray*) getMaps;
- (void) addMap:(mapInfo*)aEntry;
- (void) delMap:(mapInfo*)aEntry;

- (void) getPointsForMap:(mapInfo*)map;
- (void) addPoint:(pointInfo*)p forMap:(mapInfo*)map;
- (void) delPoint:(pointInfo*)p;

- (void) getSamplesForPoint:(pointInfo*)p;
- (void) addSample:(sampleInfo*)s forPoint:(pointInfo*)p;
- (void) delSample:(sampleInfo*)s;

- (void) getSignalsForSample:(sampleInfo*)s;
- (void) addSignals:(NSMutableArray*)signals forSample:(sampleInfo*)s;

- (NSInteger)getNextLocationID;
- (NSInteger)getNextMapID;
- (NSInteger)getNextPointID;
- (NSInteger)getNextSampleID;

- (void)setNextLocationID:(NSInteger)newID;
- (void)setNextMapID:(NSInteger)newID;
- (void)setNextPointID:(NSInteger)newID;
- (void)setNextSampleID:(NSInteger)newID;

- (NSInteger) getPointCountForMap:(mapInfo*)map;
- (NSInteger) getSampleCountForPoint:(pointInfo*)p;
- (NSInteger) getSignalCountForSample:(sampleInfo*)s;


@end
