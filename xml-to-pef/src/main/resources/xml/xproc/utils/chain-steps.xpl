<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step
    xmlns:p="http://www.w3.org/ns/xproc"
    xmlns:px="http://www.daisy.org/ns/pipeline/xproc"
    xmlns:cx="http://xmlcalabash.com/ns/extensions"
    xmlns:pxi="http://www.daisy.org/ns/pipeline/xproc/internal"
    exclude-inline-prefixes="#all"
    type="pxi:chain-steps" name="chain-steps" version="1.0">
    
    <p:input port="steps" sequence="true" primary="true"/>
    <p:output port="result" primary="true"/>
    
    <p:wrap-sequence wrapper="wrap"/>
    <p:choose>
        <p:when test="/*/p:pipeline and count(/*/*)=1">
            <p:identity>
                <p:input port="source">
                    <p:pipe step="chain-steps" port="steps"/>
                </p:input>
            </p:identity>
        </p:when>
        <p:otherwise>
            <p:group>
                <p:for-each name="steps">
                    <p:iteration-source>
                        <p:pipe step="chain-steps" port="steps"/>
                    </p:iteration-source>
                    <p:choose>
                        <p:when test="/xsl:stylesheet">
                            <p:insert match="//p:inline" position="first-child">
                                <p:input port="source">
                                    <p:inline>
                                        <p:xslt>
                                            <p:input port="stylesheet">
                                                <p:inline></p:inline>
                                            </p:input>
                                            <p:input port="parameters">
                                                <p:empty/>
                                            </p:input>
                                        </p:xslt>
                                    </p:inline>
                                </p:input>
                                <p:input port="insertion">
                                    <p:pipe step="steps" port="current"/>
                                </p:input>
                            </p:insert>
                        </p:when>
                        <p:when test="/p:pipeline">
                            <p:insert match="//p:inline" position="first-child">
                                <p:input port="source">
                                    <p:inline>
                                        <cx:eval>
                                            <p:input port="pipeline">
                                                <p:inline></p:inline>
                                            </p:input>
                                            <p:input port="options">
                                                <p:empty/>
                                            </p:input>
                                        </cx:eval>
                                    </p:inline>
                                </p:input>
                                <p:input port="insertion">
                                    <p:pipe step="steps" port="current"/>
                                </p:input>
                            </p:insert>
                        </p:when>
                        <p:otherwise>
                            <p:error code="px:brl02">
                                <p:input port="source">
                                    <p:inline><message>Could not evaluate step: neither a &lt;xsl:stylesheet&gt; nor a &lt;p:pipeline&gt;.</message></p:inline>
                                </p:input>
                            </p:error>
                        </p:otherwise>
                    </p:choose>
                </p:for-each>
                <p:wrap-sequence wrapper="p:pipeline"/>
                <p:add-attribute match="/*" attribute-name="version" attribute-value="1.0"/>
            </p:group>
        </p:otherwise>
    </p:choose>
    
</p:declare-step>
