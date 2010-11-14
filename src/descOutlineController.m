#import "descOutlineController.h"

#define currentDoc [[NSDocumentController sharedDocumentController] currentDocument]

@implementation descOutlineController

- (void) updateWithIndi: (INDI*) i
{
  [currentIndi release];
	currentIndi = [i retain];
	[descOutline reloadData];
}

- (void) handleUpButton: (id) sender
{
  GCField* item = [descOutline itemAtRow: 0];
	
	if( [[item class] isEqual: [INDI class]] )
	{
	  if( [item father: [currentDoc ged]] )
  	  [currentDoc selectIndi: [item father: [currentDoc ged]]];
		else if( [item mother: [currentDoc ged]] )
  	  [currentDoc selectIndi: [item mother: [currentDoc ged]]];
	}
	else
	{
	  if( [item husband: [currentDoc ged]] )
  	  [currentDoc selectIndi: [item husband: [currentDoc ged]]];
		else if( [item wife: [currentDoc ged]] )
  	  [currentDoc selectIndi: [item wife: [currentDoc ged]]];
	}
}

#pragma mark -
#pragma mark NSOutlineView methods

- (id)outlineView:(NSOutlineView *)outlineView
  child:(int)index
  ofItem:(GCField*)item
{
  if( !item )
	{
	  return currentIndi;
//	  return [[currentIndi spouseFamilies: [currentDoc ged]] objectAtIndex: index];
	}
	else if ( [[item class] isEqual: [INDI class]] )
	{
	  return [[item spouseFamilies: [currentDoc ged]] objectAtIndex: index];
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
	else if( [[item class] isEqual: [INDI class]]
	 && [[item spouseFamilies: [currentDoc ged]] count] > 0 )
	  return YES;
		
	return NO;
}

- (int)outlineView:(NSOutlineView *)outlineView
  numberOfChildrenOfItem:(GCField*)item
{
  if( !item )
	  return 1;
//    return [[currentIndi spouseFamilies: [currentDoc ged]] count];
	else if( [[item class] isEqual: [FAM class]] )
	  return [[item children: [currentDoc ged]] count];
	else
	  return [[item spouseFamilies: [currentDoc ged]] count];
}

- (id)outlineView:(NSOutlineView *)outlineView
  objectValueForTableColumn:(NSTableColumn *)tableColumn
  byItem:(GCField*)item
{
  if( [[item class] isEqual: [FAM class]] )
	{
		int selectedLevel = [outlineView levelForItem: item];
		int i = [outlineView rowForItem: item];
		
		while( [descOutline levelForRow: i--] >= selectedLevel
		  && ![[[descOutline itemAtRow: i] class] isEqual: [INDI class]] ) ;

		if( [[[descOutline itemAtRow: i] sex] isEqual: @"M"] )
			return [NSString stringWithFormat: @"+ %@ %@", [[item wife: [currentDoc ged]] fullName], [[item wife: [currentDoc ged]] lifespan]];
		else
			return [NSString stringWithFormat: @"+ %@ %@", [[item husband: [currentDoc ged]] fullName], [[item husband: [currentDoc ged]] lifespan]];
	}
	else
			return [NSString stringWithFormat: @"%@ %@", [item fullName], [item lifespan]];
}

- (void)outlineViewSelectionDidChange:(NSNotification *)notification
{
  GCField* item = [descOutline itemAtRow: [descOutline selectedRow]];
	
  if( [[item class] isEqual: [FAM class]] )
	{
		int selectedLevel = [descOutline levelForItem: item];
		int i = [descOutline rowForItem: item];
		
		while( [descOutline levelForRow: i--] >= selectedLevel
		  && ![[[descOutline itemAtRow: i] class] isEqual: [INDI class]] ) ;

		if( [[[descOutline itemAtRow: i] sex] isEqual: @"M"] )
      [currentDoc selectIndi: [item wife: [currentDoc ged]]];
		else
      [currentDoc selectIndi: [item husband: [currentDoc ged]]];
	}
	else
    [currentDoc selectIndi: item];
}

@end
