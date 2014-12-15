<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step xmlns:p="http://www.w3.org/ns/xproc"
                xmlns:pxi="http://www.daisy.org/ns/pipeline/xproc/internal"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:css="http://www.daisy.org/ns/pipeline/braille-css"
                type="css:split"
                exclude-inline-prefixes="#all"
                version="1.0">
    
    <!--
        Split a tree into a parts. The split points are specified with the split-before and
        split-after options. Boxes that are split get a @part attribute (first|middle|last).
    -->
    
    <p:input port="source"/>
    <p:output port="result" sequence="true"/>
    
    <!--
        must be of the form *[...] ?
    -->
    <p:option name="split-before" required="true"/> <!-- XSLTMatchPattern -->
    <p:option name="split-after" required="true"/> <!-- XSLTMatchPattern -->
    
    <p:declare-step type="pxi:split-into-sections-inner">
        <p:input port="source"/>
        <p:output port="result" sequence="true"/>
        <p:variable name="split-point"
                    select="(//*[@pxi:split-before or
                                (@pxi:split-after and not(descendant::*[@pxi:split-before or @pxi:split-after]))]
                            )[1]/@xml:id"/>
        <p:choose>
            <p:when test="$split-point!=''">
                <p:variable name="position" select="if (//*[@xml:id=$split-point]/@pxi:split-before) then 'before' else 'after'"/>
                <p:variable name="matcher" select="concat('*[@xml:id=&quot;', $split-point, '&quot;]')"/>
                <p:delete>
                    <p:with-option name="match" select="concat($matcher,'/@pxi:split-',$position)"/>
                </p:delete>
                <p:identity name="unsplit"/>
                <p:label-elements attribute="part" label="if (@part=('middle','last')) then 'middle' else 'first'">
                    <p:with-option name="match" select="concat('css:box[descendant::',$matcher,']')"/>
                </p:label-elements>
                <p:delete>
                    <p:with-option name="match" select="if ($position='before')
                                                        then concat('node()[preceding::',$matcher,']|',$matcher)
                                                        else concat('node()[preceding::',$matcher,']')"/>
                </p:delete>
                <p:identity name="first-part"/>
                <p:identity>
                    <p:input port="source">
                        <p:pipe step="unsplit" port="result"/>
                    </p:input>
                </p:identity>
                <p:label-elements attribute="part" label="if (@part=('first','middle')) then 'middle' else 'last'">
                    <p:with-option name="match" select="concat('css:box[descendant::',$matcher,']')"/>
                </p:label-elements>
                <p:delete>
                    <p:with-option name="match" select="if ($position='before')
                                                        then concat('node()[following::',$matcher,']')
                                                        else concat('node()[following::',$matcher,']|',$matcher)"/>
                </p:delete>
                <p:for-each>
                    <pxi:split-into-sections-inner/>
                </p:for-each>
                <p:identity name="next-parts"/>
                <p:identity>
                    <p:input port="source">
                        <p:pipe step="first-part" port="result"/>
                        <p:pipe step="next-parts" port="result"/>
                    </p:input>
                </p:identity>
            </p:when>
            <p:otherwise>
                <p:identity/>
            </p:otherwise>
        </p:choose>
    </p:declare-step>
    
    <p:add-attribute attribute-name="pxi:split-before" attribute-value="true">
        <p:with-option name="match" select="$split-before"/>
    </p:add-attribute>
    
    <p:add-attribute attribute-name="pxi:split-after" attribute-value="true">
        <p:with-option name="match" select="$split-after"/>
    </p:add-attribute>
    
    <p:label-elements attribute="xml:id" replace="false" label="concat('__temp__',$p:index)"
                      match="*[@pxi:split-before or @pxi:split-after]"/>
    
    <pxi:split-into-sections-inner/>
    
    <p:for-each>
        <p:delete match="@xml:id[starts-with(., '__temp__')]|@pxi:split-before|@pxi:split-after"/>
    </p:for-each>
    
    <p:for-each>
        <p:delete match="css:box[@part=('middle','last')]/@css:*[matches(local-name(),'^counter-(reset|set|increment)')]|
                         css:box[@part=('middle','last')]/@css:string-entry|
                         css:box[@part=('middle','last')]/@css:string-set|
                         css:box[@part=('middle','last')]/@css:id"/>
    </p:for-each>
    
</p:declare-step>
