<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step
    xmlns:p="http://www.w3.org/ns/xproc"
    xmlns:px="http://www.daisy.org/ns/pipeline/xproc"
    exclude-inline-prefixes="#all"
    type="px:xml-to-pef.load-preprocessor" version="1.0">
    
    <p:output port="result" sequence="true" primary="true"/>
    <p:option name="preprocessor" required="true"/>
    
    <p:choose>
        <p:when test="contains($preprocessor, ',')">
            <px:xml-to-pef.load-preprocessor name="first">
                <p:with-option name="preprocessor" select="substring-before($preprocessor, ',')"/>
            </px:xml-to-pef.load-preprocessor>
            <p:sink/>
            <px:xml-to-pef.load-preprocessor name="rest">
                <p:with-option name="preprocessor" select="substring-after($preprocessor, ',')"/>
            </px:xml-to-pef.load-preprocessor>
            <p:sink/>
            <p:identity>
                <p:input port="source">
                    <p:pipe step="first" port="result"/>
                    <p:pipe step="rest" port="result"/>
                </p:input>
            </p:identity>
        </p:when>
        <p:otherwise>
            <p:choose>
                <p:when test="$preprocessor=''">
                    <p:identity>
                        <p:input port="source">
                            <p:empty/>
                        </p:input>
                    </p:identity>
                </p:when>
                <p:when test="matches($preprocessor, '^http:/.*')">
                    <p:load>
                        <p:with-option name="href" select="$preprocessor"/>
                    </p:load>
                </p:when>
                <p:otherwise>
                    <p:error code="px:brl01">
                        <p:input port="source">
                            <p:inline><message>The option 'preprocessor' must be of the form 'http:/...'.</message></p:inline>
                        </p:input>
                    </p:error>
                </p:otherwise>
            </p:choose>
        </p:otherwise>
    </p:choose>
    
</p:declare-step>
