//
//  GenericXMLSerializer.m
//  GenericXMLSerializer
//
//  Created by Charles Joseph Uy on 9/8/11.
//  Copyright (c) 2011 Home. All rights reserved.
//

#import "GenericXMLSerializer.h"

@interface GenericXMLSerializer () 

@property (nonatomic, strong) NSMutableDictionary *serializedData;
@property (nonatomic, strong) NSMutableString *foundCharactersBuffer;
@property (nonatomic, strong) NSMutableArray *parsingStack;

@end

@implementation GenericXMLSerializer

@synthesize serializedData = serializedData_;
@synthesize foundCharactersBuffer = foundCharactersBuffer_;
@synthesize parsingStack = parsingStack_;
@synthesize delegate;
@synthesize hasSerialized;

#pragma mark -
#pragma mark Lifecycle

- (id)init
{
    self = [super init];
    if (self) {
        // Initialization code here.
        serializedData_ = [[NSMutableDictionary alloc] init];
        foundCharactersBuffer_ = [[NSMutableString alloc] initWithCapacity:256];
        parsingStack_ = [[NSMutableArray alloc] initWithCapacity:10];
        hasSerialized = NO;
    }
    
    return self;
}

#pragma mark -
#pragma mark Public Methods

- (void)cleanup
{
    [self.parsingStack removeAllObjects];
    [self.serializedData removeAllObjects];        
}

- (id)objectForKeyPath:(NSString *)keyPath
{
    return [GenericXMLSerializer objectForKeyPath:keyPath fromDictionary:self.serializedData];
}

+ (id)objectForKeyPath:(NSString *)keyPath fromDictionary:(NSDictionary *)aDictionary
{
    NSArray *levels = [keyPath componentsSeparatedByString:@"/"];
    
    NSDictionary *data = [aDictionary objectForKey:@"data"];
    NSDictionary *levelDictionary = data;
    
    id object = nil;
    BOOL didResolvePath = YES;
    for (NSString *component in levels) {
        if ([levelDictionary objectForKey:component]) {
            levelDictionary = [[levelDictionary objectForKey:component] objectForKey:component];
            object = levelDictionary;
        }
        else {
            didResolvePath = NO;
            break;
        }
    }
        
    return didResolvePath ? object : nil;
}

#pragma mark -
#pragma mark NSXMLParserDelegate

- (void)parserDidStartDocument:(NSXMLParser *)parser
{
    NSLog(@"start document");
    [self cleanup];
    [self.serializedData setObject:@"data" forKey:@"key"];
    [self.serializedData setObject:[NSNull null] forKey:@"data"];
    [self.parsingStack addObject:self.serializedData];
}

- (void)parserDidEndDocument:(NSXMLParser *)parser
{
    NSLog(@"end document");
    [self.delegate serializer:self didSerializeIntoDictionary:[NSDictionary dictionaryWithDictionary:[self.serializedData objectForKey:@"data"]]];
    hasSerialized = YES;    
}

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qualifiedName attributes:(NSDictionary *)attributeDict
{
    NSLog(@"start elementName = %@", elementName);
    
    // Clear the buffer for found characters.
    [self.foundCharactersBuffer deleteCharactersInRange:NSMakeRange(0, [self.foundCharactersBuffer length])];     

    // Setup dictionary for the element

    NSMutableDictionary *element = nil;    
    if ([attributeDict count] > 0) {
        element = [[NSMutableDictionary alloc] initWithObjectsAndKeys:elementName, @"key", [NSNull null], elementName, attributeDict, @"attributes", nil];
    }
    else {
        element = [[NSMutableDictionary alloc] initWithObjectsAndKeys:elementName, @"key", [NSNull null], elementName, nil];
    }
    
    // Add that dictionary element to the parent dictionary

    // Check if parent dictionary's object 
    NSMutableDictionary *parentDictionary = [self.parsingStack lastObject];
    NSString *parentKey = [parentDictionary objectForKey:@"key"];
    NSObject *value = [parentDictionary objectForKey:parentKey];
    if (![value isEqual:[NSNull null]]) {
        // has a value

        // If its a string, then error.
        if ([value isMemberOfClass:[NSString class]]) {
        }

        if ([value isKindOfClass:[NSDictionary class]]) {
            NSMutableDictionary *valueDict = (NSMutableDictionary *)value;
            // Check if the value dict contains that key.
            if ([valueDict objectForKey:elementName]) {
                if ([[valueDict objectForKey:elementName] isKindOfClass:[NSArray class]]) {
                    [[valueDict objectForKey:elementName] addObject:element];
                }
                else {
                    NSMutableArray *elementArray = [NSMutableArray arrayWithObjects:[valueDict objectForKey:elementName], element, nil];
                    [valueDict setObject:elementArray forKey:elementName];                    
                }
            }
            else {
                [valueDict setObject:element forKey:elementName];
            }
        }
        else {
            // If it's not a mutable dictionary, it's an error.
        }
        
    }
    else {
        NSMutableDictionary *values = [NSMutableDictionary dictionaryWithObject:element forKey:elementName];
        [[self.parsingStack lastObject] setObject:values forKey:[[self.parsingStack lastObject] objectForKey:@"key"]];
    }
    
    // Add element dictionary to parsing stack.
    [self.parsingStack addObject:element];
}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string
{
    NSString *cleanString = [string stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    [self.foundCharactersBuffer appendString:cleanString];
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName
{
    if ([self.foundCharactersBuffer length] > 0) {
        // Set found characters if any.
        [[self.parsingStack lastObject] setObject:[NSString stringWithString:self.foundCharactersBuffer] forKey:elementName];
        [self.foundCharactersBuffer deleteCharactersInRange:NSMakeRange(0, [self.foundCharactersBuffer length])];
    }
    
    [self.parsingStack removeLastObject];
}

@end
