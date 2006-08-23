#import "famDetailPanelController.h"
#import "sourceSelectorController.h"

#define currentDoc [[NSDocumentController sharedDocumentController] currentDocument]

@implementation famDetailPanelController

+ (famDetailPanelController*) sharedFamDetailPanel
{
  static famDetailPanelController* sharedController = nil;
  
  if( ! sharedController )
    sharedController = [[famDetailPanelController alloc] init];
    
  return sharedController;
}

- (famDetailPanelController*) init
{
  [NSBundle loadNibNamed: @"famDetailPanel" owner:self];
	
  return self;
}

- (void) setVisible: (BOOL) b
{
  if( b )
	  [panel makeKeyAndOrderFront: nil];
	else
	  [panel orderOut: nil];
}

- (void) toggle
{
  if( ![panel isVisible] )
	  [panel makeKeyAndOrderFront:self];
	else
	  [panel orderOut:self];
}

- (void) updateWithFam: (FAM*) i
{
  INDI* husband = [i husband: [currentDoc ged]];
  INDI* wife = [i wife: [currentDoc ged]];
	GCField* tmp;
	
	[currentFam release];
	currentFam = [i retain];
	
	if( husband )
	  [husbandText setStringValue: [husband fullName]];
	else
	  [husbandText setStringValue: @""];
		
	if( wife )
	  [wifeText setStringValue: [wife fullName]];
	else
	  [wifeText setStringValue: @""];
		
	if( [i marriageDate] )
	  [marriageDateText setStringValue: [[i marriageDate] descriptionWithCalendarFormat: @"%b %d, %Y" timeZone: nil locale: nil]];
	else
	  [marriageDateText setStringValue: @""];
			
	if( tmp = [currentFam subfieldWithType: @"SOUR"] )
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

	[childrenTable reloadData];
	[panel display];

  [NSThread detachNewThreadSelector: @selector( refreshDataSources: ) toTarget: self withObject: self];
}

- (void) refreshDataSources: (id)sender
{
  NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	
	[progIndicator startAnimation: self];
	
	[childDataSource refresh];
	[husbandDataSource refresh];
	[wifeDataSource refresh];

	[progIndicator stopAnimation: self];

  [pool release];
}
- (BOOL) isVisible
{
  return [panel isVisible];
}

# pragma mark -
# pragma mark IBAction handlers

- (void) handleSelectChild: (id) sender
{
  [currentDoc selectIndi: [[currentFam children: [currentDoc ged]] objectAtIndex: [childrenTable selectedRow]]];
}

- (void) handleSelectHusband: (id) sender
{
  [currentDoc selectIndi: [currentFam husband: [currentDoc ged]]];
}

- (void) handleSelectWife: (id) sender
{
  [currentDoc selectIndi: [currentFam wife: [currentDoc ged]]];
}

- (void) handleChangeHusband: (id) sender
{
  [NSApp beginSheet: husbandSheet modalForWindow: panel modalDelegate: nil didEndSelector: nil contextInfo: nil];
}

- (void) handleHusbOK: (id) sender
{
  GCField* tmp;
	
  [[[currentDoc ged] recordWithLabel: [currentFam valueOfSubfieldWithType: @"HUSB"]] removeSubfieldWithType: @"FAMS" Value: [currentFam fieldValue]];
	[[husbandDataSource selectedIndi] addSubfield: @"FAMS" : [currentFam fieldValue]];
	tmp = [currentFam subfieldWithType: @"HUSB"];
	if( !tmp )
	  tmp = [currentFam addSubfield: @"HUSB" : @""];
	[tmp setFieldValue: [[husbandDataSource selectedIndi] fieldValue]];
	[currentDoc handleContentChange];

  [NSApp endSheet: husbandSheet];
	[husbandSheet orderOut: nil];
}

- (void) handleHusbCancel: (id) sender
{
  [NSApp endSheet: husbandSheet];
	[husbandSheet orderOut: nil];
}

- (void) handleChangeWife: (id) sender
{
  [NSApp beginSheet: wifeSheet modalForWindow: panel modalDelegate: nil didEndSelector: nil contextInfo: nil];
}

- (void) handleWifeOK: (id) sender
{
  GCField* tmp;
	
  [[[currentDoc ged] recordWithLabel: [currentFam valueOfSubfieldWithType: @"WIFE"]] removeSubfieldWithType: @"FAMS" Value: [currentFam fieldValue]];
	[[wifeDataSource selectedIndi] addSubfield: @"FAMS" : [currentFam fieldValue]];
	tmp = [currentFam subfieldWithType: @"WIFE"];
	if( !tmp )
	  tmp = [currentFam addSubfield: @"WIFE" : @""];
	[tmp setFieldValue: [[wifeDataSource selectedIndi] fieldValue]];
	[currentDoc handleContentChange];

  [NSApp endSheet: wifeSheet];
	[wifeSheet orderOut: nil];
}

- (void) handleWifeCancel: (id) sender
{
  [NSApp endSheet: wifeSheet];
	[wifeSheet orderOut: nil];
}

- (void) handleAddChild: (id) sender
{
  [NSApp beginSheet: childSheet modalForWindow: panel modalDelegate: nil didEndSelector: nil contextInfo: nil];
}

- (void) handleChildOK: (id) sender
{
  if( [currentFam subfieldWithType: @"CHIL" value: [[childDataSource selectedIndi] fieldValue]] )
    NSRunAlertPanel( @"Error",
			 @"The selected person is already a child of this family",
			 @"OK", nil, nil );
	else
	{	
		[currentFam addSubfield: @"CHIL" : [[childDataSource selectedIndi] fieldValue]];
		[[childDataSource selectedIndi] addSubfield: @"FAMC" : [currentFam fieldValue]];
		[currentDoc handleContentChange];
	}
	
  [NSApp endSheet: childSheet];
	[childSheet orderOut: nil];
}

- (void) handleChildCancel: (id) sender
{
  [NSApp endSheet: childSheet];
	[childSheet orderOut: nil];
}

- (void) handleDeleteChild: (id) sender
{
  NSString* label = [[[currentFam children: [currentDoc ged]] objectAtIndex: [childrenTable selectedRow]] fieldValue];
	[[[currentFam children: [currentDoc ged]] objectAtIndex: [childrenTable selectedRow]] removeSubfieldWithType: @"FAMC" Value: [currentFam fieldValue]];
  [currentFam removeSubfieldWithType: @"CHIL" Value: label];
	[currentDoc handleContentChange];
}

- (void) handleSelectSource: (id) sender
{
}

- (void) handleChangeSource: (id) sender
{
  [NSApp beginSheet: [[sourceSelectorController sharedSelector] panel] modalForWindow: panel modalDelegate: self didEndSelector: @selector( changeSourceSheetDidEnd ) contextInfo: nil];
}

- (void) changeSourceSheetDidEnd
{
  GCField* tmp = [currentFam subfieldWithType: @"SOUR"];
	if( !tmp )
		tmp = [currentFam addSubfield: @"SOUR" : @""];
		
  [tmp setFieldValue: [[[sourceSelectorController sharedSelector] selectedSource] fieldValue]];
	[currentDoc handleContentChange];
}

# pragma mark -
# pragma mark NSTableView methods

- (int)numberOfRowsInTableView: (NSTableView*)aTableView
{
  return [[currentFam children: [currentDoc ged]] count];
}

- (id)tableView: (NSTableView *)aTableView
  objectValueForTableColumn: (NSTableColumn *)aTableColumn
  row: (int)rowIndex
{
  return [[[currentFam children: [currentDoc ged]] objectAtIndex: rowIndex] fullName];
}

- (void) tableViewSelectionDidChange:(NSNotification *)notification
{
  [self handleSelectChild: childrenTable];
}


@end
