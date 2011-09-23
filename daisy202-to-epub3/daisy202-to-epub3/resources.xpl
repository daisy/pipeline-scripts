<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step xmlns:p="http://www.w3.org/ns/xproc" xmlns:px="http://www.daisy.org/ns/pipeline/xproc" xmlns:pxi="http://www.daisy.org/ns/pipeline/xproc/internal"
    xmlns:xd="http://www.daisy.org/ns/pipeline/doc" type="pxi:daisy202-to-epub3-resources" name="resources" version="1.0">

    <p:documentation xd:target="parent">
        <xd:short>Copy the auxiliary resources from the DAISY 2.02 fileset to the EPUB 3 fileset, and return a manifest of all the resulting files.</xd:short>
    </p:documentation>

    <p:input port="daisy-smil" sequence="true">
        <p:documentation>
            <xd:short>The DAISY 2.02 SMIL-files.</xd:short>
            <xd:example xmlns="">
                <smil xml:base="file:/home/user/daisy202/a.smil">...</smil>
                <smil xml:base="file:/home/user/daisy202/b.smil">...</smil>
                <smil xml:base="file:/home/user/daisy202/c.smil">...</smil>
            </xd:example>
        </p:documentation>
    </p:input>
    <p:input port="daisy-content" sequence="true">
        <p:documentation>
            <xd:short>The EPUB3 Content Documents with @original-base annotated to reference the original DAISY 2.02 content files.</xd:short>
            <xd:example>
                <html xmlns="http://www.w3.org/1999/xhtml" xml:base="file:/home/user/epub3/epub/Publication/Content/a.xhtml" original-base="file:/home/user/daisy202/a.html">...</html>
                <html xmlns="http://www.w3.org/1999/xhtml" xml:base="file:/home/user/epub3/epub/Publication/Content/b.xhtml" original-base="file:/home/user/daisy202/b.html">...</html>
                <html xmlns="http://www.w3.org/1999/xhtml" xml:base="file:/home/user/epub3/epub/Publication/Content/c.xhtml" original-base="file:/home/user/daisy202/c.html">...</html>
            </xd:example>
        </p:documentation>
    </p:input>
    <p:output port="manifest" primary="true">
        <p:documentation>
            <xd:short>A fileset with references to all the resources after copying (audio, images, etc.).</xd:short>
            <xd:example>
                <d:fileset xmlns:d="http://www.daisy.org/ns/pipeline/data" xml:base="file:/home/user/epub3/epub/Publication/Content/">
                    <d:file xml:base="audio.mp3" media-type="audio/mpeg"/>
                    <d:file xml:base="image.jpg" media-type="image/jpeg"/>
                    <d:file xml:base="stylesheet.css" media-type="text/css"/>
                </d:fileset>
            </xd:example>
        </p:documentation>
    </p:output>

    <p:option name="content-dir" required="true">
        <p:documentation>
            <xd:short>URI to the EPUB3 Content directory.</xd:short>
            <xd:example>file:/home/user/epub3/epub/Publication/Content/</xd:example>
        </p:documentation>
    </p:option>
    <p:option name="include-mediaoverlay-resources" required="true">
        <p:documentation>
            <xd:short>Whether or not to include audio files associated with media overlays. Can be either 'true' or 'false'.</xd:short>
        </p:documentation>
    </p:option>

    <p:import href="http://www.daisy.org/pipeline/modules/fileset-utils/xproc/fileset-library.xpl">
        <p:documentation>For manipulating filesets.</p:documentation>
    </p:import>
    <p:import href="http://www.daisy.org/pipeline/modules/mediatype-utils/mediatype.xpl">
        <p:documentation>For identifying the media type of files.</p:documentation>
    </p:import>

    <p:for-each>
        <p:iteration-source>
            <p:pipe port="daisy-content" step="resources"/>
        </p:iteration-source>
        <p:add-attribute match="/*" attribute-name="xml:base">
            <p:with-option name="attribute-value" select="/*/@original-base"/>
        </p:add-attribute>
        <p:xslt>
            <p:input port="parameters">
                <p:empty/>
            </p:input>
            <p:input port="stylesheet">
                <p:document href="daisy202-content-to-resource-fileset.xsl"/>
            </p:input>
        </p:xslt>
    </p:for-each>
    <px:fileset-join name="content-resources"/>
    <p:sink/>
    <p:for-each name="smil-resources">
        <p:output port="result" sequence="true"/>
        <p:iteration-source>
            <p:pipe port="daisy-smil" step="resources"/>
        </p:iteration-source>
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
    <px:fileset-copy>
        <p:with-option name="target" select="$content-dir"/>
    </px:fileset-copy>

</p:declare-step>
