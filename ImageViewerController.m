#import "ImageViewerController.h"

@implementation ImageViewerController

static ImageViewerController* shared_viewer = nil;

+ (ImageViewerController*) sharedViewer
{
  if( ! shared_viewer )
    shared_viewer = [[ImageViewerController alloc] initViewer];
    
  return shared_viewer;
}

// Load the nib
- (ImageViewerController*) initViewer
{
  [events release];
  events = [[NSMutableArray alloc] init];
  
  [NSBundle loadNibNamed: @"ImageViewer" owner:self];

  return self;
}

// The nib has been loaded
- (void)awakeFromNib
{
  NSBrowserCell*	prototypeCell;
  NSTableColumn*	tableColumn;
  
  // BrowserCell creation
  prototypeCell = [[NSBrowserCell alloc] init];
  [prototypeCell setLeaf: YES];
  tableColumn = [imageOutline tableColumnWithIdentifier: @"filePath"];
  [tableColumn setDataCell: prototypeCell];
  [prototypeCell release];

  // Delegates
  [imageOutline setDelegate: self];
  [imageOutline setDataSource: self];
  
  // Notification observer
  NSNotificationCenter*		appNotificationCenter;

  // Register the current object as an observer
  appNotificationCenter = [NSNotificationCenter defaultCenter];

  [appNotificationCenter 	addObserver: self
                            selector: @selector( handleNotificationContentChange: )
                            name: @"GenXContentChange"
                            object: nil];
}

// Content change notification
- (void) notifyContentChange
{
  NSNotificationCenter*		appNotificationCenter;

  // Send a notification to the notification center
  appNotificationCenter = [NSNotificationCenter defaultCenter];
  [appNotificationCenter 	postNotificationName: @"GenXContentChange"
                            object: self];
}

// 
- (void) handleNotificationContentChange:(NSNotification *)aNotification
{
  [self updateViewContent];
}

// Set the record that contains the multimedia files that should be displayed
// in the window
- (void) setRecord: (id) aRecord
{
  if( record != aRecord )
  {
    [record release];
    [aRecord retain];
    record = aRecord;
  }
  
  [self updateViewContent];

  // Make the outlineviex the first responder
  [window makeFirstResponder: imageOutline];
  
  // Select the first row
  [imageOutline selectRow: 0 byExtendingSelection: NO];
}

// Get the record that contains the multimedia files that should be displayed
// in the window
- (id) record
{
    return record;
}

// The window accessor
- (NSWindow*) window
{
  return window;
}

// Update the content of the view
- (void) updateViewContent
{
  GCField* gc_tmp;
  NSMutableString* title = [NSMutableString stringWithString: @"Images for\n"];
  int i = 0;
  
  [events removeAllObjects];
  [imagePreview setImage: nil];
  
  // We're looking for images directly inside fam and indi records
  for( i = 0; i < [record numSubfields]; i++ )
  {
    gc_tmp = [record subfieldAtIndex: i];
    if( [[gc_tmp fieldType] isEqualToString: @"OBJE"] )
      [events addObject: gc_tmp];
  }
  
  // We're looking for images directly inside events of current record
  for( i = 0; i < [record numSubfields]; i++ )
  {
    gc_tmp = [record subfieldAtIndex: i];
    if( [gc_tmp isEvent] && [[gc_tmp subfieldsWithType: @"OBJE"] count] > 0 )
      [events addObject: gc_tmp];
  }
  
  // If the current record is an indi then fullName is displayed
  if( [[record fieldType] isEqualToString: @"INDI"] )
    [title appendString: [record fullName]];
  else
    [title appendString: [record fieldValue]];
  
  [headerText setStringValue: title];
  
  // Update outline view
  [imageOutline reloadData];
}

- (void)addImagePanelDidClose:(NSOpenPanel *)sheet
  returnCode:(int)returnCode
  contextInfo:(void  *)contextInfo
{
  GCField* gc_tmp;
  NSString* file = [sheet filename];
  
  if (returnCode == NSOKButton)
  {
    [record setNeedSave: true];
    gc_tmp = [record addSubfield: @"OBJE": @""];
    if( [file hasSuffix: @".jpg"] || [file hasSuffix: @"JPG"] )
      [gc_tmp addSubfield: @"FORM": @"jpeg"];
    else if( [file hasSuffix: @".gif"] || [file hasSuffix: @"GIF"] )
      [gc_tmp addSubfield: @"FORM": @"gif"];
    else if( [file hasSuffix: @".bmp"] || [file hasSuffix: @"BMP"] )
      [gc_tmp addSubfield: @"FORM": @"bmp"];
    else if( [file hasSuffix: @".tiff"] || [file hasSuffix: @"TIFF"] )
      [gc_tmp addSubfield: @"FORM": @"tiff"];
    [gc_tmp addSubfield: @"FILE": file];
  }
  
  // Send a notification to update the interface
  [self notifyContentChange];

  [window makeFirstResponder: imageOutline];
  [imageOutline selectRow: [imageOutline numberOfRows] - 1 byExtendingSelection: NO];
}

- (void) showAddImagePanel:(id) sender
{
  NSOpenPanel* open;
  NSArray *fileTypes = [NSArray arrayWithObjects:
    @"jpg", @"JPG", @"gif", @"GIF", @"bmp", @"BMP", @"tiff", @"TIFF", nil];
  
  // Display a standard open dialog
  open = [NSOpenPanel openPanel];
  [open setAllowsMultipleSelection:false];
  [open beginSheetForDirectory:NSHomeDirectory()
    file:nil
    types:fileTypes
//    modalForWindow: [appController mainWindow]
    modalForWindow: window
    modalDelegate: self
    didEndSelector: @selector(addImagePanelDidClose:returnCode:contextInfo:)
    contextInfo: nil];
}

// buttonUp has been clicked
// Change the selection upward
- (void) buttonUpHasBeenClicked: (id) sender
{
  int		selectedRow;
  
  // Get the selected record
  selectedRow = [imageOutline selectedRow];
  if( selectedRow < 0 )
    selectedRow = 0;
  else
    selectedRow--;
  
  [imageOutline selectRow: selectedRow byExtendingSelection: NO];
  [imageOutline scrollRowToVisible: selectedRow];
  [window makeFirstResponder: imageOutline];
}

// buttonDown has been clicked
// Change the selection downward
- (void) buttonDownHasBeenClicked: (id) sender
{
  int		selectedRow;
  
  // Get the selected record
  selectedRow = [imageOutline selectedRow];
  if( selectedRow < 0 )
    selectedRow = 0;
  else
    selectedRow++;

  [imageOutline selectRow: selectedRow byExtendingSelection: NO];
  [imageOutline scrollRowToVisible: selectedRow];
  [window makeFirstResponder: imageOutline];
}

// buttonPlus has been clicked
// Add an image to the current indi or to the current fam
- (void) buttonPlusHasBeenClicked: (id) sender
{
  [self showAddImagePanel: self];
}

// buttonMinus has been clicked
// Delete the selected image
// Images owned by events cannot be deleted here
- (void) buttonMinusHasBeenClicked: (id) sender
{
  GCField*		selectedField;
  int			selectedRow;
  
  // Get the selected record
  selectedRow = [imageOutline selectedRow];
  if( selectedRow > -1 && [imageOutline levelForRow: selectedRow] == 0 )
  {
    selectedField = [imageOutline itemAtRow: selectedRow];
    if( [[selectedField fieldType] isEqualToString: @"OBJE"] )
    {
      [record removeSubfield: selectedField];
      
      // Send a notification to update the interface
      [self notifyContentChange];

      // Make the outlineview the first responder
      [window makeFirstResponder: imageOutline];
  
      // Select the right row
      if( selectedRow > [imageOutline numberOfRows] - 1 )
        [imageOutline selectRow: [imageOutline numberOfRows] - 1 byExtendingSelection: NO];
    }
  }
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
    return [[item subfieldsWithType: @"OBJE"] objectAtIndex: index];
}

- (BOOL)outlineView:(NSOutlineView *)outlineView
  isItemExpandable:(GCField*)item
{
  if( item == nil && [events count] > 0)
    return true;
  else if( [[item subfieldsWithType: @"OBJE"] count] > 0 )
    return true;
  
  return false;
}

- (int)outlineView:(NSOutlineView *)outlineView
  numberOfChildrenOfItem:(GCField*)item
{
  if( item == nil )
    return [events count];
  else
    return [[item subfieldsWithType: @"OBJE"] count];
}

- (void)outlineView: (NSOutlineView *)outlineView
willDisplayCell: (id)cell
forTableColumn: (NSTableColumn *)tableColumn
item: (id)item
{
  NSImage* image;
  NSSize	newSize;
  NSSize	oldSize;
  NSString*	imagePath;

  // Get the image file path
  imagePath = [[item subfieldWithType: @"FILE"] fieldValue];

  // If the image file exists and the image can be loaded
  if( [[NSFileManager defaultManager] fileExistsAtPath: imagePath]
   && ( image = [[NSImage alloc] initWithContentsOfFile: imagePath] ) )
  {
    [cell setImage: nil];

    // Change scale of the image to fit the outline view row height
    [image setScalesWhenResized: YES];
    oldSize = [image size];
    newSize.height = [outlineView rowHeight];
    newSize.width = oldSize.width / oldSize.height * newSize.height;
    [image setSize: newSize];
    
    [cell setImage: image];
    
    [image release];
  }
  else
  {
    [cell setImage: nil];
  }
}

- (id)outlineView:(NSOutlineView *)outlineView
  objectValueForTableColumn:(NSTableColumn *)tableColumn
  byItem:(GCField*)item
{
  // Multimedia
  if( [[item fieldType] isEqualToString: @"OBJE"] )
  {
    if( [item subfieldWithType: @"FILE"] )
    {
      if( [item subfieldWithType: @"TITL"] )
        return [[item subfieldWithType: @"TITL"] fieldValue];
      else
        return [[item subfieldWithType: @"FILE"] fieldValue];
    }
    else
      return @"OBJE has no FILE tag";
  }
  // Event
  else
  {
    return [[GenXUtil sharedUtil] eventStringFromGEDCOM: [item fieldType]];
  }
}

- (void)outlineViewSelectionDidChange: (NSNotification *)notification
{
  GCField* 	gc_tmp;
  NSImage*	image;
  NSString*	imagePath;
  int		selectedRow;

  // Get the selected record
  selectedRow = [imageOutline selectedRow];
  
  // Update the up and down buttons state
  if( selectedRow < 0 )
  {
    [buttonUp setEnabled: NO];
    [buttonDown setEnabled: NO];
  }
  else if( selectedRow == 0 )
  {
    [buttonUp setEnabled: NO];
    [buttonDown setEnabled: YES];
  }
  else if( selectedRow > [imageOutline numberOfRows] - 2 )
  {
    [buttonUp setEnabled: YES];
    [buttonDown setEnabled: NO];
  }
  else
  {
    [buttonUp setEnabled: YES];
    [buttonDown setEnabled: YES];
  }
  
  // Update the minus buttons state
  if( selectedRow < 0 )
    [buttonMinus setEnabled: NO];
  else
    [buttonMinus setEnabled: YES];
  
  gc_tmp = [imageOutline itemAtRow: selectedRow];
  imagePath = [gc_tmp valueOfSubfieldWithType: @"FILE"];

  // Get the image file path
  imagePath = [[gc_tmp subfieldWithType: @"FILE"] fieldValue];
  
  // If the image file exists and the image can be loaded
  if( [[NSFileManager defaultManager] fileExistsAtPath: imagePath]
   && ( image = [[NSImage alloc] initWithContentsOfFile: imagePath] ) )
  {
    [imagePreview setImage: nil];
    [imagePreview setImage: image];
    [image release];
  }
  else
  {
    [imagePreview setImage: nil];
  }
}

- (void) imageHasBeenClicked: (id) sender
{
  GCField* 	gc_tmp;
  int		selectedRow;

  selectedRow = [imageOutline selectedRow];
  gc_tmp = [imageOutline itemAtRow: selectedRow];

  [[NSWorkspace sharedWorkspace] openFile: [gc_tmp valueOfSubfieldWithType: @"FILE"]];
}

@end
