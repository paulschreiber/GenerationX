/* NewIndiController */

#import <Cocoa/Cocoa.h>
#import "GCFile.h"

@interface EventWithFAMCController : NSObject
{
    IBOutlet NSWindow* event_window;

    IBOutlet NSTextField*   header_text;
    IBOutlet NSPopUpButton* event_day;
    IBOutlet NSPopUpButton* event_month;
    IBOutlet NSTextField*   event_year;
    IBOutlet NSTextField*   event_place;
    IBOutlet NSTextField*   father_label;
    IBOutlet NSTextField*   father_text;
    IBOutlet NSTextField*   mother_label;
    IBOutlet NSTextField*   mother_text;
    IBOutlet NSTextField*   source_text;
    IBOutlet NSTextField*   note_text;

    NSModalSession modal_session;
    NSString* type;
    GCFile* ged;
    GCField* field;
    INDI* indi;
}

+ (EventWithFAMCController*) sharedEvent;
- (EventWithFAMCController*) initNib;
//- (void) setType: (NSString*) my_type;
- (void) setField: (id) my_field: (id) my_indi: (id) my_ged;
- (void) process;
- (void) handleOk: (id) sender;
- (void) handleCancel: (id) sender;
- (NSWindow*) window;

@end
