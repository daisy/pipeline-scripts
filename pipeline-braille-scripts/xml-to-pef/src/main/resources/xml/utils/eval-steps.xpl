<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step
    xmlns:p="http://www.w3.org/ns/xproc"
    xmlns:c="http://www.w3.org/ns/xproc-step"
    xmlns:px="http://www.daisy.org/ns/pipeline/xproc"
    xmlns:cx="http://xmlcalabash.com/ns/extensions"
    xmlns:pxi="http://www.daisy.org/ns/pipeline/xproc/internal"
    exclude-inline-prefixes="#all"
    type="pxi:eval-steps" name="eval-steps" version="1.0">
    
    <p:input port="source" sequence="true" primary="true"/>
    <p:input port="steps" sequence="true"/>
    <p:option name="temp-dir" required="true"/>
    <p:output port="result" primary="true"/>
    
    <p:import href="eval.xpl"/>
    
    <p:count>
        <p:input port="source">
            <p:pipe step="eval-steps" port="steps"/>
        </p:input>
    </p:count>
    
    <p:choose>
        <p:when test="number(/c:result) > 0">
            <p:split-sequence name="split-steps" test="position()=1">
                <p:input port="source">
                    <p:pipe step="eval-steps" port="steps"/>
                </p:input>
            </p:split-sequence>
            <p:choose>
                <p:when test="/xsl:stylesheet">
                    <p:xslt>
                        <p:input port="source">
                            <p:pipe step="eval-steps" port="source"/>
                        </p:input>
                        <p:input port="stylesheet">
                            <p:pipe step="split-steps" port="matched"/>
                        </p:input>
                        <p:with-param name="temp-dir" select="$temp-dir"/>
                    </p:xslt>
                </p:when>
                <p:when test="/p:pipeline">
                    <pxi:eval>
                        <p:input port="source">
                            <p:pipe step="eval-steps" port="source"/>
                        </p:input>
                        <p:input port="pipeline">
                            <p:pipe step="split-steps" port="matched"/>
                        </p:input>
                        <p:with-param name="temp-dir" select="$temp-dir"/>
                    </pxi:eval>
                </p:when>
                <p:otherwise>
                    <p:error code="px:brl02">
                        <p:input port="source">
                            <p:inline><message>Could not evaluate step: neither a &lt;xsl:stylesheet&gt; nor a &lt;p:pipeline&gt;.</message></p:inline>
                        </p:input>
                    </p:error>
                </p:otherwise>
            </p:choose>
            <pxi:eval-steps>
                <p:input port="steps">
                    <p:pipe step="split-steps" port="not-matched"/>
                </p:input>
                <p:with-option name="temp-dir" select="$temp-dir"/>
            </pxi:eval-steps>
        </p:when>
        <p:otherwise>
            <p:identity>
                <p:input port="source">
                    <p:pipe step="eval-steps" port="source"/>
                </p:input>
            </p:identity>
        </p:otherwise>
    </p:choose>
    
</p:declare-step>
