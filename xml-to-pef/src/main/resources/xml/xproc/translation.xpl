<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step
    xmlns:p="http://www.w3.org/ns/xproc"
    xmlns:px="http://www.daisy.org/ns/pipeline/xproc"
    xmlns:pxi="http://www.daisy.org/ns/pipeline/xproc/internal"
    xmlns:cx="http://xmlcalabash.com/ns/extensions"
    xmlns:css="http://www.daisy.org/ns/pipeline/braille-css"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    exclude-inline-prefixes="#all"
    type="pxi:translation" name="translation" version="1.0">
    
    <p:input port="source" primary="true"/>
    <p:output port="result" primary="true"/>
    <p:option name="translator" required="true"/>
    <p:option name="hyphenator" required="true"/>
    
    <p:import href="http://xmlcalabash.com/extension/steps/library-1.0.xpl"/>
    <p:import href="build-translation-pipeline.xpl"/>
    
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
    
    <!-- Build translation pipeline -->
    
    <pxi:build-translation-pipeline name="pipeline">
        <p:with-option name="translator" select="$translator"/>
        <p:with-option name="hyphenator" select="$hyphenator"/>
    </pxi:build-translation-pipeline>
    
    <!-- Translate each block -->
    
    <p:try name="translate">
        <p:group>
            <p:output port="result"/>
            <p:viewport match="css:block">
                <p:viewport-source>
                    <p:pipe step="blocks" port="result"/>
                </p:viewport-source>
                <cx:eval>
                    <p:input port="pipeline">
                        <p:pipe step="pipeline" port="result"/>
                    </p:input>
                    <p:input port="options">
                        <p:empty/>
                    </p:input>
                </cx:eval>
            </p:viewport>
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
                    <p:inline><message>Translated document is invalid: </message></p:inline>
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
    
    <!-- Unwrap blocks, normalize space  -->
    
    <p:xslt>
        <p:input port="source">
            <p:pipe step="translate" port="result"/>
        </p:input>
        <p:input port="stylesheet">
            <p:document href="../xslt/normalize-space.xsl"/>
        </p:input>
        <p:input port="parameters">
            <p:empty/>
        </p:input>
    </p:xslt>
    
    <!-- Re-insert string-set -->
    
    <p:viewport match="*[child::css:string-set]">
        <p:string-replace match="@style" replace="concat(
            'string-set: ',
            string(/*/css:string-set/@name),
            ' &quot;',
            string(/*/css:string-set),
            '&quot;; ',
            string(/*/@style))"/>
        <p:delete match="css:string-set"/>
    </p:viewport>
    
</p:declare-step>
