/* PreferencesController */

#import <Cocoa/Cocoa.h>

@interface PreferencesController : NSObject
{
    IBOutlet NSWindow*    pref_window;
    IBOutlet NSTextField* auto_save_text;
    IBOutlet NSTextField* user_name_text;
    IBOutlet NSTextField* default_file_text;
    IBOutlet NSButton*    sort_records_button;
    IBOutlet NSButton*    sort_filtered_button;
}

+ (PreferencesController*) sharedPrefs;
- (PreferencesController*) initPrefs;
- (void) displayPrefWindow;
- (IBAction)handleCancel:(id)sender;
- (IBAction)handleChangeDefaultPath:(id)sender;
- (IBAction)handleOk:(id)sender;
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
//- (void) savePrefs;

@end
