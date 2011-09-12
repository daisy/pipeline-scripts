<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step xmlns:p="http://www.w3.org/ns/xproc" xmlns:html="http://www.w3.org/1999/xhtml" xmlns:c="http://www.w3.org/ns/xproc-step" type="pxi:daisy202-to-epub3-ncc-navigation"
    name="ncc-navigation" xmlns:pxi="http://www.daisy.org/ns/pipeline/xproc/internal" version="1.0">

    <p:input port="ncc"/>
    <p:input port="daisy-smil" sequence="true"/>

    <p:output port="result" primary="false">
        <p:pipe port="result" step="ncc-navigation.result"/>
    </p:output>
    <p:output port="original-base" primary="false">
        <p:pipe port="result" step="ncc-navigation.original-base"/>
    </p:output>

    <p:option name="publication-dir" required="true"/>
    <p:option name="content-dir" required="true"/>

    <p:import href="resolve-links.xpl"/>

    <p:variable name="subdir" select="substring-after($content-dir,$publication-dir)"/>
    <pxi:daisy202-to-epub3-resolve-links>
        <p:input port="source">
            <p:pipe port="ncc" step="ncc-navigation"/>
        </p:input>
        <p:input port="daisy-smil">
            <p:pipe port="daisy-smil" step="ncc-navigation"/>
        </p:input>
    </pxi:daisy202-to-epub3-resolve-links>
    <p:identity name="ncc-navigation.no-navs"/>
    <p:sink/>
    <p:xslt name="ncc-navigation.toc">
        <p:input port="parameters">
            <p:empty/>
        </p:input>
        <p:input port="source">
            <p:pipe port="result" step="ncc-navigation.no-navs"/>
        </p:input>
        <p:input port="stylesheet">
            <p:document href="ncc-to-nav-toc.xsl"/>
        </p:input>
    </p:xslt>
    <p:sink/>
    <p:xslt>
        <p:input port="parameters">
            <p:empty/>
        </p:input>
        <p:input port="source">
            <p:pipe port="result" step="ncc-navigation.no-navs"/>
        </p:input>
        <p:input port="stylesheet">
            <p:document href="ncc-to-nav-page-list.xsl"/>
        </p:input>
    </p:xslt>
    <p:choose>
        <p:when test="count(/*/*)=0">
            <p:identity>
                <p:input port="source">
                    <p:empty/>
                </p:input>
            </p:identity>
        </p:when>
        <p:otherwise>
            <p:identity/>
        </p:otherwise>
    </p:choose>
    <p:identity name="ncc-navigation.page-list"/>
    <p:sink/>
    <p:xslt>
        <p:input port="parameters">
            <p:empty/>
        </p:input>
        <p:input port="source">
            <p:pipe port="result" step="ncc-navigation.no-navs"/>
        </p:input>
        <p:input port="stylesheet">
            <p:document href="ncc-to-nav-landmarks.xsl"/>
        </p:input>
    </p:xslt>
    <p:choose>
        <p:when test="count(/*/*)=0">
            <p:identity>
                <p:input port="source">
                    <p:empty/>
                </p:input>
            </p:identity>
        </p:when>
        <p:otherwise>
            <p:identity/>
        </p:otherwise>
    </p:choose>
    <p:identity name="ncc-navigation.landmarks"/>
    <p:sink/>
    <p:delete match="html:body/*">
        <p:input port="source">
            <p:pipe port="result" step="ncc-navigation.no-navs"/>
        </p:input>
    </p:delete>
    <p:insert match="html:body" position="last-child">
        <p:input port="insertion">
            <p:pipe port="result" step="ncc-navigation.toc"/>
            <p:pipe port="result" step="ncc-navigation.page-list"/>
            <p:pipe port="result" step="ncc-navigation.landmarks"/>
        </p:input>
    </p:insert>
    <p:add-attribute match="/*" attribute-name="profile" attribute-value="http://www.idpf.org/epub/30/profile/content/"/>
    <p:identity name="ncc-navigation.original-links"/>
    <p:viewport match="html:a[@href and not(matches(@href,'^[^/]+:'))]">
        <p:add-attribute match="/*" attribute-name="href">
            <p:with-option name="attribute-value"
                select="concat($subdir,replace(tokenize(/*/@href,'#')[1],'^(.*)\.html$','$1.xhtml#'),if (contains(/*/@href,'#')) then tokenize(/*/@href,'#')[last()] else '')"/>
        </p:add-attribute>
    </p:viewport>
    <p:identity name="ncc-navigation.result"/>
    <p:sink/>
    
    <p:add-attribute name="ncc-navigation.original-base" match="/*" attribute-name="xml:base">
        <p:input port="source">
            <p:pipe port="result" step="ncc-navigation.original-links"/>
        </p:input>
        <p:with-option name="attribute-value" select="/*/@xml:base">
            <p:pipe port="ncc" step="ncc-navigation"/>
        </p:with-option>
    </p:add-attribute>
    <p:sink/>

</p:declare-step>
