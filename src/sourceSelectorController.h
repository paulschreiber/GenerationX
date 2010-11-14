/* sourceSelectorController */

#import <Cocoa/Cocoa.h>
#import "GCField.h"

@interface sourceSelectorController : NSObject
{
    IBOutlet id panel;
    IBOutlet id sourceTable;
    IBOutlet id sourceText;
		
		GCField* currentSource;
		id callbackObj;
}

+ (sourceSelectorController*) sharedSelector;
- (sourceSelectorController*) initNib;

- (void) refresh;
- (NSWindow*) panel;
- (GCField*) selectedSource;

- (IBAction)handleCancel:(id)sender;
- (IBAction)handleOK:(id)sender;

@end
