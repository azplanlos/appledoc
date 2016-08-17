//
//  GBFullMarkdownOutputGenerator.m
//  appledoc
//
//  Created by Andreas Zöllner on 16/08/16.
//  Copyright © 2016 Gentle Bytes. All rights reserved.
//

#import "GBFullMarkdownOutputGenerator.h"
#import "GBTemplateHandler.h"
#import "GBMarkdownOutputGenerator.h"
#import "GBStore.h"
#import "GBApplicationSettingsProvider.h"
#import "GBDataObjects.h"
#import "GBMarkdownTemplateVariablesProvider.h"
#import <GRMustache/GRMustache.h>


@interface GBFullMarkdownOutputGenerator ()

@property (readonly) GBTemplateHandler* mdFullTemplate;
@property (readonly) GBTemplateHandler *mdFooterTemplate;

@end

@implementation GBFullMarkdownOutputGenerator

-(BOOL)generateOutputWithStore:(id)store error:(NSError *__autoreleasing *)error {
    if (![super generateOutputWithStore:store error:error]) return NO;
    if (![self validateTemplates:error]) return NO;
    if (![self processFull:error]) return NO;
    return YES;
}

- (BOOL)processFull:(NSError **)error {
    NSMutableArray* classes = [NSMutableArray new];
    for (GBClassData *class in self.store.classes) {
        GBLogInfo(@"Generating output for class %@...", class);
        if (!class.includeInOutput) continue;
        NSDictionary *vars = [self.variablesProvider variablesForClass:class withStore:self.store];
        vars = [self dictionaryByAddingTemplateFunctionsAndDefaultTemplates:vars];
        [classes addObject:vars];
    }
    NSMutableArray* categories = [NSMutableArray new];
    for (GBCategoryData *category in self.store.categories) {
        if (!category.includeInOutput) continue;
        GBLogInfo(@"Generating output for category %@...", category);
        NSDictionary *vars = [self.variablesProvider variablesForCategory:category withStore:self.store];
        vars = [self dictionaryByAddingTemplateFunctionsAndDefaultTemplates:vars];
        [categories addObject:vars];
    }
    NSMutableArray* protocols = [NSMutableArray new];
    for (GBProtocolData *protocol in self.store.protocols) {
        if (!protocol.includeInOutput) continue;
        GBLogInfo(@"Generating output for protocol %@...", protocol);
        NSDictionary *vars = [self.variablesProvider variablesForProtocol:protocol withStore:self.store];
        vars = [self dictionaryByAddingTemplateFunctionsAndDefaultTemplates:vars];
        [protocols addObject:vars];
    }
    NSMutableArray* constants = [NSMutableArray new];
    for (GBTypedefEnumData *enumTypedef in self.store.constants) {
        if (!enumTypedef.includeInOutput) continue;
        GBLogInfo(@"Generating output for constant %@...", enumTypedef);
        NSDictionary *vars = [self.variablesProvider variablesForConstant:enumTypedef withStore:self.store];
        vars = [self dictionaryByAddingTemplateFunctionsAndDefaultTemplates:vars];
        [constants addObject:vars];
    }
    NSMutableArray* blocks = [NSMutableArray new];
    for (GBTypedefBlockData *blockTypedef in self.store.blocks) {
        if (!blockTypedef.includeInOutput) continue;
        GBLogInfo(@"Generating output for block %@...", blockTypedef);
        NSDictionary *vars = [self.variablesProvider variablesForBlocks:blockTypedef withStore:self.store];
        vars = [self dictionaryByAddingTemplateFunctionsAndDefaultTemplates:vars];
        [blocks addObject:vars];
    }
    NSMutableArray* documents = [NSMutableArray new];
    for (GBDocumentData *document in self.store.documents) {
        GBLogInfo(@"Generating output for document %@...", document);
        NSDictionary *vars = [self.variablesProvider variablesForDocument:document withStore:self.store];
        vars = [self dictionaryByAddingTemplateFunctionsAndDefaultTemplates:vars];
        [documents addObject:vars];
    }
    GBLogInfo(@"Generating output for index...");
    NSMutableDictionary* index = [NSMutableDictionary new];
    if ([self.store.classes count] > 0 || [self.store.protocols count] > 0 || [self.store.categories count] > 0 || [self.store.constants count] > 0 || [self.store.blocks count] > 0) {
        NSDictionary *vars = [self.variablesProvider variablesForIndexWithStore:self.store];
        vars = [self dictionaryByAddingTemplateFunctionsAndDefaultTemplates:vars];
        [index setValuesForKeysWithDictionary:vars];
    }
    GBLogInfo(@"Generating output for hierarchy...");
    NSMutableDictionary* hierarchy = [NSMutableDictionary new];
    if ([self.store.classes count] > 0 || [self.store.protocols count] > 0 || [self.store.categories count] > 0 || [self.store.constants count] > 0 || [self.store.blocks count] > 0) {
        NSDictionary *vars = [self.variablesProvider variablesForHierarchyWithStore:self.store];
        vars = [self dictionaryByAddingTemplateFunctionsAndDefaultTemplates:vars];
        [hierarchy setValuesForKeysWithDictionary:vars];
    }
    NSMutableDictionary* page = [NSMutableDictionary new];
    [self.variablesProvider addFooterVarsToDictionary:page];
    NSDictionary* vars = @{@"classes": classes, @"categories": categories, @"protocols": protocols, @"constants": constants, @"blocks": blocks, @"documents": documents, @"index": index, @"hierarchy": hierarchy, @"page": page };
    vars = [self dictionaryByAddingTemplateFunctionsAndDefaultTemplates:vars];
    NSLog(@"vars: %@", vars);
    NSString *output = [self.mdFullTemplate renderObject:vars];
    NSString *path = self.settings.markdownOutputFilename;
    if (![self writeString:output toFile:[path stringByStandardizingPath] error:error]) {
        GBLogWarn(@"Failed writing full markdown to '%@'!", path);
        return NO;
    }
    GBLogDebug(@"Finished generating full output.");
    return YES;
}

- (BOOL)validateTemplates:(NSError **)error {
    if (!self.mdFullTemplate) {
        if (error) {
            NSString *desc = [NSString stringWithFormat:@"Full template file 'full-template.md' is missing at '%@'!", self.templateUserPath];
            *error = [NSError errorWithCode:GBErrorHTMLObjectTemplateMissing description:desc reason:nil];
        }
        return NO;
    }
    return YES;
}

- (NSString *)outputSubpath {
    return @"markdown-full";
}

- (GBMarkdownTemplateVariablesProvider *)variablesProvider {
    static GBMarkdownTemplateVariablesProvider *result = nil;
    if (!result) {
        GBLogDebug(@"Initializing variables provider...");
        result = [[GBMarkdownTemplateVariablesProvider alloc] initWithSettingsProvider:self.settings];
    }
    return result;
}

-(GBTemplateHandler*)mdFullTemplate {
    return self.templateFiles[@"full-template.md"];
}

- (GBTemplateHandler *)mdFooterTemplate {
    return self.templateFiles[@"footer-template.md"];
}

-(NSDictionary*)dictionaryByAddingTemplateFunctionsAndDefaultTemplates:(NSDictionary*)vars {
    NSMutableDictionary* mutableVars = [NSMutableDictionary dictionaryWithDictionary:vars];
    [mutableVars setObject:[GRMustacheFilter filterWithBlock:^id(NSNumber *countNumber) {
        
        // ... extracts the count from its argument...
        NSUInteger count = [countNumber unsignedIntegerValue];
        
        // ... and actually returns an object that processes the section it renders for:
        return [GRMustacheRendering renderingObjectWithBlock:^NSString *(GRMustacheTag *tag, GRMustacheContext *context, BOOL *HTMLSafe, NSError *__autoreleasing *error) {
            // ... and finally use our count
            NSMutableString* levelIdent = [NSMutableString new];
            for (int i = 0; i < count; i++) [levelIdent appendString:@" "];
            [levelIdent appendString:@"- "];
            return levelIdent;
        }];
    }] forKey:@"levelIndent"];
    [mutableVars setObject:[[self mdFooterTemplate] mustacheTemplate] forKey:@"footer"];
    return [NSDictionary dictionaryWithDictionary:mutableVars];
}

@end
