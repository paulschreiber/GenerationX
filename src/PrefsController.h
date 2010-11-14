/* PrefsController */

#import <Cocoa/Cocoa.h>

@interface PrefsController : NSObject
{
    IBOutlet id htmlEmailText;
    IBOutlet id htmlTimestampSwitch;
    IBOutlet id htmlTitleText;
    IBOutlet id panel;
}

+ (PrefsController*) sharedPrefs;
- (PrefsController*) initNib;
- (void) showPrefs;

- (IBAction)handleHtmlChangeEmail:(id)sender;
- (IBAction)handleHtmlChangeTimestamp:(id)sender;
- (IBAction)handleHtmlChangeTitle:(id)sender;
@end
