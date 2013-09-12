<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step
    xmlns:p="http://www.w3.org/ns/xproc"
    xmlns:c="http://www.w3.org/ns/xproc-step"
    xmlns:px="http://www.daisy.org/ns/pipeline/xproc"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    exclude-inline-prefixes="#all"
    type="px:validate-braille" version="1.0">
    
    <p:input port="source"/>
    <p:output port="result"/>
    
    <p:option name="fail-if-invalid" select="'false'"/>
    
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
            <p:sink/>
            <p:identity>
                <p:input port="source">
                    <p:inline><c:result>true</c:result></p:inline>
                </p:input>
            </p:identity>
        </p:group>
        <p:catch name="validate-catch">
            <p:choose>
                <p:when test="$fail-if-invalid='true'">
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
                </p:when>
                <p:otherwise>
                    <p:identity>
                        <p:input port="source">
                            <p:inline><c:result>false</c:result></p:inline>
                        </p:input>
                    </p:identity>
                </p:otherwise>
            </p:choose>
        </p:catch>
    </p:try>
    
</p:declare-step>
