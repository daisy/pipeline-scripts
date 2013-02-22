<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step type="pxi:select-by-base"
    xmlns:p="http://www.w3.org/ns/xproc"
    xmlns:pxi="http://www.daisy.org/ns/pipeline/xproc/internal"
    exclude-inline-prefixes="#all"
    version="1.0">
    
    <p:input port="source" sequence="true" primary="true"/>
    <p:option name="base" required="true"/>
    <p:option name="include-not-matched" required="false" select="'false'"/>
    <p:output port="result" sequence="true" primary="true"/>
    
    <p:split-sequence name="split-sequence">
        <p:with-option name="test" select="concat('base-uri(/*)=&quot;', $base, '&quot;')">
            <p:empty/>
        </p:with-option>
    </p:split-sequence>
    
    <p:choose>
        <p:when test="$include-not-matched='true'">
            <p:identity>
                <p:input port="source">
                    <p:pipe step="split-sequence" port="matched"/>
                    <p:pipe step="split-sequence" port="not-matched"/>
                </p:input>
            </p:identity>
        </p:when>
        <p:otherwise>
            <p:identity>
                <p:input port="source">
                    <p:pipe step="split-sequence" port="matched"/>
                </p:input>
            </p:identity>
        </p:otherwise>
    </p:choose>
    
</p:declare-step>
