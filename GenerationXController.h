/* GenerationXController */

#import <Cocoa/Cocoa.h>
#import <Foundation/Foundation.h>
#import "GCFile.h"
#import "IndiListController.h"
#import "FamListController.h"
#import "RecordListDataSource.h"
#import "PreferencesController.h"

@interface GenerationXController : NSObject
{
    // Main window
    IBOutlet NSWindow*    main_window;
    IBOutlet NSTabView*   main_tabs;
    IBOutlet id           main_status_text;
    
    // Menus
    IBOutlet NSMenuItem*  event_menu;
    IBOutlet NSMenuItem*  indi_event_menu;
    IBOutlet NSMenuItem*  fam_event_menu;

    // Other controllers

    // Indi list controller
    IBOutlet IndiListController*	indiListController;

    // Indi view
    IBOutlet NSTextField* indi_name;
    IBOutlet NSTextField* indi_info;
    IBOutlet NSTextField* indi_born_text;
    IBOutlet NSTextField* indi_died_text;
    IBOutlet NSTextField* indi_father_text;
    IBOutlet NSTextField* indi_mother_text;
    IBOutlet id           indi_spice_outline;
    IBOutlet NSImageView* indi_image;
    
    // Fam list controller
    IBOutlet FamListController*	famListController;

    // Fam view
    IBOutlet NSTextField* fam_info;
    IBOutlet NSTextField* fam_husb_text;
    IBOutlet NSTextField* fam_wife_text;
    IBOutlet NSTextField* fam_marr_text;
    IBOutlet NSTextField* fam_child_table;
    IBOutlet NSImageView* fam_image;

    // Event drawer
    IBOutlet NSDrawer*    event_drawer;
    IBOutlet NSTableView* event_list;

    // Pedigree view
    IBOutlet NSTextField* ped_root;
    IBOutlet NSTextField* ped_father;
    IBOutlet NSTextField* ped_pgf;
    IBOutlet NSTextField* ped_pgm;
    IBOutlet NSTextField* ped_ppgf;
    IBOutlet NSTextField* ped_ppgm;
    IBOutlet NSTextField* ped_pmgf;
    IBOutlet NSTextField* ped_pmgm;
    IBOutlet NSTextField* ped_mother;
    IBOutlet NSTextField* ped_mgf;
    IBOutlet NSTextField* ped_mgm;
    IBOutlet NSTextField* ped_mpgf;
    IBOutlet NSTextField* ped_mpgm;
    IBOutlet NSTextField* ped_mmgf;
    IBOutlet NSTextField* ped_mmgm;

    // Descendants view
    IBOutlet NSTextField*   dec_name;
    IBOutlet NSOutlineView* dec_outline;
    
    RecordListDataSource*  	recordListDataSource;
    NSTimer* 				autoSaveTimer;

    GCFile*               	ged;
    NSMutableArray*             indi_history;
    GCField*              	current_record;
    GCField*              	current_event;
}

// Accessors
- (NSWindow*) mainWindow;
- (GCFile*) gedFile;
- (GCField*) currentRecord;
- (GCField*) currentEvent;


- (void) refreshGUI;

- (void)handleIndiSelectionChanged:(NSNotification*)notification;
- (void)handleFamSelectionChanged:(NSNotification*)notification;
- (void)handleNoteAddition:(NSNotification *)aNotification;

- (void) handleIndiMode:(id) sender;
- (void) handleFamMode:(id) sender;
- (void) handlePedigreeMode:(id) sender;
- (void) handleDescendantMode:(id) sender;
- (void) handlePedigreeClick:(id) sender;
- (void) handlePedigreeGoBack:(id) sender;
- (void) handleImageClick:(id) sender;
- (void) showRawPanel:(id) sender;
- (void) handleEventsToolbar:(id) sender;
- (void) handleImagesToolbar:(id) sender;
- (void) handleNotesToolbar:(id) sender;

// Reports
- (void) handleDescendantsGEDCOM:(id) sender;
- (void) handleAncestorsGEDCOM:(id) sender;
- (void) handleDescendantReport:(id) sender;
- (void) handleAllHTML:(id) sender;

// File menu
- (void) handleOpenFile:(id) sender;
- (void) doOpenFile;
- (void) handleSaveFile:(id) sender;
- (void) handleSaveAs:(id) sender;
- (void) handleNewFile:(id) sender;
- (void) doNewFile;
- (void) handleMergeFile:(id) sender;

// Record menu
- (void) handleNewRecord:(id) sender;
- (void) handleEditRecord:(id) sender;
- (void) handleDeleteRecord:(id) sender;

// App menu
- (void) handlePrefs:(id) sender;
- (IBAction)showAboutBox:(id)sender;

- (void) handleCheckVersion:(id) sender;
- (void) handleBugReport:(id) sender;
- (void) handleFeatureRequest:(id) sender;
- (void) handleDonate:(id) sender;
- (void) handleEmail:(id) sender;

// Window menu
- (void) handleFileStats:(id) sender;

- (void) handleGoToFather:(id) sender;
- (void) handleGoToMother:(id) sender;
- (void) handleFamGoToHusb:(id) sender;
- (void) handleFamGoToWife:(id) sender;
- (void) handleFamGoToChild:(id) sender;

- (void) setupToolbar;

@end
