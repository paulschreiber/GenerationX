/* GenerationXController */

#import <Cocoa/Cocoa.h>
#import <Foundation/Foundation.h>
#import "GCFile.h"
#import "RecordListDataSource.h"
#import "PreferencesController.h"

@interface GenerationXController : NSView
{
    IBOutlet NSWindow*    main_window;
    IBOutlet NSTabView*   main_tabs;
    
    IBOutlet NSMenuItem*  event_menu;
    IBOutlet NSMenuItem*  indi_event_menu;
    IBOutlet NSMenuItem*  fam_event_menu;

    IBOutlet NSDrawer*    indi_drawer;
    IBOutlet NSTableView* indi_list;
    IBOutlet NSTextField* indi_filter_text;
    IBOutlet NSButton*    indi_filter_button;
    IBOutlet NSTextField* displayed_indi_text;
    IBOutlet NSTextField* indi_name;
    IBOutlet NSTextField* indi_info;
    IBOutlet NSImageView* indi_image;
    IBOutlet NSImageView* fam_image;

    IBOutlet NSDrawer*    fam_drawer;
    IBOutlet NSTableView* fam_list;
    IBOutlet NSTextField* fam_filter_text;
    IBOutlet NSButton*    fam_filter_button;
    IBOutlet NSTextField* displayed_fam_text;
    IBOutlet NSTextField* fam_info;

    IBOutlet NSDrawer*    event_drawer;
    IBOutlet NSTableView* event_list;

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

    IBOutlet NSTextField*   dec_name;
    IBOutlet NSOutlineView* dec_outline;
    
    RecordListDataSource*  record_data_source;
    NSTimer* auto_save_timer;

    GCFile*               ged;
    GCField*              current_record;
    GCField*              current_event;
}

- (void) refreshGUI;
- (IBAction)handleSelectIndi:(id)sender;
- (void) handleFilter:(id) sender;
- (IBAction)handleSelectFam:(id)sender;
- (void) handleIndiMode:(id) sender;
- (void) handleFamMode:(id) sender;
- (void) handlePedigreeMode:(id) sender;
- (void) handleDescendantMode:(id) sender;
- (void) handlePedigreeClick:(id) sender;
- (void) handleImageClick:(id) sender;
- (void) showRawPanel:(id) sender;
- (void) handleEventsToolbar:(id) sender;

// INDI events
- (void) handleAddChristening:(id) sender;
- (void) handleAddBaptism:(id) sender;
- (void) handleAddBlessing:(id) sender;
- (void) handleAddConfirmation:(id) sender;
- (void) handleAddBarmitzvah:(id) sender;
- (void) handleAddBasmitzvah:(id) sender;
- (void) handleAddFirstCommunion:(id) sender;
- (void) handleAddAdultChristening:(id) sender;
- (void) handleAddOrdination:(id) sender;
- (void) handleAddAdoption:(id) sender;
- (void) handleAddEmigration:(id) sender;
- (void) handleAddImmigration:(id) sender;
- (void) handleAddNaturalization:(id) sender;
- (void) handleAddGraduation:(id) sender;
- (void) handleAddRetirement:(id) sender;
- (void) handleAddProbate:(id) sender;
- (void) handleAddWill:(id) sender;
- (void) handleAddCremation:(id) sender;
- (void) handleAddBurial:(id) sender;

// FAM events
- (void) handleAddEngagement:(id) sender;
- (void) handleAddDivorce:(id) sender;
- (void) handleAddAnnulment:(id) sender;
- (void) handleAddMarriageBann:(id) sender;
- (void) handleAddMarriageSettlement:(id) sender;
- (void) handleAddMarriageContract:(id) sender;
- (void) handleAddMarriageLicense:(id) sender;
- (void) handleAddDivorceFiling:(id) sender;

// FAM & INDI events
- (void) handleAddMarriage:(id) sender;
- (void) handleAddNote:(id) sender;
- (void) handleAddImage:(id) sender;

// Reports
- (void) handleDescendantsGEDCOM:(id) sender;
- (void) handleAncestorsGEDCOM:(id) sender;
- (void) handleDescendantReport:(id) sender;
- (void) handleAllHTML:(id) sender;

- (void) handleAddOtherEvent:(id) sender;
- (void) addEvent:(NSString*) type;
- (void) handleNewRecord:(id) sender;
- (void) handleEditRecord:(id) sender;
- (void) handleDeleteRecord:(id) sender;
- (void) handleOpenFile:(id) sender;
- (void) doOpenFile;
- (void) handleSaveFile:(id) sender;
- (void) handleSaveAs:(id) sender;
- (void) handleNewFile:(id) sender;
- (void) doNewFile;
- (void) handleMergeFile:(id) sender;
- (void) handlePrefs:(id) sender;
- (void) handleCheckVersion:(id) sender;
- (void) setupToolbar;

@end
