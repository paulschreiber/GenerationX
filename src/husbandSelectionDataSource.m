#import "husbandSelectionDataSource.h"
#import "MyDocument.h"
#define currentDoc (MyDocument *)[[NSDocumentController sharedDocumentController] currentDocument]

@implementation husbandSelectionDataSource

- (void) refresh
{
	int i;
	NSMutableArray* tmp = [NSMutableArray array];
	
	for ( i = 0; i < [[currentDoc ged] numIndividuals]; i++ ) {
		if ( [[[[currentDoc ged] indiAtIndex: i] sex] isEqualToString: @"M"] ) {
			[tmp addObject: [[currentDoc ged] indiAtIndex: i]];
		}
	}
	
	[tmp sortUsingSelector: @selector( compareLastName: )];
	
	[husbandTable setTarget: famController];
	[husbandTable setDoubleAction: @selector( handleHusbOK: )];
	
	[data release];
	data = [tmp retain];
	
	[husbandTable reloadData];
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
	selectedIndi = [[data objectAtIndex: [husbandTable selectedRow]] retain];
}

@end
