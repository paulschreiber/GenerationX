//  IndiListController.h
//  GenerationX
//
//  Created by Benjamin Chartier on August 29 2002.

#import <Cocoa/Cocoa.h>

#import "RecordListDataSource.h"

@interface IndiListController : NSObject
{
  // Outlets
    
    // Main Window
    IBOutlet NSWindow*    	mainWindow;

    // IndiDrawer Outlets
    IBOutlet NSDrawer*    	drawer;
    IBOutlet NSTableView* 	indiList;
    IBOutlet NSButton*    	indiFilterButton;
    IBOutlet NSTextField* 	indiFilterTextField;
    IBOutlet NSTextField* 	indiFilterLabel;

  // DataSource
  RecordListDataSource*		dataSource;
  
  // Sort info
  NSTableColumn*			sortedColumn;
  BOOL						sortDescending;

  // Selection
  INDI*						selectedIndi;
}

// Actions

  // Action on the flter button
  - (IBAction) filterButtonHasBeenClicked:(id)sender;

// Methods

  // Gui
  - (void) setupDrawerGui;
  - (void) showDrawer: (BOOL)show;
  - (void) toggleDrawer;

  // Data source
  - (void) setListDataSource: (RecordListDataSource*)dataSource;
  - (void) reloadData;

  // Filter
  - (void) filterList;
  - (void) setFilter;

  // Selection
  - (INDI*) selection;
  - (void) setSelection: (INDI*)indiRecord;
  - (void) makeSelectionVisible;
  - (NSTableView*) indiList;

@end
