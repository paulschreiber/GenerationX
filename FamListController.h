//  FamListController.h
//  GenerationX
//
//  Created by Benjamin Chartier on September 17 2002.

#import <Cocoa/Cocoa.h>

#import "RecordListDataSource.h"

@interface FamListController : NSObject
{
  // Outlets
  
    // Main Window
    IBOutlet NSWindow*    	mainWindow;

    // FamDrawer Outlets
    IBOutlet NSDrawer*    	drawer;
    IBOutlet NSTableView* 	famList;
    IBOutlet NSButton*    	famFilterButton;
    IBOutlet NSTextField* 	famFilterTextField;
    IBOutlet NSTextField* 	famFilterLabel;


  // DataSource
  RecordListDataSource*		dataSource;

  // Sort info
  NSTableColumn*			sortedColumn;
  BOOL						sortDescending;

  // Selection
  FAM*						selectedFam;
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
  - (FAM*) selection;
  - (void) setSelection: (FAM*)indiRecord;
  - (void) makeSelectionVisible;
  - (NSTableView*) famList;

@end
