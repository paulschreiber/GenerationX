//
//  indiTableDataSource.h
//  GenXDoc
//
//  Created by Nowhere Man on Tue Feb 10 2004.
//  Copyright (c) 2004 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "GCFile.h"

@interface indiTableDataSource : NSObject
{
  NSTableColumn* sortedColumn;
	BOOL sortDescending;
	
  GCFile* ged;
	NSMutableArray* displayedIndividuals;
}

- (indiTableDataSource*) initWithGED: (GCFile*) my_ged;
- (void) setGED: (GCFile*) my_ged;
- (void) refresh;

- (INDI*) indiAtIndex: (int) i;
- (int) indexOfIndi: (INDI*) i;
- (int) numberDisplayed;
- (int) numberTotal;

- (void) filterWithString: (NSString*) s;
- (void) sortIndisUsingFieldId: (id)fieldId descending: (BOOL) sortDescending;

@end
