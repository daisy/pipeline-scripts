<?xml version="1.0" encoding="UTF-8"?>

<p:declare-step version="1.0" name="dtbook2zedai" xmlns:p="http://www.w3.org/ns/xproc"
    xmlns:c="http://www.w3.org/ns/xproc-step" xmlns:cx="http://xmlcalabash.com/ns/extensions"
    xmlns:cxo="http://xmlcalabash.com/ns/extensions/osutils"
    xmlns:d2z="http://pipeline.daisy.org/ns/dtbook2zedai/" exclude-inline-prefixes="cx">

    <!-- 
        
        This XProc script is the main entry point for the DTBook2ZedAI module.
        The module's homepage is here: http://code.google.com/p/daisy-pipeline/wiki/DTBook2ZedAI
        
    -->

    <p:input port="source" primary="true" sequence="true"/>
    <p:input port="parameters" kind="parameter"/>

    <p:option name="output" select="''"/>

    <p:import href="http://xmlcalabash.com/extension/steps/library-1.0.xpl"/>
    <p:import href="transform-dtbook2zedai.xpl"/>
    <p:import href="merge-dtbook.xpl"/>

    <p:variable name="zedai-file"
        select="resolve-uri(
                    if ($output='') then concat(
                        if (matches(base-uri(/),'[^/]+\..+$'))
                        then replace(tokenize(base-uri(/),'/')[last()],'\..+$','')
                        else tokenize(base-uri(/),'/')[last()],'-zedai.xml')
                    else if (ends-with($output,'.xml')) then $output 
                    else concat($output,'.xml'), base-uri(/))">
        <p:pipe step="dtbook2zedai" port="source"/>

    </p:variable>

    <p:variable name="mods-file" select="replace($zedai-file, '.xml', '-mods.xml')"/>

    <p:variable name="css-file" select="replace($zedai-file, '.xml', '.css')"/>

    <!-- Validate DTBook Input-->
    <p:validate-with-relax-ng assert-valid="true" name="validate-dtbook">
        <p:input port="schema">
            <p:document href="schema/dtbook-2005-3.rng"/>
        </p:input>
    </p:validate-with-relax-ng>


    <!--<p:count name="num-input-documents" limit="2"/>

    <p:choose>
        <p:when test=".//c:result[. > 1]">
            <d2z:merge-dtbook/>
        </p:when>
        <p:otherwise>
            <cx:message>
                <p:with-option name="message" select="'single'"/>
            </cx:message>
        </p:otherwise>
    </p:choose>
-->


    <!-- create MODS metadata record -->
    <p:xslt name="create-mods">
        <p:input port="source">
            <p:pipe step="validate-dtbook" port="result"/>
        </p:input>
        <p:input port="stylesheet">
            <p:document href="generate-mods.xsl"/>
        </p:input>
    </p:xslt>

    <!-- normalize and transform -->
    <d2z:transform-dtbook2zedai name="transform-dtbook2zedai">
        <p:input port="source">
            <p:pipe port="result" step="validate-dtbook"/>
        </p:input>
        <p:with-option name="css-filename" select="$css-file"/>
        <p:with-option name="mods-filename" select="$mods-file"/>
    </d2z:transform-dtbook2zedai>

    <p:xslt name="generate-css">
        <p:input port="source">
            <p:pipe step="transform-dtbook2zedai" port="result"/>
        </p:input>
        <p:input port="stylesheet">
            <p:inline>
                <xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="2.0">
                    <xsl:import href="generate-css.xsl"/>
                    <xsl:template match="/">
                        <css-data>
                            <xsl:apply-imports/>
                        </css-data>
                    </xsl:template>
                </xsl:stylesheet>
            </p:inline>
        </p:input>
    </p:xslt>

    <p:xslt name="remove-css-attributes">
        <p:input port="stylesheet">
            <p:document href="remove-css-attributes.xsl"/>
        </p:input>
        <p:input port="source">
            <p:pipe step="transform-dtbook2zedai" port="result"/>
        </p:input>
    </p:xslt>

    <!-- Validate the ZedAI output -->
    <p:validate-with-relax-ng name="validate-zedai" assert-valid="false">
        <p:input port="schema">
            <p:document href="schema/z3986a-book-0.8/z3986a-book.rng"/>
        </p:input>
        <p:input port="source">
            <p:pipe port="result" step="remove-css-attributes"/>
        </p:input>
    </p:validate-with-relax-ng>


    <!-- write files-->
    <!-- write the ZedAI file -->
    <p:store>
        <p:input port="source">
            <p:pipe step="validate-zedai" port="result"/>
        </p:input>
        <p:with-option name="href" select="$zedai-file"/>
    </p:store>

    <!-- write the MODS metadata record -->
    <p:store>
        <p:input port="source">
            <p:pipe step="create-mods" port="result"/>
        </p:input>
        <p:with-option name="href" select="$mods-file"/>
    </p:store>

    <!-- write the CSS file (first strip it of its xml wrapper) -->
    <p:string-replace match="/text()" replace="''">
        <p:input port="source">
            <p:pipe step="generate-css" port="result"/>
        </p:input>
    </p:string-replace>
    <p:store method="text">
        <p:with-option name="href" select="$css-file"/>
    </p:store>
</p:declare-step>
