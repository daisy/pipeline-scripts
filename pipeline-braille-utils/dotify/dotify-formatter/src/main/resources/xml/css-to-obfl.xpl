<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step type="pxi:css-to-obfl"
                xmlns:p="http://www.w3.org/ns/xproc"
                xmlns:px="http://www.daisy.org/ns/pipeline/xproc"
                xmlns:pxi="http://www.daisy.org/ns/pipeline/xproc/internal"
                xmlns:css="http://www.daisy.org/ns/pipeline/braille-css"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                exclude-inline-prefixes="pxi xsl"
                version="1.0">
    
    <!--
        Convert a document with inline Braille CSS to OBFL (Open Braille Formatting Language)
    -->
    
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
        <css:parse-stylesheet/>
        <css:make-pseudo-elements/>
        <css:parse-properties properties="content white-space display list-style-type
                                          string-set counter-reset counter-set counter-increment"/>
        <css:parse-content/>
    </p:for-each>
    
    <css:label-targets/>
    
    <p:for-each>
        <css:eval-string-set/>
        <css:preserve-white-space/>
        <css:make-boxes/>
        <css:make-anonymous-inline-boxes/>
    </p:for-each>
    
    <css:eval-counter exclude-counters="page"/>
    
    <p:for-each>
        <css:parse-counter-set counters="page"/>
        <!--
            Split before and after @css:page and before @css:counter-set-page
        -->
        <css:split split-before="*[@css:page or @css:counter-set-page]" split-after="*[@css:page]"/>
    </p:for-each>
    
    <p:for-each>
        <!--
            Move @css:page and @css:counter-set-page to root element
        -->
        <p:label-elements match="/*[descendant::*/@css:page]" attribute="css:page"
                          label="(descendant::*/@css:page)[last()]"/>
        <p:label-elements match="/*[descendant::*/@css:counter-set-page]" attribute="css:counter-set-page"
                          label="(descendant::*/@css:counter-set-page)[last()]"/>
        <p:delete match="/*//*/@css:page"/>
        <p:delete match="/*//*/@css:counter-set-page"/>
        <!--
            Delete empty inline boxes (possible side effect of css:split)
        -->
        <p:rename match="css:box[@type='inline']
                                [matches(string(.), '^[\s&#x2800;]*$') and
                                 not(descendant::css:white-space or
                                     descendant::css:string or
                                     descendant::css:counter or
                                     descendant::css:text or
                                     descendant::css:leader)]"
                  new-name="css:_"/>
    </p:for-each>
    
    <css:shift-string-set/>
    <css:shift-id/>
    
    <p:for-each>
        <p:unwrap match="css:_[not(@css:*)]"/>
        <css:parse-properties properties="padding-left padding-right padding-top padding-bottom"/>
        <css:padding-to-margin/>
        <css:make-anonymous-block-boxes/>
    </p:for-each>
    
    <css:repeat-string-set/>
    <p:split-sequence test="//css:box"/>
    
    <p:xslt template-name="main">
        <p:input port="stylesheet">
            <p:document href="css-to-obfl.xsl"/>
        </p:input>
        <p:input port="parameters">
            <p:empty/>
        </p:input>
    </p:xslt>
    
</p:declare-step>
