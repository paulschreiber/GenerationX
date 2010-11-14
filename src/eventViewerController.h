/* eventViewerController */

#import <Cocoa/Cocoa.h>

#import "GCField.h"

@interface eventViewerController : NSObject
{
    IBOutlet id eventTable;
    IBOutlet id panel;
    IBOutlet id sourceText;
		
    IBOutlet id addEventSheet;
    IBOutlet id addEventMenu;

		GCField* currentRecord;
}

+ (eventViewerController*) sharedEventPanel;
- (eventViewerController*) init;

- (void) toggle;
- (void) updateWithRecord: (GCField*) r;
- (BOOL) isVisible;

- (void) handleSelectSource: (id) sender;
- (void) handleChangeSource: (id) sender;
- (void) handleAddEvent: (id) sender;
- (void) handleDeleteEvent: (id) sender;
- (void) handleSelectEventType: (id) sender;
- (void) addEventSheetDidEnd;

@end
