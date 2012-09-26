<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step
    xmlns:p="http://www.w3.org/ns/xproc"
    xmlns:px="http://www.daisy.org/ns/pipeline/xproc"
    xmlns:css="http://xmlcalabash.com/ns/extensions/braille-css"
    exclude-inline-prefixes="px css"
    type="px:xml-to-pef.styling" name="xml-to-pef.styling" version="1.0">

    <p:input port="source" primary="true"/>
    <p:output port="result" primary="true"/>
    <p:option name="default-stylesheet" required="true"/>
    
    <p:import href="http://www.daisy.org/pipeline/modules/braille/css-calabash/xproc/library.xpl"/>

    <p:choose>
        <p:xpath-context>
            <p:pipe port="source" step="xml-to-pef.styling"/>
        </p:xpath-context>
        
        <p:when test="not(//*[name()='head'][1]/link[@rel='stylesheet' and @media='embossed' and @type='text/css'])">
            
            <p:add-attribute match="/link" attribute-name="href" name="link">
                <p:input port="source">
                    <p:inline>
                        <link rel="stylesheet" media="embossed" type="text/css"/>
                    </p:inline>
                </p:input>
                <p:with-option name="attribute-value" select="$default-stylesheet">
                    <p:empty/>
                </p:with-option>
            </p:add-attribute>
            
            <p:insert match="//*[name()='head'][1]" position="first-child">
                <p:input port="source">
                    <p:pipe port="source" step="xml-to-pef.styling"/>
                </p:input>
                <p:input port="insertion">
                    <p:pipe step="link" port="result"/>
                </p:input>
            </p:insert>
        </p:when>
        <p:otherwise>
            <p:identity>
                <p:input port="source">
                    <p:pipe port="source" step="xml-to-pef.styling"/>
                </p:input>
            </p:identity>
        </p:otherwise>
    </p:choose>
    
    <!-- Apply stylesheet -->
    
    <css:apply-stylesheet/>
    
    <!-- Handle :before and :after pseudo-elements -->
    
    <p:xslt>
        <p:input port="stylesheet">
            <p:document href="../xslt/handle-before-after.xsl"/>
        </p:input>
        <p:input port="parameters">
            <p:empty/>
        </p:input>
    </p:xslt>
    
</p:declare-step>
