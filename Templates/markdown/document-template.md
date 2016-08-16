# {{page.title}}

{{#object.comment}}{{#longDescription}}{{>GBCommentComponentsList}}{{/longDescription}}{{/object.comment}}

Section GBCommentComponentsList
{{#components}}{{>GBCommentComponent}}{{/components}}
EndSection

Section GBCommentComponent
{{&htmlValue}}
EndSection