<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns:regex="regex-utils"
                version="2.0">
	
	<xsl:function name="regex:join" as="xs:string">
		<xsl:param name="regexps" as="xs:string*"/>
		<xsl:param name="separator" as="xs:string"/>
		<xsl:sequence select="string-join($regexps, $separator)"/>
	</xsl:function>
	
	<xsl:function name="regex:concat" as="xs:string">
		<xsl:param name="regexps" as="xs:string*"/>
		<xsl:sequence select="regex:join($regexps, '')"/>
	</xsl:function>
	
	<xsl:function name="regex:or" as="xs:string">
		<xsl:param name="regexps" as="xs:string*"/>
		<xsl:choose>
			<xsl:when test="$regexps[1]">
				<xsl:sequence select="concat('(', regex:join($regexps, '|'), ')')"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:sequence select="''"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:function>
	
	<xsl:function name="regex:exact" as="xs:string">
		<xsl:param name="regex" as="xs:string"/>
		<xsl:sequence select="concat('^', $regex, '$')"/>
	</xsl:function>
	
	<xsl:function name="regex:space-separated" as="xs:string">
		<xsl:param name="regex" as="xs:string"/>
		<xsl:sequence select="regex:join(($regex,'(\s+',$regex,')*'), '')"/>
	</xsl:function>
	
	<xsl:function name="regex:comma-separated" as="xs:string">
		<xsl:param name="regex" as="xs:string"/>
		<xsl:sequence select="regex:join(($regex,'(\s*,\s*',$regex,')*'), '')"/>
	</xsl:function>
	
</xsl:stylesheet>
