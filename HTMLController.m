#include <unistd.h>

#import "HTMLController.h"

@implementation HTMLController

+ (HTMLController*) sharedHTML
{
  static HTMLController* shared_html = nil;
  
  if( ! shared_html )
    shared_html = [[HTMLController alloc] initNib];
    
  return shared_html;
}

- (HTMLController*) initNib
{
  [NSBundle loadNibNamed: @"HTML" owner:self];
  
  return self;
}

- (NSWindow*) window
{
  return window;
}

- (void) setGED: (GCFile*) my_ged
{
  ged = my_ged;
  [progress setDoubleValue: 0];
}

- (BOOL) exportHTML: (NSString*) my_dir
{
  BOOL result = true;
  NSString* html_path = [my_dir stringByAppendingString: @"/index.html"];
  NSString* alpha = @"ABCDEFGHIJKLMNOPQRSTUVWXYZ";
  NSString* prefix;
  int i = 0;
//  NSFileHandle* html_file = [NSFileHandle fileHandleForWritingAtPath: html_path];
 
  NSMutableString* html_text = [[NSMutableString alloc] initWithString: @"<html><head><title>GenerationX "];
  
  NSModalSession modal = [NSApp beginModalSessionForWindow: window];
  [NSApp runModalSession: modal];

  // first the index type pages
  [html_text appendString: [[NSDate date] description]];
  [html_text appendString: @"</title></head>\n<body bgcolor=FFFFFF>\n\n"];
  [html_text appendString: @"<center><font size=+5>G</font><font size=+2>enerationX</font>\n<br>\n<i>"];
  [html_text appendString: [[NSDate date] description]];
  [html_text appendString: @"</i></center>\n<p>\n"];
  [html_text appendString: [[NSNumber numberWithInt: [ged numIndividuals]] stringValue]];
  [html_text appendString: @" individuals in this database:\n<p><center>\n"];
  [header setStringValue: @"Building Index Pages"];
//  [progress setDoubleValue: 1.0];
  [window displayIfNeeded];
  for( i = 0; i < [alpha length]; i++ )
  {
    prefix = [[alpha substringFromIndex: i] substringToIndex: 1];
    
    [html_text appendString: @"<a href=\"INDI_"];
    [html_text appendString: prefix];
    [html_text appendString: @".html\">"];
    [html_text appendString: prefix];
    [html_text appendString: @"</a>\n"];

    if( ![self buildINDIIndexPage: prefix: my_dir] )
    {
      [NSApp endModalSession: modal];
      [window orderOut: self];
      return false;
    }
  }
  [html_text appendString: @"\n"];
  [html_text appendString: @"\n"];
  [html_text appendString: @"\n"];
  [html_text appendString: @"\n"];
  [html_text appendString: @"\n"];
  [html_text appendString: @"\n"];
  [html_text appendString: @"</body></html>\n"];
    
  if( ![html_text writeToFile: html_path atomically: true] )
    result = false;

  // and now the INDI pages
  if( ![self buildINDIPages: my_dir] )
  {
    [NSApp endModalSession: modal];
    [window orderOut: self];
    return false;
  }    

  [NSApp endModalSession: modal];
  [window orderOut: self];
  return true;
}

- (BOOL) buildINDIIndexPage: (NSString*) my_prefix: (NSString*) my_dir
{
  INDI* tmp_indi;
  NSString* prefix;
  int i = 0;
  NSString* alpha = @"ABCDEFGHIJKLMNOPQRSTUVWXYZ";
  NSString* stripped_label;
  NSMutableArray* indi_array = [ged indisWithPrefix: my_prefix];
  NSMutableString* html_text = [[NSMutableString alloc] initWithString: @"<html><head><title>GenerationX "];
  NSMutableString* html_path = [[NSMutableString alloc] initWithString: my_dir];
  [html_path appendString: @"/INDI_"];
  [html_path appendString: my_prefix];
  [html_path appendString: @".html"];

  [html_text appendString: [[NSDate date] description]];
  [html_text appendString: @"</title></head>\n<body bgcolor=FFFFFF>\n\n"];
  [html_text appendString: @"<center><font size=+5>G</font><font size=+2>enerationX</font>\n<br>\n<i>"];
  [html_text appendString: [[NSDate date] description]];
  [html_text appendString: @"</i>\n<p>\n"];
  for( i = 0; i < [alpha length]; i++ )
  {
    prefix = [[alpha substringFromIndex: i] substringToIndex: 1];
    [html_text appendString: @"<a href=\"INDI_"];
    [html_text appendString: prefix];
    [html_text appendString: @".html\">\n"];
    [html_text appendString: prefix];
    [html_text appendString: @"</a>\n"];
  }
  [html_text appendString: @"<p><table border=0 width=600 cellpadding=10><tr><td valign=top>"];
  
  [indi_array sortUsingSelector: @selector(compare:)];
  for( i = 0; i < [indi_array count]; i++ )
  {
    if( [indi_array count] > 20 && i == [indi_array count]/2 )
      [html_text appendString: @"<td valign=top>"];
      
    tmp_indi = [indi_array objectAtIndex: i];
    stripped_label = [[[tmp_indi fieldValue] componentsSeparatedByString: @"@"] objectAtIndex: 1];
    [html_text appendString: @"<a href=\"INDI"];
//    [html_text appendString: my_prefix];
    [html_text appendString: @"/"];
    [html_text appendString: stripped_label];
    [html_text appendString: @".html\">"];
    [html_text appendString: [tmp_indi lastName]];
    [html_text appendString: @", "];
    [html_text appendString: [tmp_indi firstName]];
    [html_text appendString: @" "];
    [html_text appendString: [tmp_indi nameSuffix]];
    [html_text appendString: @"</a><br>\n"];
    [html_text appendString: @"\n"];
    [html_text appendString: @"\n"];
  }
  [html_text appendString: @"</table></body></html>\n"];
  
  if( ![html_text writeToFile: html_path atomically: true] )
    return false;
  
  return true;
}

- (BOOL) buildINDIPages: (NSString*) my_dir
{
  INDI* tmp_indi;
  int i = 0;
  double progress_value;
  BOOL is_dir;
  NSFileManager* manager = [NSFileManager defaultManager];
  NSString* stripped_label;
//  NSMutableArray* indi_array = [ged indisWithPrefix: my_prefix];
    NSMutableString* html_text = [[NSMutableString alloc] initWithString: @"<html><head><title>GenerationX "];
//  NSMutableString* indi_text = [[NSMutableString alloc] init];
  NSMutableString* indi_path = [[NSMutableString alloc] init];
  NSMutableString* html_path = [[NSMutableString alloc] initWithString: my_dir];
  int num_indi = [ged numIndividuals];
  
  [html_path appendString: @"/INDI"];
//  [html_path appendString: my_prefix];

  [html_text appendString: [[NSDate date] description]];
  [html_text appendString: @"</title></head>\n<body bgcolor=FFFFFF>\n\n"];
  [html_text appendString: @"<center><font size=+5>G</font><font size=+2>enerationX</font>\n<br>\n<i>"];
  [html_text appendString: [[NSDate date] description]];
  [html_text appendString: @"</i>\n<p><table border=0>\n"];

  if( !( [manager fileExistsAtPath: indi_path isDirectory: &is_dir] && is_dir ) )
    [manager createDirectoryAtPath: html_path attributes: nil];
    
//  [indi_array sortUsingSelector: @selector(compare:)];
  [header setStringValue: @"Building Individual Pages"];
  for( i = 0; i < num_indi; i++ )
  {
    progress_value = ((i * 100.0)/num_indi);
    [progress setDoubleValue: (double)progress_value];
    [window displayIfNeeded];
    tmp_indi = [ged indiAtIndex: i];
    stripped_label = [[[tmp_indi fieldValue] componentsSeparatedByString: @"@"] objectAtIndex: 1];
    [indi_path setString: html_path];
    [indi_path appendString: @"/"];
    [indi_path appendString: stripped_label];
    [indi_path appendString: @".html"];
    
    if( ![[tmp_indi htmlSummary: ged] writeToFile: indi_path atomically: true] )
      return false;
  }
  
  return true;
}

@end
