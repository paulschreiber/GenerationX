/* PreferencesController */

#import <Cocoa/Cocoa.h>

@interface PreferencesController : NSObject
{
    // General tab
    IBOutlet NSWindow*    pref_window;
    IBOutlet NSTextField* auto_save_text;
    IBOutlet NSTextField* user_name_text;
    IBOutlet NSTextField* default_file_text;
    IBOutlet NSButton*    sort_records_button;
    IBOutlet NSButton*    sort_filtered_button;
    IBOutlet NSButton*    sort_events_button;
    
    // GEDCOM tab
    IBOutlet NSButton*    guess_last_names;

    // HTML tab
    IBOutlet NSTextField* html_title;    
    IBOutlet NSTextField* html_email;    
    IBOutlet NSColorWell* html_back_color;
    IBOutlet NSColorWell* html_text_color;
    IBOutlet NSButton*    html_timestamp;
}

+ (PreferencesController*) sharedPrefs;
- (PreferencesController*) initPrefs;
- (void) displayPrefWindow;
- (IBAction)handleCancel:(id)sender;
- (IBAction)handleChangeDefaultPath:(id)sender;
- (IBAction)handleOk:(id)sender;

// General
- (BOOL)sortRecords;
- (void) setSort: (BOOL) my_sort;
- (BOOL)sortFiltered;
- (void) setSortFiltered: (BOOL) my_sort;
- (NSString*) defaultFile;
- (void) setDefaultFile: (NSString*) my_default_file;
- (int) autoSave;
- (void) setAutoSave: (int) my_auto_save;
- (NSString*) userName;
- (void) setUserName: (NSString*) my_user_name;
- (int) lastVersionCheck;
- (void) setLastVersionCheck: (int) my_auto_save;
- (BOOL) sortEvents;
- (void) setSortEvents: (BOOL) my_sort;

// GEDCOM
- (BOOL) guessLastNames;
- (void) setGuessLastNames: (BOOL) t;

// HTML
- (NSString*) HTMLTitle;
- (void) setHTMLTitle: (NSString*) t;
- (NSString*) HTMLEmail;
- (void) setHTMLEmail: (NSString*) t;
- (NSString*) HTMLBackColor;
- (void) setHTMLBackColor: (NSString*) t;
- (NSString*) HTMLTextColor;
- (void) setHTMLTextColor: (NSString*) t;
- (BOOL) HTMLTimestamp;
- (void) setHTMLTimestamp: (BOOL) t;

//- (void) savePrefs;

@end
