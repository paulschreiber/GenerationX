#import "IndiViewController.h"

@implementation IndiViewController

+ (IndiViewController*) sharedIndiView
{
  static IndiViewController* shared_view = nil;

  if( shared_view == nil )
    shared_view = [[IndiViewController alloc] init];
    
  return shared_view;
}

- (IndiViewController*) init
{
  [NSBundle loadNibNamed: @"IndiView" owner:self];
    
  return self;  
}

- (NSView*) indiView
{
  return indi_view;
}

@end
