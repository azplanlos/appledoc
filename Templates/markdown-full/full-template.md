{{#index}}
# {{page.title}}
_Last updated: {{page.lastUpdatedDate}}_
{{/index}}

{{#documents}}
## {{page.title}}

{{#object.comment}}{{#longDescription}}{{>GBCommentComponentsList}}{{/longDescription}}{{/object.comment}}

Section GBCommentComponentsList
{{#components}}{{>GBCommentComponent}}{{/components}}
EndSection

Section GBCommentComponent
{{&htmlValue}}
EndSection
{{/documents}}

{{#index}}
{{#indexDescription}}	
{{#comment}}
{{#hasLongDescription}}
{{#longDescription}}{{#components}}{{&htmlValue}}{{/components}}{{/longDescription}}
{{/hasLongDescription}}
{{/comment}}
{{/indexDescription}}

{{#hasDocs}}
## {{page.docsTitle}}
{{#docs}}
* [{{title}}]({{href}})
{{/docs}}
{{/hasDocs}}

{{#hasClasses}}
## {{strings.indexPage.classesTitle}}
{{#classes}}
* [{{title}}]({{href}})
{{/classes}}
{{/hasClasses}}

{{#hasProtocolsOrCategories}}
{{#hasProtocols}}
## {{strings.indexPage.protocolsTitle}}
{{#protocols}}
* [{{title}}]({{href}})
{{/protocols}}
{{/hasProtocols}}

{{#hasConstants}}
## {{strings.indexPage.constantsTitle}}					{{#constants}}
* [{{title}}]({{href}})
{{/constants}}
{{/hasConstants}}

{{#hasCategories}}
## {{strings.indexPage.categoriesTitle}}
{{#categories}}
* [{{title}}]({{href}})
{{/categories}}
{{/hasCategories}}
{{/hasProtocolsOrCategories}}
{{/index}}

{{#hierarchy}}
{{#hasClasses}}
## {{strings.hierarchyPage.classesTitle}}

{{>Classes}}
{{/hasClasses}}

{{#hasProtocolsOrCategories}}
{{#hasProtocols}}
## {{strings.hierarchyPage.protocolsTitle}}
{{#protocols}}
* [{{title}}]({{href}})
{{/protocols}}
{{/hasProtocols}}

{{#hasConstants}}
## {{strings.hierarchyPage.constantsTitle}}
{{#constants}}
* [{{title}}]({{href}})
{{/constants}}
{{/hasConstants}}
						
{{#hasCategories}}
## {{strings.hierarchyPage.categoriesTitle}}
{{#categories}}
* [{{title}}]({{href}})					
{{/categories}}
{{/hasCategories}}
{{/hasProtocolsOrCategories}}

Section Classes
{{#hasClasses}}
{{#classes}}{{#levelIndent(level)}}{{/}}[{{name}}]({{#href}}{{href}}{{/href}}){{>Classes}}
{{/classes}}
{{/hasClasses}}
EndSection
{{/hierarchy}}

{{#classes}}
{{>objectDescription}}
{{/classes}}

{{#categories}}
{{>objectDescription}}
{{/categories}}

{{#protocols}}
{{>objectDescription}}
{{/protocols}}

{{#constants}}
{{>objectDescription}}
{{/constants}}

{{#blocks}}
{{>objectDescription}}
{{/blocks}}

{{footer}}

Section objectDescription
##{{page.title}}

{{#page.specifications}}
{{#used}}| __Object Specification__ |   |
|---|---|{{/used}}
{{#values}}{{>ObjectSpecification}}
{{/values}}
{{#used}}{{/used}}
{{/page.specifications}}

{{#object.comment}}
{{#hasLongDescription}}
###{{strings.objectOverview.title}}

{{#longDescription}}{{>GBCommentComponentsList}}{{/longDescription}}

{{/hasLongDescription}}
{{/object.comment}}

{{#object.methods}}
{{#hasSections}}
### {{strings.objectTasks.title}}

Method overview:

{{#methods}}{{>MethodLink}}{{/methods}}

---

{{#sections}}

{{#sectionName}}
{{#sectionName}}{{.}}{{/sectionName}}
{{/sectionName}}
{{>TaskTitle}}

{{#methods}}{{>Method}}{{/methods}}
						
{{/sections}}
{{/hasSections}}
{{/object.methods}}

{{#typedefEnum}}
#### {{nameOfEnum}}
{{#comment}}
{{#hasLongDescription}}
{{#longDescription}}_{{>GBCommentComponentsList}}_{{/longDescription}}
{{/hasLongDescription}}
{{/comment}}
                    
{{#constants}}
##### Definition
    typedef {{enumStyle}}({{enumPrimitive}}, {{nameOfEnum}} ) { <br>
    {{#constants}}
    {{name}}{{#hasAssignedValue}} = {{assignedValue}}{{/hasAssignedValue}},<br>
    {{/constants}}
    };
{{/constants}}

{{#constants}}
##### Constants
{{#constants}}
{{>Constant}}
{{/constants}}
{{/constants}}

{{#comment}}
{{#hasAvailability}}
##### {strings.objectMethods.availability}}
{{#availability}}{{>GBCommentComponentsList}}{{/availability}}
{{/hasAvailability}}

{{#hasRelatedItems}}
##### {{strings.objectMethods.seeAlsoTitle}}

{{#relatedItems.components}}
* {{>GBCommentComponent}}
{{/relatedItems.components}}
{{/hasRelatedItems}}

{{#prefferedSourceInfo}}
##### {{strings.objectMethods.declaredInTitle}}
_{{filename}}_
{{/prefferedSourceInfo}}
{{/comment}}
{{/typedefEnum}}

{{#typedefBlock}}
##### {{strings.objectMethods.blockDefTitle}}


{{>BlocksDefList}}
{{/typedefBlock}}
EndSection

Section ObjectSpecification
| _{{title}}_ | {{#values}}{{string}}{{&delimiter}}{{/values}} |
EndSection

Section GBCommentComponentsList
{{#components}}{{>GBCommentComponent}}{{/components}}
EndSection

Section GBCommentComponent
{{&htmlValue}}
EndSection

Section TaskTitle
{{#hasMultipleSections}}## {{#sectionName}}{{.}}{{/sectionName}}{{^sectionName}}{{strings.objectTasks.otherMethodsSectionName}}{{/sectionName}}
{{/hasMultipleSections}}
{{^hasMultipleSections}}{{#sectionName}}## {{.}}
{{/sectionName}}{{/hasMultipleSections}}
EndSection

Section Method
<a name="{{methodSelector}}"></a>
#### {{>TaskMethod}}

{{#comment}}

{{#hasShortDescription}}
{{#shortDescription}}_{{>GBCommentComponent}}_{{/shortDescription}}
{{/hasShortDescription}}
{{/comment}}

    {{>MethodDeclaration}}

{{#comment}}
{{#hasMethodParameters}}

######{{strings.objectMethods.parametersTitle}}

| {{strings.objectMethods.parametersTitle}} |   |
|---|---|
{{#methodParameters}}| {{argumentName}} | {{#argumentDescription}}{{>GBCommentComponentsList}}{{/argumentDescription}} |					
{{/methodParameters}}
{{/hasMethodParameters}}

{{#hasMethodResult}}
##### {{strings.objectMethods.resultTitle}}

{{#methodResult}}{{>GBCommentComponentsList}}{{/methodResult}}
{{/hasMethodResult}}

{{#hasAvailability}}
##### {{strings.objectMethods.availability}}

{{#availability}}{{>GBCommentComponentsList}}{{/availability}}
{{/hasAvailability}}

{{#hasLongDescription}}
######{{strings.objectMethods.discussionTitle}}

{{#longDescription}}{{>GBCommentComponentsList}}{{/longDescription}}
{{/hasLongDescription}}

{{#hasMethodExceptions}}
##### {{strings.objectMethods.exceptionsTitle}}

| {{strings.objectMethods.exceptionsTitle}} |   |
|---|---|
{{#methodExceptions}}| {{argumentName}} | {{#argumentDescription}}{{>GBCommentComponentsList}}{{/argumentDescription}} |

{{/methodExceptions}}
{{/hasMethodExceptions}}

{{#hasRelatedItems}}
##### {{strings.objectMethods.seeAlsoTitle}}

{{#relatedItems.components}}
- {{>GBCommentComponent}}

{{/relatedItems.components}}
{{/hasRelatedItems}}

{{#prefferedSourceInfo}}

##### {{strings.objectMethods.declaredInTitle}}

_{{filename}}_
{{/prefferedSourceInfo}}

---


{{/comment}}
EndSection

Section TaskMethod
{{>TaskSelector}}
{{#isRequired}}
{{strings.objectTasks.requiredMethod}}
{{/isRequired}}
EndSection

Section TaskSelector
{{#isInstanceMethod}}-{{/isInstanceMethod}}{{#isClassMethod}}+{{/isClassMethod}}{{#isProperty}} {{/isProperty}} {{methodSelector}}
EndSection

Section MethodDeclaration
{{#formattedComponents}}{{#emphasized}}{{/emphasized}}{{#href}}{{/href}}{{value}}{{#href}}{{/href}}{{#emphasized}}{{/emphasized}}{{/formattedComponents}}
EndSection

Section MethodLink

__[{{>TaskMethod}}](#{{methodSelector}})__ <br/>

EndSection

Section Constant
{{name}}

{{#comment}}
{{#hasShortDescription}}
{{#shortDescription}}{{>GBCommentComponent}}{{/shortDescription}}
{{/hasShortDescription}}

{{#hasAvailability}}
    
Available in {{#availability}}{{#components}}{{stringValue}}{{/components}}{{/availability}}
{{/hasAvailability}}

{{/comment}}
{{#prefferedSourceInfo}}
{{strings.objectMethods.declaredInTitle}} _{{filename}}_.
{{/prefferedSourceInfo}}

EndSection

Section BlocksDefList
#### {{nameOfBlock}}

{{#comment}}
{{#hasShortDescription}}
{{#shortDescription}}_{{>GBCommentComponent}}_{{/shortDescription}}
{{/hasShortDescription}}
{{/comment}}

    typedef {{returnType}} (^{{nameOfBlock}}) ({{&htmlParameterList}})
  
{{#comment}}
{{#hasLongDescription}}
##### {{strings.objectMethods.discussionTitle}}

{{#longDescription}}{{>GBCommentComponentsList}}{{/longDescription}}
{{/hasLongDescription}}
{{/comment}}
  
{{#comment}}
{{#hasAvailability}}
##### {{strings.objectMethods.availability}}

{{#availability}}{{>GBCommentComponentsList}}{{/availability}}
{{/hasAvailability}}
  
{{#hasRelatedItems}}
##### {{strings.objectMethods.seeAlsoTitle}}

{{#relatedItems.components}}
* {{>GBCommentComponent}}
{{/relatedItems.components}}
{{/hasRelatedItems}}
  
{{#prefferedSourceInfo}}
##### {{strings.objectMethods.declaredInTitle}}

_{{filename}}_
{{/prefferedSourceInfo}}
{{/comment}}
EndSection