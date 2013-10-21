<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step type="louis:translate"
    xmlns:p="http://www.w3.org/ns/xproc"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:louis="http://liblouis.org/liblouis"
    xmlns:c="http://www.w3.org/ns/xproc-step"
    version="1.0">
    <p:input port="parameters" kind="parameter"/>
    <p:output port="result"/>
    <p:xslt template-name="main">
        <p:input port="source">
            <p:empty/>
        </p:input>
        <p:input port="stylesheet">
            <p:inline>
                <xsl:stylesheet version="2.0">
                    <xsl:import href="../../main/resources/xml/library.xsl"/>
                    <xsl:param name="table"/>
                    <xsl:param name="text"/>
                    <xsl:template name="main">
                        <xsl:element name="c:result">
                            <xsl:sequence select="louis:translate($table, $text)"/>
                        </xsl:element>
                    </xsl:template>
                </xsl:stylesheet>
            </p:inline>
        </p:input>
    </p:xslt>
</p:declare-step>
