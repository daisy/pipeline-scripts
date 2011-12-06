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
      <xd:short>DTBook to ZedAI</xd:short>
      <xd:detail>Transforms DTBook XML into ZedAI XML.</xd:detail>
        <xd:homepage>http://code.google.com/p/daisy-pipeline/wiki/DTBookToZedAI</xd:homepage>
        <xd:author>
            <xd:name>Marisa DeMeglio</xd:name>
            <xd:mailto>marisa.demeglio@gmail.com</xd:mailto>
            <xd:organization>DAISY</xd:organization>
        </xd:author>
    </p:documentation>

    <p:input
        port="source" 
        primary="true" 
        sequence="true"
        px:media-type="application/x-dtbook+xml">
        <p:documentation>
            <xd:short>DTBook file(s)</xd:short>
            <xd:detail>One or more DTBook files to be transformed. In the case of multiple files, a merge will be performed.</xd:detail>
        </p:documentation>
    </p:input>
    
    <p:option name="opt-output-dir" required="true" px:dir="output" px:type="anyDirURI">
        <p:documentation>
            <xd:short>Output directory</xd:short>
            <xd:detail>The directory to store the generated files in.</xd:detail>
        </p:documentation>
    </p:option>
    
    <p:option name="opt-zedai-filename" required="false" px:dir="output" px:type="string" select="''">
        <p:documentation>
            <xd:short>ZedAI filename</xd:short>
            <xd:detail>Filename for the generated ZedAI file</xd:detail>
        </p:documentation>
    </p:option> 
    <p:option name="opt-mods-filename" required="false" px:dir="output" px:type="string" select="''">
        <p:documentation>
            <xd:short>MODS filename</xd:short>
            <xd:detail>Filename for the generated MODS file</xd:detail>
        </p:documentation>
    </p:option>
    <p:option name="opt-css-filename" required="false" px:dir="output" px:type="string" select="''">
        <p:documentation>
            <xd:short>CSS filename</xd:short>
            <xd:detail>Filename for the generated CSS file</xd:detail>
        </p:documentation>
    </p:option>
    <p:option name="opt-lang" required="false" px:dir="output" px:type="string" select="''">
        <p:documentation>
            <xd:short>Language code</xd:short>
            <xd:detail>Language code of the input document.</xd:detail>
        </p:documentation>
    </p:option>
    
    <p:import href="http://xmlcalabash.com/extension/steps/library-1.0.xpl">
        <p:documentation>
            <xd:short>Calabash extension steps.</xd:short>
        </p:documentation>
    </p:import>
    <p:import href="dtbook2005-3-to-zedai.xpl">
        <p:documentation>
            <xd:short>Converts DTBook 2005-3 to ZedAI</xd:short> 
        </p:documentation>
    </p:import>
    
    <p:import href="copy-referenced-files.xpl">
        <p:documentation>
            <xd:short>Copies ZedAI referenced files to a specified output directory.</xd:short> 
        </p:documentation>
    </p:import>

    <!-- for use with the pipeline framework -->
    <p:import href="http://www.daisy.org/pipeline/modules/metadata-utils/metadata-utils-library.xpl">
        <p:documentation>
            <xd:short>Collection of utilities for generating metadata.</xd:short> 
        </p:documentation>
    </p:import>
    
    <p:import href="http://www.daisy.org/pipeline/modules/dtbook-utils/dtbook-utils-library.xpl">
        <p:documentation>
            <xd:short>Collection of utilities for merging and upgrading DTBook files.</xd:short> 
        </p:documentation>
    </p:import>
    
    <!-- replace the two imports above with these to test from within oxygen -->   
    <!--<p:import href="../../utilities/metadata-utils/metadata-utils/metadata-utils-library.xpl"/>
    <p:import href="../../utilities/dtbook-utils/dtbook-utils/dtbook-utils-library.xpl"/>
    -->
    
    <p:variable name="output-dir" select="if (ends-with($opt-output-dir, '/')) then $opt-output-dir 
                                      else concat($opt-output-dir, '/')"/>
    
    <p:variable name="default-zedai-filename" select="'zedai.xml'"/>
    <p:variable name="default-mods-filename" select="'zedai-mods.xml'"/>
    <p:variable name="default-css-filename" select="'zedai-css.css'"/>
    
    <p:variable name="zedai-filename" select="if (string-length($opt-zedai-filename) > 0) 
        then $opt-zedai-filename
        else $default-zedai-filename"/>
    
    <p:variable name="mods-filename" select="if (string-length($opt-mods-filename) > 0) 
        then $opt-mods-filename 
        else $default-mods-filename"/>
    
    <p:variable name="css-filename" select="if (string-length($opt-css-filename) > 0)
        then $opt-css-filename
        else $default-css-filename"/>
    
    <p:variable name="zedai-file" select="concat($output-dir, $zedai-filename)"/>
    <p:variable name="mods-file" select="concat($output-dir, $mods-filename)"/>
    <p:variable name="css-file" select="concat($output-dir, $css-filename)"/>


    <cx:message>
        <p:with-option name="message" select="concat('ZedAI file name: ',$zedai-filename)"/>
    </cx:message>
    <cx:message>
        <p:with-option name="message" select="concat('MODS file name: ',$mods-filename)"/>
    </cx:message>
    <cx:message>
        <p:with-option name="message" select="concat('CSS file name: ',$css-filename)"/>
    </cx:message>
    
    
    
    <!-- =============================================================== -->
    <!-- UPGRADE -->
    <!-- =============================================================== -->
    <p:documentation>Upgrade the DTBook document(s) to 2005-3</p:documentation>
    <px:upgrade-dtbook name="upgrade-dtbook">
        <p:input port="parameters">
            <p:empty/>
        </p:input>
    </px:upgrade-dtbook>

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
                <p:input port="parameters">
                    <p:empty/>
                </p:input>
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
            <p:document href="./schema/dtbook-2005-3.rng"/>
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
        <p:input port="parameters">
            <p:empty/>
        </p:input>
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
                <p:with-param name="css" select="$css-filename"/>
                <p:input port="stylesheet">
                    <p:inline>
                        <!-- This adds a processing instruction to reference the CSS file.  In the end, it's easier than using XProc's p:insert. -->
                        <xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                            version="2.0">
                            <xsl:output indent="yes" method="xml"/>
                            <xsl:param name="css"/>
                            
                            <xsl:template match="/">
                                <xsl:message>Adding CSS PI</xsl:message>
                                <xsl:processing-instruction name="xml-stylesheet">
                                        href="<xsl:value-of select="$css"/>" </xsl:processing-instruction>
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
        <p:input port="parameters">
            <p:empty/>
        </p:input>
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
        <p:input port="parameters">
            <p:empty/>
        </p:input>
        <p:input port="source">
            <p:pipe step="validate-dtbook" port="result"/>
        </p:input>
    </px:dtbook-to-mods-meta>

    <p:documentation>Generate ZedAI metadata</p:documentation>
    <px:dtbook-to-zedai-meta name="generate-zedai-metadata">
        <p:input port="parameters">
            <p:empty/>
        </p:input>
        
        <p:input port="source">
            <p:pipe step="validate-dtbook" port="result"/>
        </p:input>
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
            select="concat('&quot;',$mods-filename,'&quot;')"/>
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

    <!-- add xml:lang if not already present AND if specified by the opt-lang option -->
    <p:documentation>Add the xml:lang attribute</p:documentation>
    <p:choose>
        <p:when test="//z:document/@xml:lang">
            <p:identity/>
        </p:when>
        <p:otherwise>
            <p:choose>
                <p:when test="string-length($opt-lang) > 0">
                    <p:add-attribute match="//z:document">
                        <p:with-option name="attribute-name" select="'xml:lang'"/>
                        <p:with-option name="attribute-value" select="$opt-lang"/>
                    </p:add-attribute>
                </p:when>
                <p:otherwise>
                    <cx:message message="WARNING: required xml:lang attribute not found, and no 'opt-lang' option was passed to the converter."/>
                    <p:identity/>
                </p:otherwise>
            </p:choose>
        </p:otherwise>
    </p:choose>
    <!-- =============================================================== -->
    <!-- VALIDATE FINAL OUTPUT -->
    <!-- =============================================================== -->
    <p:documentation>Validate the final ZedAI output.</p:documentation>
    <cx:message message="Validating ZedAI"/>
    <p:validate-with-relax-ng name="validate-zedai" assert-valid="true">
        <p:input port="schema">
            <p:document href="./schema/z3986a-book-0.8/z3986a-book.rng"/>
        </p:input>
    </p:validate-with-relax-ng>
    
    <!-- =============================================================== -->
    <!-- WRITE TO DISK -->
    <!-- =============================================================== -->
    <cx:message message="Conversion complete. Storing files."/>
    <p:documentation>Copy all referenced files to the output directory</p:documentation>
    
    <pxi:copy-referenced-files>
        <p:input port="source">
            <p:pipe step="validate-zedai" port="result"/>
        </p:input>
        <p:with-option name="output-dir" select="$output-dir"/>
        <p:with-option name="dtbook-base-uri" select="base-uri(/)">
            <p:pipe port="source" step="dtbook-to-zedai"/>
        </p:with-option>
    </pxi:copy-referenced-files>
    
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
            <cx:message>
                <p:with-option name="message" select="$css-file"/>
            </cx:message>
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
