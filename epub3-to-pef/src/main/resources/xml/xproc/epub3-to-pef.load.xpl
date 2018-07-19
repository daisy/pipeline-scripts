<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step type="px:epub3-to-pef.load" version="1.0"
                xmlns:p="http://www.w3.org/ns/xproc"
                xmlns:px="http://www.daisy.org/ns/pipeline/xproc"
                xmlns:d="http://www.daisy.org/ns/pipeline/data"
                exclude-inline-prefixes="#all"
                name="main">
    
    <p:output port="fileset.out" primary="true"/>
    <p:output port="in-memory.out" sequence="true">
        <p:pipe step="opf" port="result"/>
        <!-- other files are loaded lazily -->
    </p:output>
    <p:output port="opf">
        <p:pipe step="opf" port="result"/>
    </p:output>
    
    <p:option name="epub" required="true" px:media-type="application/epub+zip application/oebps-package+xml"/>
    <!-- Empty temporary directory dedicated to this conversion -->
    <p:option name="temp-dir" required="true"/>

    <p:import href="http://www.daisy.org/pipeline/modules/common-utils/library.xpl"/>
    <p:import href="http://www.daisy.org/pipeline/modules/fileset-utils/library.xpl"/>
    <p:import href="http://www.daisy.org/pipeline/modules/zip-utils/library.xpl"/>
    <p:import href="http://www.daisy.org/pipeline/modules/mediatype-utils/library.xpl"/>
    
    <!--
        Until v1.10 of DP2 is released, we cannot point into ZIP files using URIs.
        So for now we unzip the entire EPUB before continuing.
        See: https://github.com/daisy/pipeline-modules-common/pull/73
    -->
    <p:choose px:progress="1">
        <p:when test="ends-with(lower-case($epub),'.epub')"
                px:message="EPUB is in a ZIP container; unzipping">
            <px:fileset-unzip store-to-disk="true" name="unzip">
                <p:with-option name="href" select="$epub"/>
                <p:with-option name="unzipped-basedir" select="concat($temp-dir,'epub/')"/>
            </px:fileset-unzip>
            <p:sink/>
            <p:identity>
                <p:input port="source">
                    <p:pipe step="unzip" port="fileset"/>
                </p:input>
            </p:identity>
            <!-- Why does fileset-unzip add @original-href? Not needed. -->
            <p:delete match="@original-href"/>
        </p:when>
        <p:otherwise px:message="EPUB is not in a container">
            <px:fileset-create>
                <p:with-option name="base" select="replace($epub,'(.*/)([^/]*)','$1')"/>
            </px:fileset-create>
            <px:fileset-add-entry media-type="application/oebps-package+xml">
                <p:with-option name="href" select="replace($epub,'(.*/)([^/]*)','$2')"/>
            </px:fileset-add-entry>
        </p:otherwise>
    </p:choose>
    <px:mediatype-detect name="tmp-fileset"/>
    
    <!-- Get the OPF so that we can use the metadata in options -->
    <px:message message="Getting the OPF"/>
    <px:fileset-load media-types="application/oebps-package+xml">
        <p:input port="in-memory">
            <p:empty/>
        </p:input>
    </px:fileset-load>
    <p:identity name="opf"/>
    
    <!-- Add content files to fileset. -->
    <p:xslt>
        <p:input port="parameters">
            <p:empty/>
        </p:input>
        <p:input port="stylesheet">
            <p:document href="../xslt/opf-manifest-to-fileset.xsl"/>
        </p:input>
    </p:xslt>
    <p:identity name="content-fileset"/>
    
    <px:fileset-join>
        <p:input port="source">
            <p:pipe step="tmp-fileset" port="result"/>
            <p:pipe step="content-fileset" port="result"/>
        </p:input>
    </px:fileset-join>
    
</p:declare-step>
