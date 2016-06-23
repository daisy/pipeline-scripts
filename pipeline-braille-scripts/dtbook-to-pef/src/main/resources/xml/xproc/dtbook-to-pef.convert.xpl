<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step type="px:dtbook-to-pef.convert" version="1.0"
                xmlns:cx="http://xmlcalabash.com/ns/extensions"
                xmlns:p="http://www.w3.org/ns/xproc"
                xmlns:px="http://www.daisy.org/ns/pipeline/xproc"
                xmlns:pxi="http://www.daisy.org/ns/pipeline/xproc/internal"
                xmlns:d="http://www.daisy.org/ns/pipeline/data"
                xmlns:c="http://www.w3.org/ns/xproc-step"
                xmlns:pef="http://www.daisy.org/ns/2008/pef"
                xmlns:math="http://www.w3.org/1998/Math/MathML"
                exclude-inline-prefixes="#all"
                name="main">
    
    <p:input port="source">
        <p:documentation>DTBook</p:documentation>
    </p:input>
    <p:output port="result" primary="true">
        <p:documentation>PEF</p:documentation>
    </p:output>
    <p:output port="obfl" sequence="true"> <!-- sequence=false when include-obfl=true -->
        <p:documentation>OBFL</p:documentation>
        <p:pipe step="transform" port="obfl"/>
    </p:output>
    
    <p:input kind="parameter" port="parameters" sequence="true">
        <p:inline>
            <c:param-set/>
        </p:inline>
    </p:input>
    
    <p:option name="default-stylesheet" select="'http://www.daisy.org/pipeline/modules/braille/dtbook-to-pef/css/default.css'"/>
    <p:option name="stylesheet" select="''"/>
    <p:option name="transform" select="'(translator:liblouis)(formatter:dotify)'"/>
    <p:option name="include-obfl" select="'false'"/>
    
    <!-- Empty temporary directory dedicated to this conversion -->
    <p:option name="temp-dir" required="true"/>

    <p:import href="http://www.daisy.org/pipeline/modules/common-utils/library.xpl"/>
    <p:import href="http://www.daisy.org/pipeline/modules/braille/common-utils/library.xpl"/>
    <p:import href="http://www.daisy.org/pipeline/modules/braille/xml-to-pef/library.xpl"/>
    <p:import href="http://www.daisy.org/pipeline/modules/braille/pef-utils/library.xpl"/>
    <p:import href="http://www.daisy.org/pipeline/modules/dtbook-utils/library.xpl"/>
    <p:import href="http://www.daisy.org/pipeline/modules/file-utils/library.xpl"/>
    <p:import href="http://www.daisy.org/pipeline/modules/fileset-utils/library.xpl"/>
    
    <p:variable name="lang" select="(/*/@xml:lang,'und')[1]"/>
    
    <!-- Ensure that there's exactly one c:param-set -->
    <p:identity>
        <p:input port="source">
            <p:pipe step="main" port="parameters"/>
        </p:input>
    </p:identity>
    <px:message message="[progress px:dtbook-to-pef.convert 1 px:merge-parameters]"/>
    <px:merge-parameters name="parameters"/>
    <p:sink/>
    
    <p:identity>
        <p:input port="source">
            <p:pipe step="main" port="source"/>
        </p:input>
    </p:identity>
    <px:message message="[progress px:dtbook-to-pef.convert 1 px:dtbook-load] Loading DTBook"/>
    <px:dtbook-load name="load"/>
    <p:sink/>
    
    <p:identity>
        <p:input port="source">
            <p:pipe step="load" port="in-memory.out"/>
        </p:input>
    </p:identity>
    <px:message cx:depends-on="parameters" message="[progress px:dtbook-to-pef.convert 1 generate-toc.xsl] Generating table of contents"/>
    <p:xslt>
        <p:input port="stylesheet">
            <p:document href="http://www.daisy.org/pipeline/modules/braille/xml-to-pef/generate-toc.xsl"/>
        </p:input>
        <p:with-param name="depth" select="/*/*[@name='toc-depth']/@value">
            <p:pipe step="parameters" port="result"/>
        </p:with-param>
    </p:xslt>
    
    <px:message cx:depends-on="parameters" message="[progress px:dtbook-to-pef.convert 6 px:apply-stylesheets] Inlining CSS"/>
    <p:group>
        <p:variable name="first-css-stylesheet"
                    select="tokenize($stylesheet,'\s+')[matches(.,'\.s?css$')][1]"/>
        <p:variable name="first-css-stylesheet-index"
                    select="(index-of(tokenize($stylesheet,'\s+')[not(.='')], $first-css-stylesheet),10000)[1]"/>
        <p:variable name="stylesheets-to-be-inlined"
                    select="string-join((
                              (tokenize($stylesheet,'\s+')[not(.='')])[position()&lt;$first-css-stylesheet-index],
                              $default-stylesheet,
                              resolve-uri('../../css/default.scss'),
                              (tokenize($stylesheet,'\s+')[not(.='')])[position()&gt;=$first-css-stylesheet-index]),' ')">
            <p:inline><_/></p:inline>
        </p:variable>
        <px:message>
            <p:with-option name="message" select="concat('stylesheets: ',$stylesheets-to-be-inlined)"/>
        </px:message>
        <px:apply-stylesheets>
            <p:with-option name="stylesheets" select="$stylesheets-to-be-inlined"/>
            <p:input port="parameters">
                <p:pipe port="result" step="parameters"/>
            </p:input>
        </px:apply-stylesheets>
    </p:group>
    
    <px:message message="[progress px:dtbook-to-pef.convert 4 px:dtbook-to-pef.convert.viewport-math] Transforming MathML"/>
    <p:viewport match="math:math">
        <px:message>
            <p:with-option name="message" select="concat('[progress px:dtbook-to-pef.convert.viewport-math 1/$1 *] MathML: ', string-join(*/name(),', '))"/>
            <p:with-option name="param1" select="p:iteration-size()"/>
        </px:message>
        <px:transform>
            <p:with-option name="query" select="concat('(input:mathml)(locale:',$lang,')')"/>
            <p:with-option name="temp-dir" select="$temp-dir"/>
        </px:transform>
    </p:viewport>
    
    <px:message message="[progress px:dtbook-to-pef.convert 84 px:dtbook-to-pef.convert.choose-transform] Transforming from XML to PEF" cx:depends-on="parameters"/>
    <p:choose name="transform">
        <p:when test="$include-obfl='true'">
            <p:output port="pef" primary="true"/>
            <p:output port="obfl">
                <p:pipe step="obfl" port="result"/>
            </p:output>
            <p:group name="obfl">
                <p:output port="result"/>
                <p:variable name="transform-query" select="concat('(input:css)(output:obfl)',$transform,'(locale:',$lang,')')"/>
                <px:message severity="DEBUG" message="px:transform query=$1">
                    <p:with-option name="param1" select="$transform-query"/>
                </px:message>
                <px:message message="[progress px:dtbook-to-pef.convert.choose-transform 34 *] Transforming from XML with inline CSS to OBFL"/>
                <px:transform>
                    <p:with-option name="query" select="$transform-query"/>
                    <p:with-option name="temp-dir" select="$temp-dir"/>
                    <p:input port="parameters">
                        <p:pipe port="result" step="parameters"/>
                    </p:input>
                </px:transform>
            </p:group>
            <p:group>
                <p:variable name="transform-query" select="concat('(input:obfl)(input:text-css)(output:pef)',$transform,'(locale:',$lang,')')"/>
                <px:message severity="DEBUG" message="px:transform query=$1">
                    <p:with-option name="param1" select="$transform-query"/>
                </px:message>
                <px:message message="[progress px:dtbook-to-pef.convert.choose-transform 66 *] Transforming from OBFL to PEF"/>
                <px:transform>
                    <p:with-option name="query" select="$transform-query"/>
                    <p:with-option name="temp-dir" select="$temp-dir"/>
                    <p:input port="parameters">
                        <p:pipe port="result" step="parameters"/>
                    </p:input>
                </px:transform>
            </p:group>
        </p:when>
        <p:otherwise>
            <p:output port="pef" primary="true"/>
            <p:output port="obfl">
                <p:empty/>
            </p:output>
            <p:group>
                <p:variable name="transform-query" select="concat('(input:css)(output:pef)',$transform,'(locale:',$lang,')')"/>
                <px:message severity="DEBUG" message="px:transform query=$1">
                    <p:with-option name="param1" select="$transform-query"/>
                </px:message>
                <px:message message="[progress px:dtbook-to-pef.convert.choose-transform 100 *] Transforming from XML with inline CSS to PEF"/>
                <px:transform>
                    <p:with-option name="query" select="$transform-query"/>
                    <p:with-option name="temp-dir" select="$temp-dir"/>
                    <p:input port="parameters">
                        <p:pipe port="result" step="parameters"/>
                    </p:input>
                </px:transform>
            </p:group>
        </p:otherwise>
    </p:choose>
    <p:identity name="pef"/>

    <p:identity>
        <p:input port="source">
            <p:pipe step="main" port="source"/>
        </p:input>
    </p:identity>
    <px:message message="[progress px:dtbook-to-pef.convert 1 dtbook-to-metadata.xsl] Extracting metadata from DTBook"/>
    <p:xslt name="metadata">
        <p:input port="stylesheet">
            <p:document href="../xslt/dtbook-to-metadata.xsl"/>
        </p:input>
        <p:input port="parameters">
            <p:empty/>
        </p:input>
    </p:xslt>
    
    <p:identity>
        <p:input port="source">
            <p:pipe step="pef" port="result"/>
        </p:input>
    </p:identity>
    <px:message cx:depends-on="metadata" message="[progress px:dtbook-to-pef.convert 1 pef:add-metadata] Adding metadata to PEF"/>
    <pef:add-metadata>
        <p:input port="metadata">
            <p:pipe step="metadata" port="result"/>
        </p:input>
    </pef:add-metadata>
    
    <p:choose>
        <p:when test="not($lang='und')">
            <px:message message="[progress px:dtbook-to-pef.convert 1 p:add-attribute] Adding language attribute to PEF"/>
            <p:add-attribute match="/*" attribute-name="xml:lang">
                <p:with-option name="attribute-value" select="$lang"/>
            </p:add-attribute>
        </p:when>
        <p:otherwise>
            <px:message message="[progress px:dtbook-to-pef.convert 1 p:identity]"/>
            <p:identity/>
        </p:otherwise>
    </p:choose>
    
</p:declare-step>
