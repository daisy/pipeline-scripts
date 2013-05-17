<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step type="pxi:split-into-sections" name="split-into-sections"
    xmlns:p="http://www.w3.org/ns/xproc"
    xmlns:pxi="http://www.daisy.org/ns/pipeline/xproc/internal"
    xmlns:css="http://www.daisy.org/ns/pipeline/braille-css"
    exclude-inline-prefixes="#all"
    version="1.0">
    
    <p:input port="source" sequence="true" primary="true"/>
    <p:output port="result" sequence="true" primary="true"/>
    
    <p:for-each name="for-each">
        <p:choose>
            <p:when test="/*//*[@css:page]">
                <p:variable name="section-id" select="(/*//*[@css:page]/@xml:id)[1]"/>
                <p:variable name="section-matcher" select="concat('*[@xml:id=&quot;', $section-id, '&quot;]')"/>
                <p:variable name="css-page" select="string(//*[@xml:id=$section-id]/@css:page)"/>
                <p:delete name="section-before">
                    <p:input port="source">
                        <p:pipe step="for-each" port="current"/>
                    </p:input>
                    <p:with-option name="match" select="concat($section-matcher, '|*[preceding::', $section-matcher, ']')"/>
                </p:delete>
                <p:sink/>
                <p:delete name="section-after">
                    <p:input port="source">
                        <p:pipe step="for-each" port="current"/>
                    </p:input>
                    <p:with-option name="match" select="concat($section-matcher, '|*[following::', $section-matcher, ']')"/>
                </p:delete>
                <p:sink/>
                <p:group name="section">
                    <p:output port="result" primary="true"/>
                    <p:delete>
                        <p:input port="source">
                            <p:pipe step="for-each" port="current"/>
                        </p:input>
                        <p:with-option name="match" select="concat('*[preceding::', $section-matcher, ']|*[following::', $section-matcher, ']')"/>
                    </p:delete>
                    <p:delete>
                        <p:with-option name="match" select="concat($section-matcher, '/@css:page')"/>
                    </p:delete>
                    <p:add-attribute match="/*" attribute-name="css:page">
                        <p:with-option name="attribute-value" select="$css-page"/>
                    </p:add-attribute>
                </p:group>
                <p:sink/>
                <p:split-sequence test="normalize-space(string(/*))!=''">
                    <p:input port="source">
                        <p:pipe step="section-before" port="result"/>
                        <p:pipe step="section" port="result"/>
                        <p:pipe step="section-after" port="result"/>
                    </p:input>
                </p:split-sequence>
                <pxi:split-into-sections/>
            </p:when>
            <p:otherwise>
                <p:identity/>
            </p:otherwise>
        </p:choose>
    </p:for-each>
    
</p:declare-step>
