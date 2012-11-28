<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step name="main" type="pxi:load" xmlns:p="http://www.w3.org/ns/xproc"
    xmlns:d="http://www.daisy.org/ns/pipeline/data"
    xmlns:px="http://www.daisy.org/ns/pipeline/xproc"
    xmlns:pxi="http://www.daisy.org/ns/pipeline/xproc/internal/daisy3-to-epub3" version="1.0">
    <p:input port="source" primary="true" sequence="false">
        <p:documentation>
            <h2 px:role="name">Input OPF</h2>
            <p px:role="desc">The package file of the input DTB.</p>
        </p:documentation>
    </p:input>

    <p:output port="fileset" primary="true" sequence="false">
        <p:pipe port="result" step="fileset-ordered"/>
    </p:output>
    <p:output port="smils" sequence="true">
        <p:pipe port="result" step="load-smils"/>
    </p:output>
    <p:output port="dtbooks" sequence="true">
        <p:pipe port="result" step="load-dtbooks"/>
    </p:output>
    <p:output port="ncx" sequence="false">
        <p:pipe port="result" step="load-ncx"/>
    </p:output>


    <p:import href="http://www.daisy.org/pipeline/modules/fileset-utils/xproc/fileset-library.xpl">
        <p:documentation xmlns="http://www.w3.org/1999/xhtml">For manipulating
            filesets.</p:documentation>
    </p:import>

    <p:xslt name="fileset">
        <p:input port="stylesheet">
            <p:document href="opf-to-fileset.xsl"/>
        </p:input>
        <p:input port="parameters">
            <p:empty/>
        </p:input>
    </p:xslt>

    <p:for-each name="load-smils">
        <p:output port="result"/>
        <p:iteration-source select="//d:file[@media-type='application/smil']">
            <p:pipe port="result" step="fileset"/>
        </p:iteration-source>
        <p:load>
            <p:with-option name="href" select="/*/resolve-uri(@href,base-uri(.))"/>
        </p:load>
    </p:for-each>

    <p:group name="fileset-ordered">
        <p:output port="result"/>
        <p:identity>
            <p:input port="source">
                <p:pipe port="result" step="fileset"/>
            </p:input>
        </p:identity>
        <!--Re-order the DTBook entries in the file set-->
        <p:choose>
            <p:when test="count(//d:file[@media-type='application/x-dtbook+xml']) > 1">
                <!--when there is more than one DTBook, delete all entries
                and re-compute them by parsing each SMIL file-->
                <p:delete name="fileset-no-dtbooks"
                    match="d:file[@media-type='application/x-dtbook+xml']"/>
                <p:for-each name="fileset-dtbooks">
                    <p:output port="result"/>
                    <p:iteration-source>
                        <p:pipe port="result" step="load-smils"/>
                    </p:iteration-source>
                    <p:xslt>
                        <p:input port="stylesheet">
                            <p:document
                                href="http://www.daisy.org/pipeline/modules/mediaoverlay-utils/smil-to-text-fileset.xsl"
                            />
                        </p:input>
                        <p:input port="parameters">
                            <p:empty/>
                        </p:input>
                    </p:xslt>
                    <p:add-attribute attribute-name="media-type"
                        attribute-value="application/x-dtbook+xml" match="d:file"/>
                </p:for-each>
                <px:fileset-join>
                    <p:input port="source">
                        <p:pipe port="result" step="fileset-no-dtbooks"/>
                        <p:pipe port="result" step="fileset-dtbooks"/>
                    </p:input>
                </px:fileset-join>
            </p:when>
            <p:otherwise>
                <p:identity/>
            </p:otherwise>
        </p:choose>
    </p:group>

    <p:for-each name="load-dtbooks">
        <p:output port="result"/>
        <p:iteration-source select="//d:file[@media-type='application/x-dtbook+xml']">
            <p:pipe port="result" step="fileset-ordered"/>
        </p:iteration-source>
        <p:load>
            <p:with-option name="href" select="/*/resolve-uri(@href,base-uri(.))"/>
        </p:load>
    </p:for-each>
    
    <p:load name="load-ncx">
        <p:with-option name="href" select="//d:file[@media-type='application/x-dtbncx+xml'][1]/resolve-uri(@href,base-uri(.))">
            <p:pipe port="result" step="fileset-ordered"/>
        </p:with-option>
    </p:load>

</p:declare-step>
