//
//  famTableDataSource.m
//  GenXDoc
//
//  Created by Nowhere Man on Tue Feb 10 2004.
//  Copyright (c) 2004 __MyCompanyName__. All rights reserved.
//

#import "famTableDataSource.h"

#define currentDoc [[NSDocumentController sharedDocumentController] currentDocument]

@implementation famTableDataSource

- (famTableDataSource*) initWithGED: (GCFile*) g
{
  int i;
  ged = g;
	displayedFams = [[NSMutableArray array] retain];
//  sort = false;
//  indis_are_sorted = false;
//  fams_are_sorted = false;
  
//  indi_filter = @"";
//  fam_filter = @"";
//  displayed_fam = [[NSMutableArray alloc] init];
  
  for( i = 0; i < [ged numFamilies]; i++ )
    [displayedFams addObject: [ged famAtIndex: i]];    
//  for( i = 0; i < [ged numFamilies]; i++ )
//    [displayed_fam addObject: [ged famAtIndex: i]];    
  
  return self;
}

- (void) setGED: (GCFile*) g
{
  ged = g;
}

- (void) refresh
{
  int i;
	[displayedFams removeAllObjects];

  for( i = 0; i < [ged numFamilies]; i++ )
    [displayedFams addObject: [ged famAtIndex: i]];    
}

- (FAM*) famAtIndex: (int) i
{
  return [displayedFams objectAtIndex: i];
}

- (int) indexOfFam: (FAM*) f
{
  return [displayedFams indexOfObject: f];
}

- (int) numberDisplayed
{
  return [displayedFams count];
}

- (int) numberTotal
{
  return [ged numFamilies];
}

- (void) filterWithString: (NSString*) s
{
  int i;
	
	s = [s lowercaseString];
	[displayedFams removeAllObjects];
	
	if( [s isEqualToString: @""] )
		for( i = 0; i < [ged numFamilies]; i++ )
		{
			[displayedFams addObject: [ged famAtIndex: i]];
		}
	else		
		for( i = 0; i < [ged numFamilies]; i++ )
		{
			if( [[[[[ged famAtIndex: i] husband: ged] lastName] lowercaseString] hasPrefix: s]
			 || [[[[[ged famAtIndex: i] wife: ged] lastName] lowercaseString] hasPrefix: s] )
				[displayedFams addObject: [ged famAtIndex: i]];
		}
}

- (void) sortFamsUsingFieldId: (id)fieldId descending: (BOOL) d
{
  if( [fieldId isEqual: @"husband"] )
	  if( d )
  	  [displayedFams sortUsingSelector: @selector( compareHusbandSurname: )];
	  else
  	  [displayedFams sortUsingSelector: @selector( compareHusbandSurnameReverse: )];
  else if( [fieldId isEqual: @"wife"] )
	  if( d )
  	  [displayedFams sortUsingSelector: @selector( compareWifeSurname: )];
	  else
  	  [displayedFams sortUsingSelector: @selector( compareWifeSurnameReverse: )];
  else if( [fieldId isEqual: @"marriageDate"] )
	  if( d )
  	  [displayedFams sortUsingSelector: @selector( compareMarriageDate: )];
	  else
  	  [displayedFams sortUsingSelector: @selector( compareMarriageDateReverse: )];
}

# pragma mark -
# pragma mark NSTableView methods

- (int)numberOfRowsInTableView: (NSTableView*)aTableView
{
  return [displayedFams count];
/*
  if( [aTableView tag] == 0 )
    return [displayed_indi count];
  else
    return [displayed_fam count];
*/
}

- (id)tableView: (NSTableView *)aTableView
  objectValueForTableColumn: (NSTableColumn *)aTableColumn
  row: (int)rowIndex
{
  if( [[aTableColumn identifier] isEqualToString: @"husband"] )
	  if( [[displayedFams objectAtIndex: rowIndex] husband: ged] )
      return [[[displayedFams objectAtIndex: rowIndex] husband: ged] fullName];
		else
		  return @"---";
  else if( [[aTableColumn identifier] isEqualToString: @"wife"] )
	  if( [[displayedFams objectAtIndex: rowIndex] wife: ged] )
      return [[[displayedFams objectAtIndex: rowIndex] wife: ged] fullName];
		else
		  return @"---";
  else if( [[aTableColumn identifier] isEqualToString: @"marriageDate"] )
    return [[[displayedFams objectAtIndex: rowIndex] marriageDate] descriptionWithCalendarFormat: @"%b %d, %Y" timeZone: nil locale: nil];
	else
	  return @"Error";
/*
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
      if( [indi nameSuffix] )
        [result appendString: [NSString stringWithFormat: @" %@", [indi nameSuffix]]];
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
*/
}

- (void) tableViewSelectionDidChange:(NSNotification *)notification
{
  [currentDoc handleSelectFam: nil];
}

- (void) tableView: (NSTableView *)aTableView
  didClickTableColumn: (NSTableColumn *)aTableColumn
{
  // Same column
  if( sortedColumn == aTableColumn )
  {
    // Invert sort order
    sortDescending = !sortDescending;
  }
  // Another column
  else
  {
    sortDescending = YES;
    if( sortedColumn )
    {
      [aTableView setIndicatorImage: nil inTableColumn: sortedColumn];
      [sortedColumn release];
    }
    
    sortedColumn = [aTableColumn retain];
    [aTableView setHighlightedTableColumn: aTableColumn];
  }
  
  // Set appearance of selected column
  [aTableView setIndicatorImage:
    (sortDescending ?
      [NSTableView _defaultTableHeaderReverseSortImage] :
      [NSTableView _defaultTableHeaderSortImage] )
    inTableColumn: aTableColumn];

  // Sort indis
  [self sortFamsUsingFieldId: [aTableColumn identifier] descending: sortDescending];
  [aTableView reloadData];
//  [self makeSelectionVisible];
}

@end
