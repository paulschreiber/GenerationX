/* NewIndiController */

#import <Cocoa/Cocoa.h>
#import "GCFile.h"

@interface GenericEventController : NSObject
{
    IBOutlet NSWindow* generic_event_window;

    IBOutlet NSTextField*   header_text;
    IBOutlet NSPopUpButton* event_day;
    IBOutlet NSPopUpButton* event_month;
    IBOutlet NSTextField*   event_year;
    IBOutlet NSTextField*   event_place;
    IBOutlet NSTextField*   note_text;
    IBOutlet NSTextField*   source_text;

    NSModalSession modal_session;
    NSString* type;
//    GCFile* ged;
    GCField* field;
}

+ (GenericEventController*) sharedEvent;
- (GenericEventController*) initNib;
- (void) setField: (id) my_field;
- (void) process;
- (void) handleOk: (id) sender;
- (void) handleCancel: (id) sender;
- (NSWindow*) window;

@end
