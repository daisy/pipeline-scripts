<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step xmlns:p="http://www.w3.org/ns/xproc" xmlns:px="http://www.daisy.org/ns/pipeline/xproc"
    xmlns:pxi="http://www.daisy.org/ns/pipeline/xproc/internal" xmlns:html="http://www.w3.org/1999/xhtml"
    xmlns:d="http://www.daisy.org/ns/pipeline/data" xmlns:mo="http://www.w3.org/ns/SMIL"
    type="pxi:daisy202-to-epub3-mediaoverlay" name="mediaoverlay" version="1.0">

    <p:input port="daisy-smil" sequence="true" primary="true"/>
    <p:input port="content-with-original-base" sequence="true"/>

    <p:output port="mediaoverlay" sequence="true">
        <p:pipe port="mediaoverlay" step="mediaoverlay-iterate"/>
    </p:output>
    <p:output port="manifest">
        <p:pipe port="result" step="manifest"/>
    </p:output>
    <p:output port="store-complete" sequence="true">
        <p:pipe port="store-complete" step="mediaoverlay-iterate"/>
    </p:output>
    <p:output port="dbg" sequence="true">
        <p:pipe port="result" step="mediaoverlay-joined"/>
    </p:output>

    <p:option name="daisy-dir" required="true"/>
    <p:option name="publication-dir" required="true"/>
    <p:option name="content-dir" required="true"/>
    <p:option name="navigation-uri" required="true"/>
    <p:option name="include-mediaoverlay" required="true"/>

    <p:import href="resolve-links.xpl"/>
    <p:import href="http://www.daisy.org/pipeline/modules/fileset-utils/xproc/fileset-library.xpl"/>
    <p:import href="http://www.daisy.org/pipeline/modules/mediaoverlay-utils/join.xpl"/>
    <p:import href="http://www.daisy.org/pipeline/modules/mediaoverlay-utils/upgrade-smil.xpl"/>
    <p:import href="http://www.daisy.org/pipeline/modules/mediaoverlay-utils/rearrange.xpl"/>
    <p:import href="http://www.daisy.org/pipeline/modules/html-utils/html-library.xpl"/>

    <p:for-each name="daisy-smil-iterate">
        <p:iteration-source>
            <p:pipe port="daisy-smil" step="mediaoverlay"/>
        </p:iteration-source>
        <p:variable name="original-uri" select="/*/@xml:base"/>
        <px:mediaoverlay-upgrade-smil/>
        <p:add-attribute match="/*" attribute-name="xml:base">
            <p:with-option name="attribute-value" select="$original-uri"/>
        </p:add-attribute>
    </p:for-each>
    <px:mediaoverlay-join name="mediaoverlay-joined"/>
    <p:sink/>

    <p:for-each name="mediaoverlay-iterate">
        <p:output port="mediaoverlay" sequence="true">
            <p:pipe port="mediaoverlay" step="mediaoverlay-iterate.choose"/>
        </p:output>
        <p:output port="store-complete" sequence="true">
            <p:pipe port="store-complete" step="mediaoverlay-iterate.choose"/>
        </p:output>
        <p:iteration-source>
            <p:pipe port="content-with-original-base" step="mediaoverlay"/>
        </p:iteration-source>
        <p:choose name="mediaoverlay-iterate.choose">
            <p:when test="$include-mediaoverlay='true'">
                <p:output port="mediaoverlay" sequence="true">
                    <p:pipe port="result" step="mediaoverlay-iterate.mediaoverlay"/>
                </p:output>
                <p:output port="store-complete" sequence="true">
                    <p:pipe port="result" step="mediaoverlay-iterate.store-mediaoverlay"/>
                </p:output>

                <p:variable name="result-uri"
                    select="if (/*/@xml:base=$navigation-uri)
                                then concat($publication-dir,'navigation.smil')
                                else concat($content-dir,
                                    substring(
                                            if (matches(/*/@xml:base,'\.[^/]*$'))
                                                then
                                                    replace(/*/@xml:base,'^(.*)\.[^/\.]*$','$1.smil')
                                                else
                                                    concat(/*/@xml:base,'.smil'),
                                            string-length($daisy-dir)+1
                                    )
                                )"/>
                <px:mediaoverlay-rearrange name="dbg-tmp">
                    <p:input port="mediaoverlay">
                        <p:pipe port="result" step="mediaoverlay-joined"/>
                    </p:input>
                </px:mediaoverlay-rearrange>
                <p:choose>
                    <p:when test="$result-uri = concat($publication-dir,'navigation.smil')">
                        <p:viewport match="//mo:text">
                            <p:add-attribute match="/*" attribute-name="src">
                                <p:with-option name="attribute-value"
                                    select="concat('navigation.xhtml#',tokenize(/*/@src,'#')[last()])"/>
                            </p:add-attribute>
                        </p:viewport>
                        <p:viewport match="//mo:audio">
                            <p:add-attribute match="/*" attribute-name="src">
                                <p:with-option name="attribute-value"
                                    select="concat(substring-after($content-dir,$publication-dir),/*/@src)"/>
                            </p:add-attribute>
                        </p:viewport>
                    </p:when>
                    <p:otherwise>
                        <p:identity/>
                    </p:otherwise>
                </p:choose>
                <p:add-attribute match="/*" name="mediaoverlay-iterate.mediaoverlay" attribute-name="xml:base">
                    <p:with-option name="attribute-value" select="$result-uri"/>
                </p:add-attribute>
                <p:delete match="//@xml:base"/>
                <p:viewport match="//mo:text">
                    <p:add-attribute match="/*" attribute-name="src">
                        <p:with-option name="attribute-value" select="replace(/*/@src,'^(.+)\.[^\.]*#(.*)$','$1.xhtml#$2')"/>
                    </p:add-attribute>
                </p:viewport>
                <p:store indent="true" name="mediaoverlay-iterate.store-mediaoverlay">
                    <p:with-option name="href" select="$result-uri"/>
                </p:store>
            </p:when>
            <p:otherwise>
                <p:output port="mediaoverlay" sequence="true">
                    <p:empty/>
                </p:output>
                <p:output port="store-complete" sequence="true">
                    <p:empty/>
                </p:output>
                <p:sink/>
            </p:otherwise>
        </p:choose>
    </p:for-each>

    <p:for-each name="mediaoverlay-filesets">
        <p:output port="result" sequence="true"/>
        <p:iteration-source>
            <p:pipe port="mediaoverlay" step="mediaoverlay-iterate"/>
        </p:iteration-source>
        <p:variable name="uri" select="/*/@xml:base"/>
        <p:choose>
            <p:when test="$include-mediaoverlay">
                <p:identity>
                    <p:input port="source">
                        <p:inline>
                            <d:fileset xmlns:d="http://www.daisy.org/ns/pipeline/data">
                                <d:file media-type="application/smil+xml"/>
                            </d:fileset>
                        </p:inline>
                    </p:input>
                </p:identity>
                <p:add-attribute match="/*" attribute-name="xml:base">
                    <p:with-option name="attribute-value" select="replace($uri,'(.*/)[^/]*$','$1')"/>
                </p:add-attribute>
                <p:add-attribute match="/*/*" attribute-name="href">
                    <p:with-option name="attribute-value" select="replace($uri,'.*/([^/]*)$','$1')"/>
                </p:add-attribute>
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
    <p:sink/>
    <px:fileset-join name="manifest">
        <p:input port="source">
            <p:pipe port="result" step="mediaoverlay-filesets"/>
        </p:input>
    </px:fileset-join>

</p:declare-step>
