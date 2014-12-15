<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:d="http://www.daisy.org/ns/pipeline/data"
                xmlns:pf="http://www.daisy.org/ns/pipeline/functions"
                xmlns:opf="http://www.idpf.org/2007/opf"
                version="2.0">
	
	<xsl:include href="http://www.daisy.org/pipeline/modules/file-utils/uri-functions.xsl"/>
	
	<xsl:param name="braille-rendition.package-document.base"/>
	
	<xsl:variable name="default-rendition.package-document" select="collection()[1]"/>
	<xsl:variable name="braille-rendition.fileset" select="collection()[2]"/>
	
	<xsl:template match="/*">
		<xsl:copy>
			<xsl:attribute name="xml:base" select="$braille-rendition.package-document.base"/>
			<xsl:apply-templates select="(@* except @xml:base)|node()"/>
		</xsl:copy>
	</xsl:template>
	
	<xsl:template match="@*|node()">
		<xsl:copy>
			<xsl:apply-templates select="@*|node()"/>
		</xsl:copy>
	</xsl:template>
	
	<xsl:template match="opf:manifest/opf:item">
		<xsl:variable name="original-href" select="resolve-uri(@href,base-uri(.))"/>
		<xsl:copy>
			<xsl:attribute name="href"
			               select="pf:relativize-uri(
			                         $braille-rendition.fileset//d:file[resolve-uri(@original-href,base-uri(.))=$original-href]
			                                                    /resolve-uri(@href,base-uri(.)),
			                         $braille-rendition.package-document.base)"/>
			<xsl:sequence select="@* except @href"/>
		</xsl:copy>
	</xsl:template>
	
</xsl:stylesheet>
