//
//  RecordListDataSource.h
//  GenerationX
//
//  Created by Nowhere Man on Tue Mar 19 2002.
//  Copyright (c) 2001 Nowhere Man. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TableSortInfo.h"
#import "GCFile.h"
#import "INDI.h"


@interface RecordListDataSource : NSObject
{
  GCFile* ged;
  BOOL sort;
  int sort_column;
  BOOL sort_descending;
  
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
- (void) sortIndisUsingFieldId: (id)fieldId descending: (BOOL) sortDescending;
- (void) sortFamsUsingFieldId: (id)fieldId descending: (BOOL) sortDescending;
- (void) refresh;
- (void) refreshIndis;
- (void) refreshFams;
- (INDI*) indiAtIndex: (int) index;
- (FAM*) famAtIndex: (int) index;
- (int) indexForIndi: (INDI*) indi;
- (int) indexForFam: (FAM*) indi;
- (int) numIndiDisplayed;
- (int) numIndiAll;
- (int) numFamDisplayed;
- (int) numFamAll;

@end
