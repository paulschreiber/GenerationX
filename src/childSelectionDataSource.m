#import "childSelectionDataSource.h"
#import "MyDocument.h"
#define currentDoc (MyDocument *)[[NSDocumentController sharedDocumentController] currentDocument]

@implementation childSelectionDataSource

- (void) refresh
{
	int i;
	NSMutableArray* tmp = [NSMutableArray array];
	
	for ( i = 0; i < [[currentDoc ged] numIndividuals]; i++ ) {
		[tmp addObject: [[currentDoc ged] indiAtIndex: i]];
	}
	
	[tmp sortUsingSelector: @selector( compareLastName: )];
	
	[childTable setTarget: famController];
	[childTable setDoubleAction: @selector( handleChildOK: )];
	
	[data release];
	data = [tmp retain];
	
	[childTable reloadData];
}

- (INDI*) selectedIndi
{
	return selectedIndi;
}

- (NSInteger)numberOfRowsInTableView: (NSTableView*)aTableView
{
	return [data count];
}

- (id)tableView: (NSTableView *)aTableView
objectValueForTableColumn: (NSTableColumn *)aTableColumn
			row: (NSInteger)rowIndex
{
	return [NSString stringWithFormat: @"%@ %@",
			[[data objectAtIndex: rowIndex] fullName],
			[[data objectAtIndex: rowIndex] lifespan]];
}

- (void) tableViewSelectionDidChange:(NSNotification *)notification
{
	[selectedIndi release];
	selectedIndi = [[data objectAtIndex: [childTable selectedRow]] retain];
}

@end
