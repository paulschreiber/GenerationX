#import "PreferencesController.h"

#define preferences [NSUserDefaults standardUserDefaults]

@implementation PreferencesController

+ (PreferencesController*) sharedPrefs
{
  static PreferencesController* my_data = nil;
  
  if( ! my_data )
    my_data = [[PreferencesController alloc] initPrefs];
    
  return my_data;
}

- (PreferencesController*) initPrefs
{
  // setup defaults in case there's no pref file to load
  NSMutableDictionary* defaults = [NSMutableDictionary dictionary];
  
  // General
  if( ![preferences stringForKey: @"DEFAULT_FILE"] )
    [defaults setObject: [@"~/Documents/GenerationX_data.ged" stringByExpandingTildeInPath] forKey: @"DEFAULT_FILE"];
  if( ![preferences stringForKey: @"SORT_ALL"] )
    [defaults setObject: [NSNumber numberWithBool: false] forKey: @"SORT_ALL"];
  if( ![preferences stringForKey: @"SORT_FILTERED"] )
    [defaults setObject: [NSNumber numberWithBool: false] forKey: @"SORT_FILTERED"];
  if( ![preferences stringForKey: @"AUTO_SAVE"] )
    [defaults setObject: [NSNumber numberWithInt: 0] forKey: @"AUTO_SAVE"];
  if( ![preferences stringForKey: @"USER_NAME"] )
    [defaults setObject: @"GenerationX User" forKey: @"USER_NAME"];
  if( ![preferences stringForKey: @"SORT_EVENTS"] )
    [defaults setObject: [NSNumber numberWithBool: true] forKey: @"SORT_EVENTS"];
    
  // GEDCOM
  if( ![preferences stringForKey: @"GUESS_LAST_NAMES"] )
    [defaults setObject: [NSNumber numberWithBool: false] forKey: @"GUESS_LAST_NAMES"];
 
  // HTML
  if( ![preferences stringForKey: @"HTML_TITLE"] )
    [defaults setObject: [@"GenerationX" stringByExpandingTildeInPath] forKey: @"HTML_TITLE"];
  if( ![preferences stringForKey: @"HTML_EMAIL"] )
    [defaults setObject: @"" forKey: @"HTML_EMAIL"];
  if( ![preferences stringForKey: @"HTML_BACK_COLOR"] )
    [defaults setObject: [@"FFFFFF" stringByExpandingTildeInPath] forKey: @"HTML_BACK_COLOR"];
  if( ![preferences stringForKey: @"HTML_TEXT_COLOR"] )
    [defaults setObject: [@"000000" stringByExpandingTildeInPath] forKey: @"HTML_TEXT_COLOR"];
  if( ![preferences stringForKey: @"HTML_TIMESTAMP"] )
    [defaults setObject: [NSNumber numberWithBool: true] forKey: @"HTML_TIMESTAMP"];
   
  [preferences registerDefaults: defaults];
  
  // load the nib and set up some GUI stuff
  [NSBundle loadNibNamed: @"Preferences" owner:self];
//  [NSColorPanel setPickerMask: NSColorPanelColorListModeMask];
  [NSColorPanel setPickerMode: NSColorListModeColorPanel];
  [[NSColorPanel sharedColorPanel] attachColorList: [NSColorList colorListNamed: @"Web Safe Colors"]];
  
  //
  // get saved values
  //
  [default_file_text setStringValue: [[preferences stringForKey: @"DEFAULT_FILE"] lastPathComponent]];
  [user_name_text setStringValue: [preferences stringForKey: @"USER_NAME"]];
  [auto_save_text setStringValue: [[NSNumber numberWithInt: [preferences integerForKey: @"AUTO_SAVE"]] stringValue]];
  
  if( [preferences boolForKey: @"SORT_ALL"] )
    [sort_records_button setState: NSOnState];
  else
    [sort_records_button setState: NSOffState];

  if( [preferences boolForKey: @"SORT_FILTERED"] )
    [sort_filtered_button setState: NSOnState];
  else
    [sort_filtered_button setState: NSOffState];

  if( [preferences boolForKey: @"SORT_EVENTS"] )
    [sort_events_button setState: NSOnState];
  else
    [sort_events_button setState: NSOffState];

  // GEDCOM
  if( [preferences boolForKey: @"GUESS_LAST_NAMES"] )
    [guess_last_names setState: NSOnState];
  else
    [guess_last_names setState: NSOffState];

  // HTML
  [html_title setStringValue: [preferences stringForKey: @"HTML_TITLE"]];
  [html_email setStringValue: [preferences stringForKey: @"HTML_EMAIL"]];
//  [html_back_color setColor: 
//    [NSColor Color[preferences stringForKey: @"HTML_BACK_COLOR"]]];
//  [html_text_color setColor: [preferences stringForKey: @"HTML_TEXT_COLOR"]];

  if( [preferences boolForKey: @"HTML_TIMESTAMP"] )
    [html_timestamp setState: NSOnState];
  else
    [html_timestamp setState: NSOffState];

  return self;
}  

- (void) displayPrefWindow
{
  [pref_window makeKeyAndOrderFront: self];  
}

- (IBAction)handleChangeDefaultPath:(id)sender
{
  NSOpenPanel* open;
  NSArray *fileTypes = [NSArray arrayWithObject:@"ged"];
  
  // display a standard open dialog
  open = [NSOpenPanel openPanel];
  [open setTitle: @"Select a GEDCOM file to open"];
  [open setAllowsMultipleSelection:false];
  [open beginSheetForDirectory:NSHomeDirectory()
    file:nil  types:fileTypes
    modalForWindow: pref_window modalDelegate: self
    didEndSelector: @selector(doChangeDefaultPath:returnCode:contextInfo:) contextInfo: nil];
}

- (void)doChangeDefaultPath:(NSOpenPanel *)sheet
  returnCode:(int)returnCode
  contextInfo:(void  *)contextInfo
{
  if (returnCode == NSOKButton)
  {
    // attempt to load a file into the database
    NSArray *filesToOpen = [sheet filenames];
    [default_file_text setStringValue: [[filesToOpen objectAtIndex: 0] lastPathComponent]];
   }
}

- (IBAction)handleCancel:(id)sender
{
  [pref_window orderOut: self];
}

- (IBAction)handleOk:(id)sender
{
  [[PreferencesController sharedPrefs] setDefaultFile: [default_file_text stringValue]];
  [[PreferencesController sharedPrefs] setUserName: [user_name_text stringValue]];
  [[PreferencesController sharedPrefs] setAutoSave: [[auto_save_text stringValue] intValue]];
  
  if( [sort_records_button state] == NSOnState )
    [[PreferencesController sharedPrefs] setSort: true];
  else
    [[PreferencesController sharedPrefs] setSort: false];
  
  if( [sort_filtered_button state] == NSOnState )
    [[PreferencesController sharedPrefs] setSortFiltered: true];
  else
    [[PreferencesController sharedPrefs] setSortFiltered: false];

  if( [sort_events_button state] == NSOnState )
    [[PreferencesController sharedPrefs] setSortEvents: true];
  else
    [[PreferencesController sharedPrefs] setSortEvents: false];
  
  // GEDCOM
  if( [guess_last_names state] == NSOnState )
    [[PreferencesController sharedPrefs] setGuessLastNames: true];
  else
    [[PreferencesController sharedPrefs] setGuessLastNames: false];
    
  // HTML
  [[PreferencesController sharedPrefs] setHTMLTitle: [html_title stringValue]];
  [[PreferencesController sharedPrefs] setHTMLEmail: [html_email stringValue]];

  if( [html_timestamp state] == NSOnState )
    [[PreferencesController sharedPrefs] setHTMLTimestamp: true];
  else
    [[PreferencesController sharedPrefs] setHTMLTimestamp: false];

  [pref_window orderOut: self];
}

//
// General
//
- (BOOL)sortRecords
{
  return [preferences boolForKey: @"SORT_ALL"];
}

- (void) setSort: (BOOL) my_sort
{
  [preferences setBool: my_sort forKey: @"SORT_ALL"];
}

- (BOOL)sortFiltered
{
  return [preferences boolForKey: @"SORT_FILTERED"];
}

- (void) setSortFiltered: (BOOL) my_sort
{
  [preferences setBool: my_sort forKey: @"SORT_FILTERED"];
}

- (NSString*) defaultFile
{
  NSString* result;
  
  if( !( result = [preferences stringForKey: @"DEFAULT_FILE"] ) )
    result = @"";
    
  return result;
}

- (void) setDefaultFile: (NSString*) my_default_file
{
  [preferences setObject: my_default_file forKey: @"DEFAULT_FILE"];
}

- (int) autoSave
{
  return [preferences integerForKey: @"AUTO_SAVE"];
}

- (void) setAutoSave: (int) my_auto_save
{
  [preferences setInteger: my_auto_save forKey: @"AUTO_SAVE"];
}

- (NSString*) userName
{
  return [preferences stringForKey: @"USER_NAME"];
}

- (void) setUserName: (NSString*) my_user_name
{
  [preferences setObject: my_user_name forKey: @"USER_NAME"];
}

- (int) lastVersionCheck
{
  return [preferences integerForKey: @"LAST_VERSION_CHECK"];
}

- (void) setLastVersionCheck: (int) my_version_check
{
  [preferences setInteger: my_version_check forKey: @"LAST_VERSION_CHECK"];
}

- (BOOL)sortEvents
{
  return [preferences boolForKey: @"SORT_EVENTS"];
}

- (void) setSortEvents: (BOOL) my_sort
{
  [preferences setBool: my_sort forKey: @"SORT_EVENTS"];
}

//
// GEDCOM
//

- (BOOL) guessLastNames
{
  return [preferences boolForKey: @"GUESS_LAST_NAMES"];
}

- (void) setGuessLastNames: (BOOL) t
{
  [preferences setBool: t forKey: @"GUESS_LAST_NAMES"];
}

//
// HTML 
//

- (NSString*) HTMLTitle
{
  return [preferences stringForKey: @"HTML_TITLE"];
}

- (void) setHTMLTitle: (NSString*) t
{
  [preferences setObject: t forKey: @"HTML_TITLE"];
}

- (NSString*) HTMLEmail
{
  return [preferences stringForKey: @"HTML_EMAIL"];
}

- (void) setHTMLEmail: (NSString*) t
{
  [preferences setObject: t forKey: @"HTML_EMAIL"];
}

- (NSString*) HTMLBackColor;
{
  return [preferences stringForKey: @"HTML_BACK_COLOR"];
}

- (void) setHTMLBackColor: (NSString*) t;
{
  [preferences setObject: t forKey: @"HTML_BACK_COLOR"];
}

- (NSString*) HTMLTextColor;
{
  return [preferences stringForKey: @"HTML_TEXT_COLOR"];
}

- (void) setHTMLTextColor: (NSString*) t;
{
  [preferences setObject: t forKey: @"HTML_TEXT_COLOR"];
}


- (BOOL) HTMLTimestamp
{
  return [preferences boolForKey: @"HTML_TIMESTAMP"];
}

- (void) setHTMLTimestamp: (BOOL) t
{
  [preferences setBool: t forKey: @"HTML_TIMESTAMP"];
}

/*
- (void) savePrefs
{
  NSString* text;
  
  text = @"DEFAULT_FILE\t";
  text = [text stringByAppendingString: default_file];
  if( sort )
    text = [text stringByAppendingString: @"\nSORT\tT"];
  else
    text = [text stringByAppendingString: @"\nSORT\tF"];
  if( sort_filtered )
    text = [text stringByAppendingString: @"\nSORT_FILTERED\tT"];
  else
    text = [text stringByAppendingString: @"\nSORT_FILTERED\tF"];
  text = [text stringByAppendingString: @"\nAUTO_SAVE\t"];
  text = [text stringByAppendingString: [[NSNumber numberWithInt: auto_save] stringValue]];
  text = [text stringByAppendingString: @"\n"];

  if( ![text isEqual: @""] )
    [text writeToFile: pref_path atomically: false];
}*/

@end
