//  TableSortInfo.h
//  GenerationX
//
//  Created by Benjamin Chartier on August 29 2002.

#import <Foundation/Foundation.h>
#import "GCFile.h"

@interface TableSortInfo : NSObject
{
  id		columnId;
  BOOL 		descending;
  GCFile*	gcFile;
}

  // Init
  - (TableSortInfo*) initWithColumnId: (id)columnId withDescending: (BOOL)descending withGCFile: (GCFile*)gcFile;
  
  // Accessors
  - (BOOL) descending;
  - (id) columnId;
  - (GCFile*) gcFile;

@end
