<?xml version="1.0" encoding="UTF-8"?>
<p:pipeline
    xmlns:p="http://www.w3.org/ns/xproc"
    xmlns:px="http://www.daisy.org/ns/pipeline/xproc"
    xmlns:louis="http://liblouis.org/liblouis"
    xmlns:m="http://www.w3.org/1998/Math/MathML"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    exclude-inline-prefixes="p px louis xsl"
    type="px:generic-liblouis-translate-mathml" version="1.0">
    
    <p:option name="temp-dir" required="true"/>
    
    <p:import href="http://www.daisy.org/pipeline/modules/braille/liblouis-utils/library.xpl"/>
    
    <p:xslt>
        <p:input port="stylesheet">
            <p:inline>
                <xsl:stylesheet version="2.0">
                    <xsl:template match="m:math">
                        <xsl:copy>
                            <xsl:variable name="lang" select="ancestor-or-self::*[@xml:lang][1]/@xml:lang"/>
                            <xsl:if test="not(lang('en') or lang('de') or lang('nl'))">
                                <xsl:message terminate="yes">
                                    <xsl:value-of select="concat(
                                        'No math code found that matches xml:lang=&quot;', $lang, '&quot;')"/>
                                </xsl:message>
                            </xsl:if>
                            <xsl:attribute name="xml:lang" select="$lang"/>
                            <xsl:sequence select="@*|node()"/>
                        </xsl:copy>
                    </xsl:template>
                    <xsl:template match="node()|@*">
                        <xsl:copy>
                            <xsl:apply-templates select="@*|node()"/>
                        </xsl:copy>
                    </xsl:template>
                </xsl:stylesheet>
            </p:inline>
        </p:input>
        <p:input port="parameters">
            <p:empty/>
        </p:input>
    </p:xslt>
    
    <p:viewport match="m:math" name="math">
        <louis:translate-mathml>
            <p:with-option name="temp-dir" select="$temp-dir"/>
            <p:with-option name="math-code" select="if (/m:math[lang('en-GB')]) then 'ukmaths' else
                                                    if (/m:math[lang('en')]) then 'nemeth' else
                                                    if (/m:math[lang('de')]) then 'marburg' else
                                                    if (/m:math[lang('nl')]) then 'woluwe' else ''">
                <p:pipe step="math" port="current"/>
            </p:with-option>
        </louis:translate-mathml>
        <p:identity/>
    </p:viewport>
    
</p:pipeline>
