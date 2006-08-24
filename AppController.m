#import "AppController.h"
#import "RawPanelController.h"
#import "indiDetailPanelController.h"
#import "famDetailPanelController.h"
#import "ImageViewerController.h"
#import "eventViewerController.h"
#import "NoteViewerController.h"
#import "PrefsController.h"

#define prefs [NSUserDefaults standardUserDefaults]
#define currentDoc [[NSDocumentController sharedDocumentController] currentDocument]
#define expire @"1 OCT 2006"

@implementation AppController

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
  NSDate* date = [NSDate date];
	NSDate* expires = [NSDate dateWithNaturalLanguageString: expire];
  NSMutableDictionary* defaults = [[NSMutableDictionary alloc] init];
	
//
// alpha expiration code
//
  if( [date timeIntervalSinceDate: expires] > 0 )
	{
    int button = NSRunAlertPanel( @"Expired",
			 @"This alpha version has expired. Please download the latest software from our website. The application will now quit.",
			 @"OK", @"Visit Website", nil );

    if( button == 0 )
		  [[NSWorkspace sharedWorkspace] openURL: [NSURL URLWithString: @"http://thenowhereman.com/hacks/"]];
		[NSApp terminate: nil];
	}
	  
	[defaults setObject: @"user@mail.com" forKey: @"htmlEmailAddress"];
	[defaults setObject: @"GenerationX 3.0" forKey: @"htmlTitle"];
	[defaults setObject: [NSNumber numberWithBool: YES] forKey: @"htmlIncludeTimestamp"];
	[[NSUserDefaults standardUserDefaults] registerDefaults:defaults];
	
  if( [prefs boolForKey: @"IndiPanelIsVisible"] )
	  [[indiDetailPanelController sharedIndiDetailPanel] toggle];
  if( [prefs boolForKey: @"FamPanelIsVisible"] )
	  [[famDetailPanelController sharedFamDetailPanel] toggle];
  if( [prefs boolForKey: @"EventPanelIsVisible"] )
	  [[eventViewerController sharedEventPanel] toggle];
  if( [prefs boolForKey: @"NotePanelIsVisible"] )
	  [[NoteViewerController sharedViewer] toggle];
  if( [prefs boolForKey: @"ImagePanelIsVisible"] )
	  [[ImageViewerController sharedViewer] toggle];
  if( [prefs boolForKey: @"RawPanelIsVisible"] )
	  [[RawPanelController sharedRawPanel] toggle];
}

- (NSApplicationTerminateReply)applicationShouldTerminate:(NSApplication *)sender
{
	[prefs setObject: [NSNumber numberWithBool: [[indiDetailPanelController sharedIndiDetailPanel] isVisible]] forKey: @"IndiPanelIsVisible"];
	[prefs setObject: [NSNumber numberWithBool: [[famDetailPanelController sharedFamDetailPanel] isVisible]] forKey: @"FamPanelIsVisible"];
	[prefs setObject: [NSNumber numberWithBool: [[eventViewerController sharedEventPanel] isVisible]] forKey: @"EventPanelIsVisible"];
	[prefs setObject: [NSNumber numberWithBool: [[NoteViewerController sharedViewer] isVisible]] forKey: @"NotePanelIsVisible"];
	[prefs setObject: [NSNumber numberWithBool: [[ImageViewerController sharedViewer] isVisible]] forKey: @"ImagePanelIsVisible"];
	[prefs setObject: [NSNumber numberWithBool: [[RawPanelController sharedRawPanel] isVisible]] forKey: @"RawPanelIsVisible"];
	
	return YES;
}

- (IBAction)handleShowPrefs:(id)sender
{
  [[PrefsController sharedPrefs] showPrefs];
}

- (IBAction)handleShowGEDCOM:(id)sender
{
	[[RawPanelController sharedRawPanel] toggle];
}

- (IBAction)handleShowIndiDetail:(id)sender
{
	[[indiDetailPanelController sharedIndiDetailPanel] toggle];
}

- (IBAction)handleShowFamDetail:(id)sender
{
	[[famDetailPanelController sharedFamDetailPanel] toggle];
}

- (IBAction)handleShowImageViewer:(id)sender
{
  [[ImageViewerController sharedViewer] toggle];
}

- (IBAction)handleShowEventViewer:(id)sender
{
  [[eventViewerController sharedEventPanel] toggle];
}

- (IBAction)handleShowNoteViewer:(id)sender
{
  [[NoteViewerController sharedViewer] toggle];
}

- (void) handleDescendantsGEDCOM:(id) sender
{
  [currentDoc handleDescendantsGEDCOM: nil];
}

- (void) handleAncestorsGEDCOM:(id) sender
{
  [currentDoc handleAncestorsGEDCOM: nil];
}

- (void) handleDescendantReport:(id) sender
{
  [currentDoc handleDescendantReport: nil];
}

- (void) handleAncestorsReport:(id) sender
{
  [currentDoc handleAncestorsReport: nil];
}

- (void) handleAllHTML:(id) sender
{
  [currentDoc handleAllHTML: nil];
}

- (void) handleMergeFile:(id) sender
{
  [currentDoc handleMergeFile: nil];
}

@end
