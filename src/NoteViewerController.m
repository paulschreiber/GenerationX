#import "NoteViewerController.h"
#import "sourceSelectorController.h"

#define currentDoc [[NSDocumentController sharedDocumentController] currentDocument]

@implementation NoteViewerController

+ (NoteViewerController*) sharedViewer
{
  static NoteViewerController* shared_viewer = nil;
  
  if( ! shared_viewer )
    shared_viewer = [[NoteViewerController alloc] initViewer];
    
  return shared_viewer;
}

// load the nib
- (NoteViewerController*) initViewer
{
  [NSBundle loadNibNamed: @"NoteViewer" owner:self];
//  [image_outline setIndentationPerLevel: 0];
  [note_outline setDelegate: self];
  [note_outline setDataSource: self];
  events = [[NSMutableArray alloc] init];
  
  return self;
}

- (void) setField: (id) my_field
{
  GCField* gc_tmp;
  NSMutableString* title = [[NSMutableString alloc] initWithString: @"Notes for "];
  int i = 0;
  field = my_field;
  
  [events removeAllObjects];
  
  for( i = 0; i < [field numSubfields]; i++ )
  {
    gc_tmp = [field subfieldAtIndex: i];
    if( [[gc_tmp fieldType] isEqualToString: @"NOTE"] )
      [events addObject: gc_tmp];
  }
  for( i = 0; i < [field numSubfields]; i++ )
  {
    gc_tmp = [field subfieldAtIndex: i];
    if( [gc_tmp isEvent] )//&& [[gc_tmp subfieldsWithType: @"NOTE"] count] > 0 )
      [events addObject: gc_tmp];
  }
  
  if( [[field fieldType] isEqualToString: @"INDI"] )
    [title appendString: [my_field fullName]];
  else
    [title appendString: [my_field fieldValue]];
  
  [header_text setStringValue: title];
  [note_outline reloadData];
}

- (void) toggle
{
  if( ![panel isVisible] )
	  [panel makeKeyAndOrderFront:self];
	else
	  [panel orderOut:self];
}

- (BOOL) isVisible
{
  return [panel isVisible];
}

#pragma mark -
#pragma mark IBAction handlers

- (void) handleSelectSource: (id) sender
{
}

- (void) handleChangeSource: (id) sender
{
  [NSApp beginSheet: [[sourceSelectorController sharedSelector] panel] modalForWindow: panel modalDelegate: self didEndSelector: @selector( changeSourceSheetDidEnd ) contextInfo: nil];
}

- (void) changeSourceSheetDidEnd
{
  if( [[[note_outline itemAtRow: [note_outline selectedRow]] fieldType] isEqualToString: @"NOTE"] )
	{
		GCField* tmp = [[note_outline itemAtRow: [note_outline selectedRow]] subfieldWithType: @"SOUR"];
		if( !tmp )
			tmp = [[note_outline itemAtRow: [note_outline selectedRow]] addSubfield: @"SOUR" : @""];
			
		[tmp setFieldValue: [[[sourceSelectorController sharedSelector] selectedSource] fieldValue]];
		[currentDoc handleContentChange];
	}
}

- (void) handleAddNote: (id) sender
{
  GCField* g;
	
	if( [note_outline selectedRow] == -1 )
		g = [field addSubfield: @"NOTE": @""];
	else if( [[note_outline itemAtRow: [note_outline selectedRow]] isEvent] )
		g = [[note_outline itemAtRow: [note_outline selectedRow]] addSubfield: @"NOTE": @""];
	else
		return;
	
	[[[NSDocumentController sharedDocumentController] currentDocument] handleContentChange];
  
  [panel makeFirstResponder: note_outline];
  [note_outline selectRowIndexes: [NSIndexSet indexSetWithIndex:([note_outline numberOfRows] - 1)] byExtendingSelection: NO];
}

- (void) handleDeleteNote: (id) sender
{
  GCField*		selectedField, *parentField;
  int			selectedRow, i;
  
  // Get the selected record
  selectedRow = [note_outline selectedRow];
	i = selectedRow - 1;
  if( selectedRow > -1 && [[[note_outline itemAtRow: selectedRow] fieldType] isEqualToString: @"NOTE"] )
  {
    selectedField = [note_outline itemAtRow: selectedRow];
		
		parentField = [note_outline itemAtRow: i];
		while( ![parentField isEvent] && i > -1)
		  parentField = [note_outline itemAtRow: i--];
		if( i == -1 )
		  parentField = field;
		
		[parentField removeSubfield: selectedField];
		
		// Send a notification to update the interface
//		[self notifyContentChange];

		// Make the outlineview the first responder
		[panel makeFirstResponder: note_outline];

		// Select the right row
		if( selectedRow > [note_outline numberOfRows] - 1 )
			[note_outline selectRowIndexes: [NSIndexSet indexSetWithIndex:([note_outline numberOfRows] - 1)] byExtendingSelection: NO];
			
		[[[NSDocumentController sharedDocumentController] currentDocument] handleContentChange];
  }
}

#pragma mark -
#pragma mark NSOutlineView methods
//
// NSOutlineView methods
//
- (id)outlineView:(NSOutlineView *)outlineView
  child:(int)index
  ofItem:(GCField*)item
{
  if( item == nil )
    return [events objectAtIndex: index];
  else
    return [[item subfieldsWithType: @"NOTE"] objectAtIndex: index];
}

- (BOOL)outlineView:(NSOutlineView *)outlineView
  isItemExpandable:(GCField*)item
{
  if( item == nil && [events count] > 0)
    return true;
  else if( [[item subfieldsWithType: @"NOTE"] count] > 0 )
    return true;
  
  return false;
}

- (int)outlineView:(NSOutlineView *)outlineView
  numberOfChildrenOfItem:(GCField*)item
{
  if( item == nil )
    return [events count];
  else
    return [[item subfieldsWithType: @"NOTE"] count];
}

- (id)outlineView:(NSOutlineView *)outlineView
  objectValueForTableColumn:(NSTableColumn *)tableColumn
  byItem:(GCField*)item
{
    
  if( item == nil )
  {
    return [[GenXUtil sharedUtil] eventStringFromGEDCOM: [field fieldType]];
  }
  else if( [[item fieldType] isEqualToString: @"NOTE"] )
  {
    return [item fieldValue];
  }
  else
  {
    return [[GenXUtil sharedUtil] eventStringFromGEDCOM: [item fieldType]];
  }
}

- (void)outlineView:(NSOutlineView *)outlineView
  setObjectValue:(NSString*)object 
  forTableColumn:(NSTableColumn *)tableColumn
  byItem:(GCField*)item
{
//  [item setFieldValue: object];
//	[[[NSDocumentController sharedDocumentController] currentDocument] handleContentChange];
}

//
// NSOutlineView delegate methods
//

- (void)outlineView:(NSOutlineView *)olv
  willDisplayCell:(NSCell *)cell
  forTableColumn:(NSTableColumn *)tableColumn
  item:(id)item
{
  [cell setTextColor: [NSColor blackColor]];
}

- (void)outlineViewSelectionDidChange: (NSNotification *)notification
{
  int		selectedRow;
  GCField* tmp;
	
  // Get the selected record
  selectedRow = [note_outline selectedRow];
	
	if( selectedRow > -1 && [[[note_outline itemAtRow: selectedRow] fieldType] isEqualToString: @"NOTE"] )
	{
	  [currentNote release];
  	currentNote = [note_outline itemAtRow: selectedRow];
		if( [[currentNote fieldValue] hasPrefix: @"@"] )
		  currentNote = [[[currentDoc ged] recordWithLabel: [currentNote fieldValue]] retain];
		else
		  [currentNote retain];
			
	  [noteText setString: [currentNote textValue]];
	}
	else
	{
	  currentNote = nil;
	  [noteText setString: @""];
	}

	if( tmp = [currentNote subfieldWithType: @"SOUR"] )
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

  // update the plus button state  
	if( [note_outline selectedRow] < 0)
    [buttonPlus setEnabled: YES];
	else if( [[note_outline itemAtRow: [note_outline selectedRow]] isEvent] )
    [buttonPlus setEnabled: YES];
	else
    [buttonPlus setEnabled: NO];
	
  // Update the minus buttons state
  if( selectedRow > -1 
	 && [[[note_outline itemAtRow: selectedRow] fieldType] isEqualToString: @"NOTE"] )
    [buttonMinus setEnabled: YES];
  else
    [buttonMinus setEnabled: NO];
}

//- (BOOL)tableView:(NSTableView *)aTableView shouldEditTableColumn:(NSTableColumn *)aTableColumn row:(int)rowIndex
//{
//}

//- (void)textDidChange:(NSNotification *)aNotification
- (void)textDidEndEditing:(NSNotification *)aNotification
{
  NSString* s = [NSString stringWithString: [noteText string]];
	NSArray* lines = [s componentsSeparatedByString: @"\n"];
	int i, n;
	
	n = [currentNote numSubfields];
	for( i = 0; i < [currentNote numSubfields]; i++ )
	  if( [[[currentNote subfieldAtIndex: i] fieldType] isEqualToString: @"CONT"]
		 || [[[currentNote subfieldAtIndex: i] fieldType] isEqualToString: @"CONC"] )
		  [currentNote removeSubfield: [currentNote subfieldAtIndex: i--]];
	
	[currentNote setFieldValue: [lines objectAtIndex: 0]];
	
	for( i = 1; i < [lines count]; i++ )
	  [currentNote addSubfield: @"CONT" : [lines objectAtIndex: i]];
		
	[note_outline reloadData];
	[[[NSDocumentController sharedDocumentController] currentDocument] handleContentChange];
}

@end
