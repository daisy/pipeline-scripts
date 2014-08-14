<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:xs="http://www.w3.org/2001/XMLSchema"
	xmlns:css="http://www.daisy.org/ns/pipeline/braille-css"
	xmlns:pxi="http://www.daisy.org/ns/pipeline/xproc/internal"
	exclude-result-prefixes="#all">
	
	<!--
	    css-utils [2.0.0,3.0.0)
	-->
	<xsl:import href="http://www.daisy.org/pipeline/modules/braille/css-utils/library.xsl"/>
	
	<xsl:template match="css:block" mode="#default after before string-set">
		<xsl:apply-templates select="node()" mode="#current"/>
	</xsl:template>
	
	<xsl:template match="@*|node()" mode="#default after before string-set">
		<xsl:copy>
			<xsl:apply-templates select="@*|node()" mode="#current"/>
		</xsl:copy>
	</xsl:template>
	
	<xsl:template match="/*">
		<xsl:apply-templates select="." mode="identify-blocks"/>
	</xsl:template>
	
	<xsl:variable name="inline-properties" as="xs:string*"
	              select="$css:properties[not(.='display') and css:applies-to(., 'inline')]"/>
	
	<xsl:template match="*" mode="identify-blocks">
		<xsl:param name="is-block" as="xs:boolean" select="true()" tunnel="yes"/>
		<xsl:param name="has-string-set" as="xs:boolean" select="true()" tunnel="yes"/>
		<xsl:param name="display" as="xs:string" select="'block'" tunnel="yes"/>
		<xsl:variable name="is-block" as="xs:boolean" select="$is-block and pxi:is-block(.)"/>
		<xsl:variable name="has-string-set" as="xs:boolean" select="$has-string-set and pxi:has-string-set(.)"/>
		<xsl:variable name="display" as="xs:string" select="if ($display='none') then 'none' else pxi:display(.)"/>
		<xsl:variable name="translated-rules" as="element()*">
			<xsl:apply-templates select="css:parse-stylesheet(@style)" mode="translate-rule-list">
				<xsl:with-param name="context" select="." tunnel="yes"/>
			</xsl:apply-templates>
		</xsl:variable>
		<xsl:copy>
			<xsl:sequence select="@* except @style"/>
			<xsl:sequence select="css:style-attribute(css:serialize-stylesheet($translated-rules))"/>
			<xsl:choose>
				<xsl:when test="$display='none'">
					<xsl:if test="$has-string-set">
						<xsl:apply-templates select="*" mode="#current">
							<xsl:with-param name="is-block" select="$is-block" tunnel="yes"/>
							<xsl:with-param name="has-string-set" select="$has-string-set" tunnel="yes"/>
							<xsl:with-param name="display" select="$display" tunnel="yes"/>
						</xsl:apply-templates>
					</xsl:if>
				</xsl:when>
				<xsl:otherwise>
					<xsl:variable name="this" as="element()" select="."/>
					<xsl:variable name="lang" as="xs:string?" select="pxi:lang(.)"/>
					<xsl:variable name="space" as="xs:string?" select="pxi:space(.)"/>
					<xsl:for-each-group select="*|text()" group-adjacent="($is-block and pxi:is-block(.))
					                                                      or ($has-string-set and pxi:has-string-set(.))">
						<xsl:choose>
							<xsl:when test="current-grouping-key()">
								<xsl:for-each select="current-group()">
									<xsl:apply-templates select="." mode="#current">
										<xsl:with-param name="is-block" select="$is-block" tunnel="yes"/>
										<xsl:with-param name="has-string-set" select="$has-string-set" tunnel="yes"/>
										<xsl:with-param name="display" select="$display" tunnel="yes"/>
									</xsl:apply-templates>
								</xsl:for-each>
							</xsl:when>
							<xsl:when test="normalize-space(string-join(current-group()/string(.), ''))=''"/>
							<xsl:otherwise>
								<xsl:variable name="block">
									<xsl:element name="css:block">
										<xsl:if test="$lang">
											<xsl:attribute name="xml:lang" select="$lang"/>
										</xsl:if>
										<xsl:if test="$space">
											<xsl:attribute name="xml:space" select="$space"/>
										</xsl:if>
										<xsl:sequence select="css:style-attribute(css:serialize-declaration-list(
										                        css:specified-properties($inline-properties, true(), false(), false(), $this)
										                        [not(@value='initial')]))"/>
										<xsl:for-each select="current-group()">
											<xsl:sequence select="."/>
										</xsl:for-each>
									</xsl:element>
								</xsl:variable>
								<xsl:apply-templates select="$block/css:block">
									<xsl:with-param name="context" select="$this"/>
								</xsl:apply-templates>
							</xsl:otherwise>
						</xsl:choose>
					</xsl:for-each-group>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:copy>
	</xsl:template>
	
	<xsl:template match="@*|text()" mode="identify-blocks">
		<xsl:copy/>
	</xsl:template>
	
	<xsl:template match="css:rule|css:property|
	                     css:content-fn|css:string-fn|css:counter-fn|
	                     css:target-text-fn|css:target-string-fn|css:target-counter-fn|css:leader-fn"
	              mode="translate-rule-list translate-declaration-list translate-content-list">
		<xsl:sequence select="."/>
	</xsl:template>
	
	<xsl:template match="css:rule[not(@selector) or @selector=('::before', '::after')]" mode="translate-rule-list">
		<xsl:variable name="properties" as="element()*" select="css:parse-declaration-list(@declaration-list)"/>
		<xsl:choose>
			<xsl:when test="(not(@selector) and $properties[@name='string-set'])
			                or (@selector=('::before', '::after') and $properties[@name='content'])">
				<xsl:variable name="translated-properties" as="element()*">
					<xsl:apply-templates select="$properties" mode="translate-declaration-list">
						<xsl:with-param name="mode" tunnel="yes"
						                select="if (@selector='::before') then 'before'
						                        else if (@selector='::after') then 'after'
						                        else 'string-set'"/>
					</xsl:apply-templates>
				</xsl:variable>
				<xsl:copy>
					<xsl:sequence select="@selector"/>
					<xsl:attribute name="declaration-list" select="css:serialize-declaration-list($translated-properties)"/>
				</xsl:copy>
			</xsl:when>
			<xsl:otherwise>
				<xsl:next-match/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	
	<xsl:template match="css:rule[not(@selector)]" mode="translate-rule-list" priority="0.6">
		<xsl:param name="has-string-set" as="xs:boolean" tunnel="yes"/>
		<xsl:choose>
			<xsl:when test="$has-string-set">
				<xsl:next-match/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:sequence select="."/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	
	<xsl:template match="css:property[@name='string-set']" mode="translate-declaration-list">
		<xsl:param name="context" as="element()" tunnel="yes"/>
		<xsl:variable name="translated-value" as="xs:string*">
			<xsl:for-each select="tokenize(@value, ',')">
				<xsl:variable name="identifier" as="xs:string" select="replace(., '^\s*(\S+)\s.*$', '$1')"/>
				<xsl:variable name="content-list" as="xs:string" select="substring-after(., $identifier)"/>
				<xsl:if test="matches($identifier, $css:IDENT_RE)">
					<xsl:variable name="translated-content-list" as="element()*">
						<xsl:apply-templates select="css:parse-content-list($content-list, $context)" mode="translate-content-list">
							<xsl:with-param name="string-name" select="$identifier" tunnel="yes"/>
						</xsl:apply-templates>
					</xsl:variable>
					<xsl:sequence select="concat($identifier, ' ', if (exists($translated-content-list))
					                                               then css:serialize-content-list($translated-content-list)
					                                               else '&quot;&quot;')"/>
				</xsl:if>
			</xsl:for-each>
		</xsl:variable>
		<xsl:sequence select="css:property('string-set', string-join($translated-value, ', '))"/>
	</xsl:template>
	
	<xsl:template match="css:property[@name='content']" mode="translate-declaration-list">
		<xsl:param name="context" as="element()" tunnel="yes"/>
		<xsl:variable name="translated-content-list" as="element()">
			<xsl:apply-templates select="css:parse-content-list(@value, $context)" mode="translate-content-list"/>
		</xsl:variable>
		<xsl:sequence select="css:property('content', if (exists($translated-content-list))
					                                  then css:serialize-content-list($translated-content-list)
					                                  else '&quot;&quot;')"/>
	</xsl:template>
	
	<xsl:template match="css:string|css:attr-fn" mode="translate-content-list" as="element()?">
		<xsl:param name="context" as="element()" tunnel="yes"/>
		<xsl:param name="mode" as="xs:string" tunnel="yes"/>
		<xsl:variable name="evaluated-string" as="xs:string">
			<xsl:apply-templates select="." mode="css:eval"/>
		</xsl:variable>
		<xsl:variable name="lang" as="xs:string?" select="pxi:lang($context)"/>
		<xsl:variable name="space" as="xs:string?" select="pxi:space($context)"/>
		<xsl:variable name="block">
			<xsl:element name="css:block">
				<xsl:if test="$lang">
					<xsl:attribute name="xml:lang" select="$lang"/>
				</xsl:if>
				<xsl:if test="$space">
					<xsl:attribute name="xml:space" select="$space"/>
				</xsl:if>
				<xsl:value-of select="$evaluated-string"/>
			</xsl:element>
		</xsl:variable>
		<xsl:variable name="translated-block">
			<xsl:choose>
				<xsl:when test="$mode='string-set'">
					<xsl:apply-templates select="$block/css:block" mode="string-set"/>
				</xsl:when>
				<xsl:when test="$mode='before'">
					<xsl:apply-templates select="$block/css:block" mode="before"/>
				</xsl:when>
				<xsl:when test="$mode='after'">
					<xsl:apply-templates select="$block/css:block" mode="after"/>
				</xsl:when>
			</xsl:choose>
		</xsl:variable>
		<css:string value="{normalize-space(string($translated-block))}"/>
	</xsl:template>
	
	<xsl:function name="pxi:lang" as="xs:string?">
		<xsl:param name="element" as="element()"/>
		<xsl:sequence select="$element/ancestor-or-self::*[@xml:lang][1]/@xml:lang"/>
	</xsl:function>
	
	<xsl:function name="pxi:space" as="xs:string?">
		<xsl:param name="element" as="element()"/>
		<xsl:sequence select="$element/ancestor-or-self::*[@xml:space][1]/@xml:space"/>
	</xsl:function>
	
	<xsl:function name="pxi:display" as="xs:string">
		<xsl:param name="element" as="element()"/>
		<xsl:sequence select="css:specified-properties('display', true(), true(), false(), $element)/@value"/>
	</xsl:function>
	
	<xsl:function name="pxi:string-set" as="xs:string">
		<xsl:param name="element" as="element()"/>
		<xsl:sequence select="css:specified-properties('string-set', true(), true(), false(), $element)/@value"/>
	</xsl:function>
	
	<xsl:function name="pxi:is-block" as="xs:boolean">
		<xsl:param name="node" as="node()"/>
		<xsl:sequence select="boolean($node/descendant-or-self::*[pxi:display(.) != 'inline'])"/>
	</xsl:function>
	
	<xsl:function name="pxi:has-string-set" as="xs:boolean">
		<xsl:param name="node" as="node()"/>
		<xsl:sequence select="boolean($node/descendant-or-self::*[pxi:string-set(.) != 'none'])"/>
	</xsl:function>
	
</xsl:stylesheet>
