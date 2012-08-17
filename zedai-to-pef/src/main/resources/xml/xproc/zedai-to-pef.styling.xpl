<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step
    xmlns:p="http://www.w3.org/ns/xproc"
    xmlns:px="http://www.daisy.org/ns/pipeline/xproc"
    xmlns:z="http://www.daisy.org/ns/z3998/authoring/"
    xmlns:css="http://xmlcalabash.com/ns/extensions/braille-css"
    exclude-inline-prefixes="px z css"
    type="px:zedai-to-pef.styling" name="zedai-to-pef.styling" version="1.0">

    <p:input port="source" primary="true" px:media-type="application/z3998-auth+xml"/>
    <p:output port="result" primary="true" px:media-type="application/z3998-auth+xml"/>
    <p:option name="default-stylesheet" required="true"/>
    
    <p:import href="http://www.daisy.org/pipeline/modules/braille/css-calabash/xproc/library.xpl"/>

    <p:choose>
        <p:xpath-context>
            <p:pipe port="source" step="zedai-to-pef.styling"/>
        </p:xpath-context>
        
        <p:when test="not(//z:head/link[@rel='stylesheet' and @media='embossed' and @type='text/css'])">
            
            <!-- FIXME this is an ugly solution -->
            <p:variable name="default-stylesheet-uri"
                select="concat(substring(base-uri(/), 0, string-length(base-uri(/))-25), 'css/', $default-stylesheet)">
                <p:document href="zedai-to-pef.xpl"/>
            </p:variable>
            
            <p:add-attribute match="/link" attribute-name="href" name="link">
                <p:input port="source">
                    <p:inline>
                        <link rel="stylesheet" media="embossed" type="text/css"/>
                    </p:inline>
                </p:input>
                <p:with-option name="attribute-value" select="$default-stylesheet-uri">
                    <p:empty/>
                </p:with-option>
            </p:add-attribute>
            
            <p:insert match="//z:head" position="first-child">
                <p:input port="source">
                    <p:pipe port="source" step="zedai-to-pef.styling"/>
                </p:input>
                <p:input port="insertion">
                    <p:pipe step="link" port="result"/>
                </p:input>
            </p:insert>
        </p:when>
        <p:otherwise>
            <p:identity>
                <p:input port="source">
                    <p:pipe port="source" step="zedai-to-pef.styling"/>
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
