<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step xmlns:p="http://www.w3.org/ns/xproc"
    xmlns:pxi="http://www.daisy.org/ns/pipeline/xproc/internal"
    xmlns:html="http://www.w3.org/1999/xhtml" xmlns:xd="http://www.daisy.org/ns/pipeline/doc"
    type="pxi:daisy202-to-epub3-resolve-links" name="resolve-links" version="1.0">

    <p:input port="source" primary="true"/>
    <p:input port="daisy-smil" sequence="true"/>
    <p:output port="result"/>

    <p:variable name="content-base" select="/*/@xml:base"/>

    <p:add-attribute match="//html:a" attribute-name="xml:base">
        <p:with-option name="attribute-value" select="$content-base"/>
    </p:add-attribute>

    <p:documentation>For each 'a'-link</p:documentation>
    <p:viewport match="//html:a">
        <p:variable name="a-uri" select="resolve-uri(tokenize(/*/@href,'#')[1],/*/@xml:base)"/>
        <p:variable name="a-fragment"
            select="if (contains(/*/@href,'#')) then tokenize(/*/@href,'#')[last()] else ''"/>
        <p:identity name="a-original"/>
        <p:documentation>For each SMIL</p:documentation>
        <p:for-each>
            <p:iteration-source>
                <p:pipe port="daisy-smil" step="resolve-links"/>
            </p:iteration-source>
            <p:variable name="smil-base" select="/*/@xml:base"/>
            <p:add-xml-base all="true" relative="false"/>
            <p:choose>
                <p:documentation>When SMIL-file is the one referenced from the
                    'a'-link</p:documentation>
                <p:when test="$smil-base=$a-uri">
                    <p:documentation>For each text element where the a@fragment matches the text@id
                        or text/parent@id</p:documentation>
                    <p:for-each>
                        <p:iteration-source
                            select="//*[local-name()='par' and (@id=$a-fragment or child::*[local-name()='text']/@id=$a-fragment)]"/>
                        <p:variable name="text-id" select="(/*/*[local-name()='text'] | /*/@id)[1]"/>
                        <p:variable name="text-uri"
                            select="p:resolve-uri(tokenize(/*/*[local-name()='text']/@src,'#')[1],/*/*[local-name()='text']/@xml:base)"/>
                        <p:variable name="text-fragment"
                            select="if (contains(/*/*[local-name()='text']/@src,'#')) then tokenize(/*/*[local-name()='text']/@src,'#')[last()] else ''"/>
                        <p:choose>
                            <p:documentation>when text@src references the content (but not the
                                'a'-link)</p:documentation>
                            <p:when test="$text-uri=$content-base">
                                <p:documentation>Keep the link, but remove the part before the '#'
                                    in @src</p:documentation>
                                <p:add-attribute match="/*" attribute-name="href">
                                    <p:with-option name="attribute-value"
                                        select="concat('#',$text-fragment)"/>
                                    <p:input port="source">
                                        <p:pipe port="result" step="a-original"/>
                                    </p:input>
                                </p:add-attribute>
                            </p:when>
                            <p:documentation>When text@src references a file in the same or
                                descendant directory</p:documentation>
                            <p:when test="starts-with($text-uri,replace($content-base,'[^/]+$',''))">
                                <p:documentation>Keep the link, but make the part before the '#' in
                                    @href relative to the targeted file. TODO: improve this script
                                    to support "upwards-pointing" relative paths</p:documentation>
                                <p:add-attribute match="/*" attribute-name="href">
                                    <p:with-option name="attribute-value"
                                        select="concat(substring($text-uri,(floor(string-length(replace($content-base,'[^/]+$','')))+1)),'#',$text-fragment)"/>
                                    <p:input port="source">
                                        <p:pipe port="result" step="a-original"/>
                                    </p:input>
                                </p:add-attribute>
                            </p:when>
                            <p:otherwise>
                                <p:documentation>Does not resolve to file in directories "above" the
                                    content documents directory (or external
                                    paths)</p:documentation>
                                <p:identity>
                                    <p:input port="source">
                                        <p:pipe port="result" step="a-original"/>
                                    </p:input>
                                </p:identity>
                            </p:otherwise>
                        </p:choose>
                        <p:identity/>
                    </p:for-each>
                </p:when>
                <p:otherwise>
                    <p:identity>
                        <p:input port="source">
                            <p:empty/>
                        </p:input>
                    </p:identity>
                </p:otherwise>
            </p:choose>
        </p:for-each>
        <p:for-each name="a-new">
            <p:output port="result" primary="true"/>
            <p:choose>
                <p:when test="p:iteration-position()=1">
                    <p:identity/>
                </p:when>
                <p:otherwise>
                    <p:identity>
                        <p:input port="source">
                            <p:empty/>
                        </p:input>
                    </p:identity>
                </p:otherwise>
            </p:choose>
        </p:for-each>
        <p:count/>
        <p:choose>
            <p:when test=". = 1">
                <p:identity>
                    <p:input port="source">
                        <p:pipe port="result" step="a-new"/>
                    </p:input>
                </p:identity>
            </p:when>
            <p:otherwise>
                <p:identity>
                    <p:input port="source">
                        <p:pipe port="result" step="a-original"/>
                    </p:input>
                </p:identity>
                <p:choose>
                    <p:when test="starts-with(/*/@href,'file:')">
                        <p:add-attribute match="/*" attribute-name="unwrap" attribute-value="3"/>
                    </p:when>
                    <p:otherwise>
                        <p:identity/>
                    </p:otherwise>
                </p:choose>
            </p:otherwise>
        </p:choose>
        <p:delete match="/*/@xml:base"/>
    </p:viewport>
    <!--p:delete match="//*[@unwrap]"/-->
    <p:xslt>
        <p:input port="parameters">
            <p:empty/>
        </p:input>
        <p:input port="stylesheet">
            <p:document href="nav-unwrap-untitled-toc-levels.xsl"/>
        </p:input>
    </p:xslt>
    <p:xslt>
        <p:input port="parameters">
            <p:empty/>
        </p:input>
        <p:input port="stylesheet">
            <p:document href="resolve-links.xsl"/>
        </p:input>
    </p:xslt>

</p:declare-step>
