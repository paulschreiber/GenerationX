#import "sourceSelectorController.h"
#import "MyDocument.h"

#define currentDoc (MyDocument *)[[NSDocumentController sharedDocumentController] currentDocument]

@implementation sourceSelectorController

+ (sourceSelectorController*) sharedSelector
{
	static sourceSelectorController* shared_panel = nil;
	
	if ( ! shared_panel )
		shared_panel = [[sourceSelectorController alloc] initNib];
    
	return shared_panel;
}

- (sourceSelectorController*) initNib
{
	[NSBundle loadNibNamed: @"sourceSelector" owner:self];
	
	return self;
}

- (void) refresh
{
	[sourceTable reloadData];
}

- (NSWindow*) panel
{
	return panel;
}

- (GCField*) selectedSource
{
	return currentSource;
}

#pragma mark - 
#pragma mark IBActionHandlers

- (IBAction)handleCancel:(id)sender
{
	[NSApp endSheet: panel];
	[panel orderOut: nil];
}

- (IBAction)handleOK:(id)sender
{
	[NSApp endSheet: panel];
	[panel orderOut: nil];
}

- (NSInteger)numberOfRowsInTableView: (NSTableView*)aTableView
{
	return [[currentDoc ged] numSources];
}

- (id)tableView: (NSTableView *)aTableView
objectValueForTableColumn: (NSTableColumn *)aTableColumn
			row: (NSInteger)rowIndex
{
	GCField* tmp = [[currentDoc ged] sourceAtIndex: rowIndex];
	
	if ( [[aTableColumn identifier] isEqualToString: @"AUTHOR"] 
		&& [tmp valueOfSubfieldWithType: @"AUTH"]) {
		return [tmp valueOfSubfieldWithType: @"AUTH"];
	} else if ( [[aTableColumn identifier] isEqualToString: @"TITLE"] 
			   && [tmp valueOfSubfieldWithType: @"TITL"]) {
		return [tmp valueOfSubfieldWithType: @"TITL"];
	}
	
	return @"---";
}

- (void) tableViewSelectionDidChange:(NSNotification *)notification
{
	currentSource = [[currentDoc ged] sourceAtIndex: [sourceTable selectedRow]];
	
	if ( [[currentSource subfieldWithType: @"TEXT"] textValue] ) {
		[sourceText setString: [[currentSource subfieldWithType: @"TEXT"] textValue]];
	} else {
		[sourceText setString: @""];
	}
}

@end
