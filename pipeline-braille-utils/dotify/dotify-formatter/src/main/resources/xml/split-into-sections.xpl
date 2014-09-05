<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step type="pxi:split-into-sections"
                xmlns:p="http://www.w3.org/ns/xproc"
                xmlns:px="http://www.daisy.org/ns/pipeline/xproc"
                xmlns:pxi="http://www.daisy.org/ns/pipeline/xproc/internal"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns:css="http://www.daisy.org/ns/pipeline/braille-css"
                xmlns:obfl="http://www.daisy.org/ns/2011/obfl"
                exclude-inline-prefixes="p px pxi xsl"
                version="1.0">
	
	<p:input port="source"/>
	<p:output port="result" sequence="true"/>
	
	<p:import href="http://www.daisy.org/pipeline/modules/braille/common-utils/library.xpl"/>
	
	<p:xslt>
		<p:input port="stylesheet">
			<p:inline>
				<xsl:stylesheet version="2.0">
					<xsl:include href="http://www.daisy.org/pipeline/modules/braille/css-utils/library.xsl"/>
					<xsl:template match="@*|node()">
						<xsl:copy>
							<xsl:apply-templates select="@*|node()"/>
						</xsl:copy>
					</xsl:template>
					<xsl:template match="@css:counter-reset">
						<xsl:variable name="pairs" as="element()*" select="css:parse-counter-reset(.)"/>
						<xsl:if test="$pairs[@identifier!='braille-page']">
							<xsl:attribute name="css:counter-reset"
							  select="string-join(for $p in $pairs[@identifier!='braille-page'] return
							                      concat($p/@identifier,' ',$p/@value), ' ')"/>
						</xsl:if>
						<xsl:if test="$pairs[@identifier='braille-page']">
							<xsl:attribute name="obfl:initial-page-number"
							               select="$pairs[@identifier='braille-page'][last()]/@value"/>
						</xsl:if>
					</xsl:template>
				</xsl:stylesheet>
			</p:inline>
		</p:input>
		<p:input port="parameters">
			<p:empty/>
		</p:input>
	</p:xslt>
	
	<px:split-into-sections split-before="*[parent::* and (@css:page or @obfl:initial-page-number)]"
	                        split-after="*[parent::* and @css:page]"/>
	
	<p:for-each>
		<p:choose>
			<p:when test="/*//*/@css:page">
				<p:add-attribute match="/*" attribute-name="css:page">
					<p:with-option name="attribute-value" select="(//*/@css:page)[last()]"/>
				</p:add-attribute>
				<p:delete match="/*//*/@css:page"/>
			</p:when>
			<p:otherwise>
				<p:identity/>
			</p:otherwise>
		</p:choose>
		<p:choose>
			<p:when test="//*[not(@part=('middle','last'))]/@obfl:initial-page-number">
				<p:add-attribute match="/*" attribute-name="obfl:initial-page-number">
					<p:with-option name="attribute-value"
					  select="(//*[not(@part=('middle','last'))]/@obfl:initial-page-number)[last()]"/>
				</p:add-attribute>
				<p:delete match="/*//*/@obfl:initial-page-number"/>
			</p:when>
			<p:otherwise>
				<p:delete match="@obfl:initial-page-number"/>
			</p:otherwise>
		</p:choose>
		<p:delete match="*[@part=('middle','last')]/@css:counter-reset|
		                 *[@part=('middle','last')]/@css:string-set"/>
	</p:for-each>
	
</p:declare-step>
