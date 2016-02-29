<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step type="px:html-to-pef.convert" version="1.0"
                xmlns:p="http://www.w3.org/ns/xproc"
                xmlns:px="http://www.daisy.org/ns/pipeline/xproc"
                xmlns:pef="http://www.daisy.org/ns/2008/pef"
                xmlns:css="http://www.daisy.org/ns/pipeline/braille-css"
                xmlns:math="http://www.w3.org/1998/Math/MathML"
                xmlns:d="http://www.daisy.org/ns/pipeline/data"
                xmlns:c="http://www.w3.org/ns/xproc-step"
                exclude-inline-prefixes="#all"
                name="main">
    
    <p:input port="source">
        <p:documentation>HTML</p:documentation>
    </p:input>
    <p:output port="result">
        <p:documentation>PEF</p:documentation>
    </p:output>
    
    <p:input kind="parameter" port="parameters" sequence="true">
        <p:inline>
            <c:param-set/>
        </p:inline>
    </p:input>
    
    <p:option name="default-stylesheet" select="'http://www.daisy.org/pipeline/modules/braille/html-to-pef/css/default.css'"/>
    <p:option name="stylesheet" select="''"/>
    <p:option name="transform" select="'(translator:liblouis)(formatter:dotify)'"/>
    
    <!-- Empty temporary directory dedicated to this conversion -->
    <p:option name="temp-dir" required="true"/>
    
    <p:import href="http://www.daisy.org/pipeline/modules/common-utils/library.xpl"/>
    <p:import href="http://www.daisy.org/pipeline/modules/braille/common-utils/library.xpl"/>
    <p:import href="http://www.daisy.org/pipeline/modules/braille/css-utils/library.xpl"/>
    <p:import href="http://www.daisy.org/pipeline/modules/braille/pef-utils/library.xpl"/>
    
    <p:variable name="lang" select="(/*/@xml:lang,'und')[1]"/>
    
    <!-- Ensure that there's exactly one c:param-set -->
    <p:identity>
        <p:input port="source">
            <p:pipe step="main" port="parameters"/>
        </p:input>
    </p:identity>
    <p:wrap-sequence wrapper="c:param-set"/>
    <p:unwrap match="/c:param-set/c:param-set"/>
    <p:delete match="/c:param-set/c:param[@name = following-sibling::c:param/@name]"/>
    <p:identity name="parameters"/>
    <p:sink/>
    
    <p:identity>
        <p:input port="source">
            <p:pipe port="source" step="main"/>
        </p:input>
    </p:identity>
    <px:message message="Generating table of contents"/>
    <p:xslt>
        <p:input port="stylesheet">
            <p:document href="http://www.daisy.org/pipeline/modules/braille/xml-to-pef/generate-toc.xsl"/>
        </p:input>
        <p:with-param name="_depth" select="/*/*[@name='toc-depth']/@value">
            <p:pipe step="parameters" port="result"/>
        </p:with-param>
    </p:xslt>
    
    <px:message message="Inlining CSS"/>
    <p:group>
        <p:variable name="stylesheets-to-be-inlined" select="string-join((
                                                               $default-stylesheet,
                                                               resolve-uri('../../css/default.scss'),
                                                               $stylesheet),' ')">
            <p:inline><_/></p:inline>
        </p:variable>
        <px:message severity="DEBUG">
            <p:with-option name="message" select="concat('stylesheets: ',$stylesheets-to-be-inlined)"/>
        </px:message>
        <css:inline>
            <p:with-option name="default-stylesheet" select="$stylesheets-to-be-inlined"/>
            <p:input port="sass-variables">
                <p:pipe port="result" step="parameters"/>
            </p:input>
        </css:inline>
    </p:group>
    
    <px:message message="Transforming MathML"/>
    <p:viewport match="math:math">
        <px:transform>
            <p:with-option name="query" select="concat('(input:mathml)(locale:',$lang,')')"/>
            <p:with-option name="temp-dir" select="$temp-dir"/>
            <p:input port="parameters">
                <!-- px:transform uses the 'duplex' parameter -->
                <p:pipe port="result" step="parameters"/>
            </p:input>
        </px:transform>
    </p:viewport>
    
    <px:message message="Transforming from XML with inline CSS to PEF"/>
    <px:transform name="pef">
        <p:with-option name="query" select="concat('(input:css)(output:pef)',$transform,'(locale:',$lang,')')">
            <p:pipe port="result" step="parameters"/>
        </p:with-option>
        <p:with-option name="temp-dir" select="$temp-dir"/>
    </px:transform>
    
    <p:identity>
        <p:input port="source">
            <p:pipe step="main" port="source"/>
        </p:input>
    </p:identity>
    <px:message message="Adding metadata from HTML to PEF"/>
    <p:xslt name="metadata">
        <p:input port="stylesheet">
            <p:document href="../xslt/html-to-opf-metadata.xsl"/>
        </p:input>
        <p:input port="parameters">
            <p:empty/>
        </p:input>
    </p:xslt>
    <pef:add-metadata>
        <p:input port="source">
            <p:pipe step="pef" port="result"/>
        </p:input>
        <p:input port="metadata">
            <p:pipe step="metadata" port="result"/>
        </p:input>
    </pef:add-metadata>
    
    
</p:declare-step>
