#import "ImageViewerController.h"
#import "sourceSelectorController.h"
#import "MyDocument.h"
#define currentDoc (MyDocument *)[[NSDocumentController sharedDocumentController] currentDocument]

@implementation ImageViewerController

static ImageViewerController* shared_viewer = nil;

+ (ImageViewerController*) sharedViewer
{
	if ( ! shared_viewer ) {
		shared_viewer = [[ImageViewerController alloc] initViewer];
	}
    
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
	
	// Notification observer
	NSNotificationCenter*		appNotificationCenter;
	
	// BrowserCell creation
	prototypeCell = [[NSBrowserCell alloc] init];
	[prototypeCell setLeaf: YES];
	tableColumn = [imageOutline tableColumnWithIdentifier: @"filePath"];
	[tableColumn setDataCell: prototypeCell];
	[prototypeCell release];
	
	// Delegates
	[imageOutline setDelegate: self];
	[imageOutline setDataSource: self];
	
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
	if ( record != aRecord ) {
		[record release];
		[aRecord retain];
		record = aRecord;
	}
	
	[self updateViewContent];
	
	// Make the outlineviex the first responder
	[window makeFirstResponder: imageOutline];
	
	// Select the first row
	[imageOutline selectRowIndexes: [NSIndexSet indexSetWithIndex:0] byExtendingSelection: NO];
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

- (void) toggle
{
	if ( [window isVisible] ) {
		[window orderOut: nil];
	} else {
		[window makeKeyAndOrderFront: nil];
	}
}

- (BOOL) isVisible
{
	return [window isVisible];
}

// Update the content of the view
- (void) updateViewContent
{
	GCField* gc_tmp;
	NSUInteger i = 0;
	
	[events removeAllObjects];
	[imagePreview setImage: nil];
	
	// We're looking for images directly inside fam and indi records
	for ( i = 0; i < [record numSubfields]; i++ ) {
		gc_tmp = [record subfieldAtIndex: i];
		if ( [[gc_tmp fieldType] isEqualToString: @"OBJE"] ) {
			[events addObject: gc_tmp];
		}
	}
	
	// We're looking for images directly inside events of current record
	for ( i = 0; i < [record numSubfields]; i++ )
	{
		gc_tmp = [record subfieldAtIndex: i];
		if ( [gc_tmp isEvent] ) { //&& [[gc_tmp subfieldsWithType: @"OBJE"] count] > 0 ) {
			[events addObject: gc_tmp];
		}
	}
	
	/*
	 // If the current record is an indi then fullName is displayed
	 if ( [[record fieldType] isEqualToString: @"INDI"] )
	 [title appendString: [record fullName]];
	 else
	 [title appendString: [record fieldValue]];
	 
	 [headerText setStringValue: title];
	 */  
	// Update outline view
	[imageOutline reloadData];
}

- (void) handleSelectSource: (id) sender
{
}

- (void) handleChangeSource: (id) sender
{
	[NSApp beginSheet: [[sourceSelectorController sharedSelector] panel] modalForWindow: window modalDelegate: self didEndSelector: @selector( changeSourceSheetDidEnd ) contextInfo: nil];
}

- (void) changeSourceSheetDidEnd
{
	if ( [[[imageOutline itemAtRow: [imageOutline selectedRow]] fieldType] isEqualToString: @"OBJE"] ) {
		GCField* tmp = [[imageOutline itemAtRow: [imageOutline selectedRow]] subfieldWithType: @"SOUR"];
		if ( !tmp ) {
			tmp = [[imageOutline itemAtRow: [imageOutline selectedRow]] addSubfield: @"SOUR" : @""];
		}
		
		[tmp setFieldValue: [[[sourceSelectorController sharedSelector] selectedSource] fieldValue]];
		[currentDoc handleContentChange];
	}
}

- (void)addImagePanelDidClose:(NSOpenPanel *)sheet
				   returnCode:(NSInteger)returnCode
				  contextInfo:(void  *)contextInfo
{
	GCField* gc_tmp;
	NSString* file = [sheet filename];
	
	if (returnCode == NSOKButton) {
		[record setNeedSave: true];
		
		if ( [imageOutline selectedRow] == -1 ) {
			gc_tmp = [record addSubfield: @"OBJE": @""];
		} else if ( [[imageOutline itemAtRow: [imageOutline selectedRow]] isEvent] ) {
			gc_tmp = [[imageOutline itemAtRow: [imageOutline selectedRow]] addSubfield: @"OBJE": @""];
		} else {
			return;
		}
		
		if ( [file hasSuffix: @".jpg"] || [file hasSuffix: @"JPG"] ) {
			[gc_tmp addSubfield: @"FORM": @"jpeg"];
		} else if ( [file hasSuffix: @".gif"] || [file hasSuffix: @"GIF"] ) {
			[gc_tmp addSubfield: @"FORM": @"gif"];
		} else if ( [file hasSuffix: @".bmp"] || [file hasSuffix: @"BMP"] ) {
			[gc_tmp addSubfield: @"FORM": @"bmp"];
		} else if ( [file hasSuffix: @".tiff"] || [file hasSuffix: @"TIFF"] ) {
			[gc_tmp addSubfield: @"FORM": @"tiff"];
		}
		[gc_tmp addSubfield: @"FILE": file];
		[[[NSDocumentController sharedDocumentController] currentDocument] handleContentChange];
	}
	
	// Send a notification to update the interface
	[self notifyContentChange];
	
	[window makeFirstResponder: imageOutline];
	[imageOutline selectRowIndexes: [NSIndexSet indexSetWithIndex:([imageOutline numberOfRows] - 1)] byExtendingSelection: NO];
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
	NSInteger		selectedRow;
	
	// Get the selected record
	selectedRow = [imageOutline selectedRow];
	if ( selectedRow < 0 ) {
		selectedRow = 0;
	} else {
		selectedRow--;
	}
	
	[imageOutline selectRowIndexes: [NSIndexSet indexSetWithIndex:selectedRow] byExtendingSelection: NO];
	[imageOutline scrollRowToVisible: selectedRow];
	[window makeFirstResponder: imageOutline];
}

// buttonDown has been clicked
// Change the selection downward
- (void) buttonDownHasBeenClicked: (id) sender
{
	NSInteger		selectedRow;
	
	// Get the selected record
	selectedRow = [imageOutline selectedRow];
	if ( selectedRow < 0 ) {
		selectedRow = 0;
	} else {
		selectedRow++;
	}
	
	[imageOutline selectRowIndexes: [NSIndexSet indexSetWithIndex:selectedRow] byExtendingSelection: NO];
	[imageOutline scrollRowToVisible: selectedRow];
	[window makeFirstResponder: imageOutline];
}

// buttonPlus has been clicked
// Add an image to the current indi or to the current fam
- (void) buttonPlusHasBeenClicked: (id) sender
{
	if ( [imageOutline selectedRow] == -1
		|| [[imageOutline itemAtRow: [imageOutline selectedRow]] isEvent] ) {
		[self showAddImagePanel: self];
	}
}

// buttonMinus has been clicked
// Delete the selected image
// Images owned by events cannot be deleted here
- (void) buttonMinusHasBeenClicked: (id) sender
{
	GCField*		selectedField, *parentField;
	NSInteger			selectedRow, i;
	
	// Get the selected record
	selectedRow = [imageOutline selectedRow];
	i = selectedRow - 1;
	if ( selectedRow > -1 && [[[imageOutline itemAtRow: selectedRow] fieldType] isEqualToString: @"OBJE"] ) {
		selectedField = [imageOutline itemAtRow: selectedRow];
		
		parentField = [imageOutline itemAtRow: i];
		while ( ![parentField isEvent] && i > -1) {
			parentField = [imageOutline itemAtRow: i--];
		}
		if ( i == -1 ) {
			parentField = record;
		}
		
		[parentField removeSubfield: selectedField];
		
		// Send a notification to update the interface
		//		[self notifyContentChange];
		
		// Make the outlineview the first responder
		[window makeFirstResponder: imageOutline];
		
		// Select the right row
		if ( selectedRow > [imageOutline numberOfRows] - 1 ) {
			[imageOutline selectRowIndexes: [NSIndexSet indexSetWithIndex:([imageOutline numberOfRows] - 1)] byExtendingSelection: NO];
		}
		
		[[[NSDocumentController sharedDocumentController] currentDocument] handleContentChange];
	}
}

//
// NSOutlineView methods
//
- (id)outlineView:(NSOutlineView *)outlineView
			child:(NSInteger)index
		   ofItem:(GCField*)item
{
	if ( item == nil ) {
		return [events objectAtIndex: index];
	} else {
		return [[item subfieldsWithType: @"OBJE"] objectAtIndex: index];
	}
}

- (BOOL)outlineView:(NSOutlineView *)outlineView
   isItemExpandable:(GCField*)item
{
	if ( [[item subfieldsWithType: @"OBJE"] count] > 0 ) {
		return true;
	}
	
	return false;
}

- (NSInteger)outlineView:(NSOutlineView *)outlineView
  numberOfChildrenOfItem:(GCField*)item
{
	if ( item == nil ) {
		return [events count];
	} else {
		return [[item subfieldsWithType: @"OBJE"] count];
	}
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
	if ( [[NSFileManager defaultManager] fileExistsAtPath: imagePath]
		&& ( image = [[NSImage alloc] initWithContentsOfFile: imagePath] ) ) {
		[cell setImage: nil];
		
		// Change scale of the image to fit the outline view row height
		[image setScalesWhenResized: YES];
		oldSize = [image size];
		newSize.height = [outlineView rowHeight];
		newSize.width = oldSize.width / oldSize.height * newSize.height;
		[image setSize: newSize];
		
		[cell setImage: image];
		
		[image release];
	} else {
		[cell setImage: nil];
	}
}

- (id)outlineView:(NSOutlineView *)outlineView
objectValueForTableColumn:(NSTableColumn *)tableColumn
		   byItem:(GCField*)item
{
	// Multimedia
	if ( [[item fieldType] isEqualToString: @"OBJE"] ) {
		if ( [item subfieldWithType: @"FILE"] ) {
			if ( [item subfieldWithType: @"TITL"] ) {
				return [[item subfieldWithType: @"TITL"] fieldValue];
			} else {
				return [[item subfieldWithType: @"FILE"] fieldValue];
			}
		} else {
			return @"OBJE has no FILE tag";
		}
		
		// Event
	} else {
		return [[GenXUtil sharedUtil] eventStringFromGEDCOM: [item fieldType]];
	}
}

- (void)outlineViewSelectionDidChange: (NSNotification *)notification
{
	GCField* 	gc_tmp;
	NSImage*	image;
	NSString*	imagePath;
	NSInteger	selectedRow;
	
	// Get the selected record
	selectedRow = [imageOutline selectedRow];
	
	if ( [[[imageOutline itemAtRow: selectedRow] fieldType] isEqualToString: @"OBJE"]   
		&& (gc_tmp = [[imageOutline itemAtRow: selectedRow] subfieldWithType: @"SOUR"]) )  {
		// if there's a linked in record
		if ( [[gc_tmp fieldValue] hasPrefix: @"@"] )
			gc_tmp = [[currentDoc ged] recordWithLabel: [gc_tmp fieldValue]];
		
		if ( [gc_tmp subfieldWithType: @"TITL"] ) {
			[sourceText setStringValue: [gc_tmp valueOfSubfieldWithType: @"TITL"]];
		} else if ( [gc_tmp subfieldWithType: @"AUTH"] ) {
			[sourceText setStringValue: [gc_tmp valueOfSubfieldWithType: @"AUTH"]];
		} else {
			[sourceText setStringValue: [gc_tmp fieldValue]];
		}
	} else {
		[sourceText setStringValue: @"No source"];
	}
	
	// update the plus button state  
	if ( [imageOutline selectedRow] < 0) {
		[buttonPlus setEnabled: YES];
	} else if ( [[imageOutline itemAtRow: [imageOutline selectedRow]] isEvent] ) {
		[buttonPlus setEnabled: YES];
	} else {
		[buttonPlus setEnabled: NO];
	}
	
	// Update the minus buttons state
	if ( selectedRow > -1 
		&& [[[imageOutline itemAtRow: selectedRow] fieldType] isEqualToString: @"OBJE"] ) {
		[buttonMinus setEnabled: YES];
	} else {
		[buttonMinus setEnabled: NO];
	}
	
	gc_tmp = [imageOutline itemAtRow: selectedRow];
	
	// Get the image file path
	imagePath = [[gc_tmp subfieldWithType: @"FILE"] fieldValue];
	
	// If the image file exists and the image can be loaded
	if ( [[NSFileManager defaultManager] fileExistsAtPath: imagePath]
		&& ( image = [[NSImage alloc] initWithContentsOfFile: imagePath] ) ) {
		[imagePreview setImage: nil];
		[imagePreview setImage: image];
		[image release];
	} else {
		[imagePreview setImage: nil];
	}
}

- (void) imageHasBeenClicked: (id) sender
{
	GCField* 	gc_tmp;
	NSInteger		selectedRow;
	
	selectedRow = [imageOutline selectedRow];
	gc_tmp = [imageOutline itemAtRow: selectedRow];
	
	[[NSWorkspace sharedWorkspace] openFile: [gc_tmp valueOfSubfieldWithType: @"FILE"]];
}

@end
