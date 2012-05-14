<?xml version="1.0" encoding="UTF-8"?>

<xsl:stylesheet version="2.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:xs="http://www.w3.org/2001/XMLSchema"
	xmlns:z="http://www.daisy.org/ns/z3998/authoring/"
	xmlns:brl="http://www.daisy.org/ns/pipeline/braille">
	
	<xsl:output method="xml" encoding="utf-8" indent="yes" />

	<xsl:template match="node()|@*">
		<xsl:copy>
			<xsl:apply-templates select="@*|node()" />
		</xsl:copy>
	</xsl:template>
	
	<xsl:template match="z:head|
						 z:object[contains(string(@srctype), 'image')]">
		<xsl:copy>
			<xsl:attribute name="brl:style" select="'display:none'"/>
			<xsl:apply-templates select="@*|node()" />
		</xsl:copy>
	</xsl:template>
	
	<xsl:template match="z:section|
						 z:toc|
		                 z:frontmatter">
		<xsl:copy>
			<xsl:attribute name="brl:style" select="'display:block;
				                                     page-break-after:always;
				                                     page-break-before:always'"/>
			<xsl:apply-templates select="@*|node()" />
		</xsl:copy>
	</xsl:template>
	
	<xsl:template match="z:h">
		<xsl:copy>
			<xsl:attribute name="brl:style" select="'display:block;
				                                     text-align:center;
													 margin-top:1;
													 margin-bottom:1;
													 border-top:⠒;
													 border-bottom:⠒;
													 page-break-after:avoid'"/>
			<xsl:apply-templates select="@*|node()" />
		</xsl:copy>
	</xsl:template>
	
	<xsl:template match="z:p">
		<xsl:copy>
			<xsl:attribute name="brl:style" select="'display:block;
					                                 text-indent:2'"/>
			<xsl:apply-templates select="@*|node()" />
		</xsl:copy>
	</xsl:template>
	
	<xsl:template match="z:verse[@role='poem']">
		<xsl:copy>
			<xsl:attribute name="brl:style" select="'display:block;
				                                     margin-left:4'"/>
			<xsl:apply-templates select="@*|node()" />
		</xsl:copy>
	</xsl:template>
	
	<xsl:template match="z:block|
						 z:lngroup|
						 z:ln|
						 z:toc/z:entry|
						 z:object|
						 z:verse">
		<xsl:copy>
			<xsl:attribute name="brl:style" select="'display:block'"/>
			<xsl:apply-templates select="@*|node()" />
		</xsl:copy>
	</xsl:template>

</xsl:stylesheet>
