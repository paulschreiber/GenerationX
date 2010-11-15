	//
	//  GCFile.m
	//  GenerationX
	//
	//  Created by Nowhere Man on Tue Feb 19 2002.
	//  Copyright (c) 2001 Nowhere Man. All rights reserved.
	//

	//#import "PreferencesController.h"
#import "Util.h"
#import "GCFile.h"
#import "GCField.h"
#import "INDI.h"
#import "FAM.h"

	//
	// class models the data stored in a GEDCOM compliant file
	//

@implementation GCFile

	// set up an empty database
- (GCFile*)init
{
	GCField* header, *subm, *tmp;
	NSCalendarDate* todays_date = [NSCalendarDate calendarDate];
	NSMutableString* todays_date_str = [[[NSMutableString alloc] init] autorelease];
	NSMutableString* subm_label = [[[NSMutableString alloc] init] autorelease];
	NSArray* month_array = [NSArray arrayWithObjects:
							@"JAN", @"FEB", @"MAR", @"APR", @"MAY", @"JUN",
							@"JUL", @"AUG", @"SEP", @"OCT", @"NOV", @"DEC", nil];
	
	[subm_label setString: @"@SUBM_"];
	[subm_label appendString:
	 [[NSNumber numberWithDouble: floor( [[NSDate date] timeIntervalSince1970] )]
	  stringValue]];
	[subm_label appendString: @"@"];
	
	[todays_date_str setString: [[NSNumber numberWithInteger: [todays_date dayOfMonth]] stringValue]];
	[todays_date_str appendString: @" "];
	[todays_date_str appendString: [month_array objectAtIndex: ([todays_date monthOfYear] - 1)]];
	[todays_date_str appendString: @" "];
	[todays_date_str appendString: [[NSNumber numberWithInteger: [todays_date yearOfCommonEra]] stringValue]];
	
	individuals =    [[NSMutableArray alloc] init];
	families =       [[NSMutableArray alloc] init];
	other_fields =   [[NSMutableArray alloc] init];
	sources =   [[NSMutableArray alloc] init];
		//  deleted_fields = [[NSMutableArray alloc] init];
	
	num_indi = num_fam = num_other = 0;
	
	path = nil;
	
		// start out with the required HEAD, SUBM and TRLR records
		// as well as a single INDI
	if ( (header = [self addRecord: @"HEAD": @"HEAD"]) ) {
		subm = [self addRecord: @"SUBM": subm_label];
			//    [subm addSubfield: @"NAME": [[PreferencesController sharedPrefs] userName]];
		if ( (tmp = [subm addSubfield: @"CHAN": @""]) ) {
			[tmp addSubfield: @"DATE": todays_date_str];
		}
		
		[header addSubfield: @"SOUR": @"GenerationX"];
		[header addSubfield: @"SUBM": subm_label];
		if ( (tmp = [header addSubfield: @"GEDC": @""]) ) {
			[tmp addSubfield: @"VERS": @"5.5"];
			[tmp addSubfield: @"FORM": @"LINEAGE-LINKED"];
		}
		[header addSubfield: @"CHAR": @"ASCII"];
	}
	
	if ( (tmp = [self addRecord: @"INDI": @"@INDI_1@"]) ) {
		[tmp addSubfield: @"NAME" : @"given name /surname/"];
	}
	
	[self addRecord: @"TRLR": @""];
	
	return self;
}

	// setup a database from a file
- (GCFile*)initWithFile:(NSString*) my_path
{
	individuals =    [[NSMutableArray alloc] init];
	families =       [[NSMutableArray alloc] init];
	other_fields =   [[NSMutableArray alloc] init];
	sources =   [[NSMutableArray alloc] init];
		//  deleted_fields = [[NSMutableArray alloc] init];
	
	num_indi = num_fam = num_other = 0;
	
		// load it up!
	path = [my_path retain];
	if ( ! [self loadData] )
		return nil;
	
	return self;
}

- (NSString*) path
{
	return path;
}

- (void) setPath: (NSString*) my_path
{
	path = my_path;
}

- (NSInteger) numRecords
{
	return ([individuals count] + [families count] + [sources count] + [other_fields count]);
}

- (NSInteger) numFamilies
{
	return [families count];
}

- (NSInteger) numOthers
{
	return [other_fields count];
}

- (NSInteger) numIndividuals
{
	return [individuals count];
}

- (NSInteger) numSources
{
	return [sources count];
}

- (GCField*) recordAtIndex: (NSUInteger) index
{
	if ( index < [individuals count] )
		return [individuals objectAtIndex: index];
	else if ( index < ( [individuals count] + [families count] ) )
		return [families objectAtIndex: (index - [individuals count])];
	else if ( index < ( [individuals count] + [families count] + [sources count] ) )
		return [sources objectAtIndex: (index - [individuals count] - [families count])];
	else
		return [other_fields objectAtIndex: (index - ([individuals count] + [families count] + [sources count]))];
}

- (INDI*) indiAtIndex: (NSInteger) index
{
	return [individuals objectAtIndex: index];
}

	// reutnr the "n-th" male in the database
- (INDI*) maleAtIndex: (NSInteger) index
{
	NSUInteger i;
	int j = 0;
	
	for ( i = 0; i < [individuals count]; i++ )
	{
		if ( [[[individuals objectAtIndex: i] sex] isEqual: @"M"] )
		{
			if ( j == index )
				return [individuals objectAtIndex: i];
			
			j++;
		}
	}
	
	return nil;
}

	// reutnr the "n-th" female in the database
- (INDI*) femaleAtIndex: (NSInteger) index
{
	NSUInteger i;
	int j = 0;
	
	for ( i = 0; i < [individuals count]; i++ )
	{
		if ( [[[individuals objectAtIndex: i] sex] isEqual: @"F"] )
		{
			if ( j == index )
				return [individuals objectAtIndex: i];
			
			j++;
		}
	}
	
	return nil;
}

- (FAM*) famAtIndex: (NSInteger) index
{
	return [families objectAtIndex: index];
}

- (GCField*) otherAtIndex: (NSInteger) index
{
	return [other_fields objectAtIndex: index];
}

- (GCField*) sourceAtIndex: (NSInteger) index
{
	return [sources objectAtIndex: index];
}

	// find a record given its label
- (GCField*) recordWithLabel: (NSString*) my_label;
{
	int i = 0;
	GCField* result;
	
	for ( i = 0; i < [self numRecords]; i++ ) {
		result = [self recordAtIndex: i];
		if ( [[result fieldValue] isEqual: my_label] ) {
			return result;
		}
	}
	
	return nil;
}

	// find a person's record given its label
- (INDI*) indiWithLabel: (NSString*) my_label;
{
	NSUInteger i = 0;
	INDI* result;
	
	for ( i = 0; i < [individuals count]; i++ ) {
		result = [individuals objectAtIndex: i];
		if ( [[result fieldValue] isEqual: my_label] ) {
			return result;
		}
	}
	
	return nil;
}

	// fina a family's record given its label
- (FAM*) famWithLabel: (NSString*) my_label
{
	NSUInteger i = 0;
	FAM* result;
	
	for ( i = 0; i < [families count]; i++ )
	{
		result = [families objectAtIndex: i];
		if ( [[result fieldValue] isEqual: my_label] )
			return result;
	}
	
	return nil;
}

	// find some other record given its label
- (GCField*) otherWithLabel: (NSString*) my_label
{
	NSUInteger i = 0;
	GCField* result;
	
	for ( i = 0; i < [other_fields count]; i++ )
	{
		result = [other_fields objectAtIndex: i];
		if ( [[result fieldValue] isEqual: my_label] )
			return result;
	}
	
	return nil;
}

- (NSMutableArray*) surnames
{
	NSMutableArray* result = [NSMutableArray array];
	INDI* gc_tmp;
	NSUInteger i;
	
	for ( i = 0; i < [individuals count]; i++ ) {
		gc_tmp = [individuals objectAtIndex: i];
		if ( ![result containsObject: [gc_tmp lastName]] ) {
			[result addObject: [gc_tmp lastName]];
		}
	}
	
	return result;
}

- (NSMutableArray*) indisWithNameContaining: (NSString*) my_name
{
	NSMutableArray* result = [NSMutableArray array];
	NSArray* indi_bits = [my_name componentsSeparatedByString: @" "];
	INDI* tmp_indi;
	NSArray* tmp_indi_array;
	NSUInteger i, j, k;
	BOOL match;
	
	if ( [my_name isEqualToString: @""] )
		return result;
	
		// for each persoon
	for ( i = 0; i < [individuals count]; i++ )
	{
		tmp_indi = [individuals objectAtIndex: i];
		
		tmp_indi_array = [[tmp_indi fullName] componentsSeparatedByString: @" "];
		
		match = true;
			// while we have a poss match run through the words passed to us
		for ( j = 0; match && j < [indi_bits count]; j++ )
		{
			match = false;
				// for each bit of the record's name
			for ( k = 0; k < [tmp_indi_array count]; k++ )
				if ( [[indi_bits objectAtIndex: j] caseInsensitiveCompare: [tmp_indi_array objectAtIndex: k]] == 0 )
					match = true;
		}
		
		if ( match && ![result containsObject: [individuals objectAtIndex: i]] )
			[result addObject: [individuals objectAtIndex: i]];
	}
	
	return result;
}

- (NSMutableArray*) indisWithPrefix: (NSString*) my_prefix
{
	NSMutableArray* result = [NSMutableArray array];
	INDI* tmp_indi;
	NSUInteger i = 0;
	
	for ( i = 0; i < [individuals count]; i++ )
	{
		tmp_indi = [individuals objectAtIndex: i];
		
		if ( [[[tmp_indi lastName] capitalizedString] hasPrefix: [my_prefix capitalizedString]] )
			[result addObject: tmp_indi];
	}
	
	return result;
}

	// this isn't used anywhere right now
	// but leave it for utility purposes
	// it may come in handy one day
- (INDI*) indiWithFullName: (NSString*) my_name
{
	NSUInteger i = 0;
	INDI* result;
	
	for ( i = 0; i < [individuals count]; i++ )
	{
		result = [individuals objectAtIndex: i];
		if ( [[result fullName] isEqual: my_name] )
			return result;
	}
	
	return nil;
}

- (NSMutableArray*) famsWithFather: (NSString*) my_husb Mother: (NSString*) my_wife
{
	NSMutableArray* result = [NSMutableArray array];
	NSArray* husb_bits = [my_husb componentsSeparatedByString: @" "];
	NSArray* wife_bits = [my_wife componentsSeparatedByString: @" "];
	INDI* tmp_husb, *tmp_wife;
	NSArray* tmp_husb_array, *tmp_wife_array;
	NSUInteger i, j, k;
	BOOL match;
	
	for ( i = 0; i < [families count]; i++ )
	{
		tmp_husb = [[families objectAtIndex: i] husband: self];
		tmp_wife = [[families objectAtIndex: i] wife: self];
		
		tmp_husb_array = [[tmp_husb fullName] componentsSeparatedByString: @" "];
		tmp_wife_array = [[tmp_wife fullName] componentsSeparatedByString: @" "];
		
		match = true;
		
		if (  ([my_husb isEqual: @""] &&  tmp_husb)
			|| (![my_husb isEqual: @""] && !tmp_husb)
			||  ([my_wife isEqual: @""] &&  tmp_wife)
			|| (![my_wife isEqual: @""] && !tmp_wife ))
			match = false;
		
		for ( j = 0; match && j < [husb_bits count]; j++ )
		{
			if ( [my_husb isEqual: @""] && !tmp_husb )
				match = true;
			else
				match = false;
			
			for ( k = 0; !match && k < [tmp_husb_array count]; k++ )
				if ( [[husb_bits objectAtIndex: j] caseInsensitiveCompare: [tmp_husb_array objectAtIndex: k]] == 0 )
					match = true;
		}
		
		for ( j = 0; match && j < [wife_bits count]; j++ )
		{
			if ( [my_wife isEqual: @""] && !tmp_wife )
				match = true;
			else
				match = false;
			
			for ( k = 0; !match && k < [tmp_wife_array count]; k++ )
					// if we find a possible HUSB match, check for a WIFE match
				if ( [[wife_bits objectAtIndex: j] caseInsensitiveCompare: [tmp_wife_array objectAtIndex: k]] == 0 )
					match = true;
		}
		
		if ( match && ![result containsObject: [families objectAtIndex: i]] )
			[result addObject: [families objectAtIndex: i]];
	}
	
	return result;
}

	// 030131 pmh
	// 030131 nowhere mans
	//   fixed bug where case of "NAME xxx /?/" was not handled well
	//   and became "NAME xxx /?/ /yyy/"
- (void) completeLastnames
{
		//Traverse the list of INDI and check NAME field for lastName
		// if lastname is not present
		//   determine fathers lastname (recursively)
		//   add lastname found to the NAME field (SURN does not show)
	NSUInteger i = 0;
	GCField* gc_tmp;
	INDI* tmp_indi;
		//NSString* indi_firstname = @"";
	NSString* indi_lastname = @"";
	NSScanner* name_scanner;
	NSString* tmp;
	
	for ( i = 0; i < [individuals count]; i++ ) {
		tmp_indi = [individuals objectAtIndex: i];
			//[indi_lastname setString: [tmp_indi lastName]];
		indi_lastname = [tmp_indi lastName];
		if ( [indi_lastname isEqual: @"?"] )
		{
			NSMutableString* indi_name = [NSMutableString stringWithCapacity:1];
			name_scanner = [NSScanner scannerWithString:
							[tmp_indi valueOfSubfieldWithType: @"NAME"]];
			
			indi_lastname = [self findFamilyname: tmp_indi];
				// Assume person has a NAME so add its SURN
				//gc_tmp = [tmp_indi addSubfield: @"SURN": indi_lastname];
				//pmh This works for export but it does not show on the display!!!!
				//pmh Therefore fetch the originale NAME in NEW var and append to it
			[name_scanner scanUpToString: @"/"
							  intoString: &tmp];      
			
			[indi_name setString: tmp];
			[indi_name appendString: @" /"];
			[indi_name appendString: indi_lastname];
			[indi_name appendString: @"/"];
				//pmh Testing this already used var does only give the pointer needed
			if ( (gc_tmp = [tmp_indi subfieldWithType: @"NAME"] ) ) {
				[gc_tmp setFieldValue: indi_name];
			} else {
				gc_tmp = [tmp_indi addSubfield: @"NAME": indi_name];
			}
			
				//and fix the SURN field
			if ( (gc_tmp = [gc_tmp subfieldWithType: @"SURN"]) ) {
				[gc_tmp setFieldValue: indi_lastname];
			} else {
				[gc_tmp addSubfield: @"SURN" : indi_lastname];
			}
		}
	}
}

	// 030131 pmh
	// 030131 nowhere mans
	//   fixed bug where case of a person with no last name AND no father was not handled
- (NSString*) findFamilyname: (INDI*) tmp_indi
{
	INDI* tmp_father;
	NSString* indi_lastname = @"";
	
		// if we ca find a father, grab his last name
		// otherwise give up
	if ( (tmp_father = [tmp_indi father: self] ) ) {
		indi_lastname = [tmp_father lastName];
	} else {
		return @"?";
	}
	
		// if we get here, we found a father, but he didn't have a last name
		// so try HIS father
	if ( [indi_lastname isEqual: @"?"] ) {
		indi_lastname = [self findFamilyname: tmp_father];
    }
	return indi_lastname;
}

	// introduce a new record given it' label
- (id) addRecord: (NSString*) my_type : (NSString*) my_value
{
	GCField* record;
	
	if ( [my_type isEqual: @"INDI"] ) {
		INDI* tmp_record = [[[INDI alloc] init: 0 : my_type : my_value] autorelease];
		[individuals addObject: tmp_record];
		num_indi++;
		return tmp_record;
	} else if ( [my_type isEqual: @"FAM"] ) {
		FAM* tmp_record = [[[FAM alloc] init: 0 : my_type : my_value] autorelease];
		[families addObject: tmp_record];
		num_fam++;
		return tmp_record;
	} else if ( [my_type isEqual: @"SOUR"] ) {
		record = [[[GCField alloc] init: 0 : my_type : my_value] autorelease];
		[sources addObject: record];
	} else {
		record = [[[GCField alloc] init: 0 : my_type : my_value] autorelease];
		[other_fields addObject: record];
		num_other++;
	}
	
	return record;
}

	// introduce the given record
- (id)addRecord: (id) my_field
{
	GCField* record;
	
	if ( [[my_field fieldType] isEqual: @"INDI"] ) {
		INDI* tmp_record = my_field;
		[individuals addObject: tmp_record];
		num_indi++;
		return tmp_record;
	} else if ( [[my_field fieldType] isEqual: @"FAM"] ) {
		FAM* tmp_record = my_field;
		[families addObject: tmp_record];
		num_fam++;
		return tmp_record;
	} else if ( [[my_field fieldType] isEqual: @"SOUR"] ) {
		record = my_field;
		[sources addObject: record];
		return record;
	} else {
		record = my_field;
		[other_fields addObject: record];
		num_other++;
	}
	
	return record;
}

	// delete a record
- (GCField*)removeRecord: (GCField*) my_field
{
	GCField* record;
	NSUInteger i;
	
	if ( [[my_field fieldType] isEqual: @"INDI"] ) {
		FAM* tmp;
		INDI* tmp_record = my_field;
		
			// first delete all references to the record
		for ( i = 0; i < [families count]; i++ ) {
			tmp = [families objectAtIndex: i];
			[tmp removeSubfieldWithType: @"HUSB" Value: [tmp_record fieldValue]];
			[tmp removeSubfieldWithType: @"WIFE" Value: [tmp_record fieldValue]];
			[tmp removeSubfieldWithType: @"CHIL" Value: [tmp_record fieldValue]];
			/*
			 if ( [tmp numSubfields] < 2 )
			 [self removeRecord: tmp];
			 */
		}
		
			// now remove the record
		[individuals removeObject: tmp_record];
		num_indi--;
		return tmp_record;
	} else if ( [[my_field fieldType] isEqual: @"FAM"] ) {
		INDI* tmp;
		FAM* tmp_record = my_field;
		
			// first delete all references to the record
		for ( i = 0; i < [individuals count]; i++ ) {
			tmp = [individuals objectAtIndex: i];
			[tmp removeSubfieldWithType: @"FAMS" Value: [tmp_record fieldValue]];
			[tmp removeSubfieldWithType: @"FAMC" Value: [tmp_record fieldValue]];
		}
		
			// now remove the record
		[families removeObject: tmp_record];
		num_fam--;
		return tmp_record;
	} else if ( [[my_field fieldType] isEqual: @"SOUR"] ) {
		record = my_field;
		[sources removeObject: record];
	} else {
		record = my_field;
		[other_fields removeObject: record];
		num_other--;
	}
	
	return record;
}

- (void) replaceRecord: (GCField*) old withRecord: (GCField*) new
{
	[new setNeedSave: true];
	
	if ( [[old fieldType] isEqual: @"INDI"] ) {
		[individuals removeObject: old];
		[individuals addObject: new];
	} else if ( [[old fieldType] isEqual: @"FAM"] ) {
		[families removeObject: old];
		[families addObject: new];
	} else if ( [[old fieldType] isEqual: @"SOUR"] ) {
		[sources removeObject: old];
		[sources addObject: new];
	} else {
		[other_fields removeObject: old];
		[other_fields addObject: new];
	}
}

	// sort the list of INDI records alphabetically by surname
- (void) sortData
{
	if ( [individuals count] > 0 ) {
		[individuals sortUsingSelector: @selector(compare:)];
	}
	if ( [families count] > 0 ) {
		[families sortUsingSelector: @selector(compare:)];
	}
}

	// load data from a GEDCOM file
- (BOOL)loadData
{
	NSError *error;
	NSString* line;
	NSString* level;
	NSString* type;
	NSString* value;
	
	GCField* current_record = [[[GCField alloc] init] autorelease];;
	GCField* working_field;
	int i;
	
	NSScanner* file_scanner = [NSScanner scannerWithString:
							   [NSString stringWithContentsOfFile: path encoding:NSUTF8StringEncoding error:&error]];
	NSScanner* line_scanner;
    
		// as long as we have stuff to crunch
	while ( [file_scanner scanUpToCharactersFromSet:
			[NSCharacterSet controlCharacterSet]
										intoString: &line] ) {
		line_scanner = [[[NSScanner alloc] initWithString: line] autorelease];
		
		level = nil;
		type = nil;
		value = nil;
			// we gotta get at least 2 tokens
			// to have a valid field
		if ( [line_scanner scanUpToCharactersFromSet:
			  [NSCharacterSet whitespaceCharacterSet]
										  intoString: &level] 
			&& [line_scanner scanUpToCharactersFromSet:
				[NSCharacterSet whitespaceCharacterSet]
											intoString: &type] ) {
					// if we got a 3rd token (most of the time)
				if ( [line_scanner scanUpToString: @"\n"
									   intoString: &value] ) {
						// if the level is 0 then this is the begining of a new record
					if ( [level intValue] == 0 ) {
						current_record = [self addRecord: value : type];
					} else {
							// build a subfield from the current line of data
							// and add it to the record we're working on
						working_field = current_record;
						for ( i = 1; i < [level intValue]; i++) {
							working_field = [working_field lastField];
						}
						
						[working_field addSubfield: type : value];
					}
				} else {
					if ( [level intValue] == 0 ) {
						current_record = [self addRecord: type : type];
					} else {
						working_field = current_record;
						for ( i = 1; i < [level intValue]; i++) {
							working_field = [working_field lastField];
						}
						
						[working_field addSubfield: type : value];
					}
				}
			}
	}
	
		//  if ( [[PreferencesController sharedPrefs] sortRecords] )
		//    [self sortData];
	
	return true;
}

	// write our data out to a file
- (BOOL) saveToFile
{
	NSError *error;
	NSUInteger i = 0;
	GCField* tmp;
	NSCalendarDate* todays_date = [NSCalendarDate calendarDate];
		// always pt the header first
	NSMutableString* out_text = [NSMutableString stringWithString: [[self recordWithLabel: @"HEAD"] dataForFile]];
	NSMutableString* todays_date_str = [NSMutableString stringWithCapacity:1];
	NSArray* month_array = [NSArray arrayWithObjects:
							@"JAN", @"FEB", @"MAR", @"APR", @"MAY", @"JUN",
							@"JUL", @"AUG", @"SEP", @"OCT", @"NOV", @"DEC", nil];
	
	[todays_date_str setString: [[NSNumber numberWithInteger: [todays_date dayOfMonth]] stringValue]];
	[todays_date_str appendString: @" "];
	[todays_date_str appendString: [month_array objectAtIndex: ([todays_date monthOfYear] - 1)]];
	[todays_date_str appendString: @" "];
	[todays_date_str appendString: [[NSNumber numberWithInteger: [todays_date yearOfCommonEra]] stringValue]];
	
		// first update the change date
	if ( (tmp = [self recordWithLabel: [[self recordWithLabel: @"HEAD"] valueOfSubfieldWithType: @"SUBM"]] ) ) {
		if ( (tmp = [tmp subfieldWithType: @"CHAN"]) ) {
			if ( (tmp = [tmp subfieldWithType: @"DATE"]) ) {
				[tmp setFieldValue: todays_date_str];
			}
		}
	}
	
		// now do the save
	for ( i = 0; i < [individuals count]; i++ ) {
		[out_text appendString: [[individuals objectAtIndex: i] dataForFile]];
	}
	for ( i = 0; i < [families count]; i++ ) {
		[out_text appendString: [[families objectAtIndex: i] dataForFile]];
	}
	for ( i = 0; i < [sources count]; i++ ) {
		[out_text appendString: [[sources objectAtIndex: i] dataForFile]];
	}
	for ( i = 1; i < [other_fields count]; i++ ) {
		if ( ! [[[other_fields objectAtIndex: i] fieldType] isEqualToString: @"TRLR"] ) {
			[out_text appendString: [[other_fields objectAtIndex: i] dataForFile]];
		}
	}
	
	[out_text appendString: @"0 TRLR\n"];
	
	if ( [out_text writeToFile: path atomically: false encoding:NSUTF8StringEncoding error:&error] ) {
		[self setNeedSave: false];
		return true;
	} else {
		return false;
	}
}

- (BOOL) needSave
{
	int i;
	for ( i = 0; i < [self numRecords]; i++ ) {
		if ( [[self recordAtIndex: i] needSave] ) {
			return true;
		}
	}
	
	return false;
}

- (void) setNeedSave: (BOOL) my_bool
{
	int i;
	for ( i = 0; i < [self numRecords]; i++ ) {
		[[self recordAtIndex: i] setNeedSave: my_bool];
	}
}

@end
