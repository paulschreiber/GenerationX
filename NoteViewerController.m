#import "NoteViewerController.h"
#import "NoteCell.h"

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
  NSMutableString* title = [[NSMutableString alloc] initWithString: @"Notes for\n"];
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
    if( [gc_tmp isEvent] && [[gc_tmp subfieldsWithType: @"NOTE"] count] > 0 )
      [events addObject: gc_tmp];
  }
  
  if( [[field fieldType] isEqualToString: @"INDI"] )
    [title appendString: [my_field fullName]];
  else
    [title appendString: [my_field fieldValue]];
  
  [header_text setStringValue: title];
  [note_outline reloadData];
}

- (NSWindow*) window
{
  return window;
}

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
  NSImage* image; 
  NSCell*  text_cell;
  NSImageCell*  image_cell;
    
  if( item == nil )
  {
    return [[GenXUtil sharedUtil] eventStringFromGEDCOM: [field fieldType]];
  }
  else if( [[item fieldType] isEqualToString: @"NOTE"] )
  {
    return [item textValue];
  }
  else
  {
    return [[GenXUtil sharedUtil] eventStringFromGEDCOM: [item fieldType]];
  }
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

@end
