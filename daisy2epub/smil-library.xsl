<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:px="http://pipeline.daisy.org/ns/" xmlns:xs="http://www.w3.org/2001/XMLSchema"
    exclude-result-prefixes="#all" version="1.0">
    
    <xsl:function name="px:clockValToSeconds" as="xs:double">
        <xsl:param name="string" as="xs:string"/>
        <xsl:variable name="stringTokenized"
            select="reverse(
            subsequence(
            tokenize(
            replace(
            replace($string, '^.*=(.*)$', '$1'),
            '^(.+?)[^\d]*$',
            '$1'),
            ':'),
            1, 3)
            )"/>
        <xsl:variable name="number"
            select=" (number($stringTokenized[1]) + (if (count($stringTokenized)&gt;=2) then number($stringTokenized[2])*60 else 0) + (if (count($stringTokenized)=3) then number($stringTokenized[3])*3600 else 0))
            *(if (ends-with($string,'ms')) then 0.001 else (if (ends-with($string,'min')) then 60 else (if (ends-with($string,'h')) then 3600 else 1)))"/>
        <xsl:value-of select="$number"/>
    </xsl:function>

    <xsl:function name="px:secondsToTimecount" as="xs:string">
        <xsl:param name="number" as="xs:double"/>
        <xsl:value-of select="concat(string($number),'s')"/>
    </xsl:function>

    <xsl:function name="px:secondsToFullClockVal" as="xs:string">
        <xsl:param name="number" as="xs:double"/>
        <xsl:variable name="HH"
            select="concat(if (($number div 3600) &lt; 10) then '0' else '', string(floor($number div 3600)))"/>
        <xsl:variable name="MM"
            select="concat(if ((($number mod 3600) div 60) &lt; 10) then '0' else '', string(floor(($number mod 3600) div 60)))"/>
        <xsl:variable name="SS"
            select="concat(if (($number mod 60) &lt; 10) then '0' else '', string($number mod 60))"/>
        <xsl:value-of select="concat($HH,':',$MM,':',$SS)"/>
    </xsl:function>

</xsl:stylesheet>
