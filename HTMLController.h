/* HTMLController */

#import <Cocoa/Cocoa.h>
#import "GCFile.h"
#import "PreferencesController.h"

@interface HTMLController : NSObject
{
    IBOutlet NSWindow* window;
    IBOutlet NSTextField* header;
    IBOutlet NSProgressIndicator* progress;
    
    GCFile* ged;
}

+ (HTMLController*) sharedHTML;
+ (NSString*) HTMLHeader;

- (HTMLController*) initNib;
- (NSWindow*) window;
- (void) setGED: (GCFile*) my_ged;
- (BOOL) exportHTML: (NSString*) my_dir;
- (BOOL) buildINDIIndexPage: (NSString*) my_prefix: (NSString*) my_dir;
- (BOOL) buildINDIPages: (NSString*) my_dir;
- (BOOL) buildSurnamePages: (NSString*) my_dir;

@end
