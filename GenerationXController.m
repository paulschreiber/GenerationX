#import "GenerationXController.h"
#import "RawPanelController.h"
#import "IndiViewController.h"
#import "EditIndiController.h"
#import "AddMarriageController.h"
#import "EventWithFAMCController.h"
#import "GenericEventController.h"
#import "NoteController.h"
#import "DescendantOutlineData.h"
#import "MergeController.h"
#import "HTMLController.h"
#import "ImageViewerController.h"
#import "NoteViewerController.h"
#import "FileStatsController.h"
#import "INDI.h"
#import "FAM.h"
#import "AboutBox.h"

#import "math.h"

@implementation GenerationXController

+ (void)initialize {
    NSMutableDictionary *defaultValues = [NSMutableDictionary dictionary];
    [defaultValues setObject: [NSNumber numberWithBool: true] forKey:@"showJaguarWarning"];
    [[NSUserDefaults standardUserDefaults] registerDefaults:defaultValues];
}

// Set up  auto-save
- (void)setupAutosave
{
  int minutes;

  minutes = [[PreferencesController sharedPrefs] autoSave];
  if( minutes > 0 )
  {
    autoSaveTimer = [NSTimer scheduledTimerWithTimeInterval: ( minutes * 60 )
                       target: self
                       selector: @selector(handleSaveFile:)
                       userInfo: nil repeats: true];
  }
}

// Set up GUI
//
// This method is called from applicationDidFinishLaunching
- (void)setupGUI
{
  NSTableColumn *tableColumn = nil;
  NSButtonCell*  buttonCell1 = [[[NSButtonCell alloc] initTextCell: @""] autorelease];
  NSButtonCell*  buttonCell2 = [[[NSButtonCell alloc] initTextCell: @""] autorelease];
  NSButtonCell*  buttonCell3 = [[[NSButtonCell alloc] initTextCell: @""] autorelease];

  // start up in indi view mode
  [main_tabs selectTabViewItemAtIndex: 0];
  
  // Setup the indi drawer
  [indiListController setupDrawerGui];
  
  // Setup the fam drawer
  [famListController setupDrawerGui];
  [famListController showDrawer: NO];

  // Setup the event drawer
  [event_list setTag: 2];
  [event_list setDelegate: self];
  [event_drawer setParentWindow: main_window];
  [event_drawer setPreferredEdge: NSMaxXEdge];

  [event_list setNextResponder: self];
  [[famListController famList] setNextResponder: self];
  [[indiListController indiList] setNextResponder: self];

  // Setup the toolbar
  [self setupToolbar];
//  [indi_image setContinuous: false];
//  [indi_image sendActionOn: NSLeftMouseUp];

  // Setup the menubar
  [indi_event_menu setEnabled: true];
  [fam_event_menu setEnabled: false];
    
//  [ped_father setTarget: self];
//  [ped_father sendActionOn: NSLeftMouseUp];
//  [ped_father setAction: @selector(handlePedigreeClick:)];

//  [indi_spice_outline setIndentationPerLevel: 10];
//  [buttonCell1 setControlSize: NSSmallControlSize];
  [buttonCell1 setTitle: @"Go"];
  [buttonCell1 setEditable: NO];
  [buttonCell1 setBezelStyle: NSShadowlessSquareBezelStyle];
  [buttonCell1 setImagePosition: NSNoImage];
  [buttonCell1 setTarget: self];
  [buttonCell1 setAction: @selector( handleGoToSpouseOrChild: )];  
  tableColumn = [indi_spice_outline tableColumnWithIdentifier: @"GO"];
  [tableColumn setDataCell:buttonCell1];

//  [indi_spice_outline setIndentationPerLevel: 10];
//  [buttonCell2 setControlSize: NSSmallControlSize];
  [buttonCell2 setTitle: @"Go"];
  [buttonCell2 setEditable: NO];
  [buttonCell2 setBezelStyle: NSShadowlessSquareBezelStyle];
  [buttonCell2 setImagePosition: NSNoImage];
  [buttonCell2 setTarget: self];
  [buttonCell2 setAction: @selector( handleGoToSpouseOrChild: )];  
  tableColumn = [dec_outline tableColumnWithIdentifier: @"GO"];
  [tableColumn setDataCell:buttonCell2];

//  [indi_spice_outline setIndentationPerLevel: 10];
//  [buttonCell2 setControlSize: NSSmallControlSize];
  [buttonCell3 setTitle: @"Go"];
  [buttonCell3 setEditable: NO];
  [buttonCell3 setBezelStyle: NSShadowlessSquareBezelStyle];
  [buttonCell3 setImagePosition: NSNoImage];
  [buttonCell3 setTarget: self];
  [buttonCell3 setAction: @selector( handleFamGoToChild: )];  
  tableColumn = [fam_child_table tableColumnWithIdentifier: @"GO"];
  [tableColumn setDataCell:buttonCell3];
}

- (void) updateIndiViewWithIndi: (INDI*)thisIndi
{
  GCField* gc_tmp;
  NSImage* image = [NSImage alloc];
  NSString* tmp;

  [indi_name setStringValue: [thisIndi fullName]];
//  [indi_info setStringValue: [thisIndi textSummary: ged]];
  if( tmp = [[thisIndi birthDate] description] )
    [indi_born_text setStringValue: [NSString stringWithFormat: @"Born:\t\t%@", tmp]];
  if( tmp = [[thisIndi deathDate] description] )
    [indi_died_text setStringValue: [NSString stringWithFormat: @"Died:\t\t%@", tmp]];
  if( [thisIndi father: ged] )
    [indi_father_text setStringValue: [NSString stringWithFormat: @"Father:\t%@", [[thisIndi father: ged] fullName]]];
  else
    [indi_father_text setStringValue: @"Father: Unknown"];
  if( [thisIndi mother: ged] )
    [indi_mother_text setStringValue: [NSString stringWithFormat: @"Mother:\t%@", [[thisIndi mother: ged] fullName]]];
  else
    [indi_mother_text setStringValue: @"Mother: Unknown"];
  
  [indi_spice_outline setDataSource: self];
  [indi_spice_outline reloadData];

// BCH
  // images stuff
  [[ImageViewerController sharedViewer] setRecord: thisIndi];
// BCH
  // note viewer stuff
  [[NoteViewerController sharedViewer] setField: thisIndi];

  if( gc_tmp = [thisIndi subfieldWithType: @"OBJE"] )
  {
    [indi_image setImage:
      [image initWithContentsOfFile:
        [gc_tmp valueOfSubfieldWithType: @"FILE"]]];
  }
  else
    [indi_image setImage: nil];
}

- (void) updateFamViewWithFam: (FAM*)thisFam
{
  GCField* gc_tmp;
  NSImage* image = [NSImage alloc];
  NSString* tmp;

  if( [thisFam husband: ged] )
    [fam_husb_text setStringValue: [NSString stringWithFormat: @"Husband: %@", [[thisFam husband: ged] fullName]]];
  else
    [fam_husb_text setStringValue: @"Husband: Unknown"];
    
  if( [thisFam wife: ged] )
    [fam_wife_text setStringValue: [NSString stringWithFormat: @"Wife: %@", [[thisFam wife: ged] fullName]]];
  else
    [fam_wife_text setStringValue: @"Wife: Unknown"];
    
  if( tmp = [[thisFam subfieldWithType: @"MARR"] valueOfSubfieldWithType: @"DATE"] )
    [fam_marr_text setStringValue: [NSString stringWithFormat: @"Married: %@", tmp]];
  [fam_info setStringValue: [thisFam textSummary: ged]];

  [fam_child_table setDataSource: self];
  [fam_child_table reloadData];

// BCH  
  // images stuff
  [[ImageViewerController sharedViewer] setRecord: thisFam];
// BCH  
  // note viewer stuff
  [[NoteViewerController sharedViewer] setField: thisFam];
  
  if( gc_tmp = [thisFam subfieldWithType: @"OBJE"] )
  {
    [fam_image setImage:
      [image initWithContentsOfFile:
        [gc_tmp valueOfSubfieldWithType: @"FILE"]]];
  }
  else
    [fam_image setImage: nil];
}

- (void) updatePedigreeViewWithIndi: (INDI*)thisIndi
{
  INDI* tmp_indi;
  NSMutableString* tmp = [[NSMutableString alloc] init];

    [ped_root setStringValue: @""];
    [ped_father setStringValue: @""];
    [ped_pgf setStringValue: @""];
    [ped_pgm setStringValue: @""];
    [ped_ppgf setStringValue: @""];
    [ped_ppgm setStringValue: @""];
    [ped_pmgf setStringValue: @""];
    [ped_pmgm setStringValue: @""];
    [ped_mother setStringValue: @""];
    [ped_mgf setStringValue: @""];
    [ped_mgm setStringValue: @""];
    [ped_mpgf setStringValue: @""];
    [ped_mpgm setStringValue: @""];
    [ped_mmgf setStringValue: @""];
    [ped_mmgm setStringValue: @""];
    
    [tmp setString: [thisIndi fullName]];
    [tmp appendString: @"\n"];
    [tmp appendString: [thisIndi lifespan]];
    [ped_root setStringValue: tmp];
  
    if( tmp_indi = [thisIndi father: ged] )
    {
      [tmp setString: [tmp_indi fullName]];
      [tmp appendString: @"\n"];
      [tmp appendString: [tmp_indi lifespan]];
      [ped_father setStringValue: tmp];
    }
    if( tmp_indi = [[thisIndi father: ged] father: ged] )
    {
      [tmp setString: [tmp_indi fullName]];
      [tmp appendString: @"\n"];
      [tmp appendString: [tmp_indi lifespan]];
      [ped_pgf setStringValue: tmp];
    }
    if( tmp_indi = [[[thisIndi father: ged] father: ged] father: ged] )
    {
      [tmp setString: [tmp_indi fullName]];
      [tmp appendString: @"\n"];
      [tmp appendString: [tmp_indi lifespan]];
      [ped_ppgf setStringValue: tmp];
    }
    if( tmp_indi = [[[thisIndi father: ged] father: ged] mother: ged] )
    {
      [tmp setString: [tmp_indi fullName]];
      [tmp appendString: @"\n"];
      [tmp appendString: [tmp_indi lifespan]];
      [ped_ppgm setStringValue: tmp];
    }
    if( tmp_indi = [[thisIndi father: ged] mother: ged] )
    {
      [tmp setString: [tmp_indi fullName]];
      [tmp appendString: @"\n"];
      [tmp appendString: [tmp_indi lifespan]];
      [ped_pgm setStringValue: tmp];
    }
    if( tmp_indi = [[[thisIndi father: ged] mother: ged] father: ged] )
    {
      [tmp setString: [tmp_indi fullName]];
      [tmp appendString: @"\n"];
      [tmp appendString: [tmp_indi lifespan]];
      [ped_pmgf setStringValue: tmp];
    }
    if( tmp_indi = [[[thisIndi father: ged] mother: ged] mother: ged] )
    {
      [tmp setString: [tmp_indi fullName]];
      [tmp appendString: @"\n"];
      [tmp appendString: [tmp_indi lifespan]];
      [ped_pmgm setStringValue: tmp];
    }
    if( tmp_indi = [thisIndi mother: ged] )
    {
      [tmp setString: [tmp_indi fullName]];
      [tmp appendString: @"\n"];
      [tmp appendString: [tmp_indi lifespan]];
      [ped_mother setStringValue: tmp];
    }
    if( tmp_indi = [[thisIndi mother: ged] father: ged] )
    {
      [tmp setString: [tmp_indi fullName]];
      [tmp appendString: @"\n"];
      [tmp appendString: [tmp_indi lifespan]];
      [ped_mgf setStringValue: tmp];
    }
    if( tmp_indi = [[[thisIndi mother: ged] father: ged] father: ged] )
    {
      [tmp setString: [tmp_indi fullName]];
      [tmp appendString: @"\n"];
      [tmp appendString: [tmp_indi lifespan]];
      [ped_mpgf setStringValue: tmp];
    }
    if( tmp_indi = [[[thisIndi mother: ged] father: ged] mother: ged] )
    {
      [tmp setString: [tmp_indi fullName]];
      [tmp appendString: @"\n"];
      [tmp appendString: [tmp_indi lifespan]];
      [ped_mpgm setStringValue: tmp];
    }
    if( tmp_indi = [[thisIndi mother: ged] mother: ged] )
    {
      [tmp setString: [tmp_indi fullName]];
      [tmp appendString: @"\n"];
      [tmp appendString: [tmp_indi lifespan]];
      [ped_mgm setStringValue: tmp];
    }
    if( tmp_indi = [[[thisIndi mother: ged] mother: ged] father: ged] )
    {
      [tmp setString: [tmp_indi fullName]];
      [tmp appendString: @"\n"];
      [tmp appendString: [tmp_indi lifespan]];
      [ped_mmgf setStringValue: tmp];
    }
    if( tmp_indi = [[[thisIndi mother: ged] mother: ged] mother: ged] )
    {
      [tmp setString: [tmp_indi fullName]];
      [tmp appendString: @"\n"];
      [tmp appendString: [tmp_indi lifespan]];
      [ped_mmgm setStringValue: tmp];
    }
    
}

- (void) updateDescendantsViewWithIndi: (INDI*)thisIndi
{
    [dec_name setStringValue:
      [@"Descendants of " stringByAppendingString: [thisIndi fullName]]];
    [[DescendantOutlineData sharedDescendant] setData: thisIndi: ged];
    [dec_outline setDataSource: [DescendantOutlineData sharedDescendant]];
    [dec_outline reloadData];
}

// Load data file
- (void)loadDataFile
{
  NSString* data_file;

  // try and load a default data file
  data_file = [[PreferencesController sharedPrefs] defaultFile];
  if( [NSFileHandle fileHandleForReadingAtPath: data_file] )
  {
    ged = [[GCFile alloc] initWithFile: data_file];

//PMH Determine lastnames of the entries not having one if applicable
    if( [[PreferencesController sharedPrefs] guessLastNames] ) {
      //We have; GCFile* ged, nothing more so ask it to do the job
      [ged completeLastnames]; 
    }
// pmh
  }
  else
    // if it didn't load ask the user to specify a file
    [self doOpenFile];

/*BCH What for?  if( [[PreferencesController sharedPrefs] sortRecords] )
    [ged sortData];*/
}

// Set up data source
- (void)setupDataSource
{
  [recordListDataSource release];
  recordListDataSource = [[RecordListDataSource alloc] initWithGED: ged];
  [indiListController setListDataSource: recordListDataSource];
  [famListController setListDataSource: recordListDataSource];

  [indi_spice_outline setDataSource: self];
  [fam_child_table setDataSource: self];
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
  NSNotificationCenter*		appNotificationCenter;
  indi_history = [[NSMutableArray alloc] init];

  if (floor(NSAppKitVersionNumber) <= NSAppKitVersionNumber10_0)
  {  //User is using Mac OS X 10.0.x or earlier
    NSRunAlertPanel( @"Error",
      @"This version of GenerationX requires Mac OS X 10.2 Jaguar. The application will now terminate.",
      @"Ok", nil, nil );
    [NSApp terminate: self];
  }
  else if (floor(NSAppKitVersionNumber) <= 620)
  { // User is using Mac OS X 10.1.x
    NSRunAlertPanel( @"Error",
      @"This version of GenerationX requires Mac OS X 10.2 Jaguar. The application will now terminate.",
      @"Ok", nil, nil );
    [NSApp terminate: self];
  }
  else if (floor(NSAppKitVersionNumber) < 743 && [[NSUserDefaults standardUserDefaults] boolForKey: @"showJaguarWarning"])
  { // User is using Mac OS X 10.3.x
    int button = 
      NSRunAlertPanel( @"Warning",
      @"This version of GenX is developed and tested on Mac OS X 10.3 Panther. Performance under previous versions of Mac OS X may be unpredicatable.",
      @"Continue", @"Don't show again", @"Quit now" );
          
    if( button == 0 )
    {
      [[NSUserDefaults standardUserDefaults] setObject: [NSNumber numberWithBool: false] forKey: @"showOSWarning"];
    }
    else if( button == -1 )
      [NSApp terminate: self];
  }
  
  // Register the current object as an observer
  appNotificationCenter = [NSNotificationCenter defaultCenter];
  [appNotificationCenter 	addObserver: self
                            selector: @selector( handleIndiSelectionChanged: )
                            name: @"GenXIndiSelected"
                            object: nil];
  [appNotificationCenter 	addObserver: self
                            selector: @selector( handleFamSelectionChanged: )
                            name: @"GenXFamSelected"
                            object: nil];
  [appNotificationCenter 	addObserver: self
                            selector: @selector( handleNoteAddition: )
                            name: @"GenXNoteAdded"
                            object: nil];
  [appNotificationCenter 	addObserver: self
                            selector: @selector( handleNoteAddition: )
                            name: @"GenXContentChange"
                            object: nil];

  // Set up auto-save
  [self setupAutosave];
  
  // Load data
  [self loadDataFile];
  
  // Set up GUI
  [self setupGUI];
  
  // Set up data source
  [self setupDataSource];
  
  // Init selection
  [self handleIndiSelectionChanged: nil];
}

- (NSApplicationTerminateReply)applicationShouldTerminate:(NSApplication *)sender
{
  NSNotificationCenter*		appNotificationCenter;

  // Unregister the current object as an observer
  appNotificationCenter = [NSNotificationCenter defaultCenter];
  [appNotificationCenter 	removeObserver: self];

  if( [ged needSave] )
  {
    // ask if we should save the data to file
    NSBeginAlertSheet( nil, @"Yes", @"No",
      nil, main_window, self, @selector(saveSheetDidEnd:::), nil, @"saveBeforeQuit",
      @"Save changes before quitting?" );
      return NSTerminateLater;
  }
  
//  [prefs savePrefs];
  return true;
}

- (void) saveSheetDidEnd: (NSWindow*) sheet: (int) returnCode: (NSString*) contextInfo
{
  // if the user clicked "yes" save the data to file
  if( returnCode == NSAlertDefaultReturn )
    if( [ged path] )
      [ged saveToFile];
    // if no file has bee specified for this database yet
    // present a standard save dialog
    else
    {
      NSSavePanel* save = [NSSavePanel savePanel];
      [sheet orderOut: self];
      [save setTitle: @"Save GEDCOM file to:"];
      [save setRequiredFileType: @"ged"];
      [save beginSheetForDirectory: [@"~/Documents/" stringByExpandingTildeInPath]
            file: nil
            modalForWindow: main_window
            modalDelegate: self
            didEndSelector: @selector(savePanelDidEnd:returnCode:contextInfo:)
            contextInfo: contextInfo];
      return;
    }

  // the contextInfo helps us decide what to do next
  // since there are several situations we could be in
  if( [contextInfo isEqual: @"newFile"] )
  {
    [sheet orderOut: self];
    [self doNewFile];
  }
  else if( [contextInfo isEqual: @"openFile"] )
  {
    [sheet orderOut: self];
    [self doOpenFile];
  }
  else if( [contextInfo isEqual: @"saveBeforeQuit"] )
  {
//    [prefs savePrefs];
    [NSApp replyToApplicationShouldTerminate: true];
  }
}

// Accessors
- (NSWindow*) mainWindow
{
  return main_window;
}

- (GCFile*) gedFile
{
  return ged;
}

- (GCField*) currentRecord
{
  return current_record;
}

- (GCField*) currentEvent
{
  return current_event;
}

// Refresh GUI
//
// This method is called when the content of the ged file is updated :
// when a record is added, modified or deleted
//
// Steps :
//	- sort data inside ged object
//	- refresh data source
//	- refresh lists
//	- update GUI from selection
- (void) refreshGUI
{
/*BCH What for ? The records are sorted in the recordListDataSource
  if( [[PreferencesController sharedPrefs] sortRecords] )
    [ged sortData];*/
      
  if( ! [[[main_tabs selectedTabViewItem] identifier] isEqual: @"FAM"] )
  {
    [recordListDataSource refreshIndis];
    [self handleIndiSelectionChanged: nil];
    [indiListController reloadData];
  }
  else
  {
    [recordListDataSource refreshFams];
    [self handleFamSelectionChanged: nil];
    [famListController reloadData];
  }

  [event_list reloadData];
}

// Handle changes in the indi selection
- (void)handleIndiSelectionChanged:(NSNotification *)aNotification
{
  id		notificationSender = [aNotification object];
  INDI*		selectedIndi = [indiListController selection];

  if( selectedIndi )
  {
    // Current indi and event
    current_record = selectedIndi;
    current_event = nil;

    if( [indi_history count] == 20 )
      [indi_history removeObjectAtIndex: 0];
    if( [[current_record class] isEqual: NSClassFromString( @"INDI" )]
     && ![[indi_history lastObject] isEqual: current_record] )
      [indi_history addObject: current_record];

    if( [[PreferencesController sharedPrefs] sortEvents] )
      [current_record sortEvents];
    [event_list setDataSource: current_record];

    // Indi list
    if( notificationSender != indiListController )
    {
      [indiListController setSelection: selectedIndi];
    }

    // INDI View Mode
    [self updateIndiViewWithIndi: selectedIndi];
        
    // PED view mode
    [self updatePedigreeViewWithIndi: selectedIndi];

    // DEC view mode
    [self updateDescendantsViewWithIndi: selectedIndi];
  
    // RawPanel
    [[RawPanelController sharedRawPanel] setDataField: selectedIndi];
  }
  else
  {
    [indi_name setStringValue: @""];
    [indi_info setStringValue: @""];
  }
}

// Handle changes in the fam selection
- (void)handleFamSelectionChanged:(NSNotification *)aNotification
{
  id		notificationSender = aNotification;
  FAM*		selectedFam = [famListController selection];

  if( selectedFam )
  {
    // Current fam and event
    current_record = selectedFam;
    current_event = nil;

    if( [[PreferencesController sharedPrefs] sortEvents] )
      [current_record sortEvents];
    [event_list setDataSource: current_record];

    // Indi list
    if( notificationSender != famListController )
    {
      [famListController setSelection: selectedFam];
    }

    // FAM View Mode
    [self updateFamViewWithFam: selectedFam];
            
    // RawPanel
    [[RawPanelController sharedRawPanel] setDataField: selectedFam];
  }
  else
  {
    [indi_name setStringValue: @""];
    [indi_info setStringValue: @""];
  }
}

// Handle note addition
- (void)handleNoteAddition:(NSNotification *)aNotification
{
//BCH
  [[NoteViewerController sharedViewer] setField: current_record];
}

- (IBAction)handleSelectEvent:(id)sender
{
  // if nothing is selected
  if( [sender selectedRow] == -1 )
  {
    [indi_name setStringValue: @""];
    [indi_info setStringValue: @""];

    return;
  }
  
  current_event = [current_record eventAtIndex: [sender selectedRow]];
}

- (void) handleIndiMode:(id) sender 
{
  // if we arent in indi view mode activate indi view mode
  // if we're already there, just toggle the indi drawer
//  if( ! [[sender identifier] isEqual: @"INDI"] )
//  {
    if( ! [[sender class] isEqual: NSClassFromString( @"NSTabViewItem" )] )
      [main_tabs selectTabViewItemAtIndex: 0];
    [indi_event_menu setEnabled: true];
    [fam_event_menu setEnabled: false];
    [famListController showDrawer: NO];
    [indiListController showDrawer: YES];
    [self handleIndiSelectionChanged: nil];
    
//    fam_event_menu = [event_menu submenu];
//    [event_menu setSubmenu: indi_event_menu];
//  }
//  else
//    [indiListController toggleDrawer];
}

- (void) handleFamMode:(id) sender 
{
  // if we arent in fam view mode activate FAM view mode
  // if we're already there, just toggle the fam drawer
//  if( ! [[[main_tabs selectedTabViewItem] identifier] isEqual: @"FAM"] )
//  {
    if( ! [[sender class] isEqual: NSClassFromString( @"NSTabViewItem" )] )
      [main_tabs selectTabViewItemAtIndex: 1];
    [recordListDataSource refreshFams];
    [indi_event_menu setEnabled: false];
    [fam_event_menu setEnabled: true];
    [indiListController showDrawer: NO];
    [famListController showDrawer: YES];
    [self handleFamSelectionChanged: nil];

//    fam_event_menu = [event_menu submenu];
//    [event_menu setSubmenu: fam_event_menu];
//  }
//  else
//    [famListController toggleDrawer];
}

- (void) handlePedigreeMode:(id) sender 
{
  // if we arent in pedigree view mode activate pedigree view mode
  // if we're already there, just toggle the indi drawer
//  if( ! [[[main_tabs selectedTabViewItem] identifier] isEqual: @"PED"] )
//  {
    if( ! [[sender class] isEqual: NSClassFromString( @"NSTabViewItem" )] )
      [main_tabs selectTabViewItemAtIndex: 2];
    [indi_event_menu setEnabled: true];
    [fam_event_menu setEnabled: false];
    [indiListController showDrawer: YES];
    [famListController showDrawer: NO];
    [self handleIndiSelectionChanged: nil];
//  }
//  else
//    [indiListController toggleDrawer];
}

- (void) handlePedigreeClick:(id) sender
{
  INDI* indi;
  
  if( [[sender title] isEqualToString: @"f"] )
    indi = [(INDI*)current_record father: ged];
  else if( [[sender title] isEqualToString: @"m"] )
    indi = [(INDI*)current_record mother: ged];
  else if( [[sender title] isEqualToString: @"pgf"] )
    indi = [[(INDI*)current_record father: ged] father: ged];
  else if( [[sender title] isEqualToString: @"pgm"] )
    indi = [[(INDI*)current_record father: ged] mother: ged];
  else if( [[sender title] isEqualToString: @"mgf"] )
    indi = [[(INDI*)current_record mother: ged] father: ged];
  else if( [[sender title] isEqualToString: @"mgm"] )
    indi = [[(INDI*)current_record mother: ged] mother: ged];
  else if( [[sender title] isEqualToString: @"ppgf"] )
    indi = [[[(INDI*)current_record father: ged] father: ged] father: ged];
  else if( [[sender title] isEqualToString: @"ppgm"] )
    indi = [[[(INDI*)current_record father: ged] father: ged] mother: ged];
  else if( [[sender title] isEqualToString: @"pmgf"] )
    indi = [[[(INDI*)current_record father: ged] mother: ged] father: ged];
  else if( [[sender title] isEqualToString: @"pmgm"] )
    indi = [[[(INDI*)current_record father: ged] mother: ged] mother: ged];
  else if( [[sender title] isEqualToString: @"mpgf"] )
    indi = [[[(INDI*)current_record mother: ged] father: ged] father: ged];
  else if( [[sender title] isEqualToString: @"mpgm"] )
    indi = [[[(INDI*)current_record mother: ged] father: ged] mother: ged];
  else if( [[sender title] isEqualToString: @"mmgf"] )
    indi = [[[(INDI*)current_record mother: ged] mother: ged] father: ged];
  else if( [[sender title] isEqualToString: @"mmgm"] )
    indi = [[[(INDI*)current_record mother: ged] mother: ged] mother: ged];
  
  [indiListController setSelection: indi];
}

- (void) handlePedigreeGoBack:(id) sender
{
  INDI* previous = [indi_history lastObject];
  
  if( [previous isEqual: current_record] )
    [indi_history removeLastObject];
    
  previous = [indi_history lastObject];
  [indiListController setSelection: previous];
  [indi_history removeLastObject];
}

- (void) handleImageClick: (id) sender
{
  GCField* gc_tmp;
  if( gc_tmp = [current_record subfieldWithType: @"OBJE"] )
  {
    [[NSWorkspace sharedWorkspace] openFile: [gc_tmp valueOfSubfieldWithType: @"FILE"]];
  }
}

- (void) handleDescendantMode:(id) sender 
{
  // if we arent in descendant view mode activate pedigree view mode
  // if we're already there, just toggle the indi drawer
//  if( ! [[[main_tabs selectedTabViewItem] identifier] isEqual: @"DEC"] )
//  {
    if( ! [[sender class] isEqual: NSClassFromString( @"NSTabViewItem" )] )
      [main_tabs selectTabViewItemAtIndex: 3];
    [indi_event_menu setEnabled: true];
    [fam_event_menu setEnabled: false];
    [indiListController showDrawer: YES];
    [famListController showDrawer: NO];
    [self handleIndiSelectionChanged: nil];
//  }
//  else
//    [indiListController toggleDrawer];
}

// Handle AboutBox menu event
- (IBAction)showAboutBox:(id)sender
{
  [[AboutBox sharedInstance] showPanel];
}

//
// Reports
//
- (void) handleDescendantsGEDCOM:(id) sender
{
  NSSavePanel* save = [NSSavePanel savePanel];
  [save setRequiredFileType: @"ged"];
  [save beginSheetForDirectory: [@"~/Documents/" stringByExpandingTildeInPath]
        file: nil
        modalForWindow: main_window
        modalDelegate: self
        didEndSelector: @selector(doDescendantsGEDCOM:returnCode:contextInfo:)
        contextInfo: nil];
}

- (void)doDescendantsGEDCOM:(NSOpenPanel *)sheet
  returnCode:(int)returnCode
  contextInfo:(void  *)contextInfo
{
  if (returnCode == NSOKButton)
  {
    NSMutableString* result = [[NSMutableString alloc] init];
    GCField* tmp;
    id root = nil;
    if( [[current_record fieldType] isEqualToString: @"INDI"] )
      root = current_record;
    else
    {
      FAM* tmp = current_record;
      if( !( root = [tmp husband: ged] ))
        root = [tmp wife: ged];
    }
      
    if( root )
    {
      if( tmp = [ged recordWithLabel: @"HEAD"] )
        [result setString: [tmp dataForFile]];
      if( tmp = [ged recordWithLabel: 
          [[ged recordWithLabel: @"HEAD"] valueOfSubfieldWithType: @"SUBM"]] )
      [result appendString: [tmp dataForFile]];
      [result appendString: [root descendantsGEDCOM: ged]]; 
      [result appendString: @"0 TRLR\n"];
    }
    [result writeToFile: [sheet filename] atomically: true];
  }
}

- (void) handleAncestorsGEDCOM:(id) sender
{
  NSSavePanel* save = [NSSavePanel savePanel];
  [save setRequiredFileType: @"ged"];
  [save beginSheetForDirectory: [@"~/Documents/" stringByExpandingTildeInPath]
        file: nil
        modalForWindow: main_window
        modalDelegate: self
        didEndSelector: @selector(doAncestorsGEDCOM:returnCode:contextInfo:)
        contextInfo: nil];
}

- (void)doAncestorsGEDCOM:(NSOpenPanel *)sheet
  returnCode:(int)returnCode
  contextInfo:(void  *)contextInfo
{
  if (returnCode == NSOKButton)
  {
    NSMutableString* result = [[NSMutableString alloc] init];
    GCField* tmp;
    id root = nil;
    if( [[current_record fieldType] isEqualToString: @"INDI"] )
      root = current_record;
    else
    {
      FAM* tmp = current_record;
      if( !( root = [tmp husband: ged] ))
        root = [tmp wife: ged];
    }
      
    if( root )
    {
      if( tmp = [ged recordWithLabel: @"HEAD"] )
        [result setString: [tmp dataForFile]];
      if( tmp = [ged recordWithLabel: 
          [[ged recordWithLabel: @"HEAD"] valueOfSubfieldWithType: @"SUBM"]] )
      [result appendString: [tmp dataForFile]];
      [result appendString: [root ancestorsGEDCOM: ged]]; 
      [result appendString: @"0 TRLR\n"];
    }
    
    [result writeToFile: [sheet filename] atomically: true];
  }
}

- (void) handleDescendantReport:(id) sender
{
  NSSavePanel* save = [NSSavePanel savePanel];
  [save setRequiredFileType: @"txt"];
  [save beginSheetForDirectory: [@"~/Documents/" stringByExpandingTildeInPath]
        file: nil
        modalForWindow: main_window
        modalDelegate: self
        didEndSelector: @selector(doDescendantReport:returnCode:contextInfo:)
        contextInfo: nil];
}

- (void)doDescendantReport:(NSOpenPanel *)sheet
  returnCode:(int)returnCode
  contextInfo:(void  *)contextInfo
{
  if (returnCode == NSOKButton)
  {
    NSMutableString* result = [[NSMutableString alloc] init];
    id root = nil;
    if( [[current_record fieldType] isEqualToString: @"INDI"] )
      root = current_record;
    else
    {
      FAM* tmp = current_record;
      if( !( root = [tmp husband: ged] ))
        root = [tmp wife: ged];
    }
      
    if( root )
    {
      [result setString: @"GenerationX: "];
      [result appendString: [[NSDate date] description]];
      [result appendString: @"\n"];
      [result appendString: @"Descendants of "];
      [result appendString: [root fullName]];
      [result appendString: @"\n\n"];
    [result appendString: [root descendantReportText: ged: 0]]; 
    }
    
    if( [result writeToFile: [sheet filename] atomically: true] )
      [[NSWorkspace sharedWorkspace] openFile: [sheet filename]];
  }
}

- (void) handleAncestorsReport:(id) sender
{
  NSSavePanel* save = [NSSavePanel savePanel];
  [save setRequiredFileType: @"txt"];
  [save beginSheetForDirectory: [@"~/Documents/" stringByExpandingTildeInPath]
        file: nil
        modalForWindow: main_window
        modalDelegate: self
        didEndSelector: @selector(doAncestorsReport:returnCode:contextInfo:)
        contextInfo: nil];
}

- (void)doAncestorsReport:(NSOpenPanel *)sheet
  returnCode:(int)returnCode
  contextInfo:(void  *)contextInfo
{
  if (returnCode == NSOKButton)
  {
    NSMutableString* result = [[NSMutableString alloc] init];
    id root = nil;
    if( [[current_record fieldType] isEqualToString: @"INDI"] )
      root = current_record;
    else
    {
      FAM* tmp = current_record;
      if( !( root = [tmp husband: ged] ))
        root = [tmp wife: ged];
    }
      
    if( root )
    {
      [result setString: @"GenerationX: "];
      [result appendString: [[NSDate date] description]];
      [result appendString: @"\n"];
      [result appendString: @"Ancestors of "];
      [result appendString: [root fullName]];
      [result appendString: @"\n\n"];
      [result appendString: [root ancestorsReportText: ged: @""]]; 
    }
    
    if( [result writeToFile: [sheet filename] atomically: true] )
      [[NSWorkspace sharedWorkspace] openFile: [sheet filename]];
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
    modalForWindow: main_window modalDelegate: self
    didEndSelector: @selector(doAllHTML:returnCode:contextInfo:) contextInfo: nil];
}

- (void) doAllHTML:(NSOpenPanel *)sheet
  returnCode:(int)returnCode
  contextInfo:(void  *)contextInfo
{
  // order the sheet out before we put up the progress dialog
  [sheet orderOut: nil];
  
  // if the user selected a file and clicked "Open"
  // export to the selected directory
  if (returnCode == NSOKButton)
  {
    [[HTMLController sharedHTML] setGED: ged];
    if( ![[HTMLController sharedHTML] exportHTML: [sheet directory]] )
      NSBeginAlertSheet( nil, @"Ok", nil,
        nil, main_window, self, nil, nil, nil,
        @"The export did not complete successfully." );
  }
}


//
// Record editing methods
//
- (void) handleNewRecord:(id) sender 
{
  // display the edit record dialog with empty fields
  [[EditIndiController sharedNewIndi] prepForDisplay: ged: nil];
  [NSApp beginSheet: [[EditIndiController sharedNewIndi] window]
    modalForWindow: main_window
    modalDelegate: self
    didEndSelector: @selector(refreshGUI) contextInfo: nil];
}

- (void) handleEditRecord:(id) sender 
{
  // display the edit record dialog with info for the
  // currently selected person or event. can't edit FAM records
  if( ( (!current_event) && [[current_record fieldType] isEqual: @"INDI"] )
   || [[current_event fieldType] isEqual: @"BIRT"]
   || [[current_event fieldType] isEqual: @"DEAT"] )
  {
    [[EditIndiController sharedNewIndi] prepForDisplay: ged: current_record];
    [[NSApplication sharedApplication]
      beginSheet: [[EditIndiController sharedNewIndi] window]
      modalForWindow: main_window
      modalDelegate: self
      didEndSelector: @selector(refreshGUI) contextInfo: nil];
  }
  //
  // Generic Events
  //
  else if( [[current_event fieldType] isEqualToString: @"BURI"]
   || [[current_event fieldType] isEqualToString: @"CREM"]
   || [[current_event fieldType] isEqualToString: @"BAPM"]
   || [[current_event fieldType] isEqualToString: @"BARM"]
   || [[current_event fieldType] isEqualToString: @"BASM"]
   || [[current_event fieldType] isEqualToString: @"BLES"]
   || [[current_event fieldType] isEqualToString: @"CHRA"]
   || [[current_event fieldType] isEqualToString: @"CONF"]
   || [[current_event fieldType] isEqualToString: @"FCOM"]
   || [[current_event fieldType] isEqualToString: @"ORDN"]
   || [[current_event fieldType] isEqualToString: @"NATU"]
   || [[current_event fieldType] isEqualToString: @"EMIG"]
   || [[current_event fieldType] isEqualToString: @"IMMI"]
   || [[current_event fieldType] isEqualToString: @"CENS"]
   || [[current_event fieldType] isEqualToString: @"PROB"]
   || [[current_event fieldType] isEqualToString: @"WILL"]
   || [[current_event fieldType] isEqualToString: @"GRAD"]
   || [[current_event fieldType] isEqualToString: @"OCCU"]
   || [[current_event fieldType] isEqualToString: @"RETI"]
   || [[current_event fieldType] isEqualToString: @"MARR"]
   || [[current_event fieldType] isEqualToString: @"ANUL"]
   || [[current_event fieldType] isEqualToString: @"DIV"]
   || [[current_event fieldType] isEqualToString: @"DIVF"]
   || [[current_event fieldType] isEqualToString: @"ENGA"]
   || [[current_event fieldType] isEqualToString: @"MARB"]
   || [[current_event fieldType] isEqualToString: @"MARC"]
   || [[current_event fieldType] isEqualToString: @"MARL"]
   || [[current_event fieldType] isEqualToString: @"MARS"]
   || [[current_event fieldType] isEqualToString: @"EVEN"] )
  {
    [[GenericEventController sharedEvent] setField: current_event];
    [NSApp beginSheet: [[GenericEventController sharedEvent] window]
      modalForWindow: main_window
      modalDelegate: self
      didEndSelector: @selector(refreshGUI) contextInfo: nil];
  }
  //
  // FAMC Events
  //
  else if( [[current_event fieldType] isEqual: @"ADOP"]
   || [[current_event fieldType] isEqual: @"CHR"] )
  {
    [[EventWithFAMCController sharedEvent] setField: current_event: current_record: ged];
    [NSApp beginSheet: [[EventWithFAMCController sharedEvent] window]
      modalForWindow: main_window
      modalDelegate: self
      didEndSelector: @selector(refreshGUI) contextInfo: nil];
  }
  //
  // MARR Event
  //
  else if( [[current_event fieldType] isEqual: @"FAMS"] )
  {
    [[AddMarriageController sharedAddMarr] prepForDisplay: ged: current_event: current_record];
    [NSApp beginSheet: [[AddMarriageController sharedAddMarr] window]
      modalForWindow: main_window
      modalDelegate: self
      didEndSelector: @selector(refreshGUI) contextInfo: nil];
  }
}

- (void) handleDeleteRecord:(id) sender
{
  NSBeginAlertSheet( nil, @"Ok", @"Cancel",
    nil, main_window, self, @selector(doDeleteRecord:::), nil, nil,
    @"Are you sure you want to delete this record and all references to it by other records?" );
}

- (void) doDeleteRecord: (NSWindow*) sheet: (int) returnCode: (NSString*) contextInfo
{
  if( returnCode == NSOKButton )
  {
    // delete the currently selected record
    // should probably add a user confirmation for this
    [ged removeRecord: current_record];
    [self refreshGUI];
  }
}

- (void) showRawPanel:(id) sender
{
  // bring the raw GEDCOM panel on screen
  [[RawPanelController sharedRawPanel] display];
}

- (void) handleEventsToolbar:(id) sender
{
  int state = [event_drawer state];
  
  if( state == NSDrawerOpenState )
    [event_drawer close];
  else
    [event_drawer openOnEdge: NSMaxXEdge];
}

- (void) handleRecordsToolbar:(id) sender
{
  if( ! [[[main_tabs selectedTabViewItem] identifier] isEqual: @"FAM"] )
    [indiListController toggleDrawer];
  else
    [famListController toggleDrawer];
}

- (void) handleImagesToolbar:(id) sender
{
  [[[ImageViewerController sharedViewer] window] makeKeyAndOrderFront: self];
}

- (void) handleNotesToolbar:(id) sender
{
  [[[NoteViewerController sharedViewer] window] makeKeyAndOrderFront: self];
}

//
// File interaction methods
//
- (void) handleOpenFile:(id) sender
{
  // ask if we should save the current data before opening a new file
  if( [ged needSave] )
    NSBeginAlertSheet( nil, @"Yes", @"No",
      nil, main_window, self, @selector(saveSheetDidEnd:::), nil, @"openFile",
      @"Save changes before closing file?" );
  else
    [self doOpenFile];
}

- (void) doOpenFile
{
  NSOpenPanel* open;
  NSArray *fileTypes = [NSArray arrayWithObject:@"ged"];
  
  // display a standard open dialog
  open = [NSOpenPanel openPanel];
  [open setTitle: @"Select a GEDCOM file to open"];
  [open setAllowsMultipleSelection:false];
  [open beginSheetForDirectory:NSHomeDirectory()
    file:nil  types:fileTypes
    modalForWindow: main_window modalDelegate: self
    didEndSelector: @selector(openPanelDidEnd:returnCode:contextInfo:) contextInfo: nil];
}

- (void) handleSaveFile:(id) sender
{
  if( [ged path] )
    [ged saveToFile];
  else
    [self handleSaveAs: self];
}

- (void) handleSaveAs:(id) sender
{
  // display a standard save dialog
  NSSavePanel* save = [NSSavePanel savePanel];
  [save setTitle: @"Save GEDCOM file to:"];
  [save setRequiredFileType: @"ged"];
  [save beginSheetForDirectory: [@"~/Documents/" stringByExpandingTildeInPath]
        file: nil
        modalForWindow: main_window
        modalDelegate: self
        didEndSelector: @selector(savePanelDidEnd:returnCode:contextInfo:)
        contextInfo: nil];
}

- (void) handleNewFile:(id) sender
{
  // ask if we should save the current data before creating
  // a new, empty database
  if( [ged needSave] )
    NSBeginAlertSheet( nil, @"Yes", @"No",
      nil, main_window, self, @selector(saveSheetDidEnd:::), nil, @"newFile",
      @"Save changes before closing file?" );
  else
    [self doNewFile];
}

- (void) doNewFile
{
  // create an empty database and hook it up to the GUI
  ged = [ged init];

  [recordListDataSource setGED: ged];
  
  [indiListController setListDataSource: recordListDataSource];
  [famListController setListDataSource: recordListDataSource];
  [famListController showDrawer: NO];
  [indiListController showDrawer: YES];
  [main_tabs selectTabViewItemAtIndex: 0];
  [self refreshGUI];
//BCH  [self handleIndiSelectionChanged: nil];
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
    modalForWindow: main_window modalDelegate: self
    didEndSelector: @selector(doMerge:returnCode:contextInfo:) contextInfo: nil];
}

- (void) handlePrefs:(id) sender
{
  [[PreferencesController sharedPrefs] displayPrefWindow];
}

- (void) handleCheckVersion:(id) sender
{
  NSString* current_vers = [[[NSBundle bundleForClass: [self class]] infoDictionary] objectForKey: @"CFBundleVersion"];
  NSDictionary* latest_dict = [NSDictionary dictionaryWithContentsOfURL:
    [NSURL URLWithString: @"http://homepage.mac.com/nowhereman77/GenX/info.txt"]];
  NSString* latest_vers  = [latest_dict valueForKey: @"version"];
  
  if( latest_vers && [current_vers isEqualToString: latest_vers] )
    NSRunAlertPanel( @"Up To Date",
                     @"You have the most recent version of this software",
                     @"Ok", nil, nil );
  else if( latest_vers )
  {
    int button = NSRunAlertPanel( @"New Software Avaliable",
                   @"A newer version of this software is avaliable.\nWould you like to download the new version now?",
                   @"Yes", @"No", nil );
                   
    if( button == NSOKButton )
      [[NSWorkspace sharedWorkspace] openURL:
       [NSURL URLWithString: @"http://sourceforge.net/projects/generationx"]];
  }
  else
    NSRunAlertPanel( @"Error",
                     @"Couldn't get latest version from the Internet",
                     @"Ok", nil, nil );
}

- (void) handleBugReport:(id) sender
{
  [[NSWorkspace sharedWorkspace] openURL:
    [NSURL URLWithString: @"http://sourceforge.net/tracker/?func=add&group_id=59977&atid=492685"]];
}

- (void) handleFeatureRequest:(id) sender
{
  [[NSWorkspace sharedWorkspace] openURL:
    [NSURL URLWithString: @"http://sourceforge.net/tracker/?func=add&group_id=59977&atid=492688"]];
}

- (void) handleDonate:(id) sender
{
  [[NSWorkspace sharedWorkspace] openURL:
    [NSURL URLWithString: @"http://homepage.mac.com/nowhereman77/GenX/donate.html"]];
}

- (void) handleEmail:(id) sender
{
  [[NSWorkspace sharedWorkspace] openURL:
    [NSURL URLWithString: @"mailto:nowhereman77@mac.com"]];
}

- (void) handleFileStats:(id) sender
{
  [[FileStatsController sharedStats] displayStats: ged];
}

- (void)doMerge:(NSOpenPanel *)sheet
  returnCode:(int)returnCode
  contextInfo:(void  *)contextInfo
{
  [sheet orderOut: nil];
  
  // if the user selected a file and clicked "Open"
  // attempt to merge the file into the database
  if (returnCode == NSOKButton)
  {
    NSArray *filesToOpen = [sheet filenames];
    GCFile* file_to_merge =
      [[GCFile alloc] initWithFile: [filesToOpen objectAtIndex: 0]];

    [[MergeController sharedMerge] doMerge: ged: file_to_merge: self];
  }
}

- (void)openPanelDidEnd:(NSOpenPanel *)sheet
  returnCode:(int)returnCode
  contextInfo:(void  *)contextInfo
{
  if (returnCode == NSOKButton)
  {
    // attempt to load a file into the database
    NSArray *filesToOpen = [sheet filenames];
    ged = [[GCFile alloc] initWithFile: [filesToOpen objectAtIndex: 0]];
    
    // if the file wasn't a GEDCOM file
    // (didn't start with a HEAD record)
    // scream and discard the link to that file
    // so we don't accidently overwrite it
    if( ! [[[ged otherAtIndex: 0] fieldType] isEqual: @"HEAD"] )
    {
      [sheet orderOut: self];
      NSBeginAlertSheet( nil, @"Ok", nil,
        nil, main_window, self, nil, nil, nil,
        @"Are you sure this is a GEDCOM file?\nIt doesn't seem to have a header." );
        
      [ged setPath: nil];
    }
  }

  // this sould only be true if the user got an open dialog
  // at launch and clicked "Cancel". In that case just
  // create an empty database
  if( ! ged )
  {
    ged = [GCFile alloc];
    [self doNewFile];
  }

//PMH Determine lastnames of the entries not having one if applicable
  if( [[PreferencesController sharedPrefs] guessLastNames] ) {
    //We have; GCFile* ged, nothing more so ask it to do the job
    [ged completeLastnames]; 
  }
// pmh

  [recordListDataSource setGED: ged];
  [recordListDataSource setIndiFilter: @""];
  [recordListDataSource setFamFilter: @""];

  [indiListController setSelection: nil];
  [indiListController setListDataSource: recordListDataSource];
  [famListController setSelection: nil];
  [famListController setListDataSource: recordListDataSource];
  [self refreshGUI];
//BCH  [self handleIndiSelectionChanged: nil];
}

- (void)savePanelDidEnd:(NSOpenPanel *)sheet
  returnCode:(int)returnCode
  contextInfo:(NSString*)contextInfo
{
  if( returnCode == NSOKButton )
  {
    // save to a specified file
    [ged setPath: [sheet filename]];
    [ged saveToFile];
  }
  
  if( [contextInfo isEqual: @"newFile"] )
  {
    [sheet orderOut: self];
    [self doNewFile];
  }
  else if( [contextInfo isEqual: @"openFile"] )
  {
    [sheet orderOut: self];
    [self doOpenFile];
  }
  else if( [contextInfo isEqual: @"saveBeforeQuit"] )
    [NSApp replyToApplicationShouldTerminate: true];
}

- (void) handleGoToFather:(id) sender
{
  [indiListController setSelection: [current_record father: ged]];
}

- (void) handleGoToMother:(id) sender
{
  [indiListController setSelection: [current_record mother: ged]];
}

- (void) handleGoToSpouseOrChild:(id) sender
{
  id item = [indi_spice_outline itemAtRow: [indi_spice_outline selectedRow]];
  if( !item )
    item = [dec_outline itemAtRow: [dec_outline selectedRow]];
  
  if( [[item class] isEqual: NSClassFromString( @"FAM" )] )
  {
    if( [[current_record sex] isEqual: @"F"] )
      [indiListController setSelection: [item husband: ged]];
    else
      [indiListController setSelection: [item wife: ged]];
  }
  else
    [indiListController setSelection: item];
}

- (void) handleFamGoToHusb:(id) sender
{
  [indiListController setSelection: [current_record husband: ged]];
  [self handleIndiMode: nil];
}

- (void) handleFamGoToWife:(id) sender
{
  [indiListController setSelection: [current_record wife: ged]];
  [self handleIndiMode: nil];
}

- (void) handleFamGoToChild:(id) sender
{
  [indiListController setSelection: [[current_record children: ged] objectAtIndex: [fam_child_table selectedRow]]];
  [self handleIndiMode: nil];
}

#pragma mark -
#pragma mark Toolbar stuff

static NSString* 	MyToolbarIdentifier 		  = @"My Toolbar Identifier";
//static NSString*	IndiToolbarItemIdentifier = @"Individual Item Identifier";
//static NSString*	FamToolbarItemIdentifier 	= @"Family Item Identifier";
static NSString*	RawToolbarItemIdentifier 	= @"Raw Item Identifier";
//static NSString*	PedigreeToolbarItemIdentifier 	= @"Pedigree Item Identifier";
//static NSString*	DescendantsToolbarItemIdentifier 	= @"Descendants Item Identifier";
static NSString*	NewRecordToolbarItemIdentifier 	= @"New Record Item Identifier";
static NSString*	EditRecordToolbarItemIdentifier 	= @"Edit Record Item Identifier";
static NSString*	EventToolbarItemIdentifier 	= @"Event Item Identifier";
static NSString*	RecordToolbarItemIdentifier 	= @"Record Item Identifier";

- (void) setupToolbar {
    // Create a new toolbar instance, and attach it to our document window 
    NSToolbar *toolbar = [[[NSToolbar alloc] initWithIdentifier:
                         MyToolbarIdentifier] autorelease];
    
    // Set up toolbar properties: Allow customization,
    // give a default display mode, and remember state in user defaults 
    [toolbar setAllowsUserCustomization: YES];
    [toolbar setAutosavesConfiguration: YES];
    [toolbar setDisplayMode: NSToolbarDisplayModeLabelOnly];
    
    // We are the delegate
    [toolbar setDelegate: self];
    
    // Attach the toolbar to the document window 
    [main_window setToolbar: toolbar];
}

- (NSToolbarItem *) toolbar: (NSToolbar *)toolbar
  itemForItemIdentifier: (NSString *)itemIdent
  willBeInsertedIntoToolbar: (BOOL)willBeInserted
{
  // Required delegate method   Given an item identifier, self method returns an item 
  // The toolbar will use self method to obtain toolbar items that can be displayed
  // in the customization sheet, or in the toolbar itself 
  NSToolbarItem *toolbarItem = [[[NSToolbarItem alloc]
                               initWithItemIdentifier: itemIdent]
                               autorelease];
/*    
  if ([itemIdent isEqual: IndiToolbarItemIdentifier])
  {
    // Set the text label to be displayed in the toolbar and customization palette 
    [toolbarItem setLabel: @"People"];
    [toolbarItem setPaletteLabel: @"People"];
    
    // Set up a reasonable tooltip, and image   Note, these aren't localized,
    // but you will likely want to localize many of the item's properties 
    [toolbarItem setToolTip: @"Enter Individual View Mode"];
    [toolbarItem setImage: [NSImage imageNamed: @"IndiItemImage"]];
    
    // Tell the item what message to send when it is clicked 
    [toolbarItem setTarget: self];
    [toolbarItem setAction: @selector(handleIndiMode:)];
  }
  else if([itemIdent isEqual: FamToolbarItemIdentifier])
  {
    // Set the text label to be displayed in the toolbar and customization palette 
    [toolbarItem setLabel: @"Families"];
    [toolbarItem setPaletteLabel: @"Families"];
    
    // Set up a reasonable tooltip, and image   Note, these aren't localized,
    // but you will likely want to localize many of the item's properties 
    [toolbarItem setToolTip: @"Enter Family View Mode"];
    [toolbarItem setImage: [NSImage imageNamed: @"FamItemImage"]];
    
    // Tell the item what message to send when it is clicked 
    [toolbarItem setTarget: self];
    [toolbarItem setAction: @selector(handleFamMode:)];
  }
  else if([itemIdent isEqual: PedigreeToolbarItemIdentifier])
  {
    // Set the text label to be displayed in the toolbar and customization palette 
    [toolbarItem setLabel: @"Pedigree"];
    [toolbarItem setPaletteLabel: @"Pedigree"];
    
    // Set up a reasonable tooltip, and image   Note, these aren't localized,
    // but you will likely want to localize many of the item's properties 
    [toolbarItem setToolTip: @"Enter Pedigree View Mode"];
    [toolbarItem setImage: [NSImage imageNamed: @"PedItemImage"]];
    
    // Tell the item what message to send when it is clicked 
    [toolbarItem setTarget: self];
    [toolbarItem setAction: @selector(handlePedigreeMode:)];
  }
  else if([itemIdent isEqual: DescendantsToolbarItemIdentifier])
  {
    // Set the text label to be displayed in the toolbar and customization palette 
    [toolbarItem setLabel: @"Descendants"];
    [toolbarItem setPaletteLabel: @"Descendants"];
    
    // Set up a reasonable tooltip, and image   Note, these aren't localized,
    // but you will likely want to localize many of the item's properties 
    [toolbarItem setToolTip: @"Enter Descendant View Mode"];
    [toolbarItem setImage: [NSImage imageNamed: @"DecItemImage"]];
    
    // Tell the item what message to send when it is clicked 
    [toolbarItem setTarget: self];
    [toolbarItem setAction: @selector(handleDescendantMode:)];
  }
*/
  if([itemIdent isEqual: NewRecordToolbarItemIdentifier])
  {
    // Set the text label to be displayed in the toolbar and customization palette 
    [toolbarItem setLabel: @"New"];
    [toolbarItem setPaletteLabel: @"New"];
    
    // Set up a reasonable tooltip, and image   Note, these aren't localized,
    // but you will likely want to localize many of the item's properties 
    [toolbarItem setToolTip: @"Add a new record to this database"];
    [toolbarItem setImage: [NSImage imageNamed: @"NewItemImage"]];
    
    // Tell the item what message to send when it is clicked 
    [toolbarItem setTarget: self];
    [toolbarItem setAction: @selector(handleNewRecord:)];
  }
  else if([itemIdent isEqual: EditRecordToolbarItemIdentifier])
  {
    // Set the text label to be displayed in the toolbar and customization palette 
    [toolbarItem setLabel: @"Edit"];
    [toolbarItem setPaletteLabel: @"Edit"];
    
    // Set up a reasonable tooltip, and image   Note, these aren't localized,
    // but you will likely want to localize many of the item's properties 
    [toolbarItem setToolTip: @"Edit the selected record"];
    [toolbarItem setImage: [NSImage imageNamed: @"EditItemImage"]];
    
    // Tell the item what message to send when it is clicked 
    [toolbarItem setTarget: self];
    [toolbarItem setAction: @selector(handleEditRecord:)];
  }
  else if([itemIdent isEqual: RawToolbarItemIdentifier])
  {
    // Set the text label to be displayed in the toolbar and customization palette 
    [toolbarItem setLabel: @"Raw GEDCOM"];
    [toolbarItem setPaletteLabel: @"Raw GEDCOM"];
    
    // Set up a reasonable tooltip, and image   Note, these aren't localized,
    // but you will likely want to localize many of the item's properties 
    [toolbarItem setToolTip: @"Display the raw GEDCOM window"];
    [toolbarItem setImage: [NSImage imageNamed: @"RawItemImage"]];
    
    // Tell the item what message to send when it is clicked 
    [toolbarItem setTarget: self];
    [toolbarItem setAction: @selector(showRawPanel:)];
  }
  else if([itemIdent isEqual: EventToolbarItemIdentifier])
  {
    // Set the text label to be displayed in the toolbar and customization palette 
    [toolbarItem setLabel: @"Details"];
    [toolbarItem setPaletteLabel: @"Details"];
    
    // Set up a reasonable tooltip, and image   Note, these aren't localized,
    // but you will likely want to localize many of the item's properties 
    [toolbarItem setToolTip: @"Toggle the events drawer"];
    [toolbarItem setImage: [NSImage imageNamed: @"EventsItemImage"]];
    
    // Tell the item what message to send when it is clicked 
    [toolbarItem setTarget: self];
    [toolbarItem setAction: @selector(handleEventsToolbar:)];
  }
  else if([itemIdent isEqual: RecordToolbarItemIdentifier])
  {
    // Set the text label to be displayed in the toolbar and customization palette 
    [toolbarItem setLabel: @"Records"];
    [toolbarItem setPaletteLabel: @"Records"];
    
    // Set up a reasonable tooltip, and image   Note, these aren't localized,
    // but you will likely want to localize many of the item's properties 
    [toolbarItem setToolTip: @"Toggle the records drawer"];
    [toolbarItem setImage: [NSImage imageNamed: @"RecordsItemImage"]];
    
    // Tell the item what message to send when it is clicked 
    [toolbarItem setTarget: self];
    [toolbarItem setAction: @selector(handleRecordsToolbar:)];
  }
  else
  {
	  // itemIdent refered to a toolbar item that is not provide or supported by us or cocoa 
  	// Returning nil will inform the toolbar self kind of item is not supported 
	  toolbarItem = nil;
  }
  
  return toolbarItem;
}

- (NSArray *) toolbarDefaultItemIdentifiers: (NSToolbar *) toolbar
{
  // Required delegate method   Returns the ordered list of items to be shown in the toolbar by default    
  // If during the toolbar's initialization, no overriding values are found in the user defaults, or if the
  // user chooses to revert to the default items self set will be used 
  return [NSArray arrayWithObjects:
//          IndiToolbarItemIdentifier, FamToolbarItemIdentifier,
//          PedigreeToolbarItemIdentifier, DescendantsToolbarItemIdentifier,
          NewRecordToolbarItemIdentifier, EditRecordToolbarItemIdentifier,
          NSToolbarFlexibleSpaceItemIdentifier,
          EventToolbarItemIdentifier,
          
          nil];
}

- (NSArray *) toolbarAllowedItemIdentifiers: (NSToolbar *) toolbar
{
  // Required delegate method   Returns the list of all allowed items by identifier   By default, the toolbar 
  // does not assume any items are allowed, even the separator   So, every allowed item must be explicitly listed   
  // The set of allowed items is used to construct the customization palette 
  return [NSArray arrayWithObjects:
//          IndiToolbarItemIdentifier, FamToolbarItemIdentifier,
          EventToolbarItemIdentifier, RecordToolbarItemIdentifier,
//          PedigreeToolbarItemIdentifier,
//          DescendantsToolbarItemIdentifier,
          NewRecordToolbarItemIdentifier,
          EditRecordToolbarItemIdentifier, RawToolbarItemIdentifier, 
          //NSToolbarShowColorsItemIdentifier,
          //NSToolbarShowFontsItemIdentifier,
          NSToolbarCustomizeToolbarItemIdentifier,
          NSToolbarFlexibleSpaceItemIdentifier, NSToolbarSpaceItemIdentifier,
          NSToolbarSeparatorItemIdentifier, nil];
}

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
  if( ! [[[main_tabs selectedTabViewItem] identifier] isEqual: @"FAM"] )
    [self handleIndiSelectionChanged: nil];
  else
    [self handleFamSelectionChanged: nil];
}

//
// NSTableView responder method
//
-(void) mouseUp: (NSEvent*) e
{
  if( [e clickCount] == 2 )
  {
    [self handleEditRecord: nil];
  }
}

#pragma mark -
#pragma mark NSOutlineView Data Source

- (id)outlineView:(NSOutlineView *)outlineView
  child:(int)index
  ofItem:(id)item
{
  if( [[current_record class] isEqual: NSClassFromString( @"INDI" )] )
  {
    NSArray* spice = [current_record spouseFamilies: ged];
    
    if( item == nil )
    {
        return [spice objectAtIndex: index];
    }
    else if( [[item class] isEqual: NSClassFromString( @"FAM" )] )
    {
        NSArray* children = [item children: ged];
        return [children objectAtIndex: index];
    }
    else
        return nil;
  }
  
  return nil;
}

- (BOOL)outlineView:(NSOutlineView *)outlineView
  isItemExpandable:(GCField*)item
{
  if( [[current_record class] isEqual: NSClassFromString( @"INDI" )] )
  {
    if( [[item class] isEqual: NSClassFromString( @"FAM" )] )
        return true;
    else
        return false;
  }
  
  return false;
}

- (int)outlineView:(NSOutlineView *)outlineView
  numberOfChildrenOfItem:(id)item
{
  if( [[current_record class] isEqual: NSClassFromString( @"INDI" )] )
  {
    if( item == nil )
    {
        NSArray* spice = [current_record spouseFamilies: ged];
        return [spice count];
    }
    else if( [[item class] isEqual: NSClassFromString( @"FAM" )] )
    {
        NSArray* children = [item children: ged];
        return [children count];
    }
    else
        return 0;
  }
  
  return 0;
}

- (id)outlineView:(NSOutlineView *)outlineView
  objectValueForTableColumn:(NSTableColumn *)tableColumn
  byItem:(id)item
{
  if( [[current_record class] isEqual: NSClassFromString( @"INDI" )] )
  {
    if( [[item class] isEqual: NSClassFromString( @"FAM" )] )
    {
      if( [[current_record sex] isEqual: @"F"] )
      {
        if( [item husband: ged] )
          return [NSString stringWithFormat: @"Spouse: %@", [[item husband: ged] fullName]];
        else
          return @"Soupse: Unknown";
      }
      else
      {
        if( [item wife: ged] )
          return [NSString stringWithFormat: @"Spouse: %@", [[item wife: ged] fullName]];
        else
          return @"Soupse: Unknown";
      }
    }
    else
        return [NSString stringWithFormat: @"Child: %@", [item fullName]];
  }
  
  return @"***";
}

#pragma mark -
#pragma mark NSTableView Data Source

- (int)numberOfRowsInTableView: (NSTableView*)aTableView
{
  if( [[current_record class] isEqual: NSClassFromString( @"FAM" )] )
  {
    return [[current_record children: ged] count];
  }
  return 0;
}

- (id)tableView: (NSTableView *)aTableView
  objectValueForTableColumn: (NSTableColumn *)aTableColumn
  row: (int)rowIndex
{
  if( [[current_record class] isEqual: NSClassFromString( @"FAM" )]
   && [[aTableColumn identifier] isEqual: @"NAME"] )
  {
    NSArray* children = [current_record children: ged];
    return [NSString stringWithFormat: @"Child: %@", [[children objectAtIndex: rowIndex] fullName]];
  }
  return @"***";
}

#pragma mark -

- (void)tabView:(NSTabView *)tabView didSelectTabViewItem:(NSTabViewItem *)tabViewItem
{
  if( [[tabViewItem identifier] isEqualToString: @"INDI"] )
    [self handleIndiMode: tabViewItem];
  else if( [[tabViewItem identifier] isEqualToString: @"FAM"] )
    [self handleFamMode: tabViewItem];
  else if( [[tabViewItem identifier] isEqualToString: @"PED"] )
    [self handlePedigreeMode: tabViewItem];
  else if( [[tabViewItem identifier] isEqualToString: @"DEC"] )
    [self handleDescendantMode: tabViewItem];
}

//
// 021114 Nowhere Man
//
//  added the following two methods to solve a problem where
// i was unable to use the menu bar if anything was selected
// in the drawer lists. no idea why it works now
//
- (BOOL) validRequestorForSendType: (id) a returnType: (id) b
{
  return true;
}

- (id) nextResponder
{
  return nil;
}

@end
