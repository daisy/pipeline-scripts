<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step type="louis:get-typeform"
    xmlns:p="http://www.w3.org/ns/xproc"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:louis="http://liblouis.org/liblouis"
    xmlns:c="http://www.w3.org/ns/xproc-step"
    version="1.0">
    <p:input port="source"/>
    <p:output port="result"/>
    <p:xslt>
        <p:input port="stylesheet">
            <p:inline>
                <xsl:stylesheet version="2.0">
                    <xsl:import href="../../main/resources/xml/xslt/library.xsl"/>
                    <xsl:template match="/*">
                        <xsl:element name="c:result">
                            <xsl:sequence select="louis:get-typeform(.)"/>
                        </xsl:element>
                    </xsl:template>
                </xsl:stylesheet>
            </p:inline>
        </p:input>
        <p:input port="parameters">
            <p:empty/>
        </p:input>
    </p:xslt>
</p:declare-step>
