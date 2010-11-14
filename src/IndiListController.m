//  IndiListController.h
//  GenerationX
//
//  Created by Benjamin Chartier on August 29 2002.

#import "IndiListController.h"

@implementation IndiListController

// Selection notification
- (void) notifySelection
{
  int						rowIndex;
  NSNotificationCenter*		appNotificationCenter;

  // Update the selected info
  rowIndex = [indiList selectedRow];
  if( rowIndex > -1 )
    [self setSelection: [dataSource indiAtIndex: rowIndex]];
  else
    [self setSelection: nil ];

  // Send a notification to the notification center
  appNotificationCenter = [NSNotificationCenter defaultCenter];
  [appNotificationCenter 	postNotificationName: @"GenXIndiSelected"
                            object: self];
}

// Action on the filter button
- (IBAction) filterButtonHasBeenClicked:(id)sender
{
  NSMutableString* tmpString = [NSMutableString stringWithString: @""];

  // Update the list data source
  [dataSource setIndiFilter: [indiFilterTextField stringValue]];
  [dataSource sortIndisUsingFieldId: [sortedColumn identifier] descending: sortDescending];

  // Refresh the list
  [self reloadData];

  // Display the number of records in the list
  [tmpString setString:
    [[NSNumber numberWithInt: [dataSource numIndiDisplayed]] stringValue]];
  [tmpString appendString: @" of "];
  [tmpString appendString:
    [[NSNumber numberWithInt: [dataSource numIndiAll]] stringValue]];
  [tmpString appendString: @" INDI records"];
  [indiFilterLabel setStringValue: tmpString];

  // Selection notification
  [self notifySelection];
}

// Setup drawer GUI
- (void) setupDrawerGui
{
  float		surnameColWidth;
  float		givenNameColWidth;
  NSSize		drawerSize;

  // Drawer
  [drawer setParentWindow: mainWindow];
  [drawer setPreferredEdge: NSMinXEdge];
  [drawer openOnEdge: NSMinXEdge];
  
  // Initial size
  drawerSize = [drawer contentSize];
  drawerSize.width = 250;
  [drawer setContentSize: drawerSize];
  
  // Column size
  surnameColWidth = [[indiList tableColumnWithIdentifier: @"surname"] width];
  givenNameColWidth = [[indiList tableColumnWithIdentifier: @"givenName"] width];
  [[indiList tableColumnWithIdentifier: @"surname"] setWidth: (surnameColWidth + givenNameColWidth)/2.];
  [[indiList tableColumnWithIdentifier: @"givenName"] setWidth: (surnameColWidth + givenNameColWidth)/2.];

  // Tag
  [indiList setTag: 0];
  
  // IndiList delegate
  [indiList setDelegate: self];
}

// Show or hide drawer
- (void) showDrawer: (BOOL)show
{
  if( show )
    [drawer open];  
  else
    [drawer close];  
}

// Toggle drawer
- (void) toggleDrawer
{
  int state = [drawer state];
  
  if( state == NSDrawerOpenState )
    [drawer close];
  else
    [drawer openOnEdge: NSMinXEdge];
}

// Set the tableview datasource
- (void) setListDataSource: (RecordListDataSource*)thisDataSource
{
  [thisDataSource retain];
  [dataSource release];
  dataSource = thisDataSource;
  
  sortDescending = NO;
  
  [dataSource setSort: sortDescending];
  [indiList setDataSource: dataSource];  
}

- (void) reloadData
{
  [indiList reloadData];
}

- (void) filterList
{
}

- (void) setFilter
{
}

- (INDI*) selection
{
  INDI*		tempIndi;
  
  if( [indiList selectedRow] > -1 )
    tempIndi = [dataSource indiAtIndex: [indiList selectedRow]];
  else
    tempIndi = nil;
  
  [tempIndi retain];
  [selectedIndi release];
  selectedIndi = tempIndi;

  return selectedIndi;
}

- (void) setSelection: (INDI*)thisIndi
{
  [thisIndi retain];
  [selectedIndi release];
  selectedIndi = thisIndi;
  
  [self makeSelectionVisible];
}

- (void) makeSelectionVisible
{
  int		rowIndex;
  
  rowIndex = [dataSource indexForIndi: selectedIndi];

  // if we fail the first time, the record we're looking for may be filtered out
  // so unfilter it
  if( rowIndex == -1 )
  {
    [dataSource setIndiFilter: @""];
    [self reloadData];
    rowIndex = [dataSource indexForIndi: selectedIndi];
  }
  
  if( rowIndex != -1 )
  {
    [indiList selectRow: rowIndex byExtendingSelection: false];
    [indiList scrollRowToVisible: rowIndex];
  }
  else
  {
    [indiList deselectAll: self];    
  }
}

// IndiList delegates
//
// NSTableView delegate methods
//
- (BOOL) tableView: (NSTableView *)aTableView
  shouldEditTableColumn: (NSTableColumn *)aTableColumn
  row:(int)rowIndex
{
  return false;
}

- (void) tableViewSelectionDidChange:(NSNotification *)notification
{
  [self notifySelection];
}

- (void) tableView: (NSTableView *)aTableView
  didClickTableColumn: (NSTableColumn *)aTableColumn
{
  // Same column
  if( sortedColumn == aTableColumn )
  {
    // Invert sort order
    sortDescending = !sortDescending;
  }
  // Another column
  else
  {
    sortDescending = NO;
    if( sortedColumn )
    {
      [aTableView setIndicatorImage: nil inTableColumn: sortedColumn];
      [sortedColumn release];
    }
    
    sortedColumn = [aTableColumn retain];
    [aTableView setHighlightedTableColumn: aTableColumn];
  }
  
  // Set appearance of selected column
  [aTableView setIndicatorImage:
    (sortDescending ?
      [NSTableView _defaultTableHeaderReverseSortImage] :
      [NSTableView _defaultTableHeaderSortImage] )
    inTableColumn: aTableColumn];

  // Sort indis
  [dataSource sortIndisUsingFieldId: [aTableColumn identifier] descending: sortDescending];
  [self reloadData];
  [self makeSelectionVisible];
}

- (NSTableView*) indiList
{
  return indiList;
}

@end
