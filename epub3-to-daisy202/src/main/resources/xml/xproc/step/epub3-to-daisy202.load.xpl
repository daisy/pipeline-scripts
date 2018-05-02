<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step type="px:epub3-to-daisy202.load" version="1.0"
                xmlns:p="http://www.w3.org/ns/xproc"
                xmlns:px="http://www.daisy.org/ns/pipeline/xproc"
                xmlns:d="http://www.daisy.org/ns/pipeline/data"
                exclude-inline-prefixes="#all"
                name="main">
    
    <!--
        This step should be moved to pipeline-scripts-utils (as px:epub3-load)
    -->
    
    <p:output port="fileset.out" primary="true">
        <p:pipe port="fileset.out" step="result"/>
    </p:output>
    <p:output port="in-memory.out" sequence="true">
        <p:pipe port="in-memory.out" step="result"/>
    </p:output>
    
    <p:option name="epub" required="true" px:media-type="application/epub+zip application/oebps-package+xml"/>
    <p:option name="temp-dir" required="true"/>
    
    <p:import href="http://www.daisy.org/pipeline/modules/fileset-utils/library.xpl"/>
    <p:import href="http://www.daisy.org/pipeline/modules/zip-utils/library.xpl"/>
    <p:import href="http://www.daisy.org/pipeline/modules/mediatype-utils/library.xpl"/>
    
    <p:choose name="result">
        <p:when test="ends-with(lower-case($epub),'.epub')">
            <p:output port="fileset.out" primary="true">
                <p:pipe step="mediatype" port="result"/>
            </p:output>
            <p:output port="in-memory.out" sequence="true">
                <p:pipe step="load" port="result"/>
            </p:output>
            <px:fileset-unzip store-to-disk="true" name="unzip">
                <p:with-option name="href" select="$epub"/>
                <p:with-option name="unzipped-basedir" select="concat($temp-dir,'epub/')"/>
            </px:fileset-unzip>
            <p:sink/>
            <px:mediatype-detect name="mediatype">
                <p:input port="source">
                    <p:pipe step="unzip" port="fileset"/>
                </p:input>
            </px:mediatype-detect>
            <px:fileset-load name="load">
                <p:input port="in-memory">
                    <p:empty/>
                </p:input>
            </px:fileset-load>
        </p:when>
        <p:otherwise>
            <p:output port="fileset.out" primary="true">
                <p:pipe port="result" step="load.fileset"/>
            </p:output>
            <p:output port="in-memory.out" sequence="true">
                <p:pipe port="result" step="opf"/>
            </p:output>
            <px:fileset-create>
                <p:with-option name="base" select="replace($epub,'(.*/)([^/]*)','$1')"/>
            </px:fileset-create>
            <px:fileset-add-entry media-type="application/oebps-package+xml">
                <p:with-option name="href" select="replace($epub,'(.*/)([^/]*)','$2')"/>
                <p:with-option name="original-href" select="$epub"/>
            </px:fileset-add-entry>
            <px:mediatype-detect/>
            <px:fileset-load>
                <p:input port="in-memory">
                    <p:empty/>
                </p:input>
            </px:fileset-load>
            <p:identity name="opf"/>
            <p:xslt>
                <p:input port="parameters">
                    <p:empty/>
                </p:input>
                <p:input port="stylesheet">
                    <p:document href="../../xslt/opf-manifest-to-fileset.xsl"/>
                </p:input>
            </p:xslt>
            <!--
                FIXME: px:fileset-move should take care of this, but doesn't seem to work
            -->
            <p:label-elements match="d:file" attribute="original-href" label="@href"/>
            <p:identity name="load.fileset"/>
        </p:otherwise>
    </p:choose>
    
</p:declare-step>
