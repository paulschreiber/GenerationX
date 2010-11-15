#include <unistd.h>

#import "HTMLController.h"

#define prefs [NSUserDefaults standardUserDefaults]

@implementation HTMLController

+ (HTMLController*) sharedHTML
{
	static HTMLController* shared_html = nil;
	
	if ( ! shared_html )
		shared_html = [[HTMLController alloc] initNib];
    
	return shared_html;
}

+ (NSString*) HTMLHeader
{
	NSMutableString* result = [NSMutableString stringWithCapacity:1];
	
	[result setString: @"<html><head><title>"];
	[result appendString: [prefs objectForKey: @"htmlTitle"]];
	if ( [[prefs objectForKey: @"htmlIncludeTimestamp"] boolValue] )
	{
		[result appendString: @" "];
		[result appendString: [[NSDate date] description]];
	}
	[result appendString: @"</title>\n"];
	[result appendString: @"<style type=\"text/css\"><!--\n"];
	[result appendString: @"body{\n"];
	[result appendString: @"  background: #"];
	[result appendString: @"#FFFFFF"];//[[PreferencesController sharedPrefs] HTMLBackColor]];
	[result appendString: @";\n"];
	[result appendString: @"  font-family: sans-serif;\n"];
	[result appendString: @"  font-size: 12px;\n"];
	[result appendString: @"  color: #"];
	[result appendString: @"#000000"];//[[PreferencesController sharedPrefs] HTMLTextColor]];
	[result appendString: @";\n"];
	[result appendString: @"}\n"];
	[result appendString: @"td{\n"];
	//  [result appendString: @"  background: #"];
	//  [result appendString: [[PreferencesController sharedPrefs] HTMLBackColor]];
	//  [result appendString: @";\n"];
	[result appendString: @"  font-family: sans-serif;\n"];
	[result appendString: @"  font-size: 12px;\n"];
	[result appendString: @"  color: #"];
	[result appendString: @"#000000"];//[[PreferencesController sharedPrefs] HTMLTextColor]];
	[result appendString: @";\n"];
	[result appendString: @"}\n"];
	[result appendString: @"--></style>\n"];
	[result appendString: @"</head>\n"];
	
	return result;
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
	NSError *error;
	BOOL is_dir;
	NSMutableString* html_path = [NSMutableString stringWithString:
								  [my_dir stringByAppendingString: @"/index.html"]];
	NSString* alpha = @"ABCDEFGHIJKLMNOPQRSTUVWXYZ";
	NSString* prefix;
	NSString* title = [prefs objectForKey: @"htmlTitle"];
	NSMutableArray* surnames = [ged surnames];
	NSFileManager* manager = [NSFileManager defaultManager];
	NSUInteger i = 0;
	//  NSFileHandle* html_file = [NSFileHandle fileHandleForWritingAtPath: html_path];
	
	NSMutableString* html_text = [NSMutableString stringWithCapacity:1];
	
	NSModalSession modal = [NSApp beginModalSessionForWindow: window];
	[NSApp runModalSession: modal];
	
	[surnames sortUsingSelector: @selector( compare: )];
	
	// index.html
	[html_text setString: [HTMLController HTMLHeader]];
	[html_text appendString: @"<body>\n\n"];
	[html_text appendString: @"<table border=0 width=600 cellpadding=10>"];
	[html_text appendString: @"<tr><td bgcolor=\"#CCCCCC\"><font size=+2>"];
	[html_text appendString: title];
	[html_text appendString: @"</font>\n<br>\n<i>"];
	if ( [[prefs objectForKey: @"htmlIncludeTimestamp"] boolValue] )
		[html_text appendString: [[NSDate date] description]];
	[html_text appendString: @"</i>\n<tr><td>\n"];
	[html_text appendString: @"<a href=\"surnames/index.html\">All surnames</a> |\n"];
	//  [html_text appendString: @"<p>\n"];
	
	[header setStringValue: @"Building Index Pages"];
	//  [progress setDoubleValue: 1.0];
	[window displayIfNeeded];
	for ( i = 0; i < [alpha length]; i++ ) {
		prefix = [[alpha substringFromIndex: i] substringToIndex: 1];
		
		[html_text appendString: @"<a href=\"INDI_"];
		[html_text appendString: prefix];
		[html_text appendString: @".html\">"];
		[html_text appendString: prefix];
		[html_text appendString: @"</a>\n"];
		
		if ( ![self buildINDIIndexPage: prefix: my_dir] )
		{
			[NSApp endModalSession: modal];
			[window orderOut: self];
			return false;
		}
	}
	[html_text appendString: @"<p>\n"];
	[html_text appendString: [[NSNumber numberWithInteger: [ged numIndividuals]] stringValue]];
	[html_text appendString: @" individual records in this database<br>\n"];
	[html_text appendString: [[NSNumber numberWithInteger: [ged numFamilies]] stringValue]];
	[html_text appendString: @" family records in this database\n<br>\n"];
	[html_text appendString: [[NSNumber numberWithUnsignedLong:[surnames count]] stringValue]];
	[html_text appendString: @" surnames in this database\n"];
	if ( ! [[prefs objectForKey: @"htmlEmailAddress"] isEqualToString: @""] ) {
		[html_text appendString: @"<p><a href=\"mailto:"];
		[html_text appendString: [prefs objectForKey: @"htmlEmailAddress"]];
		[html_text appendString: @"\">Contact the owner of this database</a>\n"];
	}
	[html_text appendString: @"\n"];
	[html_text appendString: @"\n"];
	[html_text appendString: @"\n"];
	[html_text appendString: @"\n"];
	[html_text appendString: @"\n"];
	[html_text appendString: @"</table></body></html>\n"];
    
	if ( ![html_text writeToFile: html_path atomically: true encoding:NSUTF8StringEncoding error:&error] ) {
		return false;
	}
	
	// surnames/index.html
	[html_path setString: [my_dir stringByAppendingString: @"/surnames"]];
	
	if ( !( [manager fileExistsAtPath: html_path isDirectory: &is_dir] && is_dir ) ) {
		[manager createDirectoryAtPath:html_path withIntermediateDirectories:YES attributes:nil error:&error];
	}
	
	[html_path appendString: @"/index.html"];
	
	[html_text setString: [HTMLController HTMLHeader]];
	[html_text appendString: @"<body>\n<table border=0 width=600 cellpadding=10><tr><td bgcolor=#CCCCCC><font size=+2>"];
	[html_text appendString: [prefs objectForKey: @"htmlTitle"]];
	[html_text appendString: @"</font>\n<br>\n<i>"];
	if ( [[prefs objectForKey: @"htmlIncludeTimestamp"] boolValue] ) {
		[html_text appendString: [[NSDate date] description]];
	}
	[html_text appendString: @"</i>\n<tr><td>\n"];
	[html_text appendString: @"<a href=\"../index.html\">Home</a>\n"];
	if ( ! [[prefs objectForKey: @"htmlEmailAddress"] isEqualToString: @""] ) {
		[html_text appendString: @" | <a href=\"mailto:"];
		[html_text appendString: [prefs objectForKey: @"htmlEmailAddress"]];
		[html_text appendString: @"\">Contact</a>\n"];
	}
	[html_text appendString: @"<p>"];
	// for each surname in the database
	for ( i = 0; i < [surnames count]; i++ ) {
		// put it's link on the index page
		[html_text appendString: @"<a href=\"\n"];
		if ( [[surnames objectAtIndex: i] isEqualToString: @"?"] ) {
			[html_text appendString: @"unknown"];
		} else {
			[html_text appendString: [surnames objectAtIndex: i]];
		}
		[html_text appendString: @".html\">\n"];
		if ( [[surnames objectAtIndex: i] isEqualToString: @"?"] ) {
			[html_text appendString: @"unknown"];
		} else {
			[html_text appendString: [surnames objectAtIndex: i]];
		}
		[html_text appendString: @"</a><br>\n"];
	}
	[html_text appendString: @"\n"];
	[html_text appendString: @"</table></body></html>\n"];
	
	if ( ![html_text writeToFile: html_path atomically: true encoding:NSUTF8StringEncoding error:&error] ) {
		return false;
	}
	
	// surname pages
	if ( ![self buildSurnamePages: my_dir] ) {
		[NSApp endModalSession: modal];
		[window orderOut: self];
		return false;
	}    
	
	// and now the INDI pages
	if ( ![self buildINDIPages: my_dir] ) {
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
	NSError *error;
	INDI* tmp_indi;
	NSString* prefix;
	NSUInteger i = 0;
	NSString* alpha = @"ABCDEFGHIJKLMNOPQRSTUVWXYZ";
	NSString* stripped_label;
	NSMutableArray* indi_array = [ged indisWithPrefix: my_prefix];
	NSMutableString* html_text = [NSMutableString stringWithCapacity:1];
	NSMutableString* html_path = [NSMutableString stringWithString: my_dir];
	[html_path appendString: @"/INDI_"];
	[html_path appendString: my_prefix];
	[html_path appendString: @".html"];
	
	NSLog( @"%@", my_prefix );
	[html_text setString: [HTMLController HTMLHeader]];
	[html_text appendString: @"<body>\n<table border=0 width=600 cellpadding=10><tr><td bgcolor=#CCCCCC><font size=+2>"];
	[html_text appendString: [prefs objectForKey: @"htmlTitle"]];
	[html_text appendString: @"</font>\n<br>\n<i>"];
	if ( [[prefs objectForKey: @"htmlIncludeTimestamp"] boolValue] )
		[html_text appendString: [[NSDate date] description]];
	[html_text appendString: @"</i>\n<tr><td>\n"];
	[html_text appendString: @"<a href=\"index.html\">Home</a>\n"];
	if ( ! [[prefs objectForKey: @"htmlEmailAddress"] isEqualToString: @""] )
	{
		[html_text appendString: @" | <a href=\"mailto:"];
		[html_text appendString: [prefs objectForKey: @"htmlEmailAddress"]];
		[html_text appendString: @"\">Contact</a>\n"];
	}
	[html_text appendString: @"<p>"];
	for ( i = 0; i < [alpha length]; i++ )
	{
		prefix = [[alpha substringFromIndex: i] substringToIndex: 1];
		[html_text appendString: @"<a href=\"INDI_"];
		[html_text appendString: prefix];
		[html_text appendString: @".html\">\n"];
		[html_text appendString: prefix];
		[html_text appendString: @"</a>\n"];
	}
	[html_text appendString: @"<p><tr><td valign=top>"];
	
	[indi_array sortUsingSelector: @selector(compare:)];
	for ( i = 0; i < [indi_array count]; i++ )
	{
		if ( [indi_array count] > 20 && i == [indi_array count]/2 )
			[html_text appendString: @"<td valign=top>"];
		
		tmp_indi = [indi_array objectAtIndex: i];
		if ( [[[tmp_indi fieldValue] componentsSeparatedByString: @"@"] count] > 1 )
			stripped_label = [[[tmp_indi fieldValue] componentsSeparatedByString: @"@"] objectAtIndex: 1];
		else
			stripped_label = [tmp_indi fieldValue];
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
	
	if ( ![html_text writeToFile: html_path atomically: true encoding:NSUTF8StringEncoding error:&error] )
		return false;
	
	return true;
}

- (BOOL) buildINDIPages: (NSString*) my_dir
{
	NSError *error;
	INDI* tmp_indi;
	int i = 0;
	double progress_value;
	BOOL is_dir;
	NSFileManager* manager = [NSFileManager defaultManager];
	NSString* stripped_label;
	NSMutableString* indi_path = [NSMutableString stringWithCapacity:1];
	NSMutableString* html_path = [NSMutableString stringWithString: my_dir];
	NSInteger num_indi = [ged numIndividuals];
	
	[html_path appendString: @"/INDI"];
	
	if ( !( [manager fileExistsAtPath: indi_path isDirectory: &is_dir] && is_dir ) ) {
		[manager createDirectoryAtPath:html_path withIntermediateDirectories:YES attributes:nil error:&error];
	}
	
    
	[header setStringValue: @"Building Individual Pages"];
	for ( i = 0; i < num_indi; i++ ) {
		progress_value = ((i * 100.0)/num_indi);
		[progress setDoubleValue: (double)progress_value];
		[window displayIfNeeded];
		tmp_indi = [ged indiAtIndex: i];
		if ( [[[tmp_indi fieldValue] componentsSeparatedByString: @"@"] count] > 1 ) {
			stripped_label = [[[tmp_indi fieldValue] componentsSeparatedByString: @"@"] objectAtIndex: 1];
		} else {
			stripped_label = [tmp_indi fieldValue];
		}
		NSLog( @"%@", stripped_label );
		[indi_path setString: html_path];
		[indi_path appendString: @"/"];
		[indi_path appendString: stripped_label];
		[indi_path appendString: @".html"];
		
		if ( ![[tmp_indi htmlSummary: ged] writeToFile: indi_path atomically: true encoding:NSUTF8StringEncoding error:&error] ) {
			return false;
		}
	}
	
	return true;
}

- (BOOL) buildSurnamePages: (NSString*) my_dir
{
	NSError *error;
	NSMutableArray* surnames = [ged surnames];
	NSMutableArray* indis = nil;
	NSMutableString* html_path = [NSMutableString stringWithString:my_dir];
	NSMutableString* html_text = [NSMutableString stringWithCapacity:1];
	NSString* title = [prefs objectForKey: @"htmlTitle"];
	NSString* surname, *stripped_label;
	INDI* indi;
	NSUInteger i, j;
	
	[header setStringValue: @"Building Surname Pages"];
	
	[surnames sortUsingSelector: @selector( compare: )];
	
	for ( i = 0; i < [surnames count]; i++ ) {
		surname = [surnames objectAtIndex: i];
		indis = [ged indisWithNameContaining: surname];
		
		[html_path setString: my_dir];
		[html_path appendString: @"/surnames/"];
		if ( [surname isEqualToString: @"?"] ) {
			[html_path appendString: @"unknown"];
		} else {
			[html_path appendString: surname];
		}
		[html_path appendString: @".html"];
		
		[html_text setString: [HTMLController HTMLHeader]];
		[html_text appendString: @"<body>\n\n"];
		[html_text appendString: @"<table border=0 width=600 cellpadding=10>"];
		[html_text appendString: @"<tr><td bgcolor=\"#CCCCCC\"><font size=+2>"];
		[html_text appendString: title];
		[html_text appendString: @"</font>\n<br>\n<i>"];
		if ( [[prefs objectForKey: @"htmlIncludeTimestamp"] boolValue] ) {
			[html_text appendString: [[NSDate date] description]];
		}
		[html_text appendString: @"</i>\n<tr><td>\n"];
		[html_text appendString: @"<a href=\"../index.html\">Home</a>\n"];
		if ( ! [[prefs objectForKey: @"htmlEmailAddress"] isEqualToString: @""] ) {
			[html_text appendString: @" | <a href=\"mailto:"];
			[html_text appendString: [prefs objectForKey: @"htmlEmailAddress"]];
			[html_text appendString: @"\">Contact</a>\n"];
		}
		[html_text appendString: @"<p>"];
		for ( j = 0; j < [indis count]; j++ ) {
			indi = [indis objectAtIndex: j];
			if ( [[[indi fieldValue] componentsSeparatedByString: @"@"] count] > 1 ) {
				stripped_label = [[[indi fieldValue] componentsSeparatedByString: @"@"] objectAtIndex: 1];
			} else {
				stripped_label = [indi fieldValue];
			}
			
			[html_text appendString: @"<a href=\"../INDI/\n"];
			[html_text appendString: stripped_label];
			[html_text appendString: @".html\">"];
			[html_text appendString: [indi fullName]];
			[html_text appendString: @"</a><br>\n"];
			[html_text appendString: @"\n"];
		}
		[html_text appendString: @"\n"];
		[html_text appendString: @"\n"];
		[html_text appendString: @"</table></body></html>\n"];
		
		if ( ![html_text writeToFile: html_path atomically: true encoding:NSUTF8StringEncoding error:&error] ) {
			return false;
		}
	}
	
	return true;
}

@end
