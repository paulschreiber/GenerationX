/* IndiViewController */

#import <Cocoa/Cocoa.h>

@interface IndiViewController : NSObject
{
    IBOutlet NSTextField* name_label;
    IBOutlet NSView* indi_view;
}

- (id) init;
+ (IndiViewController*) sharedIndiView;
- (NSView*) indiView;

@end
