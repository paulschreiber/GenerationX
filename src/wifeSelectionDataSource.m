#import "wifeSelectionDataSource.h"

#define currentDoc [[NSDocumentController sharedDocumentController] currentDocument]

@implementation wifeSelectionDataSource

- (void) refresh
{
  int i;
	NSMutableArray* tmp = [NSMutableArray array];
	
	for( i = 0; i < [[currentDoc ged] numIndividuals]; i++ )
	  if( [[[[currentDoc ged] indiAtIndex: i] sex] isEqualToString: @"F"] )
  	  [tmp addObject: [[currentDoc ged] indiAtIndex: i]];
	
	[tmp sortUsingSelector: @selector( compareLastName: )];

  [wifeTable setTarget: famController];
  [wifeTable setDoubleAction: @selector( handleWifeOK: )];

	[data release];
	data = [tmp retain];

	[wifeTable reloadData];
}

- (INDI*) selectedIndi
{
  return selectedIndi;
}

- (int)numberOfRowsInTableView: (NSTableView*)aTableView
{
  return [data count];
}

- (id)tableView: (NSTableView *)aTableView
  objectValueForTableColumn: (NSTableColumn *)aTableColumn
  row: (int)rowIndex
{
  return [NSString stringWithFormat: @"%@ %@",
	  [[data objectAtIndex: rowIndex] fullName],
		[[data objectAtIndex: rowIndex] lifespan]];
}

- (void) tableViewSelectionDidChange:(NSNotification *)notification
{
  [selectedIndi release];
  selectedIndi = [[data objectAtIndex: [wifeTable selectedRow]] retain];
}

@end
