//  TableSortInfo.m
//  GenerationX
//
//  Created by Benjamin Chartier on August 29 2002.

#import "TableSortInfo.h"


@implementation TableSortInfo

- (TableSortInfo*) initWithColumnId: (id)aColumnId
withDescending: (BOOL)aDescending
withGCFile: (GCFile*)aGCFile
{
  if( self == [super init] )
  {
    if( aColumnId != columnId )
    {
      [columnId release];
      columnId = [aColumnId retain];
    }
    
    if( aGCFile != gcFile )
    {
      [gcFile release];
      gcFile = [aGCFile retain];
    }
    
    descending = aDescending;
  }
  
  return self;
}

- (id) init
{
  return [self initWithColumnId: nil withDescending: NO withGCFile: nil];
}

- (void) dealloc
{
  [columnId release];
  [gcFile release];
  [super dealloc];
}

- (id) columnId
{
  return columnId;
}

- (BOOL) descending
{
  return descending;
}

- (GCFile*) gcFile
{
  return gcFile;
}

@end
