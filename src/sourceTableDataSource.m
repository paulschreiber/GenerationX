#import "sourceTableDataSource.h"

#define currentDoc [[NSDocumentController sharedDocumentController] currentDocument]

@implementation sourceTableDataSource

- (void) refresh
{
	displayedSources = [[NSMutableArray array] retain];
  [self handleFilterSources: nil];
}

- (void) refreshWithGED: (GCFile*) g
{
	displayedSources = [[NSMutableArray array] retain];
	GCField* tmp;
	int i;

	[displayedSources removeAllObjects];
	
	for( i = 0; i < [g numSources]; i++ )
	{
	  tmp = [g sourceAtIndex: i];
		[displayedSources addObject: tmp];
	}

	[sourceMessageText setStringValue: [NSString stringWithFormat: @"%@ of %@ sources",
	  [[NSNumber numberWithInt: [displayedSources count]] stringValue],
	  [[NSNumber numberWithInt: [g numSources]] stringValue]]];

  [sourceTable reloadData];
}

- (void) selectSource: (GCField*) s
{
  int i = [displayedSources indexOfObject: s];
	[sourceTable selectRow: i byExtendingSelection: NO];
}

- (GCField*) selectedSource
{
  return [displayedSources objectAtIndex: [sourceTable selectedRow]];
}

- (void) handleFilterSources: (id) sender
{
  NSString* s = [sourceSearchField stringValue];
	GCField* tmp;
	int i;

	[displayedSources removeAllObjects];
	
	for( i = 0; i < [[currentDoc ged] numSources]; i++ )
	{
	  tmp = [[currentDoc ged] sourceAtIndex: i];
		
	  if( [s isEqualToString: @""] )
		  [displayedSources addObject: tmp];
	  else if( ([tmp valueOfSubfieldWithType: @"AUTH"] && [[tmp valueOfSubfieldWithType: @"AUTH"] rangeOfString: s options: NSCaseInsensitiveSearch].location != NSNotFound)
		      || ([tmp valueOfSubfieldWithType: @"TITL"] && [[tmp valueOfSubfieldWithType: @"TITL"] rangeOfString: s options: NSCaseInsensitiveSearch].location != NSNotFound)
		      || ([tmp valueOfSubfieldWithType: @"TEXT"] && [[[tmp valueOfSubfieldWithType: @"TEXT"] textValue] rangeOfString: s options: NSCaseInsensitiveSearch].location != NSNotFound) )
		  [displayedSources addObject: tmp];
	}

	[sourceMessageText setStringValue: [NSString stringWithFormat: @"%@ of %@ sources",
	  [[NSNumber numberWithInt: [displayedSources count]] stringValue],
	  [[NSNumber numberWithInt: [[currentDoc ged] numSources]] stringValue]]];

  [sourceTable reloadData];
}

- (int)numberOfRowsInTableView: (NSTableView*)aTableView
{
  return [displayedSources count];
}

- (id)tableView: (NSTableView *)aTableView
  objectValueForTableColumn: (NSTableColumn *)aTableColumn
  row: (int)rowIndex
{
  if( [[aTableColumn identifier] isEqualToString: @"AUTHOR"] 
	 && [[displayedSources objectAtIndex: rowIndex] valueOfSubfieldWithType: @"AUTH"])
	  return [[displayedSources objectAtIndex: rowIndex] valueOfSubfieldWithType: @"AUTH"];
  else if( [[aTableColumn identifier] isEqualToString: @"TITLE"] 
	      && [[displayedSources objectAtIndex: rowIndex] valueOfSubfieldWithType: @"TITL"])
	  return [[displayedSources objectAtIndex: rowIndex] valueOfSubfieldWithType: @"TITL"];
		
	return @"---";
}

- (void)tableView:(NSTableView *)aTableView 
        setObjectValue:(id)anObject 
				forTableColumn:(NSTableColumn *)aTableColumn 
				row:(int)rowIndex
{
  GCField* tmp;
	
	if( ![anObject isEqualToString: @""] )
	{
		if( [[aTableColumn identifier] isEqualToString: @"AUTHOR"] )
		{
			tmp = [[displayedSources objectAtIndex: rowIndex] subfieldWithType: @"AUTH"];
			if( !tmp )
				tmp = [[displayedSources objectAtIndex: rowIndex] addSubfield: @"AUTH" : @""];
			[tmp setFieldValue: anObject];
		}
		else if( [[aTableColumn identifier] isEqualToString: @"TITLE"] )
		{
			tmp = [[displayedSources objectAtIndex: rowIndex] subfieldWithType: @"TITL"];
			if( !tmp )
				tmp = [[displayedSources objectAtIndex: rowIndex] addSubfield: @"TITL" : @""];
			[tmp setFieldValue: anObject];
		}
		
		[currentDoc handleContentChange];
	}
}

- (void) tableViewSelectionDidChange:(NSNotification *)notification
{
	currentSource = [displayedSources objectAtIndex: [sourceTable selectedRow]];

  if( [[currentSource subfieldWithType: @"TEXT"] textValue] )
  	[sourceText setString: [[currentSource subfieldWithType: @"TEXT"] textValue]];
	else
	  [sourceText setString: @""];
}

- (void) tableView: (NSTableView *)aTableView
  didClickTableColumn: (NSTableColumn *)aTableColumn
{
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

  if( [[aTableColumn identifier] isEqualToString: @"AUTHOR"] )
	  if( sortDescending )
  	  [displayedSources sortUsingSelector: @selector( compareAuthor: )];
		else
  	  [displayedSources sortUsingSelector: @selector( compareAuthorReverse: )];
  else if( [[aTableColumn identifier] isEqualToString: @"TITLE"] )
	  if( sortDescending )
  	  [displayedSources sortUsingSelector: @selector( compareTitle: )];
		else
  	  [displayedSources sortUsingSelector: @selector( compareTitleReverse: )];
		
	[aTableView reloadData];
}

- (void)textDidEndEditing:(NSNotification *)aNotification
{
  NSString* s = [NSString stringWithString: [sourceText string]];
	NSArray* lines = [s componentsSeparatedByString: @"\n"];
	GCField* tmp = [currentSource subfieldWithType: @"TEXT"];
	int i;
	
	[currentSource removeSubfield: tmp];
	tmp = [currentSource addSubfield: @"TEXT" : @""];
		
	[tmp setFieldValue: [lines objectAtIndex: 0]];
	for( i = 1; i < [lines count]; i++ )
	  [tmp addSubfield: @"CONT" : [lines objectAtIndex: i]];
		
	[sourceTable reloadData];
	[currentDoc handleContentChange];
}

@end
