<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step type="pxi:uppercase" version="1.0"
                xmlns:p="http://www.w3.org/ns/xproc"
                xmlns:pxi="http://www.daisy.org/ns/pipeline/xproc/internal"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
	<p:input port="source"/>
	<p:output port="result"/>
	<p:xslt>
		<p:input port="stylesheet">
			<p:inline>
				<xsl:stylesheet version="2.0">
					<xsl:template match="*">
						<xsl:copy>
							<xsl:sequence select="@*"/>
							<xsl:apply-templates/>
						</xsl:copy>
					</xsl:template>
					<xsl:template match="text()">
						<xsl:value-of select="upper-case(.)"/>
					</xsl:template>
				</xsl:stylesheet>
			</p:inline>
		</p:input>
		<p:input port="parameters">
			<p:empty/>
		</p:input>
	</p:xslt>
</p:declare-step>
