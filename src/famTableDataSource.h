//
//  famTableDataSource.h
//  GenXDoc
//
//  Created by Nowhere Man on Tue Feb 10 2004.
//  Copyright (c) 2004 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "GCFile.h"

@interface famTableDataSource : NSObject
{
	NSTableColumn* sortedColumn;
	BOOL sortDescending;
	
	GCFile* ged;
	NSMutableArray* displayedFams;
}

- (famTableDataSource*) initWithGED: (GCFile*) my_ged;
- (void) setGED: (GCFile*) my_ged;
- (void) refresh;

- (FAM*) famAtIndex: (NSInteger) i;
- (NSInteger) indexOfFam: (FAM*) f;

- (void) filterWithString: (NSString*) s;
- (void) sortFamsUsingFieldId: (id)fieldId descending: (BOOL) sortDescending;

@end
