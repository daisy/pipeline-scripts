<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step type="pxi:split-into-sections" name="split-into-sections"
    xmlns:p="http://www.w3.org/ns/xproc"
    xmlns:pxi="http://www.daisy.org/ns/pipeline/xproc/internal"
    xmlns:c="http://www.w3.org/ns/xproc-step"
    xmlns:css="http://www.daisy.org/ns/pipeline/braille-css"
    xmlns:louis="http://liblouis.org/liblouis"
    exclude-inline-prefixes="#all"
    version="1.0">
    
    <p:input port="source" sequence="true" primary="true"/>
    <p:output port="result" sequence="true" primary="true"/>
    
    <p:for-each name="for-each">
        <p:choose>
            <p:when test="/*//*[@css:page or @louis:braille-page-reset]">
                <p:variable name="section-id" select="(/*//*[@css:page or @louis:braille-page-reset]/@xml:id)[1]"/>
                <p:variable name="section-matcher" select="concat('*[@xml:id=&quot;', $section-id, '&quot;]')"/>
                
                <!-- ========= -->
                <!-- section 1 -->
                <!-- ========= -->
                
                <p:delete>
                    <p:with-option name="match" select="concat($section-matcher, '|*[preceding::', $section-matcher, ']')"/>
                </p:delete>
                <p:split-sequence test="normalize-space(string(/*))!='' or //*[@css:toc-item]"/>
                <p:identity name="section-1"/>
                <p:sink/>
                
                <!-- ========= -->
                <!-- section 2 -->
                <!-- ========= -->
                
                <p:group>
                    <p:count name="count-preceding-sections">
                        <p:input port="source">
                            <p:pipe step="section-1" port="result"/>
                        </p:input>
                    </p:count>
                    <p:group>
                        <p:variable name="count-preceding-sections" select="/c:result"/>
                        <p:delete>
                            <p:input port="source">
                                <p:pipe step="for-each" port="current"/>
                            </p:input>
                            <p:with-option name="match" select="concat('*[following::', $section-matcher, ']')"/>
                        </p:delete>
                        <p:choose>
                            <p:when test="//*[@xml:id=$section-id]/@css:page">
                                <p:delete>
                                    <p:with-option name="match" select="concat('*[preceding::', $section-matcher, ']')"/>
                                </p:delete>
                                <p:add-attribute match="/*" attribute-name="css:page">
                                    <p:with-option name="attribute-value" select="//*[@xml:id=$section-id]/@css:page"/>
                                </p:add-attribute>
                                <p:delete>
                                    <p:with-option name="match" select="concat($section-matcher, '/@css:page')"/>
                                </p:delete>
                            </p:when>
                            <p:otherwise>
                                <p:identity/>
                            </p:otherwise>
                        </p:choose>
                        <p:choose>
                            <p:when test="//*[@xml:id=$section-id]/@louis:braille-page-reset">
                                <p:add-attribute match="/*" attribute-name="louis:braille-page-reset">
                                    <p:with-option name="attribute-value" select="//*[@xml:id=$section-id]/@louis:braille-page-reset"/>
                                </p:add-attribute>
                                <p:delete>
                                    <p:with-option name="match" select="concat($section-matcher, '/@louis:braille-page-reset')"/>
                                </p:delete>
                            </p:when>
                            <p:when test="number($count-preceding-sections) > 0">
                                <p:delete match="/*/@louis:braille-page-reset"/>
                            </p:when>
                            <p:otherwise>
                                <p:identity/>
                            </p:otherwise>
                        </p:choose>
                        <p:split-sequence test="normalize-space(string(/*))!='' or //*[@css:toc-item]"/>
                    </p:group>
                </p:group>
                <p:identity name="section-2"/>
                <p:sink/>
                
                <!-- ========= -->
                <!-- section 3 -->
                <!-- ========= -->
                
                <p:group>
                    <p:count name="count-preceding-sections">
                        <p:input port="source">
                            <p:pipe step="section-1" port="result"/>
                            <p:pipe step="section-2" port="result"/>
                        </p:input>
                    </p:count>
                    <p:group>
                        <p:variable name="count-preceding-sections" select="/c:result"/>
                        <p:identity>
                            <p:input port="source">
                                <p:pipe step="for-each" port="current"/>
                            </p:input>
                        </p:identity>
                        <p:choose>
                            <p:when test="//*[@xml:id=$section-id]/@css:page">
                                <p:delete>
                                    <p:with-option name="match" select="concat($section-matcher, '|*[following::', $section-matcher, ']')"/>
                                </p:delete>
                                <p:choose>
                                    <p:when test="number($count-preceding-sections) > 0">
                                        <p:delete match="/*/@louis:braille-page-reset"/>
                                    </p:when>
                                    <p:otherwise>
                                        <p:identity/>
                                    </p:otherwise>
                                </p:choose>
                            </p:when>
                            <p:otherwise>
                                <p:identity>
                                    <p:input port="source">
                                        <p:empty/>
                                    </p:input>
                                </p:identity>
                            </p:otherwise>
                        </p:choose>
                        <p:split-sequence test="normalize-space(string(/*))!='' or //*[@css:toc-item]"/>
                    </p:group>
                </p:group>
                <p:identity name="section-3"/>
                <p:sink/>
                <pxi:split-into-sections>
                    <p:input port="source">
                        <p:pipe step="section-1" port="result"/>
                        <p:pipe step="section-2" port="result"/>
                        <p:pipe step="section-3" port="result"/>
                    </p:input>
                </pxi:split-into-sections>
            </p:when>
            <p:otherwise>
                <p:identity/>
            </p:otherwise>
        </p:choose>
    </p:for-each>
    
</p:declare-step>
