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
  indis_are_sorted = false;
  fams_are_sorted = false;
  
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
  
  [indi_filter release];
  indi_filter = [my_filter retain];

  [displayed_indi removeAllObjects];
  
  if( [indi_filter isEqual: @""] )
    for( i = 0; i < [ged numIndividuals]; i++ )
      [displayed_indi addObject: [ged indiAtIndex: i]];
  else
  {
    // Case insensitive comparison of lastname
    for( i = 0; i < [ged numIndividuals]; i++ )
      if( [[[[ged indiAtIndex: i] lastName] lowercaseString] hasPrefix: [indi_filter lowercaseString]] )
        [displayed_indi addObject: [ged indiAtIndex: i]];

//BCH
/*    if( sort )
      [displayed_indi sortUsingSelector: @selector(compare:)];*/
  }
}

- (void) setFamFilter: (NSString*) my_filter
{
  int i;
  
  [fam_filter release];
  fam_filter = [my_filter retain];

  [displayed_fam removeAllObjects];
  
  if( [fam_filter isEqual: @""] )
    for( i = 0; i < [ged numFamilies]; i++ )
      [displayed_fam addObject: [ged famAtIndex: i]];
  else
    // Case insensitive comparison
    for( i = 0; i < [ged numFamilies]; i++ )
      if( [[[[[ged famAtIndex: i] husband: ged]  lastName] lowercaseString] hasPrefix: fam_filter]
       || [[[[[ged famAtIndex: i] wife: ged]  lastName] lowercaseString] hasPrefix: fam_filter] )
        [displayed_fam addObject: [ged famAtIndex: i]];
}

// Make the content of displayed_indi and displayed_fam
// coherent with the filters and sort orders
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

- (void) refreshIndis
{
  int i;
  
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
  
  if( indis_are_sorted )
    [self sortIndisUsingFieldId: sort_column descending: sort_descending];
}

- (void) refreshFams
{
  int i;
  
  [displayed_fam removeAllObjects];
  
  if( [fam_filter isEqual: @""] )
    for( i = 0; i < [ged numFamilies]; i++ )
      [displayed_fam addObject: [ged famAtIndex: i]];
  else
    for( i = 0; i < [ged numFamilies]; i++ )
      if( [[[[ged famAtIndex: i] husband: ged] lastName] hasPrefix: fam_filter]
       || [[[[ged famAtIndex: i] wife: ged] lastName] hasPrefix: fam_filter] )
        [displayed_fam addObject: [ged famAtIndex: i]];

  if( fams_are_sorted )
    [self sortFamsUsingFieldId: sort_column descending: sort_descending];
}


static int compareIndisUsingSortInfo( id p1, id p2, void* context )
{
  TableSortInfo*	sortInfo = context;
  NSString*			columnId = [sortInfo columnId];
  BOOL				descending = [sortInfo descending];
  INDI*				indi1 = p1;
  INDI*				indi2 = p2;
  int				result;

  if( [columnId isEqualToString: @"givenName"] )
  {
    if( descending )
      result =  [[indi2 firstName] caseInsensitiveCompare: [indi1 firstName]];
    else
      result =  [[indi1 firstName] caseInsensitiveCompare: [indi2 firstName]];
  }
  else if( [columnId isEqualToString: @"surname"] )
  {
    if( descending )
      result =  [[indi2 lastName] caseInsensitiveCompare: [indi1 lastName]];
    else
      result =  [[indi1 lastName] caseInsensitiveCompare: [indi2 lastName]];

    // if the last names are the same, sub-sort on first name
    if( result == NSOrderedSame )
      if( descending )
        result =  [[indi2 firstName] caseInsensitiveCompare: [indi1 firstName]];
      else
        result =  [[indi1 firstName] caseInsensitiveCompare: [indi2 firstName]];
  }
  
  return result;
}

- (void) sortIndisUsingFieldId: (id)fieldId
descending: (BOOL) sortDescending;
{
  TableSortInfo*	sortInfo =
    [[TableSortInfo alloc] initWithColumnId: fieldId withDescending: sortDescending withGCFile: ged];

  sort_column = fieldId;
  sort_descending = sortDescending;
  indis_are_sorted = true;
  
  [displayed_indi sortUsingFunction: compareIndisUsingSortInfo context: sortInfo];
  [sortInfo release];
}


static int compareFamsUsingSortInfo( id p1, id p2, void* context )
{
  TableSortInfo*	sortInfo = context;
  NSString*			columnId = [sortInfo columnId];
  BOOL				descending = [sortInfo descending];
  GCFile*			gcFile = [sortInfo gcFile];
  FAM*				fam1 = p1;
  FAM*				fam2 = p2;
  int				result;

  if( [columnId isEqualToString: @"husband"] )
  {
    if( descending )
      result =  [[[fam2 husband: gcFile] lastName] caseInsensitiveCompare: [[fam1 husband: gcFile] lastName]];
    else
      result =  [[[fam1 husband: gcFile] lastName] caseInsensitiveCompare: [[fam2 husband: gcFile] lastName]];
  }
  else if( [columnId isEqualToString: @"wife"] )
  {
    if( descending )
      result =  [[[fam2 wife: gcFile] lastName] caseInsensitiveCompare: [[fam1 wife: gcFile] lastName]];
    else
      result =  [[[fam1 wife: gcFile] lastName] caseInsensitiveCompare: [[fam2 wife: gcFile] lastName]];
  }
  
  return result;
}

- (void) sortFamsUsingFieldId: (id)fieldId
descending: (BOOL) sortDescending;
{
  TableSortInfo*	sortInfo =
    [[TableSortInfo alloc] initWithColumnId: fieldId withDescending: sortDescending withGCFile: ged];

  sort_column = fieldId;
  sort_descending = sortDescending;
  indis_are_sorted = true;
  
  [displayed_fam sortUsingFunction: compareFamsUsingSortInfo context: sortInfo];
  [sortInfo release];
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

// 
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
- (int) indexForFam: (FAM*) fam
{
  int i;
  for( i = 0; i < [displayed_fam count]; i++ )
  {
    if( [[displayed_fam objectAtIndex: i] isEqual: fam] )
      return i;
  }
  
  return -1;
}

//
// NSTableDataSource methods
//
- (int)numberOfRowsInTableView: (NSTableView*)aTableView
{
  if( [aTableView tag] == 0 )
    return [displayed_indi count];
  else
    return [displayed_fam count];
}

- (id)tableView: (NSTableView *)aTableView
  objectValueForTableColumn: (NSTableColumn *)aTableColumn
  row: (int)rowIndex
{
  NSMutableString* 	result = [[NSMutableString alloc] init];
  NSString* 		columnId = [aTableColumn identifier];
  INDI* 			indi;
  
  if( [aTableView tag] == 0 )
  {
    // First column
    if( [columnId isEqualToString: @"givenName"] )
    {
      indi = [displayed_indi objectAtIndex: rowIndex];
      [result setString: [indi firstName]];
    }
    // Second column
    else if( [columnId isEqualToString: @"surname"] )
    {
      indi = [displayed_indi objectAtIndex: rowIndex];
      [result setString: [indi lastName]];
    }
  }
  else if( [aTableView tag] == 1 )
  {
    // First column
    if( [columnId isEqualToString: @"wife"] )
    {
      indi = [[displayed_fam objectAtIndex: rowIndex] wife: ged];
      if( indi )
        [result setString: [indi lastName]];
      else
        [result setString: @"?"];
    }
    // Second column
    else if( [columnId isEqualToString: @"husband"] )
    {
      indi = [[displayed_fam objectAtIndex: rowIndex] husband: ged];
      if( indi )
        [result setString: [indi lastName]];
      else
        [result setString: @"?"];
    }      
  }
  
  return result;
}

- (int) numIndiDisplayed
{
  return [displayed_indi count];
}

- (int) numIndiAll
{
  return [ged numIndividuals];
}

- (int) numFamDisplayed
{
  return [displayed_fam count];
}

- (int) numFamAll
{
  return [ged numFamilies];
}

@end
