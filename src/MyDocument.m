//
//  MyDocument.m
//  GenXDoc
//
//  Created by Nowhere Man on Fri Feb 06 2004.
//  Copyright (c) 2004 __MyCompanyName__. All rights reserved.
//

#import "MyDocument.h"
#import "indiDetailPanelController.h"
#import "famDetailPanelController.h"
#import "ImageViewerController.h"
#import "eventViewerController.h"
#import "RawPanelController.h"
#import "NoteViewerController.h"
#import "sourceSelectorController.h"
#import "HTMLController.h"
#import "MergeController.h"

@implementation MyDocument

- (id)init
{
    self = [super init];
    if (self) {
    	ged = [[GCFile alloc] init];
	}
    return self;
}

- (NSString *)windowNibName
{
	// Override returning the nib file name of the document
	// If you need to use a subclass of NSWindowController or if your document supports multiple NSWindowControllers, you should remove this method and override -makeWindowControllers instead.
    return @"MyDocument";
}

- (void)windowControllerDidLoadNib:(NSWindowController *) aController
{
	[super windowControllerDidLoadNib:aController];
	
	indiDataSource = [[indiTableDataSource alloc] initWithGED: ged];			
	[indiTable setDelegate: indiDataSource];
	[indiTable setDataSource: indiDataSource];
	[[indiTable tableColumnWithIdentifier: @"sex"] setDataCell: [[[NSImageCell alloc] init] autorelease]];
	[indiTable selectRowIndexes:[NSIndexSet indexSetWithIndex:0] byExtendingSelection: NO];
	currentIndi = [indiDataSource indiAtIndex: 0];
	if ( [indiDataSource numberTotal] == 1 ) {
		[indiMessageText setStringValue: [NSString stringWithFormat: @"%@ person", [[NSNumber numberWithInteger: [indiDataSource numberTotal]] stringValue]]];
	} else {
		[indiMessageText setStringValue: [NSString stringWithFormat: @"%@ people", [[NSNumber numberWithInteger: [indiDataSource numberTotal]] stringValue]]];
	}
	
	famDataSource = [[famTableDataSource alloc] initWithGED: ged];			
	[famTable setDelegate: famDataSource];
	[famTable setDataSource: famDataSource];
	if ( [famDataSource numberTotal] == 1 ) {
		[famMessageText setStringValue: [NSString stringWithFormat: @"%@ family", [[NSNumber numberWithInteger: [famDataSource numberTotal]] stringValue]]];
	} else {
		[famMessageText setStringValue: [NSString stringWithFormat: @"%@ families", [[NSNumber numberWithInteger: [famDataSource numberTotal]] stringValue]]];
	}
	
	[sourceDataSource refreshWithGED: ged];
	
	[indiTable selectRowIndexes:[NSIndexSet indexSetWithIndex:0] byExtendingSelection: NO];
	[self handleSelectIndi: nil];
}

- (BOOL)readFromFile:(NSString *)fileName ofType:(NSString *)docType
{
	int i;
	ged = [[GCFile alloc] initWithFile: fileName];
	if ( ged ) {
		for ( i = 0; i < [ged numRecords]; i++ ) {
			if ( [[[ged recordAtIndex: i] fieldType] isEqual: @"FAM"] ) {
				[[ged recordAtIndex: i] sortChildren: ged];
			}
			[[ged recordAtIndex: i] sortEvents];
		}
		return YES;
	}
	
	return NO;
}

- (BOOL)writeToFile:(NSString *)fileName ofType:(NSString *)docType
{
	[ged setPath: fileName];
	return [ged saveToFile];
}

- (GCFile*) ged
{
	return ged;
}

- (INDI*) currentIndi
{
	return currentIndi;
}

- (void) selectIndi: (INDI*) i
{
	// 040211
	// need more elegant handling of the case where
	// the requested INDI is not visible in the filtered list
	NSInteger index = [indiDataSource indexOfIndi: i];
	
	[indiTable selectRowIndexes:[NSIndexSet indexSetWithIndex:index] byExtendingSelection: NO];
	[indiTable scrollRowToVisible: index];
}

- (void) selectFam: (FAM*) f
{
	// 040211
	// need more elegant handling of the case where
	// the requested INDI is not visible in the filtered list
	NSInteger index = [famDataSource indexOfFam: f];
	
	[famTable selectRowIndexes:[NSIndexSet indexSetWithIndex:index] byExtendingSelection: NO];
	[famTable scrollRowToVisible: index];
}

- (void) handleContentChange
{
	long tab = [mainTabView indexOfTabViewItem: [mainTabView selectedTabViewItem]];
	
	[indiDataSource refresh];
	[famDataSource refresh];
	[sourceDataSource refresh];
	[indiTable reloadData];
	[famTable reloadData];
	
	[[indiDetailPanelController sharedIndiDetailPanel] updateWithIndi: currentIndi];
	[[famDetailPanelController sharedFamDetailPanel] updateWithFam: currentFam];
	
	[descController updateWithIndi: currentIndi];
	[[sourceSelectorController sharedSelector] refresh];
	
	if ( tab == 0 ) {
		[[ImageViewerController sharedViewer] setRecord: currentIndi];
		[[RawPanelController sharedRawPanel] setDataField: currentIndi];
		[[eventViewerController sharedEventPanel] updateWithRecord: currentIndi];
		[[NoteViewerController sharedViewer] setField: currentIndi];
	} else if ( tab == 1 ) {
		[[ImageViewerController sharedViewer] setRecord: currentFam];
		[[RawPanelController sharedRawPanel] setDataField: currentFam];
		[[eventViewerController sharedEventPanel] updateWithRecord: currentFam];
		[[NoteViewerController sharedViewer] setField: currentFam];
	}
	
	[self updateChangeCount: NSChangeDone];
	
	if ( [indiDataSource numberTotal] == 1 ) {
		[indiMessageText setStringValue: [NSString stringWithFormat: @"%@ person", [[NSNumber numberWithInteger: [indiDataSource numberTotal]] stringValue]]];
	} else {
		[indiMessageText setStringValue: [NSString stringWithFormat: @"%@ people", [[NSNumber numberWithInteger: [indiDataSource numberTotal]] stringValue]]];
	}
	
	if ( [famDataSource numberTotal] == 1 ) {
		[famMessageText setStringValue: [NSString stringWithFormat: @"%@ family", [[NSNumber numberWithInteger: [famDataSource numberTotal]] stringValue]]];
	} else {
		[famMessageText setStringValue: [NSString stringWithFormat: @"%@ families", [[NSNumber numberWithInteger: [famDataSource numberTotal]] stringValue]]];
	}
}

#pragma mark -
#pragma mark IBAction handlers

- (void) handleAddIndi: (id) sender
{
	NSString* label;
	INDI* new;
	
	label = [NSString stringWithFormat: @"@INDI_%@@",
			 [[NSNumber numberWithDouble: floor( [[NSDate date] timeIntervalSince1970] )] stringValue]];
	
	while ( [ged recordWithLabel: label] ) {
		label = [NSString stringWithFormat: @"@INDI_%@@",
				 [[NSNumber numberWithDouble: floor( [[NSDate date] timeIntervalSince1970] )] stringValue]];
	}
	
	new = [[[INDI alloc] init: 0 : @"INDI" : label] autorelease];
	[new addSubfield: @"NAME" : @"given name /surname/"];
	[[new subfieldWithType: @"NAME"] addSubfield: @"SURN" : @"surname"];
	[[new subfieldWithType: @"NAME"] addSubfield: @"GIVN" : @"given name"];
	
	new = [ged addRecord: new];
	[indiDataSource refresh];
	[indiTable reloadData];
	[self selectIndi: new];
	[self handleContentChange];
}

- (void) handleDeleteIndi: (id) sender
{
	[ged removeRecord: currentIndi];
	[indiDataSource refresh];
	[indiTable reloadData];
	[self handleContentChange];
}

- (void) handleSelectIndi: (id) sender
{
	NSLog(@"handleSelectIndi %@", sender);
	INDI* selectedIndi;
	
	if ( [indiTable selectedRow] == -1 ) {
		return;
	}
	
	selectedIndi = [indiDataSource indiAtIndex: [indiTable selectedRow]];
	
	if ( selectedIndi ) {
		currentIndi = selectedIndi;
		[[indiDetailPanelController sharedIndiDetailPanel] updateWithIndi: currentIndi];
		[descController updateWithIndi: currentIndi];
		[[ImageViewerController sharedViewer] setRecord: currentIndi];
		[[RawPanelController sharedRawPanel] setDataField: currentIndi];
		[[eventViewerController sharedEventPanel] updateWithRecord: currentIndi];
		[[NoteViewerController sharedViewer] setField: currentIndi];
	}
}

- (void) handleFilterIndividuals: (id) sender
{
	[indiDataSource filterWithString: [indiSearchField stringValue]];
	[indiTable reloadData];
	[indiMessageText setStringValue: [NSString stringWithFormat: @"%@ of %@ people", [[NSNumber numberWithInteger: [indiDataSource numberDisplayed]] stringValue], [[NSNumber numberWithInteger: [indiDataSource numberTotal]] stringValue]]];
}

- (void) handleAddFam: (id) sender
{
	NSString* label;
	FAM* new;
	
	label = [NSString stringWithFormat: @"@FAM_%@@",
			 [[NSNumber numberWithDouble: floor( [[NSDate date] timeIntervalSince1970] )] stringValue]];
	
	while ( [ged recordWithLabel: label] ) {
		label = [NSString stringWithFormat: @"@FAM_%@@",
				 [[NSNumber numberWithDouble: floor( [[NSDate date] timeIntervalSince1970] )] stringValue]];
	}
	
	new = [[[FAM alloc] init: 0 : @"FAM" : label] autorelease];
	
	new = [ged addRecord: new];
	[famDataSource refresh];
	[famTable reloadData];
	[self selectFam: new];
	[self handleContentChange];
}

- (void) handleDeleteFam: (id) sender
{
	[ged removeRecord: currentFam];
	[famDataSource refresh];
	[famTable reloadData];
	[self handleContentChange];
}

- (void) handleSelectFam: (id) sender
{
	FAM* selectedFam;
	
	if ( [famTable selectedRow] == -1 ) {
		return;
	}
	
	selectedFam = [famDataSource famAtIndex: [famTable selectedRow]];
	
	if ( selectedFam ) {
		currentFam = selectedFam;
		[[famDetailPanelController sharedFamDetailPanel] updateWithFam: currentFam];
		[[ImageViewerController sharedViewer] setRecord: currentFam];
		[[RawPanelController sharedRawPanel] setDataField: currentFam];
		[[eventViewerController sharedEventPanel] updateWithRecord: currentFam];
		[[NoteViewerController sharedViewer] setField: currentFam];
	}
}

- (void) handleFilterFamilies: (id) sender
{
	[famDataSource filterWithString: [famSearchField stringValue]];
	[famTable reloadData];
	[famMessageText setStringValue: [NSString stringWithFormat: @"%@ of %@ families", [[NSNumber numberWithInteger: [famDataSource numberDisplayed]] stringValue], [[NSNumber numberWithInteger: [famDataSource numberTotal]] stringValue]]];
}

- (void) handleAddSource: (id) sender
{
	NSString* label;
	GCField* new;
	
	label = [NSString stringWithFormat: @"@SOUR_%@@",
			 [[NSNumber numberWithDouble: floor( [[NSDate date] timeIntervalSince1970] )] stringValue]];
	
	while ( [ged recordWithLabel: label] ) {	
		label = [NSString stringWithFormat: @"@SOUR_%@@",
				 [[NSNumber numberWithDouble: floor( [[NSDate date] timeIntervalSince1970] )] stringValue]];
	}
	
	new = [[[GCField alloc] init: 0 : @"SOUR" : label] autorelease];
	
	new = [ged addRecord: new];
	[sourceDataSource refresh];
	//	[famTable reloadData];
	[sourceDataSource selectSource: new];
	[self handleContentChange];
}

- (void) handleDeleteSource: (id) sender
{
	[ged removeRecord: [sourceDataSource selectedSource]];
	[sourceDataSource refresh];
	//	[famTable reloadData];
	[self handleContentChange];
}

- (void) handleFilterSources: (id) sender
{
}

- (void) handleMergeFile:(id) sender
{
	NSOpenPanel* open;
	NSArray *fileTypes = [NSArray arrayWithObject:@"ged"];
	
	// present a standard open dialog for merging 2 GEDCOM files
	open = [NSOpenPanel openPanel];
	[open setAllowsMultipleSelection:false];
	[open beginSheetForDirectory:NSHomeDirectory()
							file:nil  types:fileTypes
				  modalForWindow: mainWindow modalDelegate: self
				  didEndSelector: @selector(doMerge:returnCode:contextInfo:) contextInfo: nil];
}

- (void)doMerge:(NSOpenPanel *)sheet
	 returnCode:(NSInteger)returnCode
	contextInfo:(void  *)contextInfo
{
	[sheet orderOut: nil];
	
	// if the user selected a file and clicked "Open"
	// attempt to merge the file into the database
	if (returnCode == NSOKButton) {
		NSArray *filesToOpen = [sheet filenames];
		GCFile* file_to_merge =
		[[[GCFile alloc] initWithFile: [filesToOpen objectAtIndex: 0]] autorelease];
		
		[[MergeController sharedMerge] doMerge: ged: file_to_merge: self];
	}
}

#pragma mark -
#pragma mark Reporting methods

- (void) handleDescendantsGEDCOM:(id) sender
{
	NSSavePanel* save = [NSSavePanel savePanel];
	[save setRequiredFileType: @"ged"];
	[save beginSheetForDirectory: [@"~/Documents/" stringByExpandingTildeInPath]
							file: nil
				  modalForWindow: mainWindow
				   modalDelegate: self
				  didEndSelector: @selector(doDescendantsGEDCOM:returnCode:contextInfo:)
					 contextInfo: nil];
}

- (void)doDescendantsGEDCOM:(NSOpenPanel *)sheet
				 returnCode:(NSInteger)returnCode
				contextInfo:(void  *)contextInfo
{
	NSError *error;
	if (returnCode == NSOKButton) {
		NSMutableString* result = [NSMutableString stringWithCapacity:1];
		GCField* tmp;
		id root = nil;
		if ( currentFam ) {
			if ( !( root = [currentFam husband: ged] )) {
				root = [currentFam wife: ged];
			}
			
			if (root) {
				if ( (tmp = [ged recordWithLabel: @"HEAD"]) ) {
					[result setString: [tmp dataForFile]];
				}
				if ( (tmp = [ged recordWithLabel: [[ged recordWithLabel: @"HEAD"] valueOfSubfieldWithType: @"SUBM"]]) ) {
					[result appendString: [tmp dataForFile]];
				}
				[result appendString: [root descendantsGEDCOM: ged]]; 
				[result appendString: @"0 TRLR\n"];
			}
			[result writeToFile: [sheet filename] atomically: true encoding:NSUTF8StringEncoding error:&error];
		}
	}
}

- (void) handleAncestorsGEDCOM:(id) sender
{
	NSSavePanel* save = [NSSavePanel savePanel];
	[save setRequiredFileType: @"ged"];
	[save beginSheetForDirectory: [@"~/Documents/" stringByExpandingTildeInPath]
							file: nil
				  modalForWindow: mainWindow
				   modalDelegate: self
				  didEndSelector: @selector(doAncestorsGEDCOM:returnCode:contextInfo:)
					 contextInfo: nil];
}

- (void)doAncestorsGEDCOM:(NSOpenPanel *)sheet
			   returnCode:(NSInteger)returnCode
			  contextInfo:(void  *)contextInfo
{
	NSError *error;
	if (returnCode == NSOKButton) {
		NSMutableString* result = [NSMutableString stringWithCapacity:1];
		GCField* tmp;
		id root = nil;
		if ( currentIndi ) {
			root = currentIndi;
		} else if ( currentFam ) {
			if ( !( root = [currentFam husband: ged] )) {
				root = [currentFam wife: ged];
			}
		}
		
		if ( root ) {
			if ( (tmp = [ged recordWithLabel: @"HEAD"]) ) {
				[result setString: [tmp dataForFile]];
			}
			if ( (tmp = [ged recordWithLabel: [[ged recordWithLabel: @"HEAD"] valueOfSubfieldWithType: @"SUBM"]]) ) {
				[result appendString: [tmp dataForFile]];
			}
			
			[result appendString: [root ancestorsGEDCOM: ged]]; 
			[result appendString: @"0 TRLR\n"];
		}
		
		[result writeToFile: [sheet filename] atomically: true encoding:NSUTF8StringEncoding error:&error];
	}
}

- (void) handleDescendantReport:(id) sender
{
	NSSavePanel* save = [NSSavePanel savePanel];
	[save setRequiredFileType: @"txt"];
	[save beginSheetForDirectory: [@"~/Documents/" stringByExpandingTildeInPath]
							file: nil
				  modalForWindow: mainWindow
				   modalDelegate: self
				  didEndSelector: @selector(doDescendantReport:returnCode:contextInfo:)
					 contextInfo: nil];
}

- (void)doDescendantReport:(NSOpenPanel *)sheet
				returnCode:(NSInteger)returnCode
			   contextInfo:(void  *)contextInfo
{
	NSError *error;
	if (returnCode == NSOKButton) {
		NSMutableString* result = [NSMutableString stringWithCapacity:1];
		id root = nil;
		if ( currentIndi ) {
			root = currentIndi;
		} else if ( currentFam ) {
			if ( !( root = [currentFam husband: ged] )) {
				root = [currentFam wife: ged];
			}
		}
		
		
		if ( root ) {
			[result setString: @"GenerationX: "];
			[result appendString: [[NSDate date] description]];
			[result appendString: @"\n"];
			[result appendString: @"Descendants of "];
			[result appendString: [root fullName]];
			[result appendString: @"\n\n"];
			[result appendString: [root descendantReportText: ged: 0]]; 
		}
		
		if ( [result writeToFile: [sheet filename] atomically: true encoding:NSUTF8StringEncoding error:&error] ) {
			[[NSWorkspace sharedWorkspace] openFile: [sheet filename]];
		}
	}
}

- (void) handleAncestorsReport:(id) sender
{
	NSSavePanel* save = [NSSavePanel savePanel];
	[save setRequiredFileType: @"txt"];
	[save beginSheetForDirectory: [@"~/Documents/" stringByExpandingTildeInPath]
							file: nil
				  modalForWindow: mainWindow
				   modalDelegate: self
				  didEndSelector: @selector(doAncestorsReport:returnCode:contextInfo:)
					 contextInfo: nil];
}

- (void)doAncestorsReport:(NSOpenPanel *)sheet
			   returnCode:(NSInteger)returnCode
			  contextInfo:(void  *)contextInfo
{
	NSError *error;
	if (returnCode == NSOKButton) {
		NSMutableString* result = [NSMutableString stringWithCapacity:1];
		id root = nil;
		if ( currentFam ) {
			if ( !( root = [currentFam husband: ged] )) {
				root = [currentFam wife: ged];
			}
			
			if ( root ) {
				[result setString: @"GenerationX: "];
				[result appendString: [[NSDate date] description]];
				[result appendString: @"\n"];
				[result appendString: @"Ancestors of "];
				[result appendString: [root fullName]];
				[result appendString: @"\n\n"];
				[result appendString: [root ancestorsReportText: ged: @""]]; 
			}
			
			if ( [result writeToFile: [sheet filename] atomically: true encoding:NSUTF8StringEncoding error:&error] ) {
				[[NSWorkspace sharedWorkspace] openFile: [sheet filename]];
			}
		}
	}
}

- (void) handleAllHTML:(id) sender
{
	NSOpenPanel* open;
	
	// present a standard open dialog for merging 2 GEDCOM files
	open = [NSOpenPanel openPanel];
	[open setAllowsMultipleSelection:false];
	[open setCanChooseDirectories:true];
	[open setCanChooseFiles:false];
	[open setPrompt: @"Choose"];
	[open beginSheetForDirectory:NSHomeDirectory()
							file:nil  types:nil
				  modalForWindow: mainWindow modalDelegate: self
				  didEndSelector: @selector(doAllHTML:returnCode:contextInfo:) contextInfo: nil];
}

- (void) doAllHTML:(NSOpenPanel *)sheet
		returnCode:(NSInteger)returnCode
	   contextInfo:(void  *)contextInfo
{
	// order the sheet out before we put up the progress dialog
	[sheet orderOut: nil];
	
	// if the user selected a file and clicked "Open"
	// export to the selected directory
	if (returnCode == NSOKButton) {
		[[HTMLController sharedHTML] setGED: ged];
		if ( ![[HTMLController sharedHTML] exportHTML: [sheet directory]] ) {
			NSBeginAlertSheet( nil, @"OK", nil,
							  nil, mainWindow, self, nil, nil, nil,
							  @"The export did not complete successfully." );
		}
	}
}

@end
