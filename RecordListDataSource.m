//
//  RecordListDataSource.m
//  GenerationX
//
//  Created by Nowhere Man on Tue Mar 19 2002.
//  Copyright (c) 2001 Nowhere Man. All rights reserved.
//

#import "RecordListDataSource.h"


@implementation RecordListDataSource

- (RecordListDataSource*) initWithGED: (GCFile*) my_ged
{
  int i;
  ged = my_ged;
  sort = false;
  
  indi_filter = @"";
  fam_filter = @"";
  displayed_indi = [[NSMutableArray alloc] init];
  displayed_fam = [[NSMutableArray alloc] init];
  
  for( i = 0; i < [ged numIndividuals]; i++ )
    [displayed_indi addObject: [ged indiAtIndex: i]];    
  for( i = 0; i < [ged numFamilies]; i++ )
    [displayed_fam addObject: [ged famAtIndex: i]];    
  
  return self;
}

- (void) setGED: (GCFile*) my_ged
{
  int i;
  
  ged = my_ged;
  indi_filter = @"";
  fam_filter = @"";
  
  [displayed_indi removeAllObjects];
  [displayed_fam removeAllObjects];
  
  for( i = 0; i < [ged numIndividuals]; i++ )
    [displayed_indi addObject: [ged indiAtIndex: i]];
  for( i = 0; i < [ged numFamilies]; i++ )
    [displayed_fam addObject: [ged famAtIndex: i]];
}

- (void) setIndiFilter: (NSString*) my_filter
{
  int i;
//DEBUG
// NSLog( @"setFilter" );
  
  [indi_filter release];
  indi_filter = [my_filter retain];

  [displayed_indi removeAllObjects];
  
  if( [indi_filter isEqual: @""] )
    for( i = 0; i < [ged numIndividuals]; i++ )
      [displayed_indi addObject: [ged indiAtIndex: i]];
  else
  {
    for( i = 0; i < [ged numIndividuals]; i++ )
      if( [[[ged indiAtIndex: i] lastName] hasPrefix: indi_filter] )
        [displayed_indi addObject: [ged indiAtIndex: i]];
        
    if( sort )
      [displayed_indi sortUsingSelector: @selector(compare:)];
  }
}

- (void) setFamFilter: (NSString*) my_filter
{
  int i;
//DEBUG
// NSLog( @"setFilter" );
  
  [fam_filter release];
  fam_filter = [my_filter retain];

  [displayed_fam removeAllObjects];
  
  if( [fam_filter isEqual: @""] )
    for( i = 0; i < [ged numFamilies]; i++ )
      [displayed_fam addObject: [ged famAtIndex: i]];
  else
    for( i = 0; i < [ged numFamilies]; i++ )
      if( [[[[ged famAtIndex: i] husband: ged]  lastName] hasPrefix: fam_filter]
       || [[[[ged famAtIndex: i] wife: ged]  lastName] hasPrefix: fam_filter] )
        [displayed_fam addObject: [ged famAtIndex: i]];
}

- (void) refresh
{
  int i;
  
  [displayed_indi removeAllObjects];
  [displayed_fam removeAllObjects];
  
  if( [indi_filter isEqual: @""] )
    for( i = 0; i < [ged numIndividuals]; i++ )
      [displayed_indi addObject: [ged indiAtIndex: i]];
  else
  {
    for( i = 0; i < [ged numIndividuals]; i++ )
      if( [[[ged indiAtIndex: i] lastName] hasPrefix: indi_filter] )
        [displayed_indi addObject: [ged indiAtIndex: i]];

    if( sort )
      [displayed_indi sortUsingSelector: @selector(compare:)];
  }
        
  if( [fam_filter isEqual: @""] )
    for( i = 0; i < [ged numFamilies]; i++ )
      [displayed_fam addObject: [ged famAtIndex: i]];
  else
    for( i = 0; i < [ged numFamilies]; i++ )
      if( [[[[ged famAtIndex: i] husband: ged] lastName] hasPrefix: fam_filter]
       || [[[[ged famAtIndex: i] wife: ged] lastName] hasPrefix: fam_filter] )
        [displayed_fam addObject: [ged famAtIndex: i]];
}

- (void) setSort: (BOOL) my_sort
{
  sort = my_sort;
}

- (INDI*) indiAtIndex: (int) index
{
  return [displayed_indi objectAtIndex: index];
}

- (FAM*) famAtIndex: (int) index
{
  return [displayed_fam objectAtIndex: index];
}

// assume argument is a [INDI fullName]
- (int) indexForIndi: (INDI*) indi
{
  int i;
  for( i = 0; i < [displayed_indi count]; i++ )
  {
    if( [[displayed_indi objectAtIndex: i] isEqual: indi] )
      return i;
  }
  
  return -1;
}

//
// NSTableDataSource methods
//
- (int)numberOfRowsInTableView:(NSTableView*)aTableView
{
  if( [aTableView tag] == 0 )
    return [displayed_indi count];
  else
    return [displayed_fam count];
}

- (id)tableView:(NSTableView *)aTableView
  objectValueForTableColumn:(NSTableColumn *)aTableColumn
  row:(int)rowIndex
{
  NSMutableString* result = [[NSMutableString alloc] init];
  INDI* tmp;
  
  if( [aTableView tag] == 0 )
  {
    [result setString: [[displayed_indi objectAtIndex: rowIndex] lastName]];
    [result appendString: @", "];
    [result appendString:
             [[displayed_indi objectAtIndex: rowIndex] firstName]];
  }
  else
  {
    if( tmp = [[displayed_fam objectAtIndex: rowIndex] husband: ged] )
      [result setString: [tmp lastName]];
    else
      [result setString: @"?"];
    if( tmp = [[displayed_fam objectAtIndex: rowIndex] wife: ged] )
    {
      [result appendString: @"/"];
      [result appendString: [tmp lastName]];
    }
    else
      [result appendString: @"/?"];
  }
    
  return result;
}

- (int) numIndiDisplayed
{
  return [displayed_indi count];
}

- (int) numFamDisplayed
{
  return [displayed_fam count];
}

@end
