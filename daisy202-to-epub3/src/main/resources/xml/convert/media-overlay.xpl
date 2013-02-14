<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step xmlns:p="http://www.w3.org/ns/xproc" xmlns:c="http://www.w3.org/ns/xproc-step" xmlns:px="http://www.daisy.org/ns/pipeline/xproc" xmlns:pxi="http://www.daisy.org/ns/pipeline/xproc/internal" xmlns:html="http://www.w3.org/1999/xhtml"
    xmlns:d="http://www.daisy.org/ns/pipeline/data" xmlns:mo="http://www.w3.org/ns/SMIL" xmlns:cx="http://xmlcalabash.com/ns/extensions" xmlns:epub="http://www.idpf.org/2007/ops" type="pxi:daisy202-to-epub3-mediaoverlay" name="mediaoverlay"
    version="1.0">

    <p:documentation xmlns="http://www.w3.org/1999/xhtml">
        <p px:role="desc">For processing the SMILs.</p>
    </p:documentation>

    <p:input port="daisy-smil" sequence="true" primary="true">
        <p:documentation xmlns="http://www.w3.org/1999/xhtml">The DAISY 2.02 SMIL-files.</p:documentation>
    </p:input>
    <p:input port="content" sequence="true">
        <p:documentation xmlns="http://www.w3.org/1999/xhtml">The EPUB3 Content Documents.</p:documentation>
    </p:input>

    <p:output port="mediaoverlay" sequence="true">
        <p:documentation xmlns="http://www.w3.org/1999/xhtml">The EPUB3 Media Overlays.</p:documentation>
    </p:output>

    <p:option name="daisy-dir" required="true">
        <p:documentation xmlns="http://www.w3.org/1999/xhtml">
            <p px:role="name">URI to the DAISY 2.02 files.</p>
            <pre><code class="example">file:/home/user/daisy202/</code></pre>
        </p:documentation>
    </p:option>
    <p:option name="publication-dir" required="true">
        <p:documentation xmlns="http://www.w3.org/1999/xhtml">
            <p px:role="desc">URI to the EPUB3 Publication directory.</p>
            <pre><code class="example">file:/home/user/epub3/epub/Publication/</code></pre>
        </p:documentation>
    </p:option>
    <p:option name="content-dir" required="true">
        <p:documentation xmlns="http://www.w3.org/1999/xhtml">
            <p px:role="name">URI to the EPUB3 Content directory.</p>
            <pre><code class="example">file:/home/user/epub3/epub/Publication/Content/</code></pre>
        </p:documentation>
    </p:option>
    <p:option name="navigation-uri" required="true">
        <p:documentation xmlns="http://www.w3.org/1999/xhtml">
            <p px:role="name">URI to the EPUB3 Navigation Document</p>
            <pre><code class="example">file:/home/user/epub3/epub/Publication/navigation.xhtml</code></pre>
        </p:documentation>
    </p:option>
    <p:option name="include-mediaoverlay" required="true">
        <p:documentation xmlns="http://www.w3.org/1999/xhtml">
            <p px:role="desc">Whether or not to include media overlays. Can be either 'true' or 'false'.</p>
        </p:documentation>
    </p:option>

    <p:import href="http://xmlcalabash.com/extension/steps/library-1.0.xpl">
        <p:documentation xmlns="http://www.w3.org/1999/xhtml">Calabash extension steps.</p:documentation>
    </p:import>
    <p:import href="http://www.daisy.org/pipeline/modules/fileset-utils/xproc/fileset-library.xpl">
        <p:documentation xmlns="http://www.w3.org/1999/xhtml">For manipulating filesets.</p:documentation>
    </p:import>
    <p:import href="http://www.daisy.org/pipeline/modules/mediaoverlay-utils/join.xpl">
        <p:documentation xmlns="http://www.w3.org/1999/xhtml">For joining media overlays.</p:documentation>
    </p:import>
    <p:import href="http://www.daisy.org/pipeline/modules/mediaoverlay-utils/upgrade-smil.xpl">
        <p:documentation xmlns="http://www.w3.org/1999/xhtml">For converting DAISY 2.02 SMIL-files into EPUB3 Media Overlays.</p:documentation>
    </p:import>
    <p:import href="http://www.daisy.org/pipeline/modules/mediaoverlay-utils/rearrange.xpl">
        <p:documentation xmlns="http://www.w3.org/1999/xhtml">For generating ("rearranging") new Media Overlays based on the Content Documents and the old Media Overlays.</p:documentation>
    </p:import>

    <p:declare-step type="pxi:fix-textrefs">
        <p:input port="source"/>
        <p:output port="result"/>
        <p:viewport match="/*//mo:seq[@epub:textref]">
            <p:add-attribute match="/*" attribute-name="epub:textref">
                <p:with-option name="attribute-value" select="replace(/*/@epub:textref,'^(.+)\.[^\.]*#(.*)$','$1.xhtml#$2')"/>
            </p:add-attribute>
            <pxi:fix-textrefs/>
        </p:viewport>
    </p:declare-step>

    <p:for-each name="daisy-smil-iterate">
        <p:iteration-source>
            <p:pipe port="daisy-smil" step="mediaoverlay"/>
        </p:iteration-source>
        <p:variable name="original-uri" select="base-uri(/*)"/>
        <px:mediaoverlay-upgrade-smil/>
        <cx:message>
            <p:with-option name="message" select="concat('upgraded the SMIL file ',$original-uri)"/>
        </cx:message>
        <p:add-attribute match="/*" attribute-name="xml:base">
            <p:with-option name="attribute-value" select="$original-uri"/>
        </p:add-attribute>
    </p:for-each>
    <px:mediaoverlay-join name="mediaoverlay-joined"/>
    <cx:message>
        <p:with-option name="message" select="'joined all the media overlays'"/>
    </cx:message>
    <p:sink/>

    <p:for-each>
        <p:iteration-source>
            <p:pipe port="content" step="mediaoverlay"/>
        </p:iteration-source>
        <p:variable name="content-result-uri" select="base-uri(/*)"/>
        <p:add-attribute match="/*" attribute-name="xml:base">
            <p:with-option name="attribute-value" select="/*/@original-href"/>
        </p:add-attribute>
        <p:choose>
            <p:when test="$include-mediaoverlay='true'">
                <p:variable name="result-uri" select="replace($content-result-uri,'xhtml$','smil')"/>
                
                <cx:message>
                    <p:with-option name="message" select="concat('compiling media overlay for ',substring-after($result-uri,$publication-dir))"/>
                </cx:message>
                <px:mediaoverlay-rearrange>
                    <p:input port="mediaoverlay">
                        <p:pipe port="result" step="mediaoverlay-joined"/>
                    </p:input>
                </px:mediaoverlay-rearrange>
                <p:choose>
                    <p:when test="$result-uri = concat($publication-dir,'navigation.smil')">
                        <!-- for nav doc; make links relative to publication-dir instead of content-dir -->
                        <p:viewport match="//mo:text">
                            <p:add-attribute match="/*" attribute-name="src">
                                <p:with-option name="attribute-value" select="concat('navigation.xhtml#',tokenize(/*/@src,'#')[last()])"/>
                            </p:add-attribute>
                        </p:viewport>
                        <p:viewport match="//mo:audio">
                            <p:add-attribute match="/*" attribute-name="src">
                                <p:with-option name="attribute-value" select="concat(substring-after($content-dir,$publication-dir),/*/@src)"/>
                            </p:add-attribute>
                        </p:viewport>
                    </p:when>
                    <p:otherwise>
                        <p:identity/>
                    </p:otherwise>
                </p:choose>
                <p:add-attribute match="/*" attribute-name="xml:base">
                    <p:with-option name="attribute-value" select="$result-uri"/>
                </p:add-attribute>
                <p:delete match="/*/@xml:base"/>
                <p:viewport match="//mo:text">
                    <p:add-attribute match="/*" attribute-name="src">
                        <p:with-option name="attribute-value" select="replace(/*/@src,'^(.+)\.[^\.]*#(.*)$','$1.xhtml#$2')"/>
                    </p:add-attribute>
                </p:viewport>
                <pxi:fix-textrefs/>
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

</p:declare-step>
