//  FamListController.m
//  GenerationX
//
//  Created by Benjamin Chartier on September 17 2002.

#import "FamListController.h"

@implementation FamListController

// Selection notification
- (void) notifySelection
{
  int						rowIndex;
  NSNotificationCenter*		appNotificationCenter;
  
  // Update the selected info
  rowIndex = [famList selectedRow];
  [self setSelection: [dataSource famAtIndex: rowIndex]];
    
  // Send a notification to the notification center
  appNotificationCenter = [NSNotificationCenter defaultCenter];
  [appNotificationCenter 	postNotificationName: @"GenXFamSelected"
                            object: self];
}

// Action on the filter button
- (IBAction) filterButtonHasBeenClicked:(id)sender
{
  NSMutableString* tmpString = [NSMutableString stringWithString: @""];

  // Update the list data source
  [dataSource setFamFilter: [famFilterTextField stringValue]];
  
  // Refresh the list
  [self reloadData];

  // Display the number of records in the list
  [tmpString setString:
    [[NSNumber numberWithInt: [dataSource numFamDisplayed]] stringValue]];
  [tmpString appendString: @" of "];
  [tmpString appendString:
    [[NSNumber numberWithInt: [dataSource numFamAll]] stringValue]];
  [tmpString appendString: @" FAM records"];
  [famFilterLabel setStringValue: tmpString];
  
  // Selection notification
  [self notifySelection];
}

// Setup drawer GUI
- (void) setupDrawerGui
{
  float		wifeColWidth;
  float		husbandColWidth;
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
  wifeColWidth = [[famList tableColumnWithIdentifier: @"wife"] width];
  husbandColWidth = [[famList tableColumnWithIdentifier: @"husband"] width];
  [[famList tableColumnWithIdentifier: @"wife"] setWidth: (wifeColWidth + husbandColWidth)/2.];
  [[famList tableColumnWithIdentifier: @"husband"] setWidth: (wifeColWidth + husbandColWidth)/2.];

  // Tag
  [famList setTag: 1];
  
  // IndiList delegate
  [famList setDelegate: self];
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
  [famList setDataSource: dataSource];  
}

- (void) reloadData
{
  [famList reloadData];
}

- (void) filterList
{
}

- (void) setFilter
{
}

- (FAM*) selection
{
  FAM*		tempFam;
  
  tempFam = [dataSource famAtIndex: [famList selectedRow]];
  
  [tempFam retain];
  [selectedFam release];
  selectedFam = tempFam;

  return selectedFam;
}

- (void) setSelection: (FAM*)thisFam
{
  [thisFam retain];
  [selectedFam release];
  selectedFam = thisFam;
}

- (void) makeSelectionVisible
{
  int		rowIndex;
  
  rowIndex = [dataSource indexForFam: selectedFam];
  
  // if we fail the first time, the record we're looking for may be filtered out
  // so unfilter it
  if( rowIndex == -1 )
  {
    [dataSource setFamFilter: @""];
    [self reloadData];
    rowIndex = [dataSource indexForFam: selectedFam];
  }
  
  if( rowIndex != -1 )
  {
    [famList selectRow: rowIndex byExtendingSelection: false];
    [famList scrollRowToVisible: rowIndex];
  }
  else
  {
    [famList deselectAll: self];    
  }
}

// famList delegates
//
// NSTableView delegate methods
//
- (BOOL) tableView:(NSTableView *)aTableView
  shouldEditTableColumn:(NSTableColumn *)aTableColumn
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
  [dataSource sortFamsUsingFieldId: [aTableColumn identifier] descending: sortDescending];
  [self reloadData];
  [self makeSelectionVisible];
}

- (NSTableView*) famList
{
  return famList;
}

@end
