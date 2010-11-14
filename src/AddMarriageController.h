/* NewIndiController */

#import <Cocoa/Cocoa.h>
#import "GCFile.h"

@interface AddMarriageController : NSObject
{
    IBOutlet NSWindow* add_marr_window;

    IBOutlet NSTextField*   header_text;
    IBOutlet NSTextField*   spouse_text;
    IBOutlet NSPopUpButton* marr_day;
    IBOutlet NSPopUpButton* marr_month;
    IBOutlet NSTextField*   marr_year;
    IBOutlet NSTextField*   marr_place;
    IBOutlet NSTextField*   note_text;
    IBOutlet NSTextField*   source_text;

    NSModalSession modal_session;
    GCFile* ged;
    INDI* indi;
    FAM* event;
}

+ (AddMarriageController*) sharedAddMarr;
- (AddMarriageController*) initNib;
- (void) prepForDisplay: (id) my_ged: (id) my_event: (id) my_indi;
- (void) process;
- (void) handleOk: (id) sender;
- (void) handleCancel: (id) sender;
- (NSWindow*) window;

@end
