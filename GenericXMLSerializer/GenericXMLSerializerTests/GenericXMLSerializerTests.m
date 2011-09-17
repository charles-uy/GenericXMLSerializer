//
//  GenericXMLSerializerTests.m
//  GenericXMLSerializerTests
//
//  Created by Charles Joseph Uy on 9/8/11.
//  Copyright (c) 2011 Home. All rights reserved.
//

#import "GenericXMLSerializerTests.h"

#define TEST_URL_RSS_2_00 @"http://www.rssboard.org/files/sample-rss-2.xml"
#define TEST_URL_RSS_0_92 @"http://www.rssboard.org/files/sample-rss-092.xml"
#define TEST_URL_RSS_0_91 @"http://www.rssboard.org/files/sample-rss-091.xml"

@implementation GenericXMLSerializerTests

- (void)setUp
{
    [super setUp];
    
    // Set-up code here.
}

- (void)tearDown
{
    // Tear-down code here.
    
    [super tearDown];
}

- (void)testWithURLString:(NSString *)urlString
{
    NSURL *url = [[NSURL alloc] initWithString:urlString];
    NSURLRequest *urlRequest = [[NSURLRequest alloc] initWithURL:url];
    NSURLResponse *urlResponse = nil;
    NSError *error = nil;
    NSData *returnedData = [NSURLConnection sendSynchronousRequest:urlRequest returningResponse:&urlResponse error:&error];
    
    NSXMLParser *parser = [[NSXMLParser alloc] initWithData:returnedData];
    GenericXMLSerializer *serializer = [[GenericXMLSerializer alloc] init];
    parser.delegate = serializer;
    serializer.delegate = self;
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        [parser parse]; 
    });
    while (![serializer hasSerialized]) {
        [NSThread sleepForTimeInterval:1.0f];
    }    
}

- (void)test_RSS_2_00
{
    [self testWithURLString:TEST_URL_RSS_2_00];
}

- (void)test_RSS_0_92
{
    [self testWithURLString:TEST_URL_RSS_0_92];
}

- (void)test_RSS_0_91
{
    [self testWithURLString:TEST_URL_RSS_0_91];
}

- (void)serializer:(GenericXMLSerializer *)serializer didSerializeIntoDictionary:(NSDictionary *)aDictionary
{
//    NSLog(@"serializedData = %@", aDictionary);
    NSLog(@"Channel Description = %@", [serializer objectForKeyPath:@"rss/channel/description"]);
}

@end
