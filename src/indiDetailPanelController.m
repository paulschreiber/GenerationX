#import "indiDetailPanelController.h"
#import "sourceSelectorController.h"
#import "FAM.h"

#define currentDoc [[NSDocumentController sharedDocumentController] currentDocument]

@implementation indiDetailPanelController

+ (indiDetailPanelController*) sharedIndiDetailPanel
{
  static indiDetailPanelController* sharedController = nil;
  
  if( ! sharedController )
    sharedController = [[indiDetailPanelController alloc] init];
    
  return sharedController;
}

- (indiDetailPanelController*) init
{
  [NSBundle loadNibNamed: @"indiDetailPanel" owner:self];
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

- (BOOL) isVisible
{
  return [panel isVisible];
}

- (void) updateWithIndi: (INDI*) i
{
  GCField* tmp;
	
  [currentIndi release];
  currentIndi = [i retain];
	
  [nameText setStringValue: [currentIndi fullName]];
	if( [currentIndi birthDate] )
    [birthDateText setStringValue: [[currentIndi birthDate] descriptionWithCalendarFormat: @"%b %d, %Y" timeZone: nil locale: nil]];
	else
	  [birthDateText setStringValue: @""];
		
	if( [currentIndi deathDate] )
    [deathDateText setStringValue: [[currentIndi deathDate] descriptionWithCalendarFormat: @"%b %d, %Y" timeZone: nil locale: nil]];
	else
	  [deathDateText setStringValue: @""];

	if( [currentIndi father: [currentDoc ged]] )
    [fatherText setStringValue: [[currentIndi father: [currentDoc ged]] fullName]];
	else
	  [fatherText setStringValue: @""];

	if( [currentIndi mother: [currentDoc ged]] )
    [motherText setStringValue: [[currentIndi mother: [currentDoc ged]] fullName]];
	else
	  [motherText setStringValue: @""];
		
	if( tmp = [currentIndi subfieldWithType: @"SOUR"] )
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
		
	[spouseTable reloadData];
}

#pragma mark -
#pragma mark IBAction handlers

- (void) handleSelectFather: (id) sender
{
  [currentDoc selectIndi: [currentIndi father: [currentDoc ged]]];
}

- (void) handleSelectMother: (id) sender
{
  [currentDoc selectIndi: [currentIndi mother: [currentDoc ged]]];
}

- (void) handleSelectSpouse: (id) sender
{
  GCField* item = [spouseTable itemAtRow: [spouseTable selectedRow]];
	
	if( [[item class] isEqual: [FAM class]] )
	{
	  if( [[currentIndi sex] isEqual: @"M"] )
      [currentDoc selectIndi: [item wife: [currentDoc ged]]];
		else
      [currentDoc selectIndi: [item husband: [currentDoc ged]]];
	}
	else
	{
	  [currentDoc selectIndi: item];
	}
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
  GCField* tmp = [currentIndi subfieldWithType: @"SOUR"];
	if( !tmp )
		tmp = [currentIndi addSubfield: @"SOUR" : @""];
		
  [tmp setFieldValue: [[[sourceSelectorController sharedSelector] selectedSource] fieldValue]];
	[currentDoc handleContentChange];
}

#pragma mark -
#pragma mark NSOutlineView methods

- (id)outlineView:(NSOutlineView *)outlineView
  child:(int)index
  ofItem:(GCField*)item
{
  if( !item )
	{
	  return [[currentIndi spouseFamilies: [currentDoc ged]] objectAtIndex: index];
	}
	else
	{
	  return [[item children: [currentDoc ged]] objectAtIndex: index];
	}
}

- (BOOL)outlineView:(NSOutlineView *)outlineView
  isItemExpandable:(GCField*)item
{
  if( [[item class] isEqual: [FAM class]]
	 && [[item children: [currentDoc ged]] count] > 0 )
	  return YES;
		
	return NO;
}

- (int)outlineView:(NSOutlineView *)outlineView
  numberOfChildrenOfItem:(GCField*)item
{
  if( !item )
    return [[currentIndi spouseFamilies: [currentDoc ged]] count];
	else
	  return [[item children: [currentDoc ged]] count];
}

- (id)outlineView:(NSOutlineView *)outlineView
  objectValueForTableColumn:(NSTableColumn *)tableColumn
  byItem:(GCField*)item
{
  if( [[item class] isEqual: [FAM class]] )
	{
	  if( [[currentIndi sex] isEqual: @"M"] )
		  return [[item wife: [currentDoc ged]] fullName];
		else
		  return [[item husband: [currentDoc ged]] fullName];
	}
	else
	  return [item fullName];
}

@end
