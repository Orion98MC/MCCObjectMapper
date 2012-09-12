//
//  MCCObjectMapper.m
//  MCCViewDemo
//
//  Created by Thierry Passeron on 10/09/12.
//  Copyright (c) 2012 Monte-Carlo Computing. All rights reserved.
//

#import "MCCObjectMapper.h"

@interface MCCObjectMapper ()
@property (retain, nonatomic) NSMutableDictionary *mappings;

@end

@implementation MCCObjectMapper
@synthesize mappings, postValues;

+ (id)mapperWithMappings:(NSDictionary *)theMappings {
  MCCObjectMapper * om = [[self alloc]init];
  if (!om) return nil;
  
  om.mappings = [NSMutableDictionary dictionaryWithDictionary:theMappings];
  
  return [om autorelease];
}

+ (id)mapper {
  MCCObjectMapper *om = [[self alloc]init];
  
  return [om autorelease];
}

- (id)init {
  self = [super init];
  if (!self) return nil;
  
  self.mappings = [NSMutableDictionary dictionary];
  
  return self;
}

- (void)dealloc {
  self.postValues = nil;
  self.mappings = nil;
  [super dealloc];
}

- (void)map:(NSString *)source isKeyPath:(BOOL)sourceIsKeyPath to:(NSString *)dest isKeyPath:(BOOL)destIsKeyPath valueBlock:(id(^)(id))block {
  
  uint8_t _format = 0;
  if (sourceIsKeyPath) _format |= 1 << 1;
  if (destIsKeyPath) _format |= 1 << 0;
 
  NSDictionary *_map = nil;
  
  if (block) {
    _map = @{
      @"format" : [NSNumber numberWithUnsignedShort:_format],
      @"to" : dest,
      @"block" : [[block copy]autorelease]
    };
  } else {
    _map = @{
      @"format" : [NSNumber numberWithUnsignedShort:_format],
      @"to" : dest,
    };
  }
  
  [mappings setValue:_map forKey:source];
}

- (void)mapKey:(NSString *)key toKey:(NSString *)newKey value:(id(^)(id))block {
  [self map:key isKeyPath:NO to:newKey isKeyPath:NO valueBlock:block];
}

- (void)mapKey:(NSString *)key toKey:(NSString *)newKey {
  [self map:key isKeyPath:NO to:newKey isKeyPath:NO valueBlock:nil];
}

- (void)mapKeyPath:(NSString *)key toKey:(NSString *)newKey value:(id(^)(id))block {
 [self map:key isKeyPath:YES to:newKey isKeyPath:NO valueBlock:block];
}

- (void)mapKeyPath:(NSString *)key toKey:(NSString *)newKey {
  [self map:key isKeyPath:YES to:newKey isKeyPath:NO valueBlock:nil];
}

- (void)mapKeyPath:(NSString *)key toKeyPath:(NSString *)newKey value:(id(^)(id))block {
  [self map:key isKeyPath:YES to:newKey isKeyPath:YES valueBlock:block];
}

- (void)mapKeyPath:(NSString *)key toKeyPath:(NSString *)newKey {
  [self map:key isKeyPath:YES to:newKey isKeyPath:YES valueBlock:nil];
}

- (void)mapKey:(NSString *)key toKeyPath:(NSString *)newKey value:(id(^)(id))block {
  [self map:key isKeyPath:NO to:newKey isKeyPath:YES valueBlock:block];
}

- (void)mapKey:(NSString *)key toKeyPath:(NSString *)newKey {
  [self map:key isKeyPath:NO to:newKey isKeyPath:YES valueBlock:nil];
}


- (NSMutableDictionary *)mapObject:(id)object {
  NSMutableDictionary *mapped = [NSMutableDictionary dictionaryWithCapacity:mappings.allKeys.count];
  
  for (NSString *key in mappings.allKeys) {
    NSDictionary *_map = [mappings valueForKey:key];
    uint8_t _format = [[_map valueForKey:@"format"]unsignedShortValue];
    
    BOOL sourceIsKeyPath = (_format & (1 << 1)) == (1 << 1);
    BOOL destIsKeyPath = (_format & (1 << 0)) == (1 << 0);
    id(^block)(id) = (id(^)(id))[_map valueForKey:@"block"];
    NSString *dest = [_map valueForKey:@"to"];
    
    // Get the value
    id value = nil;
    if (sourceIsKeyPath) {
      NSAssert([object respondsToSelector:@selector(valueForKeyPath:)], @"Object does not respond to valueForKeyPath:");
      value = [object valueForKeyPath:key];
    } else {
      value = [object valueForKey:key];
    }
    
    // Process the value
    if (block) {
      value = block(value);
    }

    if (postValues) {
      value = postValues(value);
    }

    // Set the value
    if (destIsKeyPath) {
      [mapped setValue:value forKeyPath:dest];
    } else {
      [mapped setValue:value forKey:dest];
    }
  }
  
  return mapped;
}

@end
