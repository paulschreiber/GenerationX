//
//  RecordListDataSource.h
//  GenerationX
//
//  Created by Nowhere Man on Tue Mar 19 2002.
//  Copyright (c) 2001 Nowhere Man. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GCFile.h"
#import "INDI.h"


@interface RecordListDataSource : NSObject
{
  GCFile* ged;
  BOOL sort;
  
  NSString* indi_filter;
  NSString* fam_filter;
  NSMutableArray* displayed_indi;
  NSMutableArray* displayed_fam;
}

- (RecordListDataSource*) initWithGED: (GCFile*) my_ged;
- (void) setGED: (GCFile*) my_ged;
- (void) setIndiFilter: (NSString*) my_filter;
- (void) setFamFilter: (NSString*) my_filter;
- (void) setSort: (BOOL) my_sort;
- (void) refresh;
- (void) refreshINDI;
- (void) refreshFAM;
- (INDI*) indiAtIndex: (int) index;
- (FAM*) famAtIndex: (int) index;
- (int) indexForIndi: (INDI*) indi;
- (int) numIndiDisplayed;
- (int) numFamDisplayed;

@end
