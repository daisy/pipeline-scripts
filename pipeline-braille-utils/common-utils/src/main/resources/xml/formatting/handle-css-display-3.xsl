<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns:css="http://www.daisy.org/ns/pipeline/braille-css"
                exclude-result-prefixes="#all"
                version="2.0">
	
	<xsl:template match="@*|node()">
		<xsl:copy>
			<xsl:apply-templates select="@*|node()"/>
		</xsl:copy>
	</xsl:template>
	
	<xsl:template match="css:temp"/>
	
	<xsl:template match="*[not(self::css:block)]/@css:string-set"/>
	
	<xsl:template match="css:block|css:inline">
		<xsl:variable name="count" select="count(following::css:block|following::css:inline|
		                                         descendant::css:block|descendant::css:inline)"/>
		<xsl:variable name="pending" as="element()*"
		              select="//*[not(self::css:block|self::css:inline)]
		                         [count(following::css:block|following::css:inline|
		                                descendant::css:block|descendant::css:inline)=$count+1]"/>
		<xsl:variable name="pending-string-set" as="xs:string*" select="$pending/@css:string-set/string()"/>
		<xsl:variable name="pending-counter-reset" as="xs:string*" select="$pending/@css:counter-reset/string()"/>
		<xsl:choose>
			<xsl:when test="exists($pending-string-set) or exists($pending-counter-reset)">
				<xsl:copy>
					<xsl:apply-templates select="@*"/>
					<xsl:if test="exists($pending-string-set)">
						<xsl:attribute name="css:string-set"
						               select="string-join(($pending-string-set, @css:string-set/string()), ', ')"/>
					</xsl:if>
					<xsl:if test="exists($pending-counter-reset)">
						<xsl:attribute name="css:counter-reset"
						               select="string-join(($pending-counter-reset, @css:counter-reset/string()), ' ')"/>
					</xsl:if>
					<xsl:apply-templates select="node()"/>
				</xsl:copy>
			</xsl:when>
			<xsl:otherwise>
				<xsl:next-match/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	
</xsl:stylesheet>
