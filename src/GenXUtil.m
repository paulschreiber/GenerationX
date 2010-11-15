//
//  GenXUtil.m
//  GenerationX
//
//  Created by Nowhere Man on Tue Jun 11 2002.
//  Copyright (c) 2001 Nowhere Man. All rights reserved.
//

#import "GenXUtil.h"


@implementation GenXUtil

+ (GenXUtil*) sharedUtil
{
	static GenXUtil* shared_util = nil;
	
	if ( ! shared_util )
		shared_util = [[GenXUtil alloc] init];
    
	return shared_util;
}

// load the nib
- (GenXUtil*) init
{
	eventDict = [[NSMutableDictionary alloc] init];
	recent_places = [[NSMutableArray alloc] init];
	
	// INDI Events
	[eventDict setObject: @"Birth" forKey: @"BIRT"];
	[eventDict setObject: @"Death" forKey: @"DEAT"];
	[eventDict setObject: @"Burial" forKey: @"BURI"];
	[eventDict setObject: @"Cremation" forKey: @"CREM"];
	[eventDict setObject: @"Baptism" forKey: @"BAPM"];
	[eventDict setObject: @"Bar Mitzvah" forKey: @"BARM"];
	[eventDict setObject: @"Bas Mitzvah" forKey: @"BASM"];
	[eventDict setObject: @"Blessing" forKey: @"BLES"];
	[eventDict setObject: @"Adult Christening" forKey: @"CHRA"];
	[eventDict setObject: @"Confirmation" forKey: @"CONF"];
	[eventDict setObject: @"First Communion" forKey: @"FCOM"];
	[eventDict setObject: @"Ordination" forKey: @"ORDN"];
	[eventDict setObject: @"Naturalization" forKey: @"NATU"];
	[eventDict setObject: @"Emigration" forKey: @"EMIG"];
	[eventDict setObject: @"Immigration" forKey: @"IMMI"];
	[eventDict setObject: @"Census" forKey: @"CENS"];
	[eventDict setObject: @"Probate" forKey: @"PROB"];
	[eventDict setObject: @"Will" forKey: @"WILL"];
	[eventDict setObject: @"Graduation" forKey: @"GRAD"];
	[eventDict setObject: @"Occupation" forKey: @"OCCU"];
	[eventDict setObject: @"Retirement" forKey: @"RETI"];
	[eventDict setObject: @"Christening" forKey: @"CHR"];
	[eventDict setObject: @"Adoption" forKey: @"ADOP"];
	//  [eventDict setObject: @"Marriage" forKey: @"FAMS"];
	
	//FAM Events
	[eventDict setObject: @"Marriage" forKey: @"MARR"];
	[eventDict setObject: @"Engagement" forKey: @"ENGA"];
	[eventDict setObject: @"Divorce" forKey: @"DIV"];
	[eventDict setObject: @"Annulment" forKey: @"ANUL"];
	[eventDict setObject: @"Marriage Bann" forKey: @"MARB"];
	[eventDict setObject: @"Marriage Settlement" forKey: @"MARS"];
	[eventDict setObject: @"Marriage Contract" forKey: @"MARC"];
	[eventDict setObject: @"Marriage License" forKey: @"MARL"];
	[eventDict setObject: @"Divorce Filing" forKey: @"DIVF"];
	[eventDict setObject: @"Other..." forKey: @"EVEN"];
	
	return self;
}

- (NSString*) eventStringFromGEDCOM: (NSString*) my_gedcom
{
	return [eventDict objectForKey: my_gedcom];
}

- (NSString*) GEDCOMFromEventString: (NSString*) s
{
	NSArray* keys = [eventDict allKeys];
	NSUInteger i;
	
	for ( i = 0; i < [keys count]; i++ ) {
		if ( [[eventDict objectForKey: [keys objectAtIndex: i]] isEqualToString: s] ) {
			return [keys objectAtIndex: i];
		}
	}
	
	return @"";
}

- (NSDate*) dateFromGEDCOM: (NSString*) str
{
	//NSLog( @"GenXUtil::dateFromGEDCOM" );
	NSMutableString* date_str = [NSMutableString stringWithCapacity:1];
	NSString* tmp;
	NSScanner* s;
	int i;
	
	str = [str stringByTrimmingCharactersInSet: [NSCharacterSet whitespaceAndNewlineCharacterSet]];
	
	if ( !str ) {
		return nil;
	}
	
	if ( [str isEqualToString: @""] ) {
		return nil;
	}
    
	s = [NSScanner scannerWithString: str];
	[s setCharactersToBeSkipped: [NSCharacterSet letterCharacterSet]];
	[s scanInt: &i];
	
	// if the DATE field starts with an int between 1 and 31
	// assume we have a full DATE
	if ( i > 0 && i <= 31 )
		return [NSDate dateWithNaturalLanguageString: str];
	// otherwise we must have "MON YEAR" or just "YEAR"
	else
		[date_str appendString: @"1 "];
	
	// reset the scanner
	[s setScanLocation: 0];
	[s setCharactersToBeSkipped: [NSCharacterSet whitespaceAndNewlineCharacterSet]];
	// if DATE starts with letters, we maust have "MON YEAR"
	if ( [s scanCharactersFromSet: [NSCharacterSet letterCharacterSet] intoString: &tmp] )
	{
		[date_str appendString: str];
	}
	// otherwise we just have "YEAR"
	else
	{
		[date_str appendString: @"JAN "];
		[date_str appendString: str];
	}
	
	//NSLog( date_str );
	return [NSDate dateWithNaturalLanguageString: date_str];  
}

- (void) updateRecentPlacesWithString: (NSString*) s
{
	if ( [recent_places containsObject: s] )
		return;
    
	if ( [recent_places count] > 9 )
		[recent_places removeObjectAtIndex: 0];
    
	[recent_places addObject: s];
}

- (NSString*) recentPlaceWithPrefix: (NSString*) s
{
	NSUInteger i;
	
	for ( i = 0; i < [recent_places count]; i++ )
	{
		if ( [[recent_places objectAtIndex: i] hasPrefix: s] )
			return [recent_places objectAtIndex: i];
	}
	
	return nil;
}

@end
