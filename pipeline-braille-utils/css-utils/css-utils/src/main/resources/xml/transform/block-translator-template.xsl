<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns:css="http://www.daisy.org/ns/pipeline/braille-css"
                xmlns:pxi="http://www.daisy.org/ns/pipeline/xproc/internal"
                exclude-result-prefixes="#all">
	
	<xsl:import href="../library.xsl"/>
	
	<!--
	    API: implement xsl:template match="css:block"
	-->
	<xsl:template match="css:block" mode="#default after before">
		<xsl:message terminate="yes">Coding error</xsl:message>
	</xsl:template>
	
	<xsl:template match="/*">
		<xsl:apply-templates select="." mode="identify-blocks"/>
	</xsl:template>
	
	<xsl:variable name="inline-properties" as="xs:string*"
	              select="$css:properties[not(.='display') and css:applies-to(., 'inline')]"/>
	
	<xsl:template match="*" mode="identify-blocks">
		<xsl:param name="is-block" as="xs:boolean" select="true()" tunnel="yes"/>
		<xsl:param name="display" as="xs:string" select="'block'" tunnel="yes"/>
		<xsl:variable name="is-block" as="xs:boolean" select="$is-block and pxi:is-block(.)"/>
		<xsl:variable name="display" as="xs:string" select="if ($display='none') then 'none' else pxi:display(.)"/>
		<xsl:variable name="rules" as="element()*" select="css:parse-stylesheet(@style)"/>
		<xsl:variable name="rules" as="element()*"
		              select="if (parent::* or $rules[not(@selector)]) then $rules
		                      else ($rules,css:parse-stylesheet('text-transform:auto'))"/>
		<xsl:variable name="translated-rules" as="element()*">
			<xsl:apply-templates select="$rules" mode="translate-rule-list">
				<xsl:with-param name="context" select="." tunnel="yes"/>
			</xsl:apply-templates>
		</xsl:variable>
		<xsl:copy>
			<xsl:sequence select="@* except @style"/>
			<xsl:sequence select="css:style-attribute(css:serialize-stylesheet($translated-rules))"/>
			<xsl:choose>
				<xsl:when test="$display='none'">
					<xsl:apply-templates select="*" mode="#current">
						<xsl:with-param name="is-block" select="$is-block" tunnel="yes"/>
						<xsl:with-param name="display" select="$display" tunnel="yes"/>
					</xsl:apply-templates>
				</xsl:when>
				<xsl:otherwise>
					<xsl:variable name="context" as="element()" select="."/>
					<xsl:variable name="lang" as="xs:string?" select="pxi:lang(.)"/>
					<xsl:variable name="space" as="xs:string?" select="pxi:space(.)"/>
					<xsl:for-each-group select="*|text()" group-adjacent="$is-block and pxi:is-block(.)">
						<xsl:choose>
							<xsl:when test="current-grouping-key()">
								<xsl:for-each select="current-group()">
									<xsl:apply-templates select="." mode="#current">
										<xsl:with-param name="is-block" select="$is-block" tunnel="yes"/>
										<xsl:with-param name="display" select="$display" tunnel="yes"/>
									</xsl:apply-templates>
								</xsl:for-each>
							</xsl:when>
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
										                        css:computed-properties($inline-properties, false(), $context)
										                        [not(@value=css:initial-value(@name))]))"/>
										<xsl:for-each select="current-group()">
											<xsl:sequence select="."/>
										</xsl:for-each>
									</xsl:element>
								</xsl:variable>
								<xsl:apply-templates select="$block/css:block">
									<xsl:with-param name="context" select="$context"/>
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
	
	<xsl:template match="css:rule|css:property|css:content|css:string[@name]|css:counter|css:text|css:leader"
	              mode="translate-rule-list translate-declaration-list translate-content-list">
		<xsl:sequence select="."/>
	</xsl:template>
	
	<xsl:template match="css:rule[not(@selector) or @selector=('::before', '::after')]" mode="translate-rule-list">
		<xsl:param name="context" as="element()" tunnel="yes"/>
		<xsl:variable name="properties" as="element()*" select="css:parse-declaration-list(@style)"/>
		<xsl:variable name="properties" as="element()*" select="if (@selector or $context/parent::* or $properties[@name='text-transform'])
		                                                        then $properties
		                                                        else ($properties,css:property('text-transform','auto'))"/>
		<xsl:variable name="translated-properties" as="element()*">
			<xsl:apply-templates select="$properties" mode="translate-declaration-list">
				<xsl:with-param name="mode" tunnel="yes"
				                select="if (@selector='::before') then 'before'
				                        else if (@selector='::after') then 'after'
				                        else '#default'"/>
			</xsl:apply-templates>
		</xsl:variable>
		<xsl:if test="$translated-properties">
			<xsl:copy>
				<xsl:sequence select="@selector"/>
				<xsl:attribute name="style" select="css:serialize-declaration-list($translated-properties)"/>
			</xsl:copy>
		</xsl:if>
	</xsl:template>
	
	<xsl:template match="css:property[@name='text-transform']" mode="translate-declaration-list">
		<css:property name="text-transform" value="none"/>
	</xsl:template>
	
	<xsl:template match="css:property[@name='string-set']" mode="translate-declaration-list">
		<xsl:if test="@value!='none'">
			<xsl:variable name="evaluated-string-set-pairs" as="element()*">
				<xsl:apply-templates select="css:parse-string-set(@value)" mode="eval-string-set-pair"/>
			</xsl:variable>
			<xsl:copy>
				<xsl:sequence select="@name"/>
				<xsl:attribute name="value" select="css:serialize-string-set($evaluated-string-set-pairs)"/>
			</xsl:copy>
		</xsl:if>
	</xsl:template>
	
	<xsl:template match="css:string-set" mode="eval-string-set-pair" as="element()">
		<xsl:param name="context" as="element()" tunnel="yes"/>
		<xsl:copy>
			<xsl:sequence select="@name"/>
			<xsl:variable name="evaluated-content-list" as="element()*">
				<xsl:apply-templates select="css:parse-content-list(@value, $context)" mode="eval-string-set-content-list">
					<xsl:with-param name="string-name" select="@name" tunnel="yes"/>
				</xsl:apply-templates>
			</xsl:variable>
			<xsl:attribute name="value" select="if (exists($evaluated-content-list))
			                                    then css:serialize-content-list($evaluated-content-list)
			                                    else '&quot;&quot;'"/>
		</xsl:copy>
	</xsl:template>
	
	<xsl:template match="css:string[@value]|css:attr|css:content" mode="eval-string-set-content-list" as="element()?">
		<xsl:variable name="evaluated-string" as="xs:string?">
			<xsl:apply-templates select="." mode="css:eval"/>
		</xsl:variable>
		<xsl:if test="exists($evaluated-string)">
			<css:string value="{$evaluated-string}"/>
		</xsl:if>
	</xsl:template>
	
	<xsl:template match="css:string[@name][not(@target)]" mode="eval-string-set-content-list">
		<xsl:message>string() function not supported in string-set property</xsl:message>
	</xsl:template>
	
	<xsl:template match="css:counter[not(@target)]" mode="eval-string-set-content-list">
		<xsl:message>counter() function not supported in string-set property</xsl:message>
	</xsl:template>
	
	<xsl:template match="css:text[@target]" mode="eval-string-set-content-list">
		<xsl:message>target-text() function not supported in string-set property</xsl:message>
	</xsl:template>
	
	<xsl:template match="css:string[@name][@target]" mode="eval-string-set-content-list">
		<xsl:message>target-string() function not supported in string-set property</xsl:message>
	</xsl:template>
	
	<xsl:template match="css:counter[@target]" mode="eval-string-set-content-list">
		<xsl:message>target-counter() function not supported in string-set property</xsl:message>
	</xsl:template>
	
	<xsl:template match="css:leader" mode="eval-string-set-content-list">
		<xsl:message>leader() function not supported in string-set property</xsl:message>
	</xsl:template>
	
	<xsl:template match="css:property[@name='content']" mode="translate-declaration-list">
		<xsl:param name="context" as="element()" tunnel="yes"/>
		<xsl:variable name="translated-content-list" as="element()*">
			<xsl:apply-templates select="css:parse-content-list(@value, $context)" mode="translate-content-list"/>
		</xsl:variable>
		<xsl:sequence select="css:property('content', if (exists($translated-content-list))
					                                  then css:serialize-content-list($translated-content-list)
					                                  else '&quot;&quot;')"/>
	</xsl:template>
	
	<xsl:template match="css:string[@value]|css:attr" mode="translate-content-list" as="element()?">
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
				<xsl:sequence select="css:style-attribute(css:serialize-declaration-list(
				                        css:computed-properties($inline-properties, true(), true(), false(), $context)
				                        [not(@value=css:initial-value(@name))]))"/>
				<xsl:element name="css:block">
					<xsl:sequence select="css:style-attribute(
					                        css:serialize-declaration-list(
					                          css:parse-declaration-list(
					                            css:parse-stylesheet($context/@style)
					                              /self::css:rule[@selector=concat('::',$mode)][last()]/@style)
					                            [@name=$inline-properties
					                             and not(@name='content')
					                             and not(@value=css:initial-value(@name))]))"/>
					<xsl:value-of select="$evaluated-string"/>
				</xsl:element>
			</xsl:element>
		</xsl:variable>
		<xsl:variable name="translated-block" as="node()*">
			<xsl:choose>
				<xsl:when test="$mode='before'">
					<xsl:apply-templates select="$block/css:block/css:block" mode="before"/>
				</xsl:when>
				<xsl:when test="$mode='after'">
					<xsl:apply-templates select="$block/css:block/css:block" mode="after"/>
				</xsl:when>
			</xsl:choose>
		</xsl:variable>
		<css:string value="{string-join($translated-block/string(.),'')}"/>
	</xsl:template>
	
	<xsl:template match="*" mode="treewalk">
		<xsl:param name="new-text-nodes" as="xs:string*" required="yes"/>
		<xsl:variable name="text-node-count" select="count(.//text())"/>
		<xsl:copy>
			<xsl:sequence select="@* except @style"/>
			<xsl:if test="@style">
				<xsl:variable name="translated-rules" as="element()*">
					<xsl:apply-templates select="css:parse-stylesheet(@style)" mode="translate-rule-list">
						<xsl:with-param name="context" select="." tunnel="yes"/>
					</xsl:apply-templates>
				</xsl:variable>
				<xsl:sequence select="css:style-attribute(css:serialize-stylesheet($translated-rules))"/>
			</xsl:if>
			<xsl:apply-templates select="child::node()[1]" mode="#current">
				<xsl:with-param name="new-text-nodes" select="$new-text-nodes[position()&lt;=$text-node-count]"/>
			</xsl:apply-templates>
		</xsl:copy>
		<xsl:apply-templates select="following-sibling::node()[1]" mode="#current">
			<xsl:with-param name="new-text-nodes" select="$new-text-nodes[position()&gt;$text-node-count]"/>
		</xsl:apply-templates>
	</xsl:template>
	
	<xsl:template match="text()" mode="treewalk">
		<xsl:param name="new-text-nodes" as="xs:string*" required="yes"/>
		<xsl:value-of select="$new-text-nodes[1]"/>
		<xsl:apply-templates select="following-sibling::node()[1]" mode="#current">
			<xsl:with-param name="new-text-nodes" select="$new-text-nodes[position()&gt;1]"/>
		</xsl:apply-templates>
	</xsl:template>
	
	<xsl:function name="pxi:lang" as="xs:string?">
		<xsl:param name="element" as="element()"/>
		<xsl:sequence select="($element/ancestor-or-self::*[@xml:lang][1]/@xml:lang,'und')[1]"/>
	</xsl:function>
	
	<xsl:function name="pxi:space" as="xs:string?">
		<xsl:param name="element" as="element()"/>
		<xsl:sequence select="$element/ancestor-or-self::*[@xml:space][1]/@xml:space"/>
	</xsl:function>
	
	<xsl:function name="pxi:display" as="xs:string">
		<xsl:param name="element" as="element()"/>
		<xsl:sequence select="css:specified-properties('display', true(), true(), false(), $element)/@value"/>
	</xsl:function>
	
	<xsl:function name="pxi:is-block" as="xs:boolean">
		<xsl:param name="node" as="node()"/>
		<xsl:sequence select="boolean($node/descendant-or-self::*[pxi:display(.) != 'inline'])"/>
	</xsl:function>
	
</xsl:stylesheet>
