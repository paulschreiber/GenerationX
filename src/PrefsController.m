#import "PrefsController.h"

#define prefs [NSUserDefaults standardUserDefaults]

@implementation PrefsController

+ (PrefsController*) sharedPrefs
{
  static PrefsController* shared_panel = nil;
  
  if( ! shared_panel )
    shared_panel = [[PrefsController alloc] initNib];
    
  return shared_panel;
}

- (PrefsController*) initNib
{
  [NSBundle loadNibNamed: @"Prefs" owner:self];
  
  return self;
}

- (void) showPrefs
{
  [htmlTitleText setStringValue: [prefs objectForKey: @"htmlTitle"]];
  [htmlEmailText setStringValue: [prefs objectForKey: @"htmlEmailAddress"]];
	
	if( [[prefs objectForKey: @"htmlIncludeTimestamp"] boolValue] )
	  [htmlTimestampSwitch setState: NSOnState];
	else
	  [htmlTimestampSwitch setState: NSOffState];
	
	[panel makeKeyAndOrderFront: nil];
}

- (IBAction)handleHtmlChangeEmail:(id)sender
{
  [prefs setObject: [htmlEmailText stringValue] forKey: @"htmlEmailAddress"];
}

- (IBAction)handleHtmlChangeTimestamp:(id)sender
{
  [prefs setObject: [NSNumber numberWithBool: ![[prefs objectForKey: @"htmlIncludeTimestamp"] boolValue]] forKey: @"htmlIncludeTimestamp"];
}

- (IBAction)handleHtmlChangeTitle:(id)sender
{
  [prefs setObject: [htmlTitleText stringValue] forKey: @"htmlTitle"];
}

@end
