//
//  indiTableDataSource.m
//  GenXDoc
//
//  Created by Nowhere Man on Tue Feb 10 2004.
//  Copyright (c) 2004 Glass Onion Software. All rights reserved.
//

#import "indiTableDataSource.h"
#import "MyDocument.h"
#define currentDoc (MyDocument *)[[NSDocumentController sharedDocumentController] currentDocument]

@implementation indiTableDataSource

- (indiTableDataSource*) initWithGED: (GCFile*) g
{
  int i;
  ged = g;
	displayedIndividuals = [[NSMutableArray array] retain];
  
  for ( i = 0; i < [ged numIndividuals]; i++ )
    [displayedIndividuals addObject: [ged indiAtIndex: i]];    
  
  return self;
}

- (void) setGED: (GCFile*) g
{
  ged = g;
	
	[self refresh];
}

- (void) refresh
{
  int i;
	[displayedIndividuals removeAllObjects];

  for ( i = 0; i < [ged numIndividuals]; i++ )
    [displayedIndividuals addObject: [ged indiAtIndex: i]];    
}

- (INDI*) indiAtIndex: (NSInteger) i
{
  return [displayedIndividuals objectAtIndex: i];
}

- (NSInteger) indexOfIndi: (INDI*) i
{
  return [displayedIndividuals indexOfObject: i];
}

- (NSInteger) numberDisplayed
{
  return [displayedIndividuals count];
}

- (NSInteger) numberTotal
{
  return [ged numIndividuals];
}

- (void) filterWithString: (NSString*) s
{
  int i;
	
	s = [s lowercaseString];
	[displayedIndividuals removeAllObjects];
	
	if ( [s isEqualToString: @""] )
		for ( i = 0; i < [ged numIndividuals]; i++ )
		{
			[displayedIndividuals addObject: [ged indiAtIndex: i]];
		}
	else		
		for ( i = 0; i < [ged numIndividuals]; i++ )
		{
			if ( [[[[ged indiAtIndex: i] lastName] lowercaseString] hasPrefix: s] )
				[displayedIndividuals addObject: [ged indiAtIndex: i]];
		}
}

- (void) sortIndisUsingFieldId: (id)fieldId descending: (BOOL) d
{
  if ( [fieldId isEqual: @"givenName"] )
	  if ( d )
  	  [displayedIndividuals sortUsingSelector: @selector( compareFirstName: )];
	  else
  	  [displayedIndividuals sortUsingSelector: @selector( compareFirstNameReverse: )];
  else if ( [fieldId isEqual: @"surname"] )
	  if ( d )
  	  [displayedIndividuals sortUsingSelector: @selector( compareLastName: )];
	  else
  	  [displayedIndividuals sortUsingSelector: @selector( compareLastNameReverse: )];
  else if ( [fieldId isEqual: @"nameSuffix"] )
	  if ( d )
  	  [displayedIndividuals sortUsingSelector: @selector( compareNameSuffix: )];
	  else
  	  [displayedIndividuals sortUsingSelector: @selector( compareNameSuffixReverse: )];
  else if ( [fieldId isEqual: @"sex"] )
	  if ( d )
  	  [displayedIndividuals sortUsingSelector: @selector( compareSex: )];
	  else
  	  [displayedIndividuals sortUsingSelector: @selector( compareSexReverse: )];
  else if ( [fieldId isEqual: @"birthDate"] )
	  if ( d )
  	  [displayedIndividuals sortUsingSelector: @selector( compareBirthdays: )];
	  else
  	  [displayedIndividuals sortUsingSelector: @selector( compareBirthdaysReverse: )];
  else if ( [fieldId isEqual: @"deathDate"] )
	  if ( d )
  	  [displayedIndividuals sortUsingSelector: @selector( compareDeathDates: )];
	  else
  	  [displayedIndividuals sortUsingSelector: @selector( compareDeathDatesReverse: )];
}

# pragma mark -
# pragma mark NSTableView methods

- (NSInteger)numberOfRowsInTableView: (NSTableView*)aTableView
{
  return [displayedIndividuals count];
}

- (id)tableView: (NSTableView *)aTableView
  objectValueForTableColumn: (NSTableColumn *)aTableColumn
  row: (NSInteger)rowIndex
{
  if ( [[aTableColumn identifier] isEqualToString: @"surname"] )
    return [[displayedIndividuals objectAtIndex: rowIndex] lastName];
  else if ( [[aTableColumn identifier] isEqualToString: @"givenName"] )
    return [[displayedIndividuals objectAtIndex: rowIndex] firstName];
  else if ( [[aTableColumn identifier] isEqualToString: @"nameSuffix"] )
    return [[displayedIndividuals objectAtIndex: rowIndex] nameSuffix];
  else if ( [[aTableColumn identifier] isEqualToString: @"sex"] )
    if ( [[[displayedIndividuals objectAtIndex: rowIndex] sex] isEqualToString: @"M"] )
  	  return [NSImage imageNamed: @"male"];
    else if ( [[[displayedIndividuals objectAtIndex: rowIndex] sex] isEqualToString: @"F"] )
  	  return [NSImage imageNamed: @"female"];
		else
  	  return [NSImage imageNamed: @"questionMark"];
  else if ( [[aTableColumn identifier] isEqualToString: @"birthDate"] )
    return [[[displayedIndividuals objectAtIndex: rowIndex] birthDate]
		  descriptionWithCalendarFormat: @"%b %d, %Y" timeZone: nil locale: nil];
  else if ( [[aTableColumn identifier] isEqualToString: @"deathDate"] )
    return [[[displayedIndividuals objectAtIndex: rowIndex] deathDate]
		  descriptionWithCalendarFormat: @"%b %d, %Y" timeZone: nil locale: nil];
	else
	  return @"Error";
}

- (void)tableView:(NSTableView *)aTableView 
        setObjectValue:(id)anObject 
				forTableColumn:(NSTableColumn *)aTableColumn 
				row:(NSInteger)rowIndex
{
	GCField* tmp;
	INDI* item = [displayedIndividuals objectAtIndex: rowIndex];
  
	if ( [[aTableColumn identifier] isEqualToString: @"surname"] )
	{
	  tmp = [item subfieldWithType: @"NAME"];
		if ( !tmp )
		  tmp = [item addSubfield: @"NAME" : @""];
		tmp = [tmp subfieldWithType: @"SURN"];
		if ( !tmp )
		  [[item subfieldWithType: @"NAME"] addSubfield: @"SURN" : @""];
		tmp = [[item subfieldWithType: @"NAME"] subfieldWithType: @"SURN"];
		[tmp setFieldValue: anObject];
		[[item subfieldWithType: @"NAME"] setFieldValue: [NSString stringWithFormat: @"%@ /%@/", [item firstName], [item lastName]]];
	}
  else if ( [[aTableColumn identifier] isEqualToString: @"givenName"] )
	{
	  tmp = [item subfieldWithType: @"NAME"];
		if ( !tmp )
		  tmp = [item addSubfield: @"NAME" : @""];
		tmp = [tmp subfieldWithType: @"GIVN"];
		if ( !tmp )
		  [[item subfieldWithType: @"NAME"] addSubfield: @"GIVN" : @""];
		tmp = [[item subfieldWithType: @"NAME"] subfieldWithType: @"GIVN"];
		[tmp setFieldValue: anObject];
		[[item subfieldWithType: @"NAME"] setFieldValue: [NSString stringWithFormat: @"%@ /%@/", [item firstName], [item lastName]]];
	}
  else if ( [[aTableColumn identifier] isEqualToString: @"nameSuffix"] )
	{
	  tmp = [item subfieldWithType: @"NAME"];
		if ( !tmp )
		  tmp = [item addSubfield: @"NAME" : @""];
		tmp = [tmp subfieldWithType: @"NSFX"];
		if ( !tmp )
		  [[item subfieldWithType: @"NAME"] addSubfield: @"NSFX" : @""];
		tmp = [[item subfieldWithType: @"NAME"] subfieldWithType: @"NSFX"];
		[tmp setFieldValue: anObject];
	}
  else if ( [[aTableColumn identifier] isEqualToString: @"sex"] )
	{
	  anObject = [anObject uppercaseString];
		
	  if ( [anObject isEqualToString: @"M"]
		 || [anObject isEqualToString: @"F"] )
		{
	    tmp = [item subfieldWithType: @"SEX"];
		  if ( !tmp )
		    tmp = [item addSubfield: @"SEX" : @""];
		  [tmp setFieldValue: anObject];
		}
	}
	
	[aTableView reloadData];
	[currentDoc handleContentChange];
}

- (void) tableViewSelectionDidChange:(NSNotification *)notification
{
  [currentDoc handleSelectIndi: nil];
}

- (void) tableView: (NSTableView *)aTableView
  didClickTableColumn: (NSTableColumn *)aTableColumn
{
  // Same column
  if ( sortedColumn == aTableColumn )
  {
    // Invert sort order
    sortDescending = !sortDescending;
  }
  // Another column
  else
  {
    sortDescending = YES;
    if ( sortedColumn )
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
  [self sortIndisUsingFieldId: [aTableColumn identifier] descending: sortDescending];
  [aTableView reloadData];
//  [self makeSelectionVisible];
}

- (BOOL)tableView:(NSTableView *)aTableView shouldEditTableColumn:(NSTableColumn *)aTableColumn row:(NSInteger)rowIndex
{
  GCField* g = [displayedIndividuals objectAtIndex: rowIndex];
	
  if ( [[aTableColumn identifier] isEqualToString: @"sex"] )
	{
	  if ( ![g subfieldWithType: @"SEX"] )
		  [g addSubfield: @"SEX" : @""];
			
    if ( [[[displayedIndividuals objectAtIndex: rowIndex] sex] isEqualToString: @"M"] )
		  [[g subfieldWithType: @"SEX"] setFieldValue: @"F"];
		else
		  [[g subfieldWithType: @"SEX"] setFieldValue: @"M"];
			
		[aTableView reloadData];
  	[currentDoc handleContentChange];
			
		return NO;
	}
	
	return YES;
}

- (void)tableView:(NSTableView *)aTableView willDisplayCell:(id)aCell forTableColumn:(NSTableColumn *)aTableColumn row:(NSInteger)rowIndex
{
}

@end
