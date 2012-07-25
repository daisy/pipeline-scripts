<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step
    xmlns:p="http://www.w3.org/ns/xproc"
    xmlns:px="http://www.daisy.org/ns/pipeline/xproc"
    xmlns:d="http://www.daisy.org/ns/pipeline/data"
    xmlns:xd="http://www.daisy.org/ns/pipeline/doc"
    xmlns:z="http://www.daisy.org/ns/z3998/authoring/"
    xmlns:css="http://xmlcalabash.com/ns/extensions/braille-css"
    xmlns:louis="http://liblouis.org/liblouis"
    xmlns:pef="http://xmlcalabash.com/ns/extensions/brailleutils"
    exclude-inline-prefixes="px d xd z css louis pef"
    type="px:zedai-to-pef" name="zedai-to-pef" version="1.0">

    <p:documentation xmlns="http://www.w3.org/1999/xhtml">
        <h1 px:role="name">ZedAI to PEF</h1>
        <p px:role="desc">Transforms a ZedAI (DAISY 4 XML) document into an PEF.</p>
        <dl px:role="author">
            <dt>Name:</dt>
            <dd px:role="name">Bert Frees</dd>
            <dt>Organization:</dt>
            <dd px:role="organization" href="http://www.sbs-online.ch/">SBS</dd>
            <dt>E-mail:</dt>
            <dd><a px:role="contact" href="mailto:bertfrees@gmail.com">bertfrees@gmail.com</a></dd>
        </dl>
    </p:documentation>

    <p:input port="source" primary="true" px:name="source" px:media-type="application/z3998-auth+xml">
        <p:documentation>
            <h2 px:role="name">source</h2>
            <p px:role="desc">Path to input ZedAI.</p>
        </p:documentation>
    </p:input>
    
    <p:option name="output-dir" required="true" px:output="result" px:sequence="false" px:type="anyDirURI">
        <p:documentation>
            <h2 px:role="name">output-dir</h2>
            <p px:role="desc">Path to output directory for the PEF.</p>
        </p:documentation>
    </p:option>
    
    <p:option name="temp-dir" required="true" px:output="temp" px:sequence="false" px:type="anyDirURI">
        <p:documentation>
            <h2 px:role="name">temp-dir</h2>
            <p px:role="desc">Path to directory for storing temporary files.</p>
        </p:documentation>
    </p:option>
    
    <p:option name="default-stylesheet" required="false" px:type="string" select="'bana.css'">
        <p:documentation>
            <h2 px:role="name">default-stylesheet</h2>
            <p px:role="desc">The default css stylesheet to apply when there aren't any provided with the input file.</p>
            <pre><code class="example">bana.css</code></pre>
        </p:documentation>
    </p:option>
    
    <p:import href="http://www.daisy.org/pipeline/modules/file-utils/xproc/file-library.xpl"/>
    <p:import href="http://www.daisy.org/pipeline/modules/liblouis-formatter/xproc/library.xpl"/>
    <p:import href="http://www.daisy.org/pipeline/modules/brailleutils-calabash/xproc/library.xpl"/>
    <p:import href="http://www.daisy.org/pipeline/modules/braille-css-calabash/xproc/library.xpl"/>
    
    <p:variable name="input-uri" select="base-uri(/)"/>
    
    <p:xslt name="output-dir-uri">
        <p:with-param name="href" select="concat($output-dir,'/')"/>
        <p:input port="source">
            <p:inline>
                <d:file/>
            </p:inline>
        </p:input>
        <p:input port="stylesheet">
            <p:inline>
                <xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:pf="http://www.daisy.org/ns/pipeline/functions" version="2.0">
                    <xsl:import href="http://www.daisy.org/pipeline/modules/file-utils/xslt/uri-functions.xsl"/>
                    <xsl:param name="href" required="yes"/>
                    <xsl:template match="/*">
                        <xsl:copy>
                            <xsl:attribute name="href" select="pf:file-uri-ify($href)"/>
                        </xsl:copy>
                    </xsl:template>
                </xsl:stylesheet>
            </p:inline>
        </p:input>
    </p:xslt>
    <p:sink/>
    
    <p:xslt name="temp-dir-uri">
        <p:with-param name="href" select="concat($temp-dir,'/')"/>
        <p:input port="source">
            <p:inline>
                <d:file/>
            </p:inline>
        </p:input>
        <p:input port="stylesheet">
            <p:inline>
                <xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                    xmlns:pf="http://www.daisy.org/ns/pipeline/functions"
                    version="2.0">
                    <xsl:import href="http://www.daisy.org/pipeline/modules/file-utils/xslt/uri-functions.xsl"/>
                    <xsl:param name="href" required="yes"/>
                    <xsl:template match="/*">
                        <xsl:copy>
                            <xsl:attribute name="href" select="pf:file-uri-ify($href)"/>
                        </xsl:copy>
                    </xsl:template>
                </xsl:stylesheet>
            </p:inline>
        </p:input>
    </p:xslt>
    <p:sink/>
    
    <p:group>
        
        <p:variable name="output-dir-uri" select="/*/@href">
            <p:pipe port="result" step="output-dir-uri"/>
        </p:variable>
        
        <p:variable name="output-uri" select="concat($output-dir-uri,replace($input-uri,'^.*/([^/]*)\.[^/\.]*$','$1'),'.pef.xml')"/>
        
        <p:variable name="temp-dir-uri" select="/*/@href">
            <p:pipe port="result" step="temp-dir-uri"/>
        </p:variable>
        
        <!-- create temporary directory -->
        
        <px:mkdir>
            <p:with-option name="href" select="$temp-dir-uri">
                <p:empty/>
            </p:with-option>
        </px:mkdir>
        
        <!-- add styling -->
        
        <p:choose>
            <p:xpath-context>
                <p:pipe port="source" step="zedai-to-pef"/>
            </p:xpath-context>
            
            <p:when test="not(//z:head/link[@rel='stylesheet' and @media='embossed' and @type='text/css'])">
                
                <!-- FIXME this is an ugly solution -->
                <p:variable name="default-stylesheet-uri"
                    select="concat(substring(base-uri(/), 0, string-length(base-uri(/))-25), 'css/', $default-stylesheet)">
                    <p:document href="zedai-to-pef.xpl"/>
                </p:variable>
                
                <p:add-attribute match="/link" attribute-name="href" name="link">
                    <p:input port="source">
                        <p:inline>
                            <link rel="stylesheet" media="embossed" type="text/css"/>
                        </p:inline>
                    </p:input>
                    <p:with-option name="attribute-value" select="$default-stylesheet-uri">
                        <p:empty/>
                    </p:with-option>
                </p:add-attribute>
                
                <p:insert match="//z:head" position="first-child">
                    <p:input port="source">
                        <p:pipe port="source" step="zedai-to-pef"/>
                    </p:input>
                    <p:input port="insertion">
                        <p:pipe step="link" port="result"/>
                    </p:input>
                </p:insert>
            </p:when>
            <p:otherwise>
                <p:identity>
                    <p:input port="source">
                        <p:pipe port="source" step="zedai-to-pef"/>
                    </p:input>
                </p:identity>
            </p:otherwise>
        </p:choose>
        
        <css:apply-stylesheet/>
        
        <!-- flatten some elements -->
        
        <p:xslt>
            <p:input port="stylesheet">
                <p:document href="../xslt/flatten.xsl"/>
            </p:input>
            <p:input port="parameters">
                <p:empty/>
            </p:input>
        </p:xslt>
        
        <!-- translate text nodes with liblouis -->
        
        <p:xslt>
            <p:input port="stylesheet">
                <p:document href="../xslt/translate.xsl"/>
            </p:input>
            <p:input port="parameters">
                <p:empty/>
            </p:input>
        </p:xslt>
        
        <!-- format with liblouisxml -->
        
        <louis:format>
            <p:with-option name="temp-dir" select="$temp-dir-uri"/>
        </louis:format>
        
        <!-- convert to pef with brailleutils -->
        
        <pef:text2pef name="text-to-pef">
            <p:with-option name="temp-dir" select="$temp-dir-uri"/>
        </pef:text2pef>
        
        <!-- store -->
        
        <p:store indent="true" encoding="utf-8">
            <p:with-option name="href" select="$output-uri"/>
        </p:store>
        
    </p:group>
    
</p:declare-step>
