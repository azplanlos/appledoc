//
//  GBMarkdownOutputGenerator.m
//  appledoc
//
//  Created by Andreas Zöllner on 11/08/16.
//  Copyright © 2016 Gentle Bytes. All rights reserved.
//

#import "GBMarkdownOutputGenerator.h"
#import "GBStore.h"
#import "GBApplicationSettingsProvider.h"
#import "GBDataObjects.h"
#import "GBMarkdownTemplateVariablesProvider.h"
#import "GBTemplateHandler.h"
#import <GRMustache/GRMustache.h>

@interface GBMarkdownOutputGenerator ()

@property (readonly) GBTemplateHandler *mdObjectTemplate;
@property (readonly) GBTemplateHandler *mdIndexTemplate;
@property (readonly) GBTemplateHandler *mdHierarchyTemplate;
@property (readonly) GBTemplateHandler *mdDocumentTemplate;

@end

@implementation GBMarkdownOutputGenerator

-(BOOL)generateOutputWithStore:(id)store error:(NSError *__autoreleasing *)error {
    if (![super generateOutputWithStore:store error:error]) return NO;
    if (![self validateTemplates:error]) return NO;
    if (![self processClasses:error]) return NO;
    if (![self processCategories:error]) return NO;
    if (![self processProtocols:error]) return NO;
    if (![self processDocuments:error]) return NO;
    if (![self processConstants:error]) return NO;
    if (![self processBlocks:error]) return NO;
    if (![self processIndex:error]) return NO;
    if (![self processHierarchy:error]) return NO;
    return YES;
}

- (BOOL)validateTemplates:(NSError **)error {
    if (!self.mdObjectTemplate) {
        if (error) {
            NSString *desc = [NSString stringWithFormat:@"Object template file 'object-template.md' is missing at '%@'!", self.templateUserPath];
            *error = [NSError errorWithCode:GBErrorHTMLObjectTemplateMissing description:desc reason:nil];
        }
        return NO;
    }
    if (!self.mdDocumentTemplate) {
        if (error) {
            NSString *desc = [NSString stringWithFormat:@"Document template file 'document-template.md' is missing at '%@'!", self.templateUserPath];
            *error = [NSError errorWithCode:GBErrorHTMLDocumentTemplateMissing description:desc reason:nil];
        }
        return NO;
    }
    if (!self.mdIndexTemplate) {
        if (error) {
            NSString *desc = [NSString stringWithFormat:@"Index template file 'index-template.md' is missing at '%@'!", self.templateUserPath];
            *error = [NSError errorWithCode:GBErrorHTMLIndexTemplateMissing description:desc reason:nil];
        }
        return NO;
    }
    if (!self.mdHierarchyTemplate) {
        if (error) {
            NSString *desc = [NSString stringWithFormat:@"Hierarchy template file 'hierarchy-template.md' is missing at '%@'!", self.templateUserPath];
            *error = [NSError errorWithCode:GBErrorHTMLHierarchyTemplateMissing description:desc reason:nil];
        }
        return NO;
    }
    return YES;
}

- (BOOL)processClasses:(NSError **)error {
    for (GBClassData *class in self.store.classes) {
        GBLogInfo(@"Generating output for class %@...", class);

        if (!class.includeInOutput) continue;
        NSDictionary *vars = [self.variablesProvider variablesForClass:class withStore:self.store];
        NSString *output = [self.mdObjectTemplate renderObject:vars];
        NSString *path = [self mdOutputPathForObject:class];
        if (![self writeString:output toFile:[path stringByStandardizingPath] error:error]) {
            GBLogWarn(@"Failed writing markdown for class %@ to '%@'!", class, path);
            return NO;
        }
        GBLogDebug(@"Finished generating output for class %@.", class);
    }
    return YES;
}

- (BOOL)processCategories:(NSError **)error {
    for (GBCategoryData *category in self.store.categories) {
        if (!category.includeInOutput) continue;
        GBLogInfo(@"Generating output for category %@...", category);
        NSDictionary *vars = [self.variablesProvider variablesForCategory:category withStore:self.store];
        NSString *output = [self.mdObjectTemplate renderObject:vars];
        NSString *path = [self mdOutputPathForObject:category];
        if (![self writeString:output toFile:[path stringByStandardizingPath] error:error]) {
            GBLogWarn(@"Failed writing markdown for category %@ to '%@'!", category, path);
            return NO;
        }
        GBLogDebug(@"Finished generating output for category %@.", category);
    }
    return YES;
}

- (BOOL)processProtocols:(NSError **)error {
    for (GBProtocolData *protocol in self.store.protocols) {
        if (!protocol.includeInOutput) continue;
        GBLogInfo(@"Generating output for protocol %@...", protocol);
        NSDictionary *vars = [self.variablesProvider variablesForProtocol:protocol withStore:self.store];
        NSString *output = [self.mdObjectTemplate renderObject:vars];
        NSString *path = [self mdOutputPathForObject:protocol];
        if (![self writeString:output toFile:[path stringByStandardizingPath] error:error]) {
            GBLogWarn(@"Failed writing markdown for protocol %@ to '%@'!", protocol, path);
            return NO;
        }
        GBLogDebug(@"Finished generating output for protocol %@.", protocol);
    }
    return YES;
}

- (BOOL)processConstants:(NSError **)error {
    for (GBTypedefEnumData *enumTypedef in self.store.constants) {
        if (!enumTypedef.includeInOutput) continue;
        GBLogInfo(@"Generating output for constant %@...", enumTypedef);
        NSDictionary *vars = [self.variablesProvider variablesForConstant:enumTypedef withStore:self.store];
        NSString *output = [self.mdObjectTemplate renderObject:vars];
        NSString *path = [self mdOutputPathForObject:enumTypedef];
        if (![self writeString:output toFile:[path stringByStandardizingPath] error:error]) {
            GBLogWarn(@"Failed writing markdown for constant %@ to '%@'!", enumTypedef, path);
            return NO;
        }
        GBLogDebug(@"Finished generating output for constant %@.", enumTypedef);
    }
    return YES;
}

- (BOOL)processBlocks:(NSError **)error {
    for (GBTypedefBlockData *blockTypedef in self.store.blocks) {
        if (!blockTypedef.includeInOutput) continue;
        GBLogInfo(@"Generating output for block %@...", blockTypedef);
        NSDictionary *vars = [self.variablesProvider variablesForBlocks:blockTypedef withStore:self.store];
        NSString *output = [self.mdObjectTemplate renderObject:vars];
        NSString *path = [self mdOutputPathForObject:blockTypedef];
        if (![self writeString:output toFile:[path stringByStandardizingPath] error:error]) {
            GBLogWarn(@"Failed writing markdown for block %@ to '%@'!", blockTypedef, path);
            return NO;
        }
        GBLogDebug(@"Finished generating output for block %@.", blockTypedef);
    }
    return YES;
}

- (BOOL)processDocuments:(NSError **)error {
    // First process all include paths by copying them over to the destination. Note that we do it even if no template is found - if the user specified some include path, we should use it...
    NSString *docsUserPath = [self.outputUserPath stringByAppendingPathComponent:self.settings.htmlStaticDocumentsSubpath];
    GBTemplateFilesHandler *handler = [[GBTemplateFilesHandler alloc] init];
    for (NSString *path in self.settings.includePaths) {
        GBLogInfo(@"Copying static documents from '%@'...", path);
        NSString *lastComponent = [path lastPathComponent];
        NSString *installPath = [docsUserPath stringByAppendingPathComponent:lastComponent];
        handler.templateUserPath = path;
        handler.outputUserPath = installPath;
        if (![handler copyTemplateFilesToOutputPath:error]) return NO;
    }
    
    // Now process all documents.
    for (GBDocumentData *document in self.store.documents) {
        GBLogInfo(@"Generating output for document %@...", document);
        NSDictionary *vars = [self.variablesProvider variablesForDocument:document withStore:self.store];
        NSString *output = [self.mdDocumentTemplate renderObject:vars];
        NSString *path = [self mdOutputPathForObject:document];
        if (![self writeString:output toFile:[path stringByStandardizingPath] error:error]) {
            GBLogWarn(@"Failed writing markdown for document %@ to '%@'!", document, path);
            return NO;
        }
        GBLogDebug(@"Finished generating output for document %@.", document);
    }
    return YES;
}

- (BOOL)processIndex:(NSError **)error {
    GBLogInfo(@"Generating output for index...");
    if ([self.store.classes count] > 0 || [self.store.protocols count] > 0 || [self.store.categories count] > 0 || [self.store.constants count] > 0 || [self.store.blocks count] > 0) {
        NSDictionary *vars = [self.variablesProvider variablesForIndexWithStore:self.store];
        NSString *output = [self.mdIndexTemplate renderObject:vars];
        NSString *path = [[self mdOutputPathForIndex] stringByStandardizingPath];
        if (![self writeString:output toFile:[path stringByStandardizingPath] error:error]) {
            GBLogWarn(@"Failed writing markdown index to '%@'!", path);
            return NO;
        }
    }
    GBLogDebug(@"Finished generating output for index.");
    return YES;
}

- (BOOL)processHierarchy:(NSError **)error {
    GBLogInfo(@"Generating output for hierarchy...");
    if ([self.store.classes count] > 0 || [self.store.protocols count] > 0 || [self.store.categories count] > 0 || [self.store.constants count] > 0 || [self.store.blocks count] > 0) {
        NSMutableDictionary *vars = [NSMutableDictionary dictionaryWithDictionary:[self.variablesProvider variablesForHierarchyWithStore:self.store]];
        [vars setObject:[GRMustacheFilter filterWithBlock:^id(NSNumber *countNumber) {
            
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
        NSString *output = [self.mdHierarchyTemplate renderObject:vars];
        NSString *path = [[self mdOutputPathForHierarchy] stringByStandardizingPath];
        if (![self writeString:output toFile:[path stringByStandardizingPath] error:error]) {
            GBLogWarn(@"Failed writing HTML hierarchy to '%@'!", path);
            return NO;
        }
    }
    GBLogDebug(@"Finished generating output for hierarchy.");
    return YES;
}

- (GBTemplateHandler *)mdObjectTemplate {
    return self.templateFiles[@"object-template.md"];
}

- (GBTemplateHandler *)mdIndexTemplate {
    return self.templateFiles[@"index-template.md"];
}

- (GBTemplateHandler *)mdHierarchyTemplate {
    return self.templateFiles[@"hierarchy-template.md"];
}

- (GBTemplateHandler *)mdDocumentTemplate {
    return self.templateFiles[@"document-template.md"];
}

- (NSString *)outputSubpath {
    return @"markdown";
}

- (NSString *)mdOutputPathForObject:(GBModelBase *)object {
    // Returns file name including full path for HTML file representing the given top-level object. This works for any top-level object: class, category or protocol. The path is automatically determined regarding to the object class. Note that we use the HTML reference to get us the actual path - we can't rely on template filename as it's the same for all objects...
    NSString *inner = [self.settings mdReferenceForObjectFromIndex:object];
    return [self.outputUserPath stringByAppendingPathComponent:inner];
}

- (GBMarkdownTemplateVariablesProvider *)variablesProvider {
    static GBMarkdownTemplateVariablesProvider *result = nil;
    if (!result) {
        GBLogDebug(@"Initializing variables provider...");
        result = [[GBMarkdownTemplateVariablesProvider alloc] initWithSettingsProvider:self.settings];
    }
    return result;
}

- (NSString *)mdOutputPathForIndex {
    // Returns file name including full path for HTML file representing the main index.
    return [self mdOutputPathForTemplateName:@"index-template.md"];
}

- (NSString *)mdOutputPathForHierarchy {
    // Returns file name including full path for HTML file representing the main hierarchy.
    return [self mdOutputPathForTemplateName:@"hierarchy-template.md"];
}

- (NSString *)mdOutputPathForTemplateName:(NSString *)template {
    // Returns full path and actual file name corresponding to the given template.
    NSString *path = [self outputPathToTemplateEndingWith:template];
    NSString *filename = [self.settings outputFilenameForTemplatePath:template];
    return [path stringByAppendingPathComponent:filename];
}


@end
