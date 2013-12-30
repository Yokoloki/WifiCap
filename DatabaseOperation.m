//
//  DatabaseOperation.m
//  WifiCap
//
//  Created by Junfeng Shen on 30/1/12.
//  Copyright (c) 2012 SYSU. All rights reserved.
//
#define DBName "wifi.db"
#import "DatabaseOperation.h"

@implementation DatabaseOperation

- (id) init{
	if([self openDatabase]){
		[super init];
		return self;
	}else
		return nil;
}
- (void) dealloc{
	[self closeDatabase];
	[super dealloc];
}

- (BOOL) openDatabase{
	NSString *dbPath = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0]
						stringByAppendingPathComponent:[NSString stringWithFormat:@"%s",DBName]];
	if(![[NSFileManager defaultManager] fileExistsAtPath:dbPath]){
		NSString *tmpPath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:[NSString stringWithUTF8String:DBName]];
		NSLog(@"Copy DB file '%@' to '%@'", tmpPath, dbPath);
		[[NSFileManager defaultManager] copyItemAtPath:tmpPath toPath:dbPath error:nil];	
	}
	if(!sqlite3_open([dbPath UTF8String], &database) == SQLITE_OK){
		NSLog(@"Error occur when opening database");
		return NO;
	}else
		return YES;
}

- (BOOL) closeDatabase{
	if (database != nil) {
		if(sqlite3_close(database) != SQLITE_OK){
			NSLog(@"Failed to close the database");
			return NO;
		}
		else{
			database = nil;
			return YES;
		}
	}else{
		NSLog(@"database = nil");
		return NO;
	}
}

- (NSMutableArray*) getMaps{
	if(database != nil){
		sqlite3_stmt *statement;
		NSString *sql = @"select map_id, map_name, map_location, map_description, image from maps";
		if(sqlite3_prepare_v2(database, [sql UTF8String], -1, &statement, nil) == SQLITE_OK){
			NSMutableArray *result = [[NSMutableArray alloc] init];
			while(sqlite3_step(statement) == SQLITE_ROW){
				mapInfo *aEntry = [[mapInfo alloc] init];
				aEntry.eId = sqlite3_column_int(statement, 0);
				aEntry.name = [NSString stringWithUTF8String:(char*)sqlite3_column_text(statement, 1)];
				aEntry.location = [NSString stringWithUTF8String:(char*)sqlite3_column_text(statement, 2)];
				aEntry.description = [NSString stringWithUTF8String:(char*)sqlite3_column_text(statement, 3)];
				const char* rawData = sqlite3_column_blob(statement, 4);
				int rawDataLength = sqlite3_column_bytes(statement, 4);
				NSData *data = [NSData dataWithBytes:rawData length:rawDataLength];
				aEntry.map = [[UIImage alloc] initWithData:data];
				[result addObject:aEntry];
				[aEntry release];
			}
			sqlite3_finalize(statement);
			return result;
		}else{
			NSLog(@"sqlite3_prepare_v2 failed when executing getMaps");
			return nil;
		}
	}else{
		NSLog(@"database = nil when executing getMaps");
		return nil;
	}
}
- (void) addMap:(mapInfo*)aEntry{
	if(database != nil){
		sqlite3_stmt *statement;
		NSString *sql = @"insert into maps (map_id, map_name, map_location, map_description, image) values (?,?,?,?,?)";
		sqlite3_prepare_v2(database, [sql UTF8String], -1, &statement, nil);
		sqlite3_bind_int(statement, 1, aEntry.eId);
		sqlite3_bind_text(statement, 2, [aEntry.name UTF8String], -1, SQLITE_TRANSIENT);
		sqlite3_bind_text(statement, 3, [aEntry.location UTF8String], -1, SQLITE_TRANSIENT);
		sqlite3_bind_text(statement, 4, [aEntry.description UTF8String], -1, SQLITE_TRANSIENT);
		NSData *data = UIImagePNGRepresentation(aEntry.map);
		sqlite3_bind_blob(statement, 5, [data bytes], [data length], SQLITE_TRANSIENT);
		sqlite3_step(statement);
		sqlite3_finalize(statement);
	}else
		NSLog(@"database = nil when executing addMap");
}
- (void) delMap:(mapInfo*)aEntry{
	if(database != nil){
		sqlite3_stmt *statement;
		
		NSString *sql = @"delete from sampleTmac where sample_id in (select sample_id from samples, mapTpoint where samples.point_id = mapTpoint.point_id and map_id = ?)";
		sqlite3_prepare_v2(database, [sql UTF8String], -1, &statement, nil);
		sqlite3_bind_int(statement, 1, aEntry.eId);
		sqlite3_step(statement);
		sqlite3_finalize(statement);
		
		sql = @"delete from samples where point_id in (select point_id from mapTpoint where and map_id = ?)";
		sqlite3_prepare_v2(database, [sql UTF8String], -1, &statement, nil);
		sqlite3_bind_int(statement, 1, aEntry.eId);
		sqlite3_step(statement);
		sqlite3_finalize(statement);
		
		sql = @"delete from points where point_id in (select point_id from mapTpoint where and map_id = ?)";
		sqlite3_prepare_v2(database, [sql UTF8String], -1, &statement, nil);
		sqlite3_bind_int(statement, 1, aEntry.eId);
		sqlite3_step(statement);
		sqlite3_finalize(statement);
		
		sql = @"delete from mapTpoint where map_id = ?";
		sqlite3_prepare_v2(database, [sql UTF8String], -1, &statement, nil);
		sqlite3_bind_int(statement, 1, aEntry.eId);
		sqlite3_step(statement);
		sqlite3_finalize(statement);
		
		sql = @"delete from maps where map_id = ?";
		sqlite3_prepare_v2(database, [sql UTF8String], -1, &statement, nil);
		sqlite3_bind_int(statement, 1, aEntry.eId);
		sqlite3_step(statement);
		sqlite3_finalize(statement);
	}else
		NSLog(@"databse = nil when executing delMap");
}


- (void) getPointsForMap:(mapInfo*)map{
	if(database != nil){
		sqlite3_stmt *statement;
		NSString *sql = @"select points.point_id, date, x, y from points, mapTpoint where map_id = ? and mapTpoint.point_id = points.point_id";
		if(sqlite3_prepare_v2(database, [sql UTF8String], -1, &statement, nil) == SQLITE_OK){
			sqlite3_bind_int(statement, 1, map.eId);
			[map.points removeAllObjects];
			while(sqlite3_step(statement) == SQLITE_ROW){
				pointInfo* p = [[pointInfo alloc] init];
				p.pId = sqlite3_column_int(statement, 0);
				p.createDate = [[NSDate alloc] initWithTimeIntervalSince1970:sqlite3_column_double(statement, 1)];
				CGPoint tmpP;
				tmpP.x = sqlite3_column_int(statement, 2);
				tmpP.y = sqlite3_column_int(statement, 3);
				p.coordinate = tmpP;
				[map.points addObject:p];
				[p release];
			}
			sqlite3_finalize(statement);
			map.pCount = map.points.count;
		}else{
			NSLog(@"sqlite3_prepare_v2 failed when executing getPointsForMap");
		}
	}else{
		NSLog(@"database = nil when executing getPointsForMap");
	}
}
- (void) addPoint:(pointInfo*)p forMap:(mapInfo*)map{
	if(database != nil){
		sqlite3_stmt *statement;
		NSString *sql = @"insert into points (point_id, date) values (?,?)";
		sqlite3_prepare_v2(database, [sql UTF8String], -1, &statement, nil);
		sqlite3_bind_int(statement, 1, p.pId);
		sqlite3_bind_double(statement, 2, [p.createDate timeIntervalSince1970]);
		sqlite3_step(statement);
		sqlite3_finalize(statement);
		
		sql = @"insert into mapTpoint (map_id, point_id, x, y)values (?,?,?,?)";
		sqlite3_prepare_v2(database, [sql UTF8String], -1, &statement, nil);
		sqlite3_bind_int(statement, 1, map.eId);
		sqlite3_bind_int(statement, 2, p.pId);
		sqlite3_bind_int(statement, 3, p.coordinate.x);
		sqlite3_bind_int(statement, 4, p.coordinate.y);
		sqlite3_step(statement);
		sqlite3_finalize(statement);
	}else
		NSLog(@"database = nil when executing addPoint");
}
- (void) delPoint:(pointInfo*)p{
	if(database != nil){
		sqlite3_stmt *statement;
		NSString *sql = @"delete from points where point_id = ?";
		sqlite3_prepare_v2(database, [sql UTF8String], -1, &statement, nil);
		sqlite3_bind_int(statement, 1, p.pId);
		sqlite3_step(statement);
		sqlite3_finalize(statement);
		
		sql = @"delete from sampleTmac where sample_id in (select sample_id from samples where point_id = ?)";
		sqlite3_prepare_v2(database, [sql UTF8String], -1, &statement, nil);
		sqlite3_bind_int(statement, 1, p.pId);
		sqlite3_step(statement);
		sqlite3_finalize(statement);
		
		sql = @"delete from samples where point_id = ?";
		sqlite3_prepare_v2(database, [sql UTF8String], -1, &statement, nil);
		sqlite3_bind_int(statement, 1, p.pId);
		sqlite3_step(statement);
		sqlite3_finalize(statement);
		
		sql = @"delete from mapTpoint where point_id = ?";
		sqlite3_prepare_v2(database, [sql UTF8String], -1, &statement, nil);
		sqlite3_bind_int(statement, 1, p.pId);
		sqlite3_step(statement);
		sqlite3_finalize(statement);
	}else
		NSLog(@"databse = nil when executing delPoint");
}


- (void) getSamplesForPoint:(pointInfo*)p{
	if(database != nil){
		sqlite3_stmt *statement;
		NSString *sql = @"select sample_id, date from samples where point_id = ?";
		if(sqlite3_prepare_v2(database, [sql UTF8String], -1, &statement, nil) == SQLITE_OK){
			sqlite3_bind_int(statement, 1, p.pId);
			[p.samples removeAllObjects];
			while(sqlite3_step(statement) == SQLITE_ROW){
				sampleInfo* s = [[sampleInfo alloc] init];
				s.sId = sqlite3_column_int(statement, 0);
				s.capDate = [[NSDate alloc] initWithTimeIntervalSince1970:sqlite3_column_double(statement, 1)];
				[p.samples addObject:s];
				[s release];
			}
			sqlite3_finalize(statement);
			p.sampleCount = p.samples.count;
		}else{
			NSLog(@"sqlite3_prepare_v2 failed when executing getSamplesForPoint");
		}
	}else{
		NSLog(@"database = nil when executing getSamplesForPoint");
	}
}
- (void) addSample:(sampleInfo*)s forPoint:(pointInfo*)p{
	if(database != nil){
        sqlite3_exec(database, "BEGIN TRANSACTION;", NULL, NULL, NULL);
		sqlite3_stmt *statement;
		NSString *sql = @"insert into samples (point_id, sample_id, date) values (?,?,?)";
		sqlite3_prepare_v2(database, [sql UTF8String], -1, &statement, nil);
		sqlite3_bind_int(statement, 1, p.pId);
		sqlite3_bind_int(statement, 2, s.sId);
		sqlite3_bind_double(statement, 3, s.capDate.timeIntervalSince1970);
		sqlite3_step(statement);
		sqlite3_finalize(statement);
		[self addSignals:s.signals forSample:s];
        sqlite3_exec(database, "END TRANSACTION;", NULL, NULL, NULL);

	}else
		NSLog(@"database = nil when executing addPoint");
}
- (void) delSample:(sampleInfo*)s{
	if(database != nil){
		sqlite3_stmt *statement;
		NSString *sql = @"delete from sampleTmac where sample_id = ?";
		sqlite3_prepare_v2(database, [sql UTF8String], -1, &statement, nil);
		sqlite3_bind_int(statement, 1, s.sId);
		sqlite3_step(statement);
		sqlite3_finalize(statement);
				
		sql = @"delete from samples where sample_id = ?";
		sqlite3_prepare_v2(database, [sql UTF8String], -1, &statement, nil);
		sqlite3_bind_int(statement, 1, s.sId);
		sqlite3_step(statement);
		sqlite3_finalize(statement);
	}else
		NSLog(@"databse = nil when executing delSample");
}

- (void) getSignalsForSample:(sampleInfo *)s{
	if(database != nil){
		sqlite3_stmt *statement;
		NSString *sql = @"select mac, ssid, channel, noise, rssi, capabilities, mode, beacon from sampleTmac where sample_id = ?";
		if(sqlite3_prepare_v2(database, [sql UTF8String], -1, &statement, nil) == SQLITE_OK){
			sqlite3_bind_int(statement, 1, s.sId);
			[s.signals removeAllObjects];
			while(sqlite3_step(statement) == SQLITE_ROW){
				signalInfo *sig = [[signalInfo alloc] init];
				sig.mac = [NSString stringWithUTF8String:(char*)sqlite3_column_text(statement, 0)];
				sig.ssid = [NSString stringWithUTF8String:(char*)sqlite3_column_text(statement, 1)];
				sig.channel = sqlite3_column_int(statement, 2);
				sig.noise = sqlite3_column_int(statement, 3);
				sig.rssi = sqlite3_column_int(statement, 4);
				sig.capabilities = sqlite3_column_int(statement, 5);
				sig.mode = sqlite3_column_int(statement, 6);
				sig.beacon = sqlite3_column_int(statement, 7);
				[s.signals addObject:sig];
				[sig release];
			}
			sqlite3_finalize(statement);
			s.signalCount = s.signals.count;
			NSLog(@"getSignalsForSample get %d signals for sample.sid=%d", s.signalCount, s.sId);
		}else{
			NSLog(@"sqlite3_prepare_v2 failed when executing getSignalsForSample");
		}
	}else{
		NSLog(@"database = nil when executing getSignalsForSample");
	}	
}
- (void) addSignals:(NSMutableArray*)signals forSample:(sampleInfo*)s{
	if(database != nil){
		sqlite3_stmt *statement;
		for(int i=0; i<signals.count; i++){
			signalInfo *sig = [signals objectAtIndex:i];
			NSString *sql = @"insert into sampleTmac (sample_id, mac, ssid, channel, noise, rssi, capabilities, mode, beacon) values (?,?,?,?,?,?,?,?,?)";
			sqlite3_prepare_v2(database, [sql UTF8String], -1, &statement, nil);
			sqlite3_bind_int(statement, 1, s.sId);
			sqlite3_bind_text(statement, 2, [sig.mac UTF8String], -1, SQLITE_TRANSIENT);
			sqlite3_bind_text(statement, 3, [sig.ssid UTF8String], -1, SQLITE_TRANSIENT);
			sqlite3_bind_int(statement, 4, sig.channel);
			sqlite3_bind_int(statement, 5, sig.noise);
			sqlite3_bind_int(statement, 6, sig.rssi);
			sqlite3_bind_int(statement, 7, sig.capabilities);
			sqlite3_bind_int(statement, 8, sig.mode);
			sqlite3_bind_int(statement, 9, sig.beacon);
			if (sqlite3_step(statement) != SQLITE_DONE)
                NSLog(@"Err when inserting into the %dth sampleTmac, %s", i, sqlite3_errmsg(database));
			sqlite3_finalize(statement);
		}
		NSLog(@"addSignals: forSample: add %d signals for sample.sid=%d", signals.count, s.sId);
	}else
		NSLog(@"database = nil when executing addSignals");
}

- (NSInteger) getNextLocationID{
	if(database != nil){
		sqlite3_stmt *statement;
		NSString *sql = @"select nextID from id where name = 'location'";
		if(sqlite3_prepare_v2(database, [sql UTF8String], -1, &statement, nil) == SQLITE_OK){
			if(sqlite3_step(statement) == SQLITE_ROW){
				NSInteger result = sqlite3_column_int(statement, 0);
				sqlite3_finalize(statement);
				return result;
			}
			return -1;
		}else{
			NSLog(@"sqlite3_prepare_v2 failed when executing getNextLocationID");
		}
	}else
		NSLog(@"database = nil when executing getNextLocationID");
	return -1;
}
- (void) setNextLocationID:(NSInteger)newID{
	if(database != nil){
		sqlite3_stmt *statement;
		NSString *sql = @"update id set nextID = ? where name = 'location'";
		sqlite3_prepare_v2(database, [sql UTF8String], -1, &statement, nil);
		sqlite3_bind_int(statement, 1, newID);
		sqlite3_step(statement);
		sqlite3_finalize(statement);
	}else
		NSLog(@"database = nil when executing updateNextLocationID");
}

- (NSInteger) getNextMapID{
	if(database != nil){
		sqlite3_stmt *statement;
		NSString *sql = @"select nextID from id where name = 'map'";
		if(sqlite3_prepare_v2(database, [sql UTF8String], -1, &statement, nil) == SQLITE_OK){
			if(sqlite3_step(statement) == SQLITE_ROW){
				NSInteger result = sqlite3_column_int(statement, 0);
				sqlite3_finalize(statement);
				return result;
			}
			return -1;
		}else{
			NSLog(@"sqlite3_prepare_v2 failed when executing getNextMapID");
		}
	}else
		NSLog(@"database = nil when executing getNextMapID");
	return -1;
}
- (void) setNextMapID:(NSInteger)newID{
	if(database != nil){
		sqlite3_stmt *statement;
		NSString *sql = @"update id set nextID = ? where name = 'map'";
		sqlite3_prepare_v2(database, [sql UTF8String], -1, &statement, nil);
		sqlite3_bind_int(statement, 1, newID);
		sqlite3_step(statement);
		sqlite3_finalize(statement);
	}else
		NSLog(@"database = nil when executing updateNextMapID");
}

- (NSInteger) getNextPointID{
	if(database != nil){
		sqlite3_stmt *statement;
		NSString *sql = @"select nextID from id where name = 'point'";
		if(sqlite3_prepare_v2(database, [sql UTF8String], -1, &statement, nil) == SQLITE_OK){
			if(sqlite3_step(statement) == SQLITE_ROW){
				NSInteger result = sqlite3_column_int(statement, 0);
				sqlite3_finalize(statement);
				return result;
			}
			return -1;
		}else{
			NSLog(@"sqlite3_prepare_v2 failed when executing getNextPointID");
		}
	}else
		NSLog(@"database = nil when executing getNextPointID");
	return -1;
}
- (void) setNextPointID:(NSInteger)newID{
	if(database != nil){
		sqlite3_stmt *statement;
		NSString *sql = @"update id set nextID = ? where name = 'point'";
		sqlite3_prepare_v2(database, [sql UTF8String], -1, &statement, nil);
		sqlite3_bind_int(statement, 1, newID);
		sqlite3_step(statement);
		sqlite3_finalize(statement);
	}else
		NSLog(@"database = nil when executing updateNextPointID");
}

- (NSInteger) getNextSampleID{
	if(database != nil){
		sqlite3_stmt *statement;
		NSString *sql = @"select nextID from id where name = 'sample'";
		if(sqlite3_prepare_v2(database, [sql UTF8String], -1, &statement, nil) == SQLITE_OK){
			if(sqlite3_step(statement) == SQLITE_ROW){
				NSInteger result = sqlite3_column_int(statement, 0);
				sqlite3_finalize(statement);
				return result;
			}
			return -1;
		}else{
			NSLog(@"sqlite3_prepare_v2 failed when executing getNextSampleID");
		}
	}else
		NSLog(@"database = nil when executing getNextSampleID");
	return -1;
}
- (void) setNextSampleID:(NSInteger)newID{
	if(database != nil){
		sqlite3_stmt *statement;
		NSString *sql = @"update id set nextID = ? where name = 'sample'";
		sqlite3_prepare_v2(database, [sql UTF8String], -1, &statement, nil);
		sqlite3_bind_int(statement, 1, newID);
		sqlite3_step(statement);
		sqlite3_finalize(statement);
	}else
		NSLog(@"database = nil when executing updateNextSampleID");
}

- (NSInteger) getPointCountForMap:(mapInfo*)map{
	if(database != nil){
		sqlite3_stmt *statement;
		NSString *sql = @"select count(*) from mapTpoint where map_id = ?";
		sqlite3_prepare_v2(database, [sql UTF8String], -1, &statement, nil);
		sqlite3_bind_int(statement, 1, map.eId);
		if(sqlite3_step(statement) == SQLITE_ROW){
			NSInteger result = sqlite3_column_int(statement, 0);
			sqlite3_finalize(statement);
			NSLog(@"select count(*) from mapTpoint where map_id = %d. return %d", map.eId, result);
			return result;
		}
	}else
		NSLog(@"database = nil when executing getPointCountForMap");
	return -1;
}
- (NSInteger) getSampleCountForPoint:(pointInfo *)p{
	if(database != nil){
		sqlite3_stmt *statement;
		NSString *sql = @"select count(*) from samples where point_id = ?";
		sqlite3_prepare_v2(database, [sql UTF8String], -1, &statement, nil);
		sqlite3_bind_int(statement, 1, p.pId);
		if(sqlite3_step(statement) == SQLITE_ROW){
			NSInteger resulte = sqlite3_column_int(statement, 0);
			sqlite3_finalize(statement);
			return resulte;
		}
	}else
		NSLog(@"database = nil when executing getSampleCountForPoint");
	return -1;
}
- (NSInteger) getSignalCountForSample:(sampleInfo *)s{
	if(database != nil){
		sqlite3_stmt *statement;
		NSString *sql = @"select count(*) from sampleTmac where sample_id = ?";
		sqlite3_prepare_v2(database, [sql UTF8String], -1, &statement, nil);
		sqlite3_bind_int(statement, 1, s.sId);
		if(sqlite3_step(statement) == SQLITE_ROW){
			NSInteger result = sqlite3_column_int(statement, 0);
			sqlite3_finalize(statement);
			NSLog(@"getSignalCountForSample return %d for sample.sid=%d", result, s.sId);
			return result;
		}
	}else
		NSLog(@"database = nil when executing getSampleCountForPoint");
	return -1;
}


/*
 SELECT TEMPLATE
 if(database != nil){
 sqlite3_stmt *statement;
 NSString *sql = @"______";
	if(sqlite3_prepare_v2(database, [sql UTF8String], -1, &statement, nil) == SQLITE_OK){
		NSMutableArray *result = [[NSMutableArray alloc] init];
		while(sqlite3_step(statement) == SQLITE_ROW){
		}
		return result;
	}else{
		NSLog(@"sqlite3_prepare_v2 failed when executing XXXXX");
		return nil;
	}
 }else{
	NSLog(@"database = nil when executing XXXXX");
	return nil;
 }
 */

/*
 INSERT TEMPLATE 
 if(database != nil){
	sqlite3_stmt *statement;
	NSString *sql = @"insert into _______ values ?,?,?";
	sqlite3_prepare_v2(database, [sql UTF8String], -1, &statement, nil);
	sqlite3_bind_text(statement, 1, [aEntry.name UTF8String], -1, SQLITE_TRANSIENT);
	sqlite3_bind_text(statement, 2, [aEntry.location UTF8String], -1, SQLITE_TRANSIENT);
	sqlite3_bind_text(statement, 3, [aEntry.description UTF8String], -1, SQLITE_TRANSIENT);
	sqlite3_step(statement);
	sqlite3_finalize(statement);
 }else
	NSLog(@"database = nil when executing XXXXX");
 */

/*
 UPDATE TEMPLATE
 */

/*
 DELETE　TEMPLATE
 */
@end
