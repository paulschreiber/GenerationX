//
//  GCFile.h
//  GenerationX
//
//  Created by Nowhere Man on Tue Feb 19 2002.
//  Copyright (c) 2001 Nowhere Man. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Cocoa/Cocoa.h>
#import "GCField.h"
#import "INDI.h"
#import "FAM.h"

@interface GCFile : NSObject
{
  NSString* path;
  
  NSMutableArray* individuals;
  NSMutableArray* families;
  NSMutableArray* sources;
  NSMutableArray* other_fields;
//  NSMutableArray* deleted_fields;
  
  int num_indi;
  int num_fam;
  int num_other;
}

- (GCFile*) init;
- (GCFile*)initWithFile: (NSString*) my_path;
- (NSString*) path;
- (void) setPath: (NSString*) my_path;
- (int) numRecords;
- (int) numFamilies;
- (int) numIndividuals;
- (int) numOthers;
- (int) numSources;
- (GCField*) recordAtIndex: (int) index;
- (INDI*) indiAtIndex: (int) index;
- (INDI*) maleAtIndex: (int) index;
- (INDI*) femaleAtIndex: (int) index;
- (FAM*) famAtIndex: (int) index;
- (GCField*) otherAtIndex: (int) index;
- (GCField*) sourceAtIndex: (int) index;
- (GCField*) recordWithLabel: (NSString*) my_label;
- (INDI*) indiWithLabel: (NSString*) my_label;
- (FAM*) famWithLabel: (NSString*) my_label;
- (GCField*) otherWithLabel: (NSString*) my_label;
- (INDI*) indiWithFullName: (NSString*) my_name;
- (NSMutableArray*) surnames;
- (NSMutableArray*) indisWithNameContaining: (NSString*) my_name;
- (NSMutableArray*) indisWithPrefix: (NSString*) my_prefix;
- (NSMutableArray*) famsWithFather: (NSString*) my_husb Mother: (NSString*) my_wife;
- (id)addRecord: (NSString*) my_type : (NSString*) my_value;
- (id)addRecord: (GCField*) my_field;
- (GCField*)removeRecord: (GCField*) my_field;
- (void) replaceRecord: (GCField*) old withRecord: (GCField*) new;
- (void) sortData;
- (BOOL)loadData;
- (BOOL) saveToFile;
- (BOOL) needSave;
- (void) setNeedSave: (BOOL) my_bool;

// 030131 pmh
- (void) completeLastnames;//: (GCFile*) my_ged;
- (NSString*) findFamilyname: (INDI*) tmp_indi;
// pmh

@end
