/* NewIndiController */

#import <Cocoa/Cocoa.h>
#import "GCFile.h"

@interface EditIndiController : NSObject
{
    IBOutlet NSWindow* new_indi_window;

    IBOutlet NSMatrix* sex_matrix;

    IBOutlet NSTextField* first_name;
    IBOutlet NSTextField* last_name;
    IBOutlet NSTextField* name_suffix;
    
    IBOutlet NSPopUpButton* birth_day;
    IBOutlet NSPopUpButton* birth_month;
    IBOutlet NSTextField*   birth_year;
    IBOutlet NSTextField*   birth_place;

    IBOutlet NSPopUpButton* death_day;
    IBOutlet NSPopUpButton* death_month;
    IBOutlet NSTextField*   death_year;
    IBOutlet NSTextField*   death_place;
    
    IBOutlet NSTextField* mother_text;
    IBOutlet NSTextField* father_text;

    NSModalSession modal_session;
    GCFile* ged;
    INDI* field;
}

+ (EditIndiController*) sharedNewIndi;
- (EditIndiController*) initNib;
- (void) prepForDisplay: (id) my_ged: (id) my_field;
- (void) process;
- (void) handleOk: (id) sender;
- (void) handleCancel: (id) sender;
- (NSWindow*) window;

@end
