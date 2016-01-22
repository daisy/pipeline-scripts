<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step type="pxi:css-to-obfl"
                xmlns:p="http://www.w3.org/ns/xproc"
                xmlns:px="http://www.daisy.org/ns/pipeline/xproc"
                xmlns:pxi="http://www.daisy.org/ns/pipeline/xproc/internal"
                xmlns:css="http://www.daisy.org/ns/pipeline/braille-css"
                xmlns:obfl="http://www.daisy.org/ns/2011/obfl"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                exclude-inline-prefixes="pxi xsl"
                version="1.0">
    
    <p:documentation>
        Convert a document with inline braille CSS to OBFL (Open Braille Formatting Language).
    </p:documentation>
    
    <p:input port="source" sequence="true"/>
    <p:output port="result" sequence="false"/>
    
    <p:option name="text-transform" required="true"/>
    
    <p:import href="http://www.daisy.org/pipeline/modules/braille/css-utils/library.xpl"/>
    <p:import href="propagate-page-break.xpl"/>
    <p:import href="shift-obfl-marker.xpl"/>
    
    <p:declare-step type="pxi:recursive-parse-stylesheet-and-make-pseudo-element">
        <p:input port="source"/>
        <p:output port="result"/>
        <css:parse-stylesheet>
            <p:documentation>
                Make css:page, css:volume, css:after, css:before and css:duplicate attributes.
            </p:documentation>
        </css:parse-stylesheet>
        <p:choose>
            <p:when test="//*/@css:before or //*/@css:after or //*/@css:duplicate">
                <css:make-pseudo-elements>
                    <p:documentation>
                        Make css:before, css:after and css:duplicate pseudo-elements from
                        css:before, css:after and css:duplicate attributes.
                    </p:documentation>
                </css:make-pseudo-elements>
                <pxi:recursive-parse-stylesheet-and-make-pseudo-element/>
            </p:when>
            <p:otherwise>
                <p:identity/>
            </p:otherwise>
        </p:choose>
    </p:declare-step>
    
    <p:add-xml-base/>
    <p:xslt>
        <p:input port="stylesheet">
            <p:inline>
                <xsl:stylesheet version="2.0">
                    <xsl:template match="/*">
                        <xsl:copy>
                            <xsl:copy-of select="document('')/*/namespace::*[name()='obfl']"/>
                            <xsl:copy-of select="document('')/*/namespace::*[name()='css']"/>
                            <xsl:sequence select="@*|node()"/>
                        </xsl:copy>
                    </xsl:template>
                </xsl:stylesheet>
            </p:inline>
        </p:input>
        <p:input port="parameters">
            <p:empty/>
        </p:input>
    </p:xslt>
    
    <pxi:recursive-parse-stylesheet-and-make-pseudo-element>
        <p:documentation>
            Make css:after, css:before and css:duplicate pseudo-elements and css:page and
            css:volume attributes.
        </p:documentation>
    </pxi:recursive-parse-stylesheet-and-make-pseudo-element>
    <css:parse-properties properties="string-set counter-reset counter-set counter-increment -obfl-marker">
        <p:documentation>
            Make css:string-set, css:counter-reset, css:counter-set, css:counter-increment and
            css:_obfl-marker attributes.
        </p:documentation>
    </css:parse-properties>
    <css:eval-string-set>
        <p:documentation>
            Evaluate css:string-set attributes.
        </p:documentation>
    </css:eval-string-set>
    
    <p:group>
        <p:documentation>
            Split into a sequence of flows.
        </p:documentation>
        <p:for-each>
            <css:parse-properties properties="flow">
                <p:documentation>
                    Make css:flow attributes.
                </p:documentation>
            </css:parse-properties>
            <p:delete match="css:duplicate[not(@css:flow)]">
                <p:documentation>
                    Only allow ::duplicate pseudo-elements that are moved into a named flow.
                </p:documentation>
            </p:delete>
        </p:for-each>
        <p:wrap wrapper="_" match="/*"/>
        <css:flow-into name="_1">
            <p:documentation>
                Extract named flows based on css:flow attributes. Extracted elements are replaced
                with empty css:_ elements with a css:id attribute.
            </p:documentation>
        </css:flow-into>
        <p:filter select="/_/*" name="_2"/>
        <p:identity>
            <p:input port="source">
                <p:pipe step="_2" port="result"/>
                <p:pipe step="_1" port="flows"/>
            </p:input>
        </p:identity>
    </p:group>
    
    <p:for-each>
        <css:parse-properties properties="content white-space display list-style-type
                                          page-break-before page-break-after">
            <p:documentation>
                Make css:content, css:white-space, css:display, css:list-style-type,
                css:page-break-before and css:page-break-after attributes.
            </p:documentation>
        </css:parse-properties>
        <css:parse-content>
            <p:documentation>
                Make css:string, css:text and css:counter elements from css:content attributes.
            </p:documentation>
        </css:parse-content>
    </p:for-each>
    
    <css:label-targets name="label-targets">
        <p:documentation>
            Make css:id attributes. <!-- depends on parse-content -->
        </p:documentation>
    </css:label-targets>
    
    <p:for-each>
        <css:preserve-white-space>
            <p:documentation>
                Make css:white-space elements from css:white-space attributes.
            </p:documentation>
        </css:preserve-white-space>
        <p:add-attribute match="*[@css:display='-obfl-toc']" attribute-name="css:_obfl-toc" attribute-value="x">
            <p:documentation>
                Mark display:-obfl-toc elements.
            </p:documentation>
        </p:add-attribute>
        <p:add-attribute match="*[@css:display='-obfl-toc']" attribute-name="css:display" attribute-value="block">
            <p:documentation>
                Treat display:-obfl-toc as block.
            </p:documentation>
        </p:add-attribute>
        <css:make-boxes>
            <p:documentation>
                Make css:box elements based on css:display and css:list-style-type attributes. <!--
                depends on flow-into and label-targets -->
            </p:documentation>
        </css:make-boxes>
        <css:make-anonymous-inline-boxes>
            <p:documentation>
                Wrap/unwrap with inline css:box elements.
            </p:documentation>
        </css:make-anonymous-inline-boxes>
    </p:for-each>
    
    <css:eval-counter exclude-counters="page">
        <p:documentation>
            Evaluate css:counter elements. <!-- depends on label-targets and parse-content -->
        </p:documentation>
    </css:eval-counter>
    
    <css:eval-target-text>
        <p:documentation>
            Evaluate css:text elements. <!-- depends on label-targets and parse-content -->
        </p:documentation>
    </css:eval-target-text>
    
    <p:group>
        <p:documentation>
            Split flows into sections.
        </p:documentation>
        <p:for-each>
            <css:parse-counter-set counters="page">
                <p:documentation>
                    Make css:counter-set-page attributes.
                </p:documentation>
            </css:parse-counter-set>
            <p:delete match="/*[@css:flow]//*/@css:page|
                             /*[@css:flow]//*/@css:volume|
                             /*[@css:flow]//*/@css:counter-set-page|
                             //*[@css:obfl-toc]//*/@css:page-break-before|
                             //*[@css:obfl-toc]//*/@css:page-break-after">
                <p:documentation>
                    Don't support 'page', 'volume' and 'counter-set: page' within named flows. Don't
                    support 'page-break-before' and 'page-break-after' within display:-obfl-toc.
                </p:documentation>
            </p:delete>
            <css:split split-before="*[@css:page or @css:volume or @css:counter-set-page]|
                                     css:box[@type='block' and @css:page-break-before='right']"
                       split-after="*[@css:page or @css:volume]|
                                    css:box[@type='block' and @css:page-break-after='right']">
                <p:documentation>
                    Split before and after css:page attributes, before css:counter-set-page
                    attributes, before and after css:volume attributes and before
                    css:page-break-before attributes with value 'right' and after
                    css:page-break-after attributes with value 'right'. <!-- depends on make-boxes
                    -->
                </p:documentation>
            </css:split>
        </p:for-each>
        <p:for-each>
            <p:group>
                <p:documentation>
                    Move css:page, css:counter-set-page and css:volume attributes to css:_ root
                    element.
                </p:documentation>
                <p:wrap wrapper="css:_" match="/*[not(@css:flow)]"/>
                <p:label-elements match="/*[descendant::*/@css:page]" attribute="css:page"
                                  label="(descendant::*/@css:page)[last()]"/>
                <p:label-elements match="/*[descendant::*/@css:counter-set-page]" attribute="css:counter-set-page"
                                  label="(descendant::*/@css:counter-set-page)[last()]"/>
                <p:label-elements match="/*[descendant::*/@css:volume]" attribute="css:volume"
                                  label="(descendant::*/@css:volume)[last()]"/>
                <p:delete match="/*//*/@css:page"/>
                <p:delete match="/*//*/@css:counter-set-page"/>
                <p:delete match="/*//*/@css:volume"/>
            </p:group>
            <p:rename match="css:box[@type='inline']
                             [matches(string(.), '^[\s&#x2800;]*$') and
                             not(descendant::css:white-space or
                             descendant::css:string or
                             descendant::css:counter or
                             descendant::css:text or
                             descendant::css:leader)]"
                      new-name="css:_">
                <p:documentation>
                    Delete empty inline boxes (possible side effect of css:split).
                </p:documentation>
            </p:rename>
        </p:for-each>
        <p:group>
            <p:documentation>
                Repeat css:string-set attributes at the beginning of sections as css:string-entry.
            </p:documentation>
            <p:split-sequence test="/*[not(@css:flow)]" name="_1"/>
            <css:repeat-string-set name="_2"/>
            <p:identity>
                <p:input port="source">
                    <p:pipe step="_2" port="result"/>
                    <p:pipe step="_1" port="not-matched"/>
                </p:input>
            </p:identity>
        </p:group>
        <css:shift-string-set>
            <p:documentation>
                Move css:string-set attributes. <!-- depends on make-anonymous-inline-boxes -->
            </p:documentation>
        </css:shift-string-set>
        <pxi:shift-obfl-marker>
            <p:documentation>
                Move css:_obfl-marker attributes. <!-- depends on make-anonymous-inline-boxes -->
            </p:documentation>
        </pxi:shift-obfl-marker>
        <css:shift-id>
            <p:documentation>
                Move css:id attributes to css:box elements.
            </p:documentation>
        </css:shift-id>
    </p:group>
    
    <p:for-each>
        <css:parse-properties properties="padding-left padding-right padding-top padding-bottom">
            <p:documentation>
                Make css:padding-left, css:padding-right, css:padding-top and css:padding-bottom
                attributes.
            </p:documentation>
        </css:parse-properties>
        <css:padding-to-margin/>
    </p:for-each>
    
    <p:for-each>
        <p:unwrap match="css:_[not(@css:*) and parent::*]" name="unwrap-css-_">
            <p:documentation>
                All css:_ elements except for root elements and empty elements with a css:string-set
                or css:_obfl-marker attribute within a css:box element should be gone now. <!--
                depends on shift-id and shift-string-set -->
            </p:documentation>
        </p:unwrap>
        <css:make-anonymous-block-boxes>
            <p:documentation>
                Wrap inline css:box elements in block css:box elements where necessary. <!-- depends
                on unwrap css:_ -->
            </p:documentation>
        </css:make-anonymous-block-boxes>
    </p:for-each>
    
    <p:split-sequence test="//css:box"/>
    
    <p:for-each>
        <css:parse-properties properties="margin-left margin-right margin-top margin-bottom
                                          border-left border-right border-top border-bottom text-indent">
            <p:documentation>
                Make css:margin-left, css:margin-right, css:margin-top, css:margin-bottom,
                css:border-left, css:border-right, css:border-top, css:border-bottom and
                css:text-indent attributes.
            </p:documentation>
        </css:parse-properties>
        <css:adjust-boxes/>
        <css:new-definition>
            <p:input port="definition">
                <p:inline>
                    <xsl:stylesheet version="2.0" xmlns:new="css:new-definition">
                        <xsl:variable name="new:properties" as="xs:string*"
                                      select="('margin-left',   'page-break-before', 'text-indent', 'text-transform', '-obfl-vertical-align',
                                               'margin-right',  'page-break-after',  'text-align',  'hyphens',        '-obfl-vertical-position',
                                               'margin-top',    'page-break-inside', 'line-height', 'white-space',    '-obfl-toc-range',
                                               'margin-bottom', 'orphans',                          'word-spacing',
                                               'border-left',   'widows',                           'letter-spacing',
                                               'border-right',
                                               'border-top',
                                               'border-bottom')"/>
                        <xsl:function name="new:is-valid" as="xs:boolean">
                            <xsl:param name="css:property" as="element()"/>
                            <xsl:param name="context" as="element()"/>
                            <xsl:sequence select="new:applies-to($css:property/@name, $context)
                                                  and (
                                                    if ($css:property/@name='-obfl-vertical-align')
                                                    then $css:property/@value=('before','center','after')
                                                    else if ($css:property/@name='-obfl-vertical-position')
                                                    then matches($css:property/@value,'^auto|0|[1-9][0-9]*$')
                                                    else if ($css:property/@name='-obfl-toc-range')
                                                    then ($context/@css:_obfl-toc and $css:property/@value=('document','volume'))
                                                    else (
                                                      css:is-valid($css:property)
                                                      and not($css:property/@value=('inherit','initial'))
                                                    )
                                                  )"/>
                        </xsl:function>
                        <xsl:function name="new:initial-value" as="xs:string">
                            <xsl:param name="property" as="xs:string"/>
                            <xsl:param name="context" as="element()"/>
                            <xsl:sequence select="if ($property='-obfl-vertical-align')
                                                  then 'after'
                                                  else if ($property='-obfl-vertical-position')
                                                  then 'auto'
                                                  else if ($property='-obfl-toc-range')
                                                  then 'document'
                                                  else css:initial-value($property)"/>
                        </xsl:function>
                        <xsl:function name="new:is-inherited" as="xs:boolean">
                            <xsl:param name="property" as="xs:string"/>
                            <xsl:param name="context" as="element()"/>
                            <xsl:sequence select="$property=('text-transform','hyphens','word-spacing')"/>
                        </xsl:function>
                        <xsl:function name="new:applies-to" as="xs:boolean">
                            <xsl:param name="property" as="xs:string"/>
                            <xsl:param name="context" as="element()"/>
                            <xsl:sequence select="$context/@type='block' or $property=('text-transform','hyphens','word-spacing')"/>
                        </xsl:function>
                    </xsl:stylesheet>
                </p:inline>
            </p:input>
        </css:new-definition>
        <p:delete match="css:box[@type='block']
                                [matches(string(.), '^[\s&#x2800;]*$') and
                                 not(descendant::css:white-space or
                                     descendant::css:string or
                                     descendant::css:counter or
                                     descendant::css:text or
                                     descendant::css:leader)]
                                //text()">
            <p:documentation>
                Remove text nodes from block boxes with no line boxes.
            </p:documentation>
        </p:delete>
        <pxi:propagate-page-break>
            <p:documentation>
                Resolve css:page-break-before="avoid" and css:page-break-after="always".
                <!-- depends on make-anonymous-block-boxes -->
            </p:documentation>
        </pxi:propagate-page-break>
        <!--
            Move css:page-break-after="avoid" to last descendant block (TODO: move to
            pxi:propagate-page-break?)
        -->
        <p:add-attribute match="css:box[@type='block'
                                        and not(child::css:box[@type='block'])
                                        and (some $self in . satisfies
                                          some $ancestor in $self/ancestor::*[@css:page-break-after='avoid'] satisfies
                                            not($self/following::css:box intersect $ancestor//*))]"
                         attribute-name="css:page-break-after"
                         attribute-value="avoid"/>
        <p:delete match="css:box[@type='block' and child::css:box[@type='block']]/@css:page-break-after[.='avoid']"/>
    </p:for-each>
    
    <p:split-sequence test="//css:box[@css:border-top|
                                      @css:border-bottom|
                                      @css:margin-top|
                                      @css:margin-bottom|
                                      descendant::text()|
                                      descendant::css:white-space|
                                      descendant::css:string|
                                      descendant::css:counter|
                                      descendant::css:text|
                                      descendant::css:leader]">
        <p:documentation>
            Remove empty sections.
        </p:documentation>
    </p:split-sequence>
    
    <!-- for debug info -->
    <p:for-each><p:identity/></p:for-each>
    
    <p:xslt template-name="main">
        <p:input port="stylesheet">
            <p:document href="css-to-obfl.xsl"/>
        </p:input>
        <p:with-param name="braille-translator-query" select="if ($text-transform='auto') then '' else $text-transform">
            <p:empty/>
        </p:with-param>
    </p:xslt>
    
    <!--
        add <marker class="foo/prev"/>
    -->
    <p:insert match="obfl:marker[not(matches(@class,'^indicator/|/entry$'))]" position="before">
        <p:input port="insertion">
          <p:inline><marker xmlns="http://www.daisy.org/ns/2011/obfl"/></p:inline>
        </p:input>
    </p:insert>
    <p:label-elements match="obfl:marker[not(@class)]" attribute="class" label="concat(following-sibling::obfl:marker[1]/@class,'/prev')"/>
    <p:label-elements match="obfl:marker[not(@value)]" attribute="value"
                      label="string-join(for $class in @class return (preceding::obfl:marker[concat(@class,'/prev')=$class])[last()]/@value,'')"/>
    
    <!--
        because empty marker values would be regarded as absent in BrailleFilterImpl
    -->
    <p:add-attribute match="obfl:marker[@value='']" attribute-name="value" attribute-value="&#x200B;"/>
    
    <!--
        move table-of-contents elements to the right place
    -->
    <p:group>
        <p:identity name="_1"/>
        <p:insert match="/obfl:obfl/obfl:volume-template[not(preceding-sibling::obfl:volume-template)]" position="before">
            <p:input port="insertion" select="//obfl:toc-sequence/obfl:table-of-contents">
                <p:pipe step="_1" port="result"/>
            </p:input>
        </p:insert>
        <p:delete match="obfl:toc-sequence/obfl:table-of-contents"/>
    </p:group>
    
</p:declare-step>
