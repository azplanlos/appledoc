//
//  GBMarkdownTemplateVariablesProvider.m
//  appledoc
//
//  Created by Andreas Zöllner on 14/08/16.
//  Copyright © 2016 Gentle Bytes. All rights reserved.
//

#import "GBMarkdownTemplateVariablesProvider.h"

@implementation GBMarkdownTemplateVariablesProvider

-(NSDictionary*)variablesForHierarchyWithStore:(id)store {
    return [self addLevelIndexToClassesDictionary:[super variablesForHierarchyWithStore:store] andLevel:-1];
}

-(id)addLevelIndexToClassesDictionary:(id)classes andLevel:(NSInteger)level {
    if ([classes isKindOfClass:[NSArray class]]) {
        NSMutableArray* vars = [NSMutableArray new];
        for (id classDict in classes) {
            NSMutableDictionary* xvars = [NSMutableDictionary dictionaryWithDictionary:classDict];
            if ([xvars valueForKey:@"name"]) [xvars setValue:@(level) forKey:@"level"];
            if ([xvars valueForKey:@"classes"] && [[xvars valueForKey:@"classes"] isKindOfClass:[NSArray class]]) [xvars setObject:[self addLevelIndexToClassesDictionary:[xvars valueForKey:@"classes"] andLevel:level+1] forKey:@"classes"];
            else NSLog(@"classes: %@", [[xvars valueForKey:@"classes"] className]);
            [vars addObject:xvars];
        }
        return [NSArray arrayWithArray:vars];
    } else if ([classes isKindOfClass:[NSDictionary class]]) {
        NSMutableDictionary* vars = [NSMutableDictionary dictionaryWithDictionary:classes];
        if ([vars valueForKey:@"name"]) [vars setValue:@(level) forKey:@"level"];
        if ([vars valueForKey:@"classes"] && [[vars valueForKey:@"classes"] isKindOfClass:[NSArray class]]) [vars setObject:[self addLevelIndexToClassesDictionary:[vars valueForKey:@"classes"] andLevel:level+1] forKey:@"classes"];
            else NSLog(@"classes: %@", [[vars valueForKey:@"classes"] className]);
        return [NSDictionary dictionaryWithDictionary:vars];
    }
    return nil;
}

@end
