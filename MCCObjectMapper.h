//
//  MCCObjectMapper.h
//  MCCViewDemo
//
//  Created by Thierry Passeron on 10/09/12.
//  Copyright (c) 2012 Monte-Carlo Computing. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MCCObjectMapper : NSObject

@property (copy, nonatomic) id(^preValues)(id);
@property (copy, nonatomic) id(^postValues)(id);

+ (id)mapper;

- (void)mapKey:(NSString *)key toKey:(NSString *)newKey value:(id(^)(id))block;
- (void)mapKey:(NSString *)key toKey:(NSString *)newKey;

- (void)mapKeyPath:(NSString *)key toKey:(NSString *)newKey value:(id(^)(id))block;
- (void)mapKeyPath:(NSString *)key toKey:(NSString *)newKey;

- (void)mapKeyPath:(NSString *)key toKeyPath:(NSString *)newKey value:(id(^)(id))block;
- (void)mapKeyPath:(NSString *)key toKeyPath:(NSString *)newKey;

- (void)mapKey:(NSString *)key toKeyPath:(NSString *)newKey value:(id(^)(id))block;
- (void)mapKey:(NSString *)key toKeyPath:(NSString *)newKey;

- (NSMutableDictionary *)mapObject:(id)object;

@end
