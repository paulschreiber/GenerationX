//
//  GEDParser.m
//  GenXDoc
//
//  Created by Nowhere Man on Fri Feb 06 2004.
//  Copyright (c) 2004 __MyCompanyName__. All rights reserved.
//

#import "GEDParser.h"


@implementation GEDParser

- (GEDParser*) init
{
  state = 0;
  g = [[GCFile alloc] init];
	return self;
}

- (void)parserDidStartDocument:(NSXMLParser *)parser
{
  g = [[GCFile alloc] init];
}

- (void)parserDidEndDocument:(NSXMLParser *)parser
{
}

- (void)parser:(NSXMLParser *)parser 
        didStartElement:(NSString *)elementName 
				namespaceURI:(NSString *)namespaceURI 
				qualifiedName:(NSString *)qualifiedName 
				attributes:(NSDictionary *)attributeDict
{
NSLog( elementName );
NSLog( [attributeDict description] );
  if ( state == kParsingHeader )
	{
	  currentRecord = [[GCField alloc] init: 0 : @"HEAD" : @""];
	}
}

- (void)parser:(NSXMLParser *)parser 
        didEndElement:(NSString *)elementName 
				namespaceURI:(NSString *)namespaceURI 
				qualifiedName:(NSString *)qName
{
}

- (void)parser:(NSXMLParser *)parser 
        foundCharacters:(NSString *)string
{
}


@end
