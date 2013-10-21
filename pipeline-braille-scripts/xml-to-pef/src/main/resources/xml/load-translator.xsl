<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:xs="http://www.w3.org/2001/XMLSchema"
	xmlns:louis="http://liblouis.org/liblouis"
	xmlns:hyphen="http://hunspell.sourceforge.net/Hyphen"
	xmlns:tex="http://code.google.com/p/texhyphj/"
	xmlns:pxi="http://www.daisy.org/ns/pipeline/xproc/internal"
	xmlns:d="http://www.daisy.org/ns/pipeline/data"
	xmlns:p="http://www.w3.org/ns/xproc"
	exclude-result-prefixes="#all">
	
	<xsl:import href="http://www.daisy.org/pipeline/modules/braille/liblouis-utils/library.xsl"/>
	<xsl:import href="http://www.daisy.org/pipeline/modules/braille/libhyphen-utils/library.xsl"/>
	<xsl:import href="http://www.daisy.org/pipeline/modules/braille/texhyph-utils/library.xsl"/>
	
	<xsl:param name="translator" as="xs:string"/>
	
	<xsl:variable name="registered-translators">
		<resource-paths>
			<resource-path id="http://www.daisy.org/pipeline/modules/braille/xml-to-pef/translation/">
				<resource>normalize-space.xsl</resource>
				<resource>generic-liblouis-translate.xsl</resource>
				<resource>generic-liblouis-translate-and-hyphenate.xsl</resource>
				<resource>generic-liblouis-translate-with-emphasis.xsl</resource>
				<resource>generic-libhyphen-hyphenate.xsl</resource>
				<resource>generic-tex-hyphenate.xsl</resource>
				<resource>generic-dotify-translate.xsl</resource>
				<resource>generic-translate.xpl</resource>
				<resource>generic-liblouis-translate-mathml.xpl</resource>
			</resource-path>
		</resource-paths>
	</xsl:variable>
	
	<xsl:function name="pxi:resolve-xml-translator" as="xs:string?">
		<xsl:param name="resource" as="xs:string"/>
		<xsl:choose>
			<xsl:when test="matches($resource, '^file:/.*')">
				<xsl:if test="doc-available($resource)">
					<xsl:if test="not(doc($resource)/*[self::p:pipeline or self::xsl:stylesheet])">
						<xsl:message terminate="yes">
							<xsl:text>Document is not a &lt;xsl:stylesheet&gt; or a &lt;p:pipeline&gt;.</xsl:text>
						</xsl:message>
					</xsl:if>
					<xsl:sequence select="$resource"/>
				</xsl:if>
			</xsl:when>
			<xsl:otherwise>
				<xsl:sequence select="
					(for $resource-path in $registered-translators/resource-paths/resource-path return
						(for $id in ($resource-path/@id/string()) return
							(for $resolved-uri in (resolve-uri($resource, $id)) return
								$resource-path/resource/concat($id, string(.))[.=$resolved-uri])))[1]"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:function>
	
	<xsl:function name="pxi:resolve-translator" as="element()?">
		<xsl:param name="resource" as="xs:string"/>
		<xsl:variable name="xml-translator" select="pxi:resolve-xml-translator($resource)"/>
		<xsl:choose>
			<xsl:when test="$xml-translator">
				<d:translator kind="xml" href="{$xml-translator}"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:choose>
					<xsl:when test="louis:resolve-table($resource)">
						<d:translator kind="liblouis" href="{$resource}"/>
					</xsl:when>
					<xsl:otherwise>
						<xsl:choose>
							<xsl:when test="hyphen:resolve-table($resource)">
								<d:translator kind="libhyphen" href="{$resource}"/>
							</xsl:when>
							<xsl:otherwise>
								<xsl:if test="tex:resolve-table($resource)">
									<d:translator kind="texhyph" href="{$resource}"/>
								</xsl:if>
							</xsl:otherwise>
						</xsl:choose>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:function>
	
	<xsl:function name="pxi:resolve-translators">
		<xsl:param name="translators" as="xs:string*"/>
		<xsl:param name="previous-match" as="element()?"/>
		<xsl:choose>
			<xsl:when test="not(exists($translators))">
				<xsl:sequence select="$previous-match"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:variable name="match" as="element()?" select="pxi:resolve-translator(string-join(($previous-match/@href, $translators[1]), ','))"/>
				<xsl:choose>
					<xsl:when test="$match">
						<xsl:sequence select="pxi:resolve-translators($translators[position() > 1], $match)"/>
					</xsl:when>
					<xsl:otherwise>
						<xsl:if test="not($previous-match)">
							<xsl:message terminate="yes">
								<xsl:text>Could not be resolved.</xsl:text>
							</xsl:message>
						</xsl:if>
						<xsl:sequence select="$previous-match"/>
						<xsl:sequence select="pxi:resolve-translators($translators, ())"/>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:function>
	
	<xsl:template name="main">
		<d:translators>
			<xsl:sequence select="pxi:resolve-translators(tokenize($translator, ','), ())"/>
		</d:translators>
	</xsl:template>
	
</xsl:stylesheet>
