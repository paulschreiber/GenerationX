#import "RawPanelController.h"

@implementation RawPanelController

+ (RawPanelController*) sharedRawPanel
{
  static RawPanelController* shared_panel = nil;
  
  if( ! shared_panel )
    shared_panel = [[RawPanelController alloc] initNib];
    
  return shared_panel;
}

// load the nib and setup its data source
- (RawPanelController*) initNib
{
  [NSBundle loadNibNamed: @"RawPanel" owner:self];
  [raw_outline setDataSource: self];
  
  return self;
}

// put the raw panel on screen
- (void) display
{
  [raw_panel setFloatingPanel: false];
  [raw_panel makeKeyAndOrderFront:self];  
}

- (void) handleNewFieldButton: (id) sender
{
  GCField* selected = [raw_outline itemAtRow: [raw_outline selectedRow]];
  GCField* added = [[GCField alloc] init];
  
  // if nothing is selected in the panel
  // create a new level 1 field for the record
  if( [raw_outline numberOfSelectedRows] == 0 )
  {
    field = [[raw_outline dataSource] dataField];
    [field addSubfield: @"" : @""];
    [raw_outline reloadData];
    [raw_outline selectRow: [raw_outline numberOfRows] - 1
                 byExtendingSelection: false];
    [raw_outline editColumn: 0 row: [raw_outline numberOfRows] - 1
                 withEvent: nil select: true ];
  }
  // otherwise create a new subfield for the selected field
  else
  {
    added = [selected addSubfield: @"" : @""];
    [raw_outline reloadData];
    [raw_outline expandItem: selected];
    [raw_outline selectRow: [raw_outline rowForItem: added]
                 byExtendingSelection: false];
    [raw_outline editColumn: 0 row: [raw_outline rowForItem: added]
                 withEvent: nil select: true ];
  }
}

- (void) handleDeleteFieldButton: (id) sender
{
  GCField* selected = [raw_outline itemAtRow: [raw_outline selectedRow]];
  int selected_level = [raw_outline levelForItem: selected];
  int i = [raw_outline selectedRow];
  NSString* type;
  
  if( i == -1 )
    return;

  // don't let the user change
  // any link fields
  type = [selected fieldType];
  if( [type isEqual: @"HUSB"] || [type isEqual: @"WIFE"]
   || [type isEqual: @"CHIL"] || [type isEqual: @"FAMC"]
   || [type isEqual: @"FAMS"] )
    return;
  
  field = [[raw_outline dataSource] dataField];
  
  if( selected_level == 0 )
  {
    [field removeSubfield: selected];
  }
  else
  {
    while( [raw_outline levelForRow: i] == selected_level )
      i--;
      
    [[raw_outline itemAtRow: i]
      removeSubfield: selected];
  }
    
  [raw_outline reloadData];
}

- (GCField*) dataField
{
  return field;
}

- (void) setDataField: (GCField*) my_field;
{
  field = my_field;
  [raw_panel setTitle: [field fieldValue]];
  [raw_outline reloadData];
}

//
// NSOutlineView methods
//
- (id)outlineView:(NSOutlineView *)outlineView
  child:(int)index
  ofItem:(GCField*)item
{
  if( item == nil )
    return [field subfieldAtIndex: index];
  else
    return [item subfieldAtIndex: index];
}

- (BOOL)outlineView:(NSOutlineView *)outlineView
  isItemExpandable:(GCField*)item
{
  if( item == nil && [field numSubfields] > 0)
    return true;
  else if( [item numSubfields] > 0 )
    return true;
  
  return false;
}

- (int)outlineView:(NSOutlineView *)outlineView
  numberOfChildrenOfItem:(GCField*)item
{
  if( item == nil )
    //return 1;
    return [field numSubfields];
  else
    return [item numSubfields];
}

- (id)outlineView:(NSOutlineView *)outlineView
  objectValueForTableColumn:(NSTableColumn *)tableColumn
  byItem:(GCField*)item
{
  if( item == nil )
    if( [[tableColumn identifier] isEqual: @"type"] )
      return [field fieldType];
    else
      return [field fieldValue];
  else
    if( [[tableColumn identifier] isEqual: @"type"] )
      return [item fieldType];
    else
      return [item fieldValue];  
}

- (void)outlineView:(NSOutlineView *)outlineView
  setObjectValue:(NSString*)object 
  forTableColumn:(NSTableColumn *)tableColumn
  byItem:(GCField*)item
{
  // don't let the user change
  // any link fields
  NSString* type = [item fieldType];
  if( [type isEqual: @"HUSB"] || [type isEqual: @"WIFE"]
   || [type isEqual: @"CHIL"] || [type isEqual: @"FAMC"]
   || [type isEqual: @"FAMS"]
   || [object isEqual: @"HUSB"] || [object isEqual: @"WIFE"]
   || [object isEqual: @"CHIL"] || [object isEqual: @"FAMC"]
   || [object isEqual: @"FAMS"] )
    return;
  
  if( [[tableColumn identifier] isEqual: @"type"] )
    [item setFieldType: object];
  else
    [item setFieldValue: object];
}

@end
