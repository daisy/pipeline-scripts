<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step
    xmlns:p="http://www.w3.org/ns/xproc"
    xmlns:px="http://www.daisy.org/ns/pipeline/xproc"
    xmlns:cx="http://xmlcalabash.com/ns/extensions"
    xmlns:css="http://www.daisy.org/ns/pipeline/braille-css"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    exclude-inline-prefixes="px css xsl"
    type="px:xml-to-pef.translation" name="xml-to-pef.translation" version="1.0">

    <p:input port="source" primary="true"/>
    <p:output port="result" primary="true"/>
    <p:option name="translator" required="true"/>

    <p:import href="http://xmlcalabash.com/extension/steps/library-1.0.xpl"/>

    <!-- Handle string-set -->
    
    <p:xslt>
        <p:input port="stylesheet">
            <p:document href="../xslt/handle-string-set.xsl"/>
        </p:input>
        <p:input port="parameters">
            <p:empty/>
        </p:input>
    </p:xslt>

    <!-- Identify blocks -->
    
    <p:xslt name="blocks">
        <p:input port="stylesheet">
            <p:document href="../xslt/identify-blocks.xsl"/>
        </p:input>
        <p:input port="parameters">
            <p:empty/>
        </p:input>
    </p:xslt>

    <!-- Load translator from URL -->
    
    <p:choose name="translator">
        <p:when test="$translator = ''">
            <p:output port="result"/>
            <p:identity>
                <p:input port="source">
                    <p:document href="../xslt/simple-liblouis-translate.xsl"/>
                </p:input>
            </p:identity>
        </p:when>
        
        <p:when test="matches($translator, '^http:/.*')">
            <p:output port="result"/>
            <p:try>
                <p:group>
                    <p:load>
                        <p:with-option name="href" select="$translator">
                            <p:empty/>
                        </p:with-option>
                    </p:load>
                </p:group>
                <p:catch>
                    <!-- If the URL is not a document, it must be a liblouis table -->
                    <p:add-attribute attribute-name="select" match="/xsl:stylesheet/xsl:variable[@name='table']">
                        <p:input port="source">
                            <p:inline>
                                <xsl:stylesheet version="2.0" xmlns:louis="http://liblouis.org/liblouis" exclude-result-prefixes="louis">
                                    <xsl:variable name="table"/>
                                    <xsl:template match="/*">
                                        <xsl:copy>
                                            <xsl:sequence select="louis:translate($table, string(.))"/>
                                        </xsl:copy>
                                    </xsl:template>
                                </xsl:stylesheet>
                            </p:inline>
                        </p:input>
                        <p:with-option name="attribute-value" select='concat("&apos;", $translator, "&apos;")'>
                            <p:empty/>
                        </p:with-option>
                    </p:add-attribute>
                </p:catch>
            </p:try>
        </p:when>
        
        <p:otherwise>
            <p:output port="result"/>
            <p:error code="px:brl01">
                <p:input port="source">
                    <p:inline><message>The option 'translator' must be of the form 'http:/...'.</message></p:inline>
                </p:input>
            </p:error>
        </p:otherwise>
    </p:choose>
    
    <!-- Translate each block -->
    
    <p:try name="translate">
        <p:group>
            <p:output port="result"/>
            <p:choose>
                <p:xpath-context>
                    <p:pipe step="translator" port="result"/>
                </p:xpath-context>
                
                <p:when test="/xsl:stylesheet">
                    <p:viewport match="css:block">
                        <p:viewport-source>
                            <p:pipe step="blocks" port="result"/>
                        </p:viewport-source>
                        <p:xslt>
                            <p:input port="stylesheet">
                                <p:pipe step="translator" port="result"/>
                            </p:input>
                            <p:input port="parameters">
                                <p:empty/>
                            </p:input>
                        </p:xslt>
                    </p:viewport>
                </p:when>
                
                <p:when test="/p:declare-step or /p:pipeline">
                    <p:viewport match="css:block">
                        <p:viewport-source>
                            <p:pipe step="blocks" port="result"/>
                        </p:viewport-source>
                        <cx:eval>
                            <p:input port="pipeline">
                                <p:pipe step="translator" port="result"/>
                            </p:input>
                            <p:input port="options">
                                <p:empty/>
                            </p:input>
                        </cx:eval>
                    </p:viewport>
                </p:when>
                
                <p:otherwise>
                    <p:error code="px:brl02">
                        <p:input port="source">
                            <p:inline><message>The translator document is neither an XSLT nor an XProc.</message></p:inline>
                        </p:input>
                    </p:error>
                </p:otherwise>
            </p:choose>
        </p:group>
        
        <p:catch name="translate-catch">
            <p:output port="result"/>
            <p:insert match="/message" position="last-child" name="translate-error">
                <p:input port="source">
                    <p:inline><message>Translation failed: </message></p:inline>
                </p:input>
                <p:input port="insertion">
                    <p:pipe step="translate-catch" port="error"/>
                </p:input>
            </p:insert>
            <p:error code="px:brl03">
                <p:input port="source">
                    <p:pipe step="translate-error" port="result"/>
                </p:input>
            </p:error>
        </p:catch>
    </p:try>
    
    <!-- Validate output -->
    
    <p:try>
        <p:group>
            <p:xslt>
                <p:input port="stylesheet">
                    <p:document href="../xslt/validate-braille.xsl"/>
                </p:input>
                <p:input port="parameters">
                    <p:empty/>
                </p:input>
            </p:xslt>
        </p:group>
        <p:catch name="validate-catch">
            <p:insert match="/message" position="last-child" name="validate-error">
                <p:input port="source">
                    <p:inline><message>Translated document is not valid: </message></p:inline>
                </p:input>
                <p:input port="insertion">
                    <p:pipe step="validate-catch" port="error"/>
                </p:input>
            </p:insert>
            <p:error code="px:brl04">
                <p:input port="source">
                    <p:pipe step="validate-error" port="result"/>
                </p:input>
            </p:error>
        </p:catch>
    </p:try>
    <p:sink/>
    
    <p:unwrap match="css:block"/>
    
</p:declare-step>
