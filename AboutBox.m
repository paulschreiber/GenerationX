//  AboutBox.m
//  GenerationX
//
//  Created by Benjamin Chartier on August 26 2002.

#import "AboutBox.h"

@implementation AboutBox

static AboutBox* sharedInstance = nil;

+ (AboutBox*)sharedInstance
{
  return sharedInstance ? sharedInstance : [[self alloc] init];
}

- (id)init
{
  if( sharedInstance )
  {
    [self dealloc];
  }
  
  if( !sharedInstance )
  {
    sharedInstance = [super init];
  }
  
  return sharedInstance;
}

- (void)showPanel
{
  NSWindow*	aboutBoxWindow;
  
  // If the AboutBox window does not exist yet
  if( !appNameField )
  {
    
    // Attempt to load the AboutBox nib file
    if( ![NSBundle loadNibNamed:@"AboutBox" owner: self] )
    {
      NSLog( @"Failed to load AboutBox.nib" );
      return;
    }
    
    aboutBoxWindow = [appNameField window];
    
    // Set up of all the window fields
    {
      NSString*					appName;
      NSString*					appVersion;
      NSString*					copyrightString;
      
      NSString*					creditsPath;
      NSAttributedString*		creditsString;
      
      NSDictionary*				infoAppPlist;
      NSDictionary*				infoAppLocalizedPlist;
      CFBundleRef				mainBundle;
    
      // Get the info.plist dictionary
      infoAppPlist = [[NSBundle mainBundle] infoDictionary];
      
      // Get the localized InfoPlist.strings dictionary
      mainBundle = CFBundleGetMainBundle();
      infoAppLocalizedPlist = (NSDictionary*)CFBundleGetLocalInfoDictionary( mainBundle );

      // Set AppNameField value
      appName = [infoAppLocalizedPlist objectForKey: @"CFBundleName"];
      if( appName )
        [appNameField setStringValue: appName];
      
      // Set AppVersionField value
      appVersion = [infoAppLocalizedPlist objectForKey: @"CFBundleVersion"];
      if( appVersion )
        [versionField setStringValue: appVersion];

      // Set CreditField value
      creditsPath = [[NSBundle mainBundle] pathForResource: @"AboutBox" ofType: @"rtf"];
      creditsString = [[NSAttributedString alloc] initWithPath: creditsPath documentAttributes: nil];
      [creditsField replaceCharactersInRange: NSMakeRange(0,0)
        withString: @"\n\n\n\n\n\n\n\n"];
      [creditsField replaceCharactersInRange: NSMakeRange(0,0)
        withRTF: [creditsString RTFFromRange: NSMakeRange(0, [creditsString length]) documentAttributes: nil]];
      [creditsField replaceCharactersInRange: NSMakeRange(0,0)
        withString: @"\n\n\n\n\n\n\n\n"];

      // Set CopyrightField value
      copyrightString = [infoAppLocalizedPlist objectForKey: @"NSHumanReadableCopyright"];
      if( copyrightString )
        [copyrightField setStringValue: copyrightString];

      // Prepare scrolling information
      // scrollHeight is set to a negaticve value to let scrollCredits method know that
      // this variable is not wet set to the proper value
      // This variable is properly set in initScrollInfo
      scrollHeight = -1;
    }
    
    // Is the AboutBox visible ?
    if( ![aboutBoxWindow isVisible] )
    {
      scrollPos = 0.;
      scrollRestartAtTop = NO;
      [creditsField scrollPoint: NSMakePoint(0,scrollPos)];
    }

    // Prepare the window before it appears to user
    [aboutBoxWindow setExcludedFromWindowsMenu: YES];
    [aboutBoxWindow setMenu: nil];
    [aboutBoxWindow center];
  }
  else
  {
    aboutBoxWindow = [appNameField window];

    if( ![aboutBoxWindow isVisible] )
    {
      scrollPos = 0.;
      scrollRestartAtTop = NO;
      [creditsField scrollPoint: NSMakePoint(0,scrollPos)];
    }
  }
  
  // Show the window
  aboutBoxWindow = [appNameField window];
  [aboutBoxWindow makeKeyAndOrderFront: nil];
}

- (void)windowDidBecomeKey: (NSNotification*)notification
{
  scrollTimer = [NSTimer 	scheduledTimerWithTimeInterval: 0.01
                            target: self
                            selector: @selector(scrollCredits:)
                            userInfo: nil
                            repeats: YES];
}

- (void)windowDidResignKey: (NSNotification*)notification
{
  [scrollTimer 	invalidate];
}

- (void)initScrollInfo
{
  // The scroll height is equal to the height of the text minus the height of the content view
	scrollHeight = [[[creditsField enclosingScrollView] documentView] bounds].size.height;
    scrollHeight -= [[[creditsField enclosingScrollView] contentView] bounds].size.height;
}

- (void)scrollCredits: (NSTimer*)timer
{
  // Check if scrollHeight is properly set
  if( scrollHeight < 0 )
  {
    [self initScrollInfo];
  }

  // Is the scroll waiting for restart ?
  if( scrollRestartAtTop )
  {
    // Scrolling info initialization
    scrollRestartAtTop = NO;
    scrollPos = 0.;
      
    return;
  }
  
  // Has the scroll reached the bottom ?
  if( scrollPos >= scrollHeight )
  {
    // Ask for restarting at top
    scrollRestartAtTop = YES;
  }
  else
  {
    // Scroll credits
    [creditsField scrollPoint: NSMakePoint(0, scrollPos)];
    scrollPos += 0.1;
  }
}

@end
