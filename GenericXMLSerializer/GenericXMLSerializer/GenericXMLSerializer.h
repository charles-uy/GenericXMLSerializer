//
//  GenericXMLSerializer.h
//  GenericXMLSerializer
//
//  Created by Charles Joseph Uy on 9/8/11.
//  Copyright (c) 2011 Home. All rights reserved.
//

#import <Foundation/Foundation.h>

@class GenericXMLSerializer;

@protocol GenericXMLSerializerDelegate <NSObject>

@required

- (void)serializer:(GenericXMLSerializer *)serializer didSerializeIntoDictionary:(NSDictionary *)aDictionary;

@end

@interface GenericXMLSerializer : NSObject <NSXMLParserDelegate> 

@property (nonatomic, weak) id <GenericXMLSerializerDelegate> delegate;
@property (nonatomic, readonly) BOOL hasSerialized;

- (void)cleanup;
- (id)objectForKeyPath:(NSString *)keyPath;
+ (id)objectForKeyPath:(NSString *)keyPath fromDictionary:(NSDictionary *)aDictionary;

@end
