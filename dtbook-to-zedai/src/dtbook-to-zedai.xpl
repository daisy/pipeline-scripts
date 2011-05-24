<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step version="1.0" name="dtbook-to-zedai"
    type="px:dtbook-to-zedai"
    xmlns:p="http://www.w3.org/ns/xproc"
    xmlns:c="http://www.w3.org/ns/xproc-step" 
    xmlns:cx="http://xmlcalabash.com/ns/extensions"
    xmlns:cxo="http://xmlcalabash.com/ns/extensions/osutils"
    xmlns:px="http://www.daisy.org/ns/pipeline/xproc"
    xmlns:pxi="http://www.daisy.org/ns/pipeline/xproc/internal"
    xmlns:xd="http://www.daisy.org/ns/pipeline/doc" 
    xmlns:tmp="http://www.daisy.org/ns/pipeline/tmp"
    exclude-inline-prefixes="cx p c cxo px tmp xd">

    <p:documentation>
        <xd:short>Main entry point for DTBook-to-ZedAI. Transforms DTBook XML into ZedAI XML, and extracts metadata and CSS.  Writes output files to disk. More information can be found at http://code.google.com/p/daisy-pipeline/wiki/DTBook2ZedAI.</xd:short>
        <xd:author>
            <xd:name>Marisa DeMeglio</xd:name>
            <xd:mailto>marisa.demeglio@gmail.com</xd:mailto>
            <xd:organization>DAISY</xd:organization>
        </xd:author>
        <xd:maintainer>Marisa DeMeglio</xd:maintainer>
        <xd:input port="source">Input DTBook file or sequence of DTBook files. Versions supported: 1.1.0, 2005-1, 2005-2, 2005-3. </xd:input>
        <xd:output port="result">Empty (results are written to disk).</xd:output>
        <xd:option name="output">URI of the output ZedAI file.</xd:option>
        
        <xd:import href="dtbook2005-3-to-zedai.xpl">Internal XProc for transforming DTBook 2005-3 to ZedAI</xd:import>
        <xd:import href="../../utilities/dtbook-utils/dtbook-utils-library.xpl">External utility for merging and upgrading DTBook files.</xd:import>
        <xd:import href="../../utilities/metadata-utils/generate-metadata.xpl">External utility for generating metadata.</xd:import>    
    </p:documentation>
    
    <p:input port="source" primary="true" sequence="true"/>
    <p:input port="parameters" kind="parameter"/>

    <p:option name="output" select="''"/>

    <p:import href="http://xmlcalabash.com/extension/steps/library-1.0.xpl"/>
    <p:import href="dtbook2005-3-to-zedai.xpl"/>
    
    <!-- TODO: absolute URIs -->
    <p:import href="../../utilities/metadata-utils/generate-metadata.xpl"/>
    <p:import href="../../utilities/dtbook-utils/dtbook-utils-library.xpl"/>
    
    <!-- TODO: multivolume document context in parameter problem e.g. -->
    <p:variable name="test-var" select="'xyz'"/>
    
    <p:variable name="zedai-file"
        select="resolve-uri(
                    if ($output='') then concat(
                        if (matches(base-uri(/),'[^/]+\..+$'))
                        then replace(tokenize(base-uri(/),'/')[last()],'\..+$','')
                        else tokenize(base-uri(/),'/')[last()],'-zedai.xml')
                    else if (ends-with($output,'.xml')) then $output 
                    else concat($output,'.xml'), base-uri(/))">
        <p:pipe step="dtbook-to-zedai" port="source"/>

    </p:variable>
    
    <!-- TODO: mods and css files should be relative URIs -->
    <p:variable name="mods-file" select="replace($zedai-file, '.xml', '-mods.xml')"/>
    <p:variable name="css-file" select="replace($zedai-file, '.xml', '.css')"/>

    <cx:message>
        <p:with-option name="message" select="base-uri(/)"/>
    </cx:message>
    
    
    <p:documentation>Upgrade the DTBook document(s) to 2005-3</p:documentation>
    <px:upgrade-dtbook name="upgrade-dtbook"/>
    
    <p:documentation>If there is more than one input DTBook document, merge them into a single document.</p:documentation>
    <p:count name="num-input-documents" limit="2"/>

    <p:choose name="choose-to-merge-dtbook-files">
        <p:when test=".//c:result[. > 1]">
            <p:output port="result"/>
            <px:merge-dtbook-files>
                <p:input port="source">
                    <p:pipe port="result" step="upgrade-dtbook"/>
                </p:input>
            </px:merge-dtbook-files>
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
 
    <p:documentation>Validate the DTBook input</p:documentation>
    <p:validate-with-relax-ng assert-valid="true" name="validate-dtbook">
        <p:input port="schema">
            <p:document href="../schema/dtbook-2005-3.rng"/>
        </p:input>
        <p:input port="source">
            <p:pipe port="result" step="choose-to-merge-dtbook-files"/>
        </p:input>
    </p:validate-with-relax-ng>
    
    <cx:message message="Output ZedAI file:"/>
    <cx:message>
        <p:with-option name="message" select="$zedai-file"/>
    </cx:message>
    
    <p:documentation>Generate external metadata, such as MODS and ONIX</p:documentation>
    <px:generate-metadata name="generate-metadata">
        <p:input port="source">
            <p:pipe step="validate-dtbook" port="result"/>
        </p:input>
        <p:with-option name="output" select="$mods-file"/>
     </px:generate-metadata>
    
    <p:documentation>Transform to ZedAI (will be invalid ZedAI because of lingering visual property attributes that are stripped out in the next steps)</p:documentation>
    <pxi:dtbook2005-3-to-zedai name="transform-to-zedai">
        <p:input port="source">
            <p:pipe port="result" step="validate-dtbook"/>
        </p:input>
        <p:with-option name="css-filename" select="$css-file"/>
        <p:with-option name="mods-filename" select="$mods-file"/>
    </pxi:dtbook2005-3-to-zedai>

    <!-- This is a step here instead of being an external library, because the following properties are required for generating CSS:
        * elements are stable (no more moving them around and potentially changing their IDs)
        * CSS information is still available (via @tmp:* attributes)
    -->
    <p:documentation>Generate CSS from the visual property attributes in the ZedAI document</p:documentation>
    <p:xslt name="generate-css">
        <p:input port="source">
            <p:pipe step="transform-to-zedai" port="result"/>
        </p:input>
        <p:input port="stylesheet">
            <p:inline>
                <!-- This is a wrapper to XML-ify the raw CSS output.  XProc will only accept it this way. -->
                <xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="2.0">
                    <xsl:import href="generate-css.xsl"/>
                    <xsl:template match="/">
                        <css-data>
                            <xsl:apply-imports/>
                        </css-data>
                    </xsl:template>
                </xsl:stylesheet>
            </p:inline>
        </p:input>
    </p:xslt>
    
    <p:documentation>Strip the visual property attributes from the ZedAI document.</p:documentation>
    <p:xslt name="remove-css-attributes">
        <p:input port="stylesheet">
            <p:document href="remove-css-attributes.xsl"/>
        </p:input>
        <p:input port="source">
            <p:pipe step="transform-to-zedai" port="result"/>
        </p:input>
    </p:xslt>

    <p:documentation>Validate the final ZedAI output.</p:documentation>
    <p:validate-with-relax-ng name="validate-zedai" assert-valid="false">
        <p:input port="schema">
            <p:document href="../schema/z3986a-book-0.8/z3986a-book.rng"/>
        </p:input>
        <p:input port="source">
            <p:pipe port="result" step="remove-css-attributes"/>
        </p:input>
    </p:validate-with-relax-ng>


    <p:documentation>Write the ZedAI file to disk.</p:documentation>
    <p:store name="store-zedai-file">
        <p:input port="source">
            <p:pipe step="validate-zedai" port="result"/>
        </p:input>
        <p:with-option name="href" select="$zedai-file"/>
    </p:store>

    <p:documentation>Strip the generated CSS of its XML wrapper and write it to disk.</p:documentation>
    <p:string-replace match="/text()" replace="''" name="remove-css-xml-wrapper">
        <p:input port="source">
            <p:pipe step="generate-css" port="result"/>
        </p:input>
    </p:string-replace>
    <p:store method="text" name="store-css-file">
        <p:with-option name="href" select="$css-file"/>
    </p:store>
    
    <p:store name="test-store">
        <p:input port="source">
            <p:pipe  step="upgrade-dtbook" port="result"/>
        </p:input>
        <p:with-option name="href" select="'file:///tmp/t.xml'"/>
    </p:store>
</p:declare-step>
