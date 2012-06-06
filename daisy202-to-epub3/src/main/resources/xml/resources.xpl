<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step xmlns:p="http://www.w3.org/ns/xproc" xmlns:px="http://www.daisy.org/ns/pipeline/xproc" xmlns:pxi="http://www.daisy.org/ns/pipeline/xproc/internal"
    xmlns:cx="http://xmlcalabash.com/ns/extensions" type="pxi:daisy202-to-epub3-resources" name="resources" version="1.0">

    <p:documentation>
        <h1 px:role="desc">Copy the auxiliary resources from the DAISY 2.02 fileset to the EPUB 3 fileset, and return a manifest of all the resulting files.</h1>
    </p:documentation>

    <p:input port="daisy-smil" sequence="true">
        <p:documentation xmlns="http://www.w3.org/1999/xhtml">
            <p px:role="desc">The DAISY 2.02 SMIL-files.</p>
            <pre><code class="example">
                <smil xml:base="file:/home/user/daisy202/a.smil">...</smil>
                <smil xml:base="file:/home/user/daisy202/b.smil">...</smil>
                <smil xml:base="file:/home/user/daisy202/c.smil">...</smil>
            </code></pre>
        </p:documentation>
    </p:input>
    <p:input port="daisy-content" sequence="true">
        <p:documentation xmlns="http://www.w3.org/1999/xhtml">
            <p px:role="desc">The EPUB3 Content Documents with @original-base annotated to reference the original DAISY 2.02 content files.</p>
            <pre><code class="example">
                <html xmlns="http://www.w3.org/1999/xhtml" xml:base="file:/home/user/epub3/epub/Publication/Content/a.xhtml" original-base="file:/home/user/daisy202/a.html">...</html>
                <html xmlns="http://www.w3.org/1999/xhtml" xml:base="file:/home/user/epub3/epub/Publication/Content/b.xhtml" original-base="file:/home/user/daisy202/b.html">...</html>
                <html xmlns="http://www.w3.org/1999/xhtml" xml:base="file:/home/user/epub3/epub/Publication/Content/c.xhtml" original-base="file:/home/user/daisy202/c.html">...</html>
            </code></pre>
        </p:documentation>
    </p:input>
    <p:output port="manifest" primary="true">
        <p:documentation xmlns="http://www.w3.org/1999/xhtml">
            <p px:role="desc">A fileset with references to all the resources after copying (audio, images, etc.).</p>
            <pre><code class="example">
                <d:fileset xmlns:d="http://www.daisy.org/ns/pipeline/data" xml:base="file:/home/user/epub3/epub/Publication/Content/">
                    <d:file xml:base="audio.mp3" media-type="audio/mpeg"/>
                    <d:file xml:base="image.jpg" media-type="image/jpeg"/>
                    <d:file xml:base="stylesheet.css" media-type="text/css"/>
                </d:fileset>
            </code></pre>
        </p:documentation>
    </p:output>

    <p:option name="content-dir" required="true">
        <p:documentation xmlns="http://www.w3.org/1999/xhtml">
            <p px:role="desc">URI to the EPUB3 Content directory.</p>
            <pre><code class="example">file:/home/user/epub3/epub/Publication/Content/</code></pre>
        </p:documentation>
    </p:option>
    <p:option name="include-mediaoverlay-resources" required="true">
        <p:documentation xmlns="http://www.w3.org/1999/xhtml">
            <p px:role="desc">Whether or not to include audio files associated with media overlays. Can be either 'true' or 'false'.</p>
        </p:documentation>
    </p:option>

    <p:import href="http://xmlcalabash.com/extension/steps/library-1.0.xpl">
        <p:documentation xmlns="http://www.w3.org/1999/xhtml">Calabash extension steps.</p:documentation>
    </p:import>
    <p:import href="http://www.daisy.org/pipeline/modules/fileset-utils/xproc/fileset-library.xpl">
        <p:documentation xmlns="http://www.w3.org/1999/xhtml">For manipulating filesets.</p:documentation>
    </p:import>
    <p:import href="http://www.daisy.org/pipeline/modules/mediatype-utils/mediatype.xpl">
        <p:documentation xmlns="http://www.w3.org/1999/xhtml">For identifying the media type of files.</p:documentation>
    </p:import>

    <p:for-each>
        <p:iteration-source>
            <p:pipe port="daisy-content" step="resources"/>
        </p:iteration-source>
        <p:variable name="original-base" select="/*/@original-base"/>
        <p:add-attribute match="/*" attribute-name="xml:base">
            <p:with-option name="attribute-value" select="$original-base"/>
        </p:add-attribute>
        <p:xslt>
            <p:input port="parameters">
                <p:empty/>
            </p:input>
            <p:input port="stylesheet">
                <p:document href="daisy202-content-to-resource-fileset.xsl"/>
            </p:input>
        </p:xslt>
        <cx:message>
            <p:with-option name="message" select="concat('extracted list of resources from ',$original-base)"/>
        </cx:message>
    </p:for-each>
    <px:fileset-join name="content-resources"/>
    <p:sink/>
    <p:for-each name="smil-resources">
        <p:output port="result" sequence="true"/>
        <p:iteration-source>
            <p:pipe port="daisy-smil" step="resources"/>
        </p:iteration-source>
        <p:variable name="original-base" select="/*/@xml:base"/>
        <p:choose>
            <p:when test="$include-mediaoverlay-resources='true'">
                <p:xslt>
                    <p:input port="parameters">
                        <p:empty/>
                    </p:input>
                    <p:input port="stylesheet">
                        <p:document href="http://www.daisy.org/pipeline/modules/mediaoverlay-utils/smil-to-audio-fileset.xsl"/>
                    </p:input>
                </p:xslt>
                <cx:message>
                    <p:with-option name="message" select="concat('extracted list of audio files from ',$original-base)"/>
                </cx:message>
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
    <px:fileset-join>
        <p:input port="source">
            <p:pipe port="result" step="content-resources"/>
            <p:pipe port="result" step="smil-resources"/>
        </p:input>
    </px:fileset-join>
    <px:mediatype-detect name="iterate.mediatype"/>
    <cx:message>
        <p:with-option name="message" select="'determined media type for all auxiliary resources'"/>
    </cx:message>
    <px:fileset-copy>
        <p:with-option name="target" select="$content-dir"/>
    </px:fileset-copy>
    <cx:message>
        <p:with-option name="message" select="concat('copied all auxiliary resources referenced from the DAISY 2.02 publication to ',$content-dir)"/>
    </cx:message>

</p:declare-step>
