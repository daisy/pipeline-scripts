<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step version="1.0" name="dtbook-to-zedai" type="px:dtbook-to-zedai"
    xmlns:p="http://www.w3.org/ns/xproc" 
    xmlns:c="http://www.w3.org/ns/xproc-step"
    xmlns:cx="http://xmlcalabash.com/ns/extensions"
    xmlns:cxo="http://xmlcalabash.com/ns/extensions/osutils"
    xmlns:px="http://www.daisy.org/ns/pipeline/xproc"
    xmlns:pxi="http://www.daisy.org/ns/pipeline/xproc/internal"
    xmlns:xd="http://www.daisy.org/ns/pipeline/doc" 
    xmlns:tmp="http://www.daisy.org/ns/pipeline/tmp"
    xmlns:z="http://www.daisy.org/ns/z3986/authoring/"
    exclude-inline-prefixes="cx p c cxo px xd pxi z tmp">

    <p:documentation>
        <xd:short>Main entry point for DTBook-to-ZedAI. Transforms DTBook XML into ZedAI XML, and
            extracts metadata and CSS. Writes output files to disk. More information can be found at
            http://code.google.com/p/daisy-pipeline/wiki/DTBookToZedAI.</xd:short>
        <xd:author>
            <xd:name>Marisa DeMeglio</xd:name>
            <xd:mailto>marisa.demeglio@gmail.com</xd:mailto>
            <xd:organization>DAISY</xd:organization>
        </xd:author>
        <xd:maintainer>Marisa DeMeglio</xd:maintainer>
        <xd:input port="source">DTBook file or sequence of DTBook files. Versions supported: 1.1.0,
            2005-1, 2005-2, 2005-3. </xd:input>
        <xd:output port="result">Empty (ZedAI results are written to disk).</xd:output>
        <xd:option name="output">File path for the output ZedAI file.</xd:option>
        <xd:import href="dtbook2005-3-to-zedai.xpl">Internal XProc for transforming DTBook 2005-3 to
            ZedAI</xd:import>
        <xd:import href="../../utilities/dtbook-utils/dtbook-utils-library.xpl">External utility for
            merging and upgrading DTBook files.</xd:import>
        <xd:import href="../../utilities/metadata-utils/metadata-utils-library.xpl">External utility
            for generating metadata.</xd:import>
    </p:documentation>

    <p:input port="source" primary="true" sequence="true"/>
    <p:input port="parameters" kind="parameter"/>

    <p:option name="output" required="true"/>

    <p:import href="http://xmlcalabash.com/extension/steps/library-1.0.xpl"/>
    <p:import href="dtbook2005-3-to-zedai.xpl"/>

    <!-- TODO: absolute URIs -->
    <p:import href="../../utilities/metadata-utils/metadata-utils-library.xpl"/>
    <p:import href="../../utilities/dtbook-utils/dtbook-utils-library.xpl"/>

    <p:variable name="zedai-file" select="$output"/>
    <p:variable name="mods-file" select="replace($zedai-file, '.xml', '-mods.xml')"/>
    <p:variable name="css-file" select="replace($zedai-file, '.xml', '.css')"/>

    <cx:message message="Output ZedAI file:"/>
    <cx:message>
        <p:with-option name="message" select="$output"/>
    </cx:message>

    <!-- =============================================================== -->
    <!-- UPGRADE -->
    <!-- =============================================================== -->
    <p:documentation>Upgrade the DTBook document(s) to 2005-3</p:documentation>
    <px:upgrade-dtbook name="upgrade-dtbook"/>

    <!-- =============================================================== -->
    <!-- MERGE -->
    <!-- =============================================================== -->
    <p:documentation>If there is more than one input DTBook document, merge them into a single
        document.</p:documentation>
    <p:count name="num-input-documents" limit="2"/>

    <p:choose name="choose-to-merge-dtbook-files">
        <p:when test=".//c:result[. > 1]">
            <p:output port="result"/>
            <px:merge-dtbook>
                <p:input port="source">
                    <p:pipe port="result" step="upgrade-dtbook"/>
                </p:input>
            </px:merge-dtbook>
        </p:when>
        <p:otherwise>
            <p:output port="result"/>
            <p:identity>
                <p:input port="source">
                    <p:pipe port="result" step="upgrade-dtbook"/>
                </p:input>
            </p:identity>
        </p:otherwise>
    </p:choose>

    <!-- =============================================================== -->
    <!-- CREATE ZEDAI -->
    <!-- =============================================================== -->
    <p:documentation>Validate the DTBook input</p:documentation>
    <p:validate-with-relax-ng assert-valid="true" name="validate-dtbook">
        <p:input port="schema">
            <p:document href="../schema/dtbook-2005-3.rng"/>
        </p:input>
        <p:input port="source">
            <p:pipe port="result" step="choose-to-merge-dtbook-files"/>
        </p:input>
    </p:validate-with-relax-ng>

    <p:documentation>Transform to ZedAI</p:documentation>
    <pxi:dtbook2005-3-to-zedai name="transform-to-zedai">
        <p:input port="source">
            <p:pipe port="result" step="validate-dtbook"/>
        </p:input>
    </pxi:dtbook2005-3-to-zedai>


    <!-- =============================================================== -->
    <!-- CSS -->
    <!-- =============================================================== -->
    <!-- This is a step here instead of being an external library, because the following properties are required for generating CSS:
        * elements are stable (no more moving them around and potentially changing their IDs)
        * CSS information is still available (via @tmp:* attributes)
    -->
    <p:documentation>Generate CSS from the visual property attributes in the ZedAI
        document</p:documentation>
    <p:xslt name="generate-css">
        <p:input port="source">
            <p:pipe step="transform-to-zedai" port="result"/>
        </p:input>
        <p:input port="stylesheet">
            <p:inline>
                <!-- This is a wrapper to XML-ify the raw CSS output.  XProc will only accept it this way. -->
                <xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="2.0"
                    xmlns:tmp="http://www.daisy.org/ns/pipeline/tmp">
                    <xsl:import href="generate-css.xsl"/>
                    <xsl:template match="/">
                        <tmp:wrapper>
                            <xsl:apply-imports/>
                        </tmp:wrapper>
                    </xsl:template>
                </xsl:stylesheet>
            </p:inline>
        </p:input>
    </p:xslt>

    <p:documentation>If CSS was generated, add a reference to the ZedAI document</p:documentation>
    <p:choose name="add-css-reference">
        <p:xpath-context>
            <p:pipe port="result" step="generate-css"/>
        </p:xpath-context>

        <p:when test="//tmp:wrapper/text()">
            <p:output port="result"/>

            <p:xslt name="add-css-reference-xslt">

                <p:input port="source">
                    <p:pipe step="transform-to-zedai" port="result"/>
                </p:input>
                <p:with-param name="css-filename" select="tokenize($css-file, '/')[last()]"/>
                <p:input port="stylesheet">
                    <p:inline>
                        <!-- This adds a processing instruction to reference the CSS file.  In the end, it's easier than using XProc's p:insert. -->
                        <xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                            version="2.0">
                            <xsl:output indent="yes" method="xml"/>
                            <xsl:param name="css-filename"/>
                            <xsl:template match="/">
                                <xsl:processing-instruction name="xml-stylesheet">
                                        href="<xsl:value-of select="$css-filename"/>" </xsl:processing-instruction>
                                <xsl:apply-templates/>
                            </xsl:template>
                            <!-- identity template -->
                            <xsl:template match="@*|node()">
                                <xsl:copy>
                                    <xsl:apply-templates select="@*|node()"/>
                                </xsl:copy>
                            </xsl:template>
                        </xsl:stylesheet>
                    </p:inline>
                </p:input>
            </p:xslt>
        </p:when>
        <p:otherwise>
            <p:output port="result"/>
            <p:identity name="not-adding-css-PI">
                <p:input port="source">
                    <p:pipe port="result" step="transform-to-zedai"/>
                </p:input>
            </p:identity>
        </p:otherwise>
    </p:choose>

    
    <!-- this step should remove the 'tmp' prefix (it is no longer needed after this point) but it doesn't! -->
    <p:documentation>Strip the visual property (CSS) attributes from the ZedAI
    document.</p:documentation>
    <p:xslt name="remove-css-attributes">
        <p:input port="stylesheet">
            <p:document href="remove-css-attributes.xsl"/>
        </p:input>
        <p:input port="source">
            <p:pipe step="add-css-reference" port="result"/>
        </p:input>
    </p:xslt>


    <!-- =============================================================== -->
    <!-- METADATA -->
    <!-- =============================================================== -->
    <p:documentation>Generate MODS metadata</p:documentation>
    <px:dtbook-to-mods-meta name="generate-mods-metadata">
        <p:input port="source">
            <p:pipe step="validate-dtbook" port="result"/>
        </p:input>
    </px:dtbook-to-mods-meta>

    <p:documentation>Generate ZedAI metadata</p:documentation>
    <px:dtbook-to-zedai-meta name="generate-zedai-metadata">
        <p:input port="source">
            <p:pipe step="validate-dtbook" port="result"/>
        </p:input>
        <p:log href="log.xml" port="result"/>
    </px:dtbook-to-zedai-meta>

    <p:documentation>Insert metadata into the head of ZedAI</p:documentation>
    <p:insert match="//z:head" position="first-child" name="insert-zedai-meta">
        <p:input port="insertion">
            <p:pipe port="result" step="generate-zedai-metadata"/>
        </p:input>
        <p:input port="source">
            <p:pipe port="result" step="remove-css-attributes"/>
        </p:input>
    </p:insert>

    <p:documentation>Create a meta element for the MODS file reference</p:documentation>
    <p:string-replace match="//z:meta/@resource | //z:meta/@about" name="create-mods-ref-meta">
        <p:input port="source">
            <p:inline>
                <meta rel="z3986:meta-record" resource="@@"
                    xmlns="http://www.daisy.org/ns/z3986/authoring/">
                    <meta property="z3986:meta-record-type" about="@@" content="z3986:mods"
                        xmlns="http://www.daisy.org/ns/z3986/authoring/"/>
                    <meta property="z3986:meta-record-version" about="@@" content="3.3"
                        xmlns="http://www.daisy.org/ns/z3986/authoring/"/>
                </meta>
            </p:inline>
        </p:input>
        <p:with-option name="replace"
            select="concat('&quot;',tokenize($mods-file, '/')[last()],'&quot;')"/>
    </p:string-replace>

    <p:documentation>Insert the MODS file reference metadata into the head of
        ZedAI</p:documentation>
    <p:insert match="//z:head" position="first-child">
        <p:input port="source">
            <p:pipe port="result" step="insert-zedai-meta"/>
        </p:input>
        <p:input port="insertion">
            <p:pipe port="result" step="create-mods-ref-meta"/>
        </p:input>
    </p:insert>

    <!-- unwrap the meta list that was wrapped with tmp:wrapper -->
    <p:unwrap name="unwrap-meta-list" match="//z:head/tmp:wrapper"/>

    <!-- =============================================================== -->
    <!-- VALIDATE FINAL OUTPUT -->
    <!-- =============================================================== -->
    <p:documentation>Validate the final ZedAI output.</p:documentation>
    <p:validate-with-relax-ng name="validate-zedai" assert-valid="false">
        <p:input port="schema">
            <p:document href="../schema/z3986a-book-0.8/z3986a-book.rng"/>
        </p:input>
    </p:validate-with-relax-ng>

    <!-- =============================================================== -->
    <!-- WRITE TO DISK -->
    <!-- =============================================================== -->
    <p:documentation>Write the ZedAI document to disk.</p:documentation>
    <p:store name="store-zedai-file">
        <p:input port="source">
            <p:pipe step="validate-zedai" port="result"/>
        </p:input>
        <p:with-option name="href" select="$zedai-file"/>
    </p:store>

    <p:documentation>If CSS was generated: Strip the generated CSS document of its intermediate XML
        wrapper and write it to disk.</p:documentation>
    <p:choose name="if-exists-store-css-file">
        <p:xpath-context>
            <p:pipe port="result" step="generate-css"/>
        </p:xpath-context>

        <p:when test="//tmp:wrapper/text()">
            <p:string-replace match="/text()" replace="''" name="remove-css-xml-wrapper">
                <p:input port="source">
                    <p:pipe step="generate-css" port="result"/>
                </p:input>
            </p:string-replace>
            <p:store method="text" name="store-css-file">
                <p:with-option name="href" select="$css-file"/>
            </p:store>
        </p:when>
        <p:otherwise>
            <p:sink>
                <p:input port="source">
                    <p:pipe step="generate-css" port="result"/>
                </p:input>
            </p:sink>
        </p:otherwise>
    </p:choose>


    <p:documentation>Write the MODS document to disk.</p:documentation>
    <p:store name="store-mods-file">
        <p:input port="source">
            <p:pipe step="generate-mods-metadata" port="result"/>
        </p:input>
        <p:with-option name="href" select="$mods-file"/>
    </p:store>


</p:declare-step>
