<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step type="pxi:css-to-obfl"
                xmlns:p="http://www.w3.org/ns/xproc"
                xmlns:px="http://www.daisy.org/ns/pipeline/xproc"
                xmlns:pxi="http://www.daisy.org/ns/pipeline/xproc/internal"
                xmlns:css="http://www.daisy.org/ns/pipeline/braille-css"
                xmlns:obfl="http://www.daisy.org/ns/2011/obfl"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                exclude-inline-prefixes="pxi xsl"
                version="1.0">
    
    <!--
        Convert a document with inline Braille CSS to OBFL (Open Braille Formatting Language)
    -->
    
    <p:input port="source" sequence="true"/>
    <p:output port="result" sequence="false"/>
    
    <p:import href="http://www.daisy.org/pipeline/modules/braille/css-utils/library.xpl"/>
    <p:import href="split-into-sections.xpl"/>
    
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
        <css:parse-declaration-list properties="content string-set counter-reset white-space display"/>
        <css:eval-content-list/>
    </p:for-each>
    
    <css:label-anchors/>
    
    <p:for-each>
        <css:eval-string-set/>
        <css:preserve-white-space/>
        <css:make-boxes/>
        <css:make-anonymous-inline-boxes/>
    </p:for-each>
    
    <css:shift-string-set/>
    <css:shift-counter-reset/>
    
    <p:for-each>
        <pxi:split-into-sections/>
    </p:for-each>
    
    <p:for-each>
        <p:rename match="css:box[@type='inline']
                                [matches(string(.), '^[\s&#x2800;]*$') and
                                 not(descendant::css:white-space or
                                     descendant::css:string-fn or
                                     descendant::css:counter-fn or
                                     descendant::css:target-text-fn or
                                     descendant::css:target-string-fn or
                                     descendant::css:target-counter-fn or
                                     descendant::css:leader-fn)]"
                  new-name="css:_"/>
    </p:for-each>
    
    <p:wrap-sequence wrapper="_"/>
    <p:label-elements match="css:_[@css:anchor]/css:box" attribute="css:anchor" replace="false"
                      label="parent::*/@css:anchor"/>
    <p:delete match="@css:anchor[.=(ancestor::*|preceding::*)/@css:anchor]"/>
    <p:delete match="css:_/@css:anchor"/>
    <p:unwrap match="css:_[not(@*)]"/>
    <p:filter select="/_/css:root"/>
    
    <p:for-each>
        <css:parse-declaration-list properties="padding-left padding-right padding-top padding-bottom"/>
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
