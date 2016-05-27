<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns:css="http://www.daisy.org/ns/pipeline/braille-css"
                exclude-result-prefixes="#all">
	
	<xsl:import href="../library.xsl"/>
	
	<!--
	    API: implement xsl:template match="css:block"
	-->
	<xsl:template mode="#default after before" match="css:block">
		<xsl:message terminate="yes">Coding error</xsl:message>
	</xsl:template>
	
	<xsl:template match="/*">
		<xsl:apply-templates select="." mode="identify-blocks"/>
	</xsl:template>
	
	<xsl:template mode="identify-blocks" match="/*">
		<_ style="text-transform: none">
			<xsl:next-match>
				<xsl:with-param name="source-style" tunnel="yes" select="()"/>
				<xsl:with-param name="result-style" tunnel="yes" select="css:property('text-transform','none')"/>
			</xsl:next-match>
		</_>
	</xsl:template>
	
	<xsl:variable name="inline-properties" as="xs:string*"
	              select="$css:properties[not(.='display') and css:applies-to(., 'inline')]"/>
	
	<xsl:template mode="identify-blocks" match="*">
		<!-- parent is block -->
		<xsl:param name="is-block" as="xs:boolean" select="true()" tunnel="yes"/>
		<!-- computed inline properties of the parent element in the source -->
		<xsl:param name="source-style" as="element()*" tunnel="yes"/> <!-- css:property* -->
		<!-- computed inline properties of the parent element in the result -->
		<xsl:param name="result-style" as="element()*" tunnel="yes"/> <!-- css:property* -->
		<xsl:variable name="style" as="element()*" select="css:deep-parse-stylesheet(@style)"/> <!-- css:rule* -->
		<xsl:variable name="context" as="element()" select="."/>
		<xsl:variable name="translated-style" as="element()*">
			<xsl:call-template name="translate-style">
				<xsl:with-param name="style" select="$style"/>
				<xsl:with-param name="context" tunnel="yes" select="$context"/>
			</xsl:call-template>
		</xsl:variable>
		<xsl:copy>
			<xsl:variable name="is-block" as="xs:boolean"
			              select="$is-block and descendant-or-self::*[@css:display[not(.='inline')]]"/>
			<xsl:variable name="source-style" as="element()*">
				<xsl:call-template name="css:computed-properties">
					<xsl:with-param name="properties" select="$inline-properties"/>
					<!--
					    passing dummy context because not used by css:cascaded-properties and
					    css:parent-property below
					-->
					<xsl:with-param name="context" select="$dummy-element"/>
					<xsl:with-param name="cascaded-properties" tunnel="yes" select="$style[not(@selector)]/css:property"/>
					<xsl:with-param name="parent-properties" tunnel="yes" select="$source-style"/>
				</xsl:call-template>
			</xsl:variable>
			<xsl:variable name="result-style" as="element()*">
				<xsl:call-template name="css:computed-properties">
					<xsl:with-param name="properties" select="$inline-properties"/>
					<xsl:with-param name="context" select="$dummy-element"/>
					<xsl:with-param name="cascaded-properties" tunnel="yes" select="$translated-style[not(@selector)]/css:property"/>
					<xsl:with-param name="parent-properties" tunnel="yes" select="$result-style"/>
				</xsl:call-template>
			</xsl:variable>
			<xsl:sequence select="@* except @style"/>
			<xsl:sequence select="css:style-attribute(css:serialize-stylesheet($translated-style))"/>
			<xsl:variable name="lang" as="xs:string?" select="(ancestor-or-self::*[@xml:lang][1]/@xml:lang,'und')[1]"/>
			<xsl:for-each-group select="*|text()"
			                    group-adjacent="$is-block and boolean(descendant-or-self::*[@css:display[not(.='inline')]])">
				<xsl:choose>
					<xsl:when test="current-grouping-key()">
						<xsl:for-each select="current-group()">
							<xsl:apply-templates mode="#current" select=".">
								<xsl:with-param name="is-block" select="$is-block" tunnel="yes"/>
								<xsl:with-param name="source-style" tunnel="yes" select="$source-style"/>
								<xsl:with-param name="result-style" tunnel="yes" select="$result-style"/>
							</xsl:apply-templates>
						</xsl:for-each>
					</xsl:when>
					<xsl:otherwise>
						<xsl:variable name="block">
							<xsl:element name="css:block">
								<!--
								    TODO: better to pass as parameter instead of attribute?
								-->
								<xsl:if test="$lang">
									<xsl:attribute name="xml:lang" select="$lang"/>
								</xsl:if>
								<xsl:for-each select="current-group()">
									<xsl:sequence select="."/>
								</xsl:for-each>
							</xsl:element>
						</xsl:variable>
						<xsl:apply-templates select="$block/css:block">
							<xsl:with-param name="context" select="$context"/>
							<xsl:with-param name="source-style" tunnel="yes" select="$source-style"/>
							<xsl:with-param name="result-style" tunnel="yes" select="$result-style"/>
						</xsl:apply-templates>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:for-each-group>
		</xsl:copy>
	</xsl:template>
	
	<xsl:template mode="identify-blocks" match="@*|text()">
		<xsl:sequence select="."/>
	</xsl:template>
	
	<xsl:template name="translate-style" as="element()*"> <!-- css:rule* -->
		<xsl:param name="style" as="element()*" required="yes"/> <!-- css:rule* -->
		<xsl:param name="source-style" as="element()*" tunnel="yes"/> <!-- css:property* -->
		<xsl:param name="result-style" as="element()*" tunnel="yes"/> <!-- css:property* -->
		<xsl:variable name="main-style" as="element()?" select="$style[not(@selector)]"/>
		<xsl:variable name="translated-main-style" as="element()?"> <!-- css:rule* -->
			<xsl:apply-templates mode="translate-style" select="$main-style">
				<xsl:with-param name="text-translated" tunnel="yes" select="true()"/>
			</xsl:apply-templates>
		</xsl:variable>
		<xsl:variable name="source-style" as="element()*">
			<xsl:call-template name="css:computed-properties">
				<xsl:with-param name="properties" select="$inline-properties"/>
				<xsl:with-param name="context" select="$dummy-element"/>
				<xsl:with-param name="cascaded-properties" tunnel="yes" select="$main-style/css:property"/>
				<xsl:with-param name="parent-properties" tunnel="yes" select="$source-style"/>
			</xsl:call-template>
		</xsl:variable>
		<xsl:variable name="result-style" as="element()*">
			<xsl:call-template name="css:computed-properties">
				<xsl:with-param name="properties" select="$inline-properties"/>
				<xsl:with-param name="context" select="$dummy-element"/>
				<xsl:with-param name="cascaded-properties" tunnel="yes" select="$translated-main-style/css:property"/>
				<xsl:with-param name="parent-properties" tunnel="yes" select="$result-style"/>
			</xsl:call-template>
		</xsl:variable>
		<xsl:sequence select="$translated-main-style"/>
		<xsl:apply-templates mode="translate-style" select="$style[@selector=('::before','::after')]">
			<xsl:with-param name="source-style" tunnel="yes" select="$source-style"/>
			<xsl:with-param name="result-style" tunnel="yes" select="$result-style"/>
		</xsl:apply-templates>
		<xsl:apply-templates mode="translate-style" select="$style[@selector and not(@selector=('::before','::after'))]"/>
	</xsl:template>
	
	<xsl:template mode="translate-style" match="css:rule">
		<xsl:param name="mode" as="xs:string" tunnel="yes" select="'#default'"/>
		<xsl:param name="source-style" as="element()*" tunnel="yes"/> <!-- css:property* -->
		<!--
		    FIXME: don't copy if empty
		-->
		<xsl:copy>
			<xsl:sequence select="@selector"/>
			<xsl:variable name="mode" as="xs:string" select="if (@selector='::before') then 'before'
			                                                 else if (@selector='::after') then 'after'
			                                                 else $mode"/>
			<xsl:choose>
				<xsl:when test="css:rule">
					<xsl:call-template name="translate-style">
						<xsl:with-param name="style" select="css:rule"/>
						<xsl:with-param name="mode" tunnel="yes" select="$mode"/>
					</xsl:call-template>
				</xsl:when>
				<xsl:otherwise>
					<xsl:variable name="source-style" as="element()*">
						<xsl:call-template name="css:computed-properties">
							<xsl:with-param name="properties" select="$inline-properties"/>
							<xsl:with-param name="context" select="$dummy-element"/>
							<xsl:with-param name="cascaded-properties" tunnel="yes" select="css:property"/>
							<xsl:with-param name="parent-properties" tunnel="yes" select="$source-style"/>
						</xsl:call-template>
					</xsl:variable>
					<xsl:apply-templates mode="#current" select="css:property">
						<xsl:with-param name="mode" tunnel="yes" select="$mode"/>
						<xsl:with-param name="source-style" tunnel="yes" select="$source-style"/>
					</xsl:apply-templates>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:copy>
	</xsl:template>
	
	<!--
	    drop properties that are not inherited and have the initial value, or that are inherited and
	    have the value of the parent element
	-->
	<xsl:template mode="translate-style" match="css:property" priority="0.4">
		<xsl:param name="result-style" as="element()*" tunnel="yes"/> <!-- css:property* -->
		<xsl:variable name="name" as="xs:string" select="@name"/>
		<xsl:variable name="value" as="xs:string" select="@value"/>
		<xsl:variable name="inherited" as="xs:boolean" select="css:is-inherited($name)"/>
		<xsl:choose>
			<xsl:when test="not($name=$inline-properties)">
				<xsl:sequence select="."/>
			</xsl:when>
			<xsl:when test="$inherited and $result-style[@name=$name and @value=$value]"/>
			<xsl:when test="not($inherited and $result-style[@name=$name]) and $value=css:initial-value($name)"/>
			<xsl:otherwise>
				<xsl:sequence select="."/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	
	<xsl:template mode="translate-style" match="css:property[@name='text-transform']">
		<xsl:param name="result-style" as="element()*" tunnel="yes"/> <!-- css:property* -->
		<xsl:param name="text-translated" as="xs:boolean" tunnel="yes" select="false()"/>
		<xsl:choose>
			<xsl:when test="$text-translated">
				<xsl:if test="not($result-style[@name='text-transform' and @value='none'])">
					<css:property name="text-transform" value="none"/>
				</xsl:if>
			</xsl:when>
			<xsl:otherwise>
				<xsl:next-match/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	
	<xsl:template mode="translate-style" match="css:property[@name='string-set']">
		<xsl:if test="@value!='none'">
			<xsl:variable name="evaluated-string-set" as="element()*">
				<xsl:apply-templates mode="eval-string-set" select="css:parse-string-set(@value)"/>
			</xsl:variable>
			<xsl:copy>
				<xsl:sequence select="@name"/>
				<xsl:attribute name="value" select="css:serialize-string-set($evaluated-string-set)"/>
			</xsl:copy>
		</xsl:if>
	</xsl:template>
	
	<xsl:template mode="translate-style"
	              match="css:content|css:string[@name]|css:counter|css:text|css:leader|css:custom-func|css:flow[@from]">
		<xsl:sequence select="."/>
	</xsl:template>
	
	<xsl:template mode="eval-string-set" match="css:string-set" as="element()">
		<xsl:param name="context" as="element()" tunnel="yes"/>
		<xsl:copy>
			<xsl:sequence select="@name"/>
			<xsl:variable name="evaluated-content-list" as="element()*">
				<xsl:apply-templates mode="#current" select="css:parse-content-list(@value, $context)">
					<xsl:with-param name="string-name" select="@name" tunnel="yes"/>
				</xsl:apply-templates>
			</xsl:variable>
			<xsl:attribute name="value" select="if (exists($evaluated-content-list))
			                                    then css:serialize-content-list($evaluated-content-list)
			                                    else '&quot;&quot;'"/>
		</xsl:copy>
	</xsl:template>
	
	<xsl:template mode="eval-string-set" match="css:string[@value]|css:attr" as="element()?">
		<xsl:param name="context" as="element()" tunnel="yes"/>
		<xsl:variable name="evaluated-string" as="xs:string?">
			<xsl:apply-templates mode="css:eval" select=".">
				<xsl:with-param name="context" select="$context"/>
			</xsl:apply-templates>
		</xsl:variable>
		<xsl:if test="exists($evaluated-string)">
			<css:string value="{$evaluated-string}"/>
		</xsl:if>
	</xsl:template>
	
	<xsl:template mode="eval-string-set" match="css:content[not(@target)]" as="element()?">
		<xsl:param name="context" as="element()" tunnel="yes"/>
		<xsl:variable name="as-string" as="xs:string" select="string($context)"/>
		<xsl:if test="not($as-string='')">
			<css:string value="{$as-string}"/>
		</xsl:if>
	</xsl:template>
	
	<xsl:template mode="eval-string-set" match="css:string[@name][not(@target)]">
		<xsl:message>string() function not supported in string-set property</xsl:message>
	</xsl:template>
	
	<xsl:template mode="eval-string-set" match="css:counter[not(@target)]">
		<xsl:message>counter() function not supported in string-set property</xsl:message>
	</xsl:template>
	
	<xsl:template mode="eval-string-set" match="css:text[@target]">
		<xsl:message>target-text() function not supported in string-set property</xsl:message>
	</xsl:template>
	
	<xsl:template mode="eval-string-set" match="css:string[@name][@target]">
		<xsl:message>target-string() function not supported in string-set property</xsl:message>
	</xsl:template>
	
	<xsl:template mode="eval-string-set" match="css:counter[@target]">
		<xsl:message>target-counter() function not supported in string-set property</xsl:message>
	</xsl:template>
	
	<xsl:template mode="eval-string-set" match="css:content[@target]">
		<xsl:message>target-content() function not supported in string-set property</xsl:message>
	</xsl:template>
	
	<xsl:template mode="eval-string-set" match="css:leader">
		<xsl:message>leader() function not supported in string-set property</xsl:message>
	</xsl:template>
	
	<xsl:template mode="eval-string-set" match="css:custom-func">
		<xsl:message><xsl:value-of select="@name"/>() function not supported in string-set property</xsl:message>
	</xsl:template>
	
	<xsl:template mode="translate-style" match="css:property[@name='content' and not(@value='none')]">
		<xsl:param name="context" as="element()" tunnel="yes"/>
		<xsl:variable name="translated-content-list" as="element()*">
			<xsl:apply-templates mode="#current" select="css:parse-content-list(@value, $context)"/>
		</xsl:variable>
		<xsl:sequence select="css:property('content', if (exists($translated-content-list))
					                                  then css:serialize-content-list($translated-content-list)
					                                  else '&quot;&quot;')"/>
	</xsl:template>
	
	<xsl:template mode="translate-style" match="css:string[@value]|css:attr" as="element()?">
		<xsl:param name="context" as="element()" tunnel="yes"/>
		<xsl:param name="source-style" as="element()*" tunnel="yes"/> <!-- css:property* -->
		<xsl:param name="result-style" as="element()*" tunnel="yes"/> <!-- css:property* -->
		<xsl:param name="mode" as="xs:string" tunnel="yes"/> <!-- before|after -->
		<xsl:variable name="evaluated-string" as="xs:string">
			<xsl:apply-templates mode="css:eval" select=".">
				<xsl:with-param name="context" select="$context"/>
			</xsl:apply-templates>
		</xsl:variable>
		<xsl:variable name="lang" as="xs:string?" select="($context/ancestor-or-self::*[@xml:lang][1]/@xml:lang,'und')[1]"/>
		<xsl:variable name="block">
			<xsl:element name="css:block">
				<xsl:if test="$lang">
					<xsl:attribute name="xml:lang" select="$lang"/>
				</xsl:if>
				<xsl:value-of select="$evaluated-string"/>
			</xsl:element>
		</xsl:variable>
		<xsl:variable name="source-style" as="element()*" select="$source-style[not(@name='content')]"/>
		<xsl:variable name="result-style" as="element()*" select="$result-style[not(@name='content')]"/>
		<xsl:variable name="translated-block" as="node()*">
			<xsl:choose>
				<xsl:when test="$mode='before'">
					<xsl:apply-templates mode="before" select="$block/css:block">
						<xsl:with-param name="context" select="$context"/>
						<xsl:with-param name="source-style" tunnel="yes" select="$source-style"/>
						<xsl:with-param name="result-style" tunnel="yes" select="$result-style"/>
					</xsl:apply-templates>
				</xsl:when>
				<xsl:when test="$mode='after'">
					<xsl:apply-templates mode="after" select="$block/css:block">
						<xsl:with-param name="context" select="$context"/>
						<xsl:with-param name="source-style" tunnel="yes" select="$source-style"/>
						<xsl:with-param name="result-style" tunnel="yes" select="$result-style"/>
					</xsl:apply-templates>
				</xsl:when>
				<xsl:otherwise>
					<xsl:sequence select="$block/css:block"/>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<css:string value="{string-join($translated-block/string(.),'')}"/>
	</xsl:template>
	
	<xsl:template mode="treewalk" match="*">
		<xsl:param name="new-text-nodes" as="xs:string*" required="yes"/>
		<xsl:param name="source-style" as="element()*" tunnel="yes"/> <!-- css:property* -->
		<xsl:param name="result-style" as="element()*" tunnel="yes"/> <!-- css:property* -->
		<xsl:variable name="text-node-count" select="count(.//text())"/>
		<xsl:variable name="style" as="element()*" select="css:deep-parse-stylesheet(@style)"/> <!-- css:rule* -->
		<xsl:variable name="context" as="element()" select="."/>
		<xsl:variable name="translated-style" as="element()*">
			<xsl:call-template name="translate-style">
				<xsl:with-param name="style" select="$style"/>
				<xsl:with-param name="context" tunnel="yes" select="$context"/>
			</xsl:call-template>
		</xsl:variable>
		<xsl:copy>
			<xsl:variable name="source-style" as="element()*">
				<xsl:call-template name="css:computed-properties">
					<xsl:with-param name="properties" select="$inline-properties"/>
					<xsl:with-param name="context" select="$dummy-element"/>
					<xsl:with-param name="cascaded-properties" tunnel="yes" select="$style/css:property"/>
					<xsl:with-param name="parent-properties" tunnel="yes" select="$source-style"/>
				</xsl:call-template>
			</xsl:variable>
			<xsl:variable name="result-style" as="element()*">
				<xsl:call-template name="css:computed-properties">
					<xsl:with-param name="properties" select="$inline-properties"/>
					<xsl:with-param name="context" select="$dummy-element"/>
					<xsl:with-param name="cascaded-properties" tunnel="yes" select="$translated-style/css:property"/>
					<xsl:with-param name="parent-properties" tunnel="yes" select="$result-style"/>
				</xsl:call-template>
			</xsl:variable>
			<xsl:sequence select="@* except @style"/>
			<xsl:sequence select="css:style-attribute(css:serialize-stylesheet($translated-style))"/>
			<xsl:apply-templates mode="#current" select="child::node()[1]">
				<xsl:with-param name="new-text-nodes" select="$new-text-nodes[position()&lt;=$text-node-count]"/>
				<xsl:with-param name="source-style" tunnel="yes" select="$source-style"/>
				<xsl:with-param name="result-style" tunnel="yes" select="$result-style"/>
			</xsl:apply-templates>
		</xsl:copy>
		<xsl:apply-templates mode="#current" select="following-sibling::node()[1]">
			<xsl:with-param name="new-text-nodes" select="$new-text-nodes[position()&gt;$text-node-count]"/>
		</xsl:apply-templates>
	</xsl:template>
	
	<xsl:template mode="treewalk" match="text()">
		<xsl:param name="new-text-nodes" as="xs:string*" required="yes"/>
		<xsl:value-of select="$new-text-nodes[1]"/>
		<xsl:apply-templates mode="#current" select="following-sibling::node()[1]">
			<xsl:with-param name="new-text-nodes" select="$new-text-nodes[position()&gt;1]"/>
		</xsl:apply-templates>
	</xsl:template>
	
	<xsl:variable name="dummy-element" as="element()"><_/></xsl:variable>
	
	<xsl:template name="css:cascaded-properties" as="element()*">
		<xsl:param name="properties" as="xs:string*" select="('#all')"/>
		<xsl:param name="validate" as="xs:boolean" select="false()"/>
		<xsl:param name="context" as="element()" select="."/>
		<xsl:param name="cascaded-properties" as="element()*" select="()" tunnel="yes"/> <!-- css:property* -->
		<xsl:sequence select="for $name in distinct-values(
		                                     if ('#all'=$properties)
		                                     then $cascaded-properties/@name
		                                     else $properties)
		                      return $cascaded-properties[@name=$name][last()]"/>
	</xsl:template>
	
	<xsl:template name="css:parent-property" as="element()?">
		<xsl:param name="property" as="xs:string" required="yes"/>
		<xsl:param name="compute" as="xs:boolean" select="false()"/>
		<xsl:param name="concretize-inherit" as="xs:boolean" select="true()"/>
		<xsl:param name="concretize-initial" as="xs:boolean" select="true()"/>
		<xsl:param name="validate" as="xs:boolean"/>
		<xsl:param name="context" as="element()" select="."/>
		<xsl:param name="parent-properties" as="element()*" select="()" tunnel="yes"/> <!-- css:property* -->
		<xsl:choose>
			<xsl:when test="exists($parent-properties[@name=$property])">
				<xsl:sequence select="$parent-properties[@name=$property]"/>
			</xsl:when>
			<xsl:when test="$concretize-initial">
				<xsl:sequence select="css:property($property, css:initial-value($property))"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:sequence select="css:property($property, 'initial')"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	
</xsl:stylesheet>
