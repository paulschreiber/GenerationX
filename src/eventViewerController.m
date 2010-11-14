#import "eventViewerController.h"
#import "sourceSelectorController.h"
#import "GenXUtil.h"
#import "INDI.h"

#define currentDoc [[NSDocumentController sharedDocumentController] currentDocument]

@implementation eventViewerController

+ (eventViewerController*) sharedEventPanel
{
	static eventViewerController* sharedController = nil;
	
	if( ! sharedController )
		sharedController = [[eventViewerController alloc] init];
    
	return sharedController;
}

- (eventViewerController*) init
{
	[NSBundle loadNibNamed: @"eventViewer" owner:self];
	return self;
}

- (void) toggle
{
	if( ![panel isVisible] )
		[panel makeKeyAndOrderFront:self];
	else
		[panel orderOut:self];
}

- (void) updateWithRecord: (GCField*) r
{
	//  NSPopUpButtonCell* buttonCell = [[[NSPopUpButtonCell alloc] initTextCell: @"" pullsDown: NO] autorelease];
	//  NSTableColumn *tableColumn = nil;
	
	[currentRecord release];
	currentRecord = [r retain];
	
	[addEventMenu removeAllItems];
	
	//	[buttonCell setControlSize: NSMiniControlSize];
	//	[buttonCell setFont: [NSFont fontWithName: @"Lucida Grande" size: 9]];
	//	[buttonCell setTarget: self];
	//	[buttonCell setAction: @selector( handleSelectEventType: )];
	if( [[currentRecord class] isEqual: [INDI class]] )
	{
		[addEventMenu addItemsWithTitles: [NSArray arrayWithObjects:
										   @"Select event type",
										   @"",
										   @"Birth", @"Adoption", @"Graduation", @"Occupation", @"Retirement",
										   @"Death", @"Burial", @"Cremation",
										   @"",
										   @"Emigration", @"Immigration", @"Naturalization", @"Census", @"Probate", @"Will",
										   @"",
										   @"Baptism", @"Blessing", @"Christening", @"Adult Christening", 
										   @"Bar Mitzvah", @"Bas Mitzvah", 
										   @"Confirmation", @"First Communion", @"Ordination",
										   @"",
										   @"Other...",
										   nil]];
	}
	else
		[addEventMenu addItemsWithTitles: [NSArray arrayWithObjects:
										   @"Select event type",
										   @"",
										   @"Engagement", @"Marriage", @"Divorce", @"Annulment",
										   @"",
										   @"Marriage License", @"Marriage Bann", @"Marriage Settlement",
										   @"Marriage Contract", @"Divorce Filing",
										   @"",
										   @"Other...",
										   nil]];
	
	/*
	 for( i = 0; i < [currentRecord numEvents]; i++ )
	 if( [[[currentRecord eventAtIndex: i] fieldType] isEqualToString: @"EVEN"]
	 && [[currentRecord eventAtIndex: i] subfieldWithType: @"TYPE"] )
	 [addEventMenu addItemWithTitle: [[currentRecord eventAtIndex: i] valueOfSubfieldWithType: @"TYPE"]];
	 */
	//  tableColumn = [eventTable tableColumnWithIdentifier: @"eventName"];
	//  [tableColumn setDataCell:buttonCell];
	//[tableColumn setMenu: menu];
	
	[eventTable reloadData];
}

- (BOOL) isVisible
{
	return [panel isVisible];
}

# pragma mark -
# pragma mark IBAction handlers

- (void) handleSelectSource: (id) sender
{
}

- (void) handleChangeSource: (id) sender
{
	[NSApp beginSheet: [[sourceSelectorController sharedSelector] panel] modalForWindow: panel modalDelegate: self didEndSelector: @selector( changeSourceSheetDidEnd ) contextInfo: nil];
}

- (void) changeSourceSheetDidEnd
{
	GCField* tmp = [[currentRecord eventAtIndex: [eventTable selectedRow]] subfieldWithType: @"SOUR"];
	if( !tmp )
		tmp = [[currentRecord eventAtIndex: [eventTable selectedRow]] addSubfield: @"SOUR" : @""];
	
	[tmp setFieldValue: [[[sourceSelectorController sharedSelector] selectedSource] fieldValue]];
	[currentDoc handleContentChange];
}

- (void) handleAddEvent: (id) sender
{
	[NSApp beginSheet: addEventSheet modalForWindow: panel modalDelegate: nil didEndSelector: nil contextInfo: nil];
	//  [currentRecord addSubfield: @"EVEN" : @""];
	//	[[[NSDocumentController sharedDocumentController] currentDocument] handleContentChange];
}

- (void) handleDeleteEvent: (id) sender
{
	[currentRecord removeSubfield: [currentRecord eventAtIndex: [eventTable selectedRow]]];
	[[[NSDocumentController sharedDocumentController] currentDocument] handleContentChange];
}

- (void) handleSelectEventType: (id) sender
{
	NSString* s = [NSString stringWithString: [sender titleOfSelectedItem]];
	
	if( ![s isEqualToString: @""] && ![s isEqualToString: @"Select event type"] )
	{
		if( ![s isEqualToString: @"Other..."] )
		{
			[currentRecord addSubfield: [[GenXUtil sharedUtil] GEDCOMFromEventString: s] : @""];
		}
		else
		{
			GCField* g = [currentRecord addSubfield: @"EVEN" : @""];
			[g addSubfield: @"TYPE" : @"unknown"];
		}
		[[[NSDocumentController sharedDocumentController] currentDocument] handleContentChange];
	}
	
	[addEventSheet orderOut: nil];
	[NSApp endSheet: addEventSheet];
}

# pragma mark -
# pragma mark NSTableView methods

- (int)numberOfRowsInTableView: (NSTableView*)aTableView
{
	return [currentRecord numEvents];
}

- (id)tableView: (NSTableView *)aTableView
objectValueForTableColumn: (NSTableColumn *)aTableColumn
			row: (int)rowIndex
{
	if ( [[aTableColumn identifier] isEqualToString: @"eventName"] ) {
		if( ![[[currentRecord eventAtIndex: rowIndex] fieldType] isEqualToString: @"EVEN"] ) {
			return [[GenXUtil sharedUtil] eventStringFromGEDCOM: [[currentRecord eventAtIndex: rowIndex] fieldType]];
		} else if( [[currentRecord eventAtIndex: rowIndex] subfieldWithType: @"TYPE"] ) {
			return [[currentRecord eventAtIndex: rowIndex] valueOfSubfieldWithType: @"TYPE"];
		} else {
			return @"unknown";
		}
	} else if( [[aTableColumn identifier] isEqualToString: @"eventDate"] ) {
		NSDate* d = [NSDate dateWithNaturalLanguageString: [[currentRecord eventAtIndex: rowIndex] valueOfSubfieldWithType: @"DATE"]];
		return [d descriptionWithCalendarFormat: @"%b %d, %Y" timeZone: nil locale: nil];
	} else if( [[aTableColumn identifier] isEqualToString: @"eventPlace"] ) {
		return [[currentRecord eventAtIndex: rowIndex] valueOfSubfieldWithType: @"PLAC"];
	}
	
	return @"unknown";
}

- (void)tableView:(NSTableView *)aTableView 
   setObjectValue:(id)anObject 
   forTableColumn:(NSTableColumn *)aTableColumn 
			  row:(int)rowIndex
{
	if( ![anObject isEqualToString: @""] ) {
		if( [[aTableColumn identifier] isEqualToString: @"eventName"] ) {
			GCField* g;
			if( ![[currentRecord eventAtIndex: rowIndex] subfieldWithType: @"TYPE"] )
				[[currentRecord eventAtIndex: rowIndex] addSubfield: @"TYPE" : @""];
			g = [[currentRecord eventAtIndex: rowIndex] subfieldWithType: @"TYPE"];
			[g setFieldValue: anObject];
		} else if( [[aTableColumn identifier] isEqualToString: @"eventDate"] ) {
			NSDate* d = [NSDate dateWithNaturalLanguageString: anObject];
			if( ![[currentRecord eventAtIndex: rowIndex] subfieldWithType: @"DATE"] )
				[[currentRecord eventAtIndex: rowIndex] addSubfield: @"DATE" : @""];
			[[[currentRecord eventAtIndex: rowIndex] subfieldWithType: @"DATE"] setFieldValue:
			 [NSString stringWithFormat: @"%@ %@ %@", 
			  [d descriptionWithCalendarFormat: @"%d" timeZone: nil locale: nil],
			  [[d descriptionWithCalendarFormat: @"%b" timeZone: nil locale: nil] uppercaseString],
			  [d descriptionWithCalendarFormat: @"%Y" timeZone: nil locale: nil]]];
		}
		else if( [[aTableColumn identifier] isEqualToString: @"eventPlace"] )
		{
			if( ![[currentRecord eventAtIndex: rowIndex] subfieldWithType: @"PLAC"] )
				[[currentRecord eventAtIndex: rowIndex] addSubfield: @"PLAC" : @""];
			[[[currentRecord eventAtIndex: rowIndex] subfieldWithType: @"PLAC"] setFieldValue: anObject];
		}
	}
	else
	{
		if( [[aTableColumn identifier] isEqualToString: @"eventDate"] )
			[[currentRecord eventAtIndex: rowIndex] removeSubfield: [[currentRecord eventAtIndex: rowIndex] subfieldWithType: @"DATE"]];
		else if( [[aTableColumn identifier] isEqualToString: @"eventPlace"] )
			[[currentRecord eventAtIndex: rowIndex] removeSubfield: [[currentRecord eventAtIndex: rowIndex] subfieldWithType: @"PLAC"]];
	}
	[[[NSDocumentController sharedDocumentController] currentDocument] handleContentChange];
}

- (void)tableView:(NSTableView *)aTableView willDisplayCell:(id)aCell forTableColumn:(NSTableColumn *)aTableColumn row:(int)rowIndex
{
}

- (void) tableViewSelectionDidChange:(NSNotification *)notification
{
	GCField* tmp, *event;
	
	event = [currentRecord eventAtIndex: [eventTable selectedRow]];
	
	if( tmp = [event subfieldWithType: @"SOUR"] )
	{
		// if there's a linked in record
		if( [[tmp fieldValue] hasPrefix: @"@"] )
			tmp = [[currentDoc ged] recordWithLabel: [tmp fieldValue]];
		
		if( [tmp subfieldWithType: @"TITL"] )
			[sourceText setStringValue: [tmp valueOfSubfieldWithType: @"TITL"]];
		else if( [tmp subfieldWithType: @"AUTH"] )
			[sourceText setStringValue: [tmp valueOfSubfieldWithType: @"AUTH"]];
		else
			[sourceText setStringValue: [tmp fieldValue]];
	}
	else
		[sourceText setStringValue: @"No source"];
}

- (BOOL)tableView:(NSTableView *)aTableView shouldEditTableColumn:(NSTableColumn *)aTableColumn row:(int)rowIndex
{
	if( [[aTableColumn identifier] isEqualToString: @"eventName"] )
		if( [[[currentRecord eventAtIndex: rowIndex] fieldType] isEqualToString: @"EVEN"] )
			return YES;
		else
			return NO;
	
	return YES;
}

@end
