<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step type="pxi:css-to-obfl"
                xmlns:p="http://www.w3.org/ns/xproc"
                xmlns:px="http://www.daisy.org/ns/pipeline/xproc"
                xmlns:pxi="http://www.daisy.org/ns/pipeline/xproc/internal"
                xmlns:css="http://www.daisy.org/ns/pipeline/braille-css"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                exclude-inline-prefixes="pxi xsl"
                version="1.0">
    
    <p:documentation>
        Convert a document with inline braille CSS to OBFL (Open Braille Formatting Language).
    </p:documentation>
    
    <p:input port="source" sequence="true"/>
    <p:output port="result" sequence="false"/>
    
    <p:import href="http://www.daisy.org/pipeline/modules/braille/css-utils/library.xpl"/>
    
    <p:for-each>
        <p:add-xml-base/>
        <p:xslt>
            <p:input port="stylesheet">
                <p:inline>
                    <xsl:stylesheet version="2.0">
                        <xsl:template match="/*">
                            <xsl:copy>
                                <xsl:copy-of select="document('')/*/namespace::*[name()='obfl']"/>
                                <xsl:copy-of select="document('')/*/namespace::*[name()='css']"/>
                                <xsl:sequence select="@*|node()"/>
                            </xsl:copy>
                        </xsl:template>
                    </xsl:stylesheet>
                </p:inline>
            </p:input>
            <p:input port="parameters">
                <p:empty/>
            </p:input>
        </p:xslt>
    </p:for-each>
    
    <p:for-each>
        <css:parse-stylesheet>
            <p:documentation>
                Make css:page, css:after and css:before attributes.
            </p:documentation>
        </css:parse-stylesheet>
        <css:make-pseudo-elements>
            <p:documentation>
                Make css:before and css:after elements from css:before and css:after attributes.
            </p:documentation>
        </css:make-pseudo-elements>
        <css:parse-properties properties="content white-space display list-style-type
                                          string-set counter-reset counter-set counter-increment">
            <p:documentation>
                Make css:content, css:white-space, css:display, css:list-style-type, css:string-set,
                css:counter-reset, css:counter-set and css:counter-increment attributes.
            </p:documentation>
        </css:parse-properties>
        <css:parse-content>
            <p:documentation>
                Make css:string, css:text and css:counter elements from css:content attributes.
            </p:documentation>
        </css:parse-content>
    </p:for-each>
    
    <css:label-targets>
        <p:documentation>
            Make css:id attributes. <!-- depends on parse-content -->
        </p:documentation>
    </css:label-targets>
    
    <p:for-each>
        <css:eval-string-set>
            <p:documentation>
                Evaluate css:string-set attributes.
            </p:documentation>
        </css:eval-string-set>
        <css:preserve-white-space>
            <p:documentation>
                Make css:white-space elements from css:white-space attributes.
            </p:documentation>
        </css:preserve-white-space>
        <css:make-boxes>
            <p:documentation>
                Make css:box elements based on css:display and css:list-style-type attributes.
            </p:documentation>
        </css:make-boxes>
        <css:make-anonymous-inline-boxes/>
        <css:eval-target-text>
            <p:documentation>
                Evaluate css:text elements. <!-- depends on label-targets and parse-content -->
            </p:documentation>
        </css:eval-target-text>
    </p:for-each>
    
    <css:eval-counter exclude-counters="page">
        <p:documentation>
            Evaluate css:counter elements. <!-- depends on label-targets and parse-content -->
        </p:documentation>
    </css:eval-counter>
    
    <p:for-each>
        <css:parse-counter-set counters="page">
            <p:documentation>
                Make css:counter-set-page attributes.
            </p:documentation>
        </css:parse-counter-set>
        <css:split split-before="*[@css:page or @css:counter-set-page]" split-after="*[@css:page]">
            <p:documentation>
                Split before and after css:page attributes and before css:counter-set-page
                attributes. <!-- depends on make-boxes -->
            </p:documentation>
        </css:split>
    </p:for-each>
    
    <p:for-each>
        <p:group>
            <p:documentation>
                Move css:page and css:counter-set-page attributes to css:_ root element.
            </p:documentation>
            <p:wrap wrapper="css:_" match="/*"/>
            <p:label-elements match="/*[descendant::*/@css:page]" attribute="css:page"
                              label="(descendant::*/@css:page)[last()]"/>
            <p:label-elements match="/*[descendant::*/@css:counter-set-page]" attribute="css:counter-set-page"
                              label="(descendant::*/@css:counter-set-page)[last()]"/>
            <p:delete match="/*//*/@css:page"/>
            <p:delete match="/*//*/@css:counter-set-page"/>
        </p:group>
        <p:rename match="css:box[@type='inline']
                                [matches(string(.), '^[\s&#x2800;]*$') and
                                 not(descendant::css:white-space or
                                     descendant::css:string or
                                     descendant::css:counter or
                                     descendant::css:text or
                                     descendant::css:leader)]"
                  new-name="css:_">
            <p:documentation>
                Delete empty inline boxes (possible side effect of css:split).
            </p:documentation>
        </p:rename>
    </p:for-each>
    
    <css:shift-id/>
    <css:repeat-string-set/>
    <css:shift-string-set/>
    
    <p:for-each>
        <p:unwrap match="css:_[not(@css:*) and parent::*]">
            <p:documentation>
                All css:_ elements (except for root elements) should be gone now. <!-- depends on
                shift-id and shift-string-set -->
            </p:documentation>
        </p:unwrap>
        <css:parse-properties properties="padding-left padding-right padding-top padding-bottom">
            <p:documentation>
                Make css:padding-left, css:padding-right, css:padding-top and css:padding-bottom
                attributes.
            </p:documentation>
        </css:parse-properties>
        <css:padding-to-margin/>
        <css:make-anonymous-block-boxes/> <!-- depends on unwrap css:_ -->
    </p:for-each>
    
    <p:split-sequence test="//css:box"/>
    
    <p:for-each>
        <css:new-definition>
            <p:input port="definition">
                <p:inline>
                    <xsl:stylesheet version="2.0" xmlns:new="css:new-definition">
                        <xsl:variable name="new:properties" as="xs:string*"
                                      select="('margin-left',     'border-left',     'page-break-before',   'text-indent',
                                               'margin-right',    'border-right',    'page-break-after',    'text-align',
                                               'margin-top',      'border-top',      'page-break-inside',
                                               'margin-bottom',   'border-bottom',   'orphans', 'widows')"/>
                        <xsl:function name="new:is-valid" as="xs:boolean">
                            <xsl:param name="css:property" as="element()"/>
                            <xsl:param name="context" as="element()"/>
                            <xsl:sequence select="css:is-valid($css:property)
                                                  and not($css:property/@value=('inherit','initial'))
                                                  and new:applies-to($css:property/@name, $context)"/>
                        </xsl:function>
                        <xsl:function name="new:initial-value" as="xs:string">
                            <xsl:param name="property" as="xs:string"/>
                            <xsl:param name="context" as="element()"/>
                            <xsl:sequence select="css:initial-value($property)"/>
                        </xsl:function>
                        <xsl:function name="new:is-inherited" as="xs:boolean">
                            <xsl:param name="property" as="xs:string"/>
                            <xsl:param name="context" as="element()"/>
                            <xsl:sequence select="false()"/>
                        </xsl:function>
                        <xsl:function name="new:applies-to" as="xs:boolean">
                            <xsl:param name="property" as="xs:string"/>
                            <xsl:param name="context" as="element()"/>
                            <xsl:sequence select="$context/@type='block'"/>
                        </xsl:function>
                    </xsl:stylesheet>
                </p:inline>
            </p:input>
        </css:new-definition>
        <css:adjust-boxes/>
    </p:for-each>
    
    <p:xslt template-name="main">
        <p:input port="stylesheet">
            <p:document href="css-to-obfl.xsl"/>
        </p:input>
        <p:input port="parameters">
            <p:empty/>
        </p:input>
    </p:xslt>
    
</p:declare-step>
