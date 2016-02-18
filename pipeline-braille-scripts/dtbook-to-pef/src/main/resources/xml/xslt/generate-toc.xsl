<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns:dtb="http://www.daisy.org/z3986/2005/dtbook/"
                xmlns:pxi="http://www.daisy.org/ns/pipeline/xproc/internal"
                xmlns="http://www.daisy.org/z3986/2005/dtbook/"
                version="2.0"
                exclude-result-prefixes="#all">
  
  <xsl:param name="_depth" as="xs:string"/>
  
  <xsl:variable name="depth" as="xs:integer" select="xs:integer($_depth)"/>
  
  <xsl:template match="/*">
    <xsl:copy>
      <xsl:apply-templates select="@*"/>
      <xsl:if test="$depth &gt; 0">
        <xsl:variable name="included-heading-names" as="xs:string*" select="for $i in 1 to $depth return concat('h',$i)"/>
        <xsl:variable name="list" as="element()*">
          <xsl:for-each-group select="//dtb:*[local-name()=$included-heading-names]" group-starting-with="dtb:h1">
            <li>
              <xsl:if test="current-group()/self::dtb:h1">
                <a href="{pxi:get-or-generate-id(current-group()/self::dtb:h1)}">
                  <xsl:apply-templates select="current-group()/self::dtb:h1/child::node()"/>
                </a>
              </xsl:if>
              <xsl:if test="$depth &gt; 1">
                <xsl:variable name="list" as="element()*">
                  <xsl:for-each-group select="current-group()[not(self::dtb:h1)]" group-starting-with="dtb:h2">
                    <li>
                      <xsl:if test="current-group()/self::dtb:h2">
                        <a href="{pxi:get-or-generate-id(current-group()/self::dtb:h2)}">
                          <xsl:apply-templates select="current-group()/self::dtb:h2/child::node()"/>
                        </a>
                      </xsl:if>
                      <xsl:if test="$depth &gt; 2">
                        <xsl:variable name="list" as="element()*">
                          <xsl:for-each-group select="current-group()[not(self::dtb:h2)]" group-starting-with="dtb:h3">
                            <li>
                              <xsl:if test="current-group()/self::dtb:h3">
                                <a href="{pxi:get-or-generate-id(current-group()/self::dtb:h3)}">
                                  <xsl:apply-templates select="current-group()/self::dtb:h3/child::node()"/>
                                </a>
                              </xsl:if>
                              <xsl:if test="$depth &gt; 3">
                                <xsl:variable name="list" as="element()*">
                                  <xsl:for-each-group select="current-group()[not(self::dtb:h3)]" group-starting-with="dtb:h4">
                                    <li>
                                      <xsl:if test="current-group()/self::dtb:h4">
                                        <a href="{pxi:get-or-generate-id(current-group()/self::dtb:h4)}">
                                          <xsl:apply-templates select="current-group()/self::dtb:h4/child::node()"/>
                                        </a>
                                      </xsl:if>
                                      <xsl:if test="$depth &gt; 4">
                                        <xsl:variable name="list" as="element()*">
                                          <xsl:for-each-group select="current-group()[not(self::dtb:h4)]" group-starting-with="dtb:h5">
                                            <li>
                                              <xsl:if test="current-group()/self::dtb:h5">
                                                <a href="{pxi:get-or-generate-id(current-group()/self::dtb:h5)}">
                                                  <xsl:apply-templates select="current-group()/self::dtb:h5/child::node()"/>
                                                </a>
                                              </xsl:if>
                                              <xsl:if test="$depth &gt; 5">
                                                <xsl:variable name="list" as="element()*">
                                                  <xsl:for-each select="current-group()/self::dtb:h6">
                                                    <li>
                                                      <a href="{pxi:get-or-generate-id(.)}">
                                                        <xsl:apply-templates select="node()"/>
                                                      </a>
                                                    </li>
                                                  </xsl:for-each>
                                                </xsl:variable>
                                                <xsl:if test="exists($list)">
                                                  <list>
                                                    <xsl:sequence select="$list"/>
                                                  </list>
                                                </xsl:if>
                                              </xsl:if>
                                            </li>
                                          </xsl:for-each-group>
                                        </xsl:variable>
                                        <xsl:if test="exists($list)">
                                          <list>
                                            <xsl:sequence select="$list"/>
                                          </list>
                                        </xsl:if>
                                      </xsl:if>
                                    </li>
                                  </xsl:for-each-group>
                                </xsl:variable>
                                <xsl:if test="exists($list)">
                                  <list>
                                    <xsl:sequence select="$list"/>
                                  </list>
                                </xsl:if>
                              </xsl:if>
                            </li>
                          </xsl:for-each-group>
                        </xsl:variable>
                        <xsl:if test="exists($list)">
                          <list>
                            <xsl:sequence select="$list"/>
                          </list>
                        </xsl:if>
                      </xsl:if>
                    </li>
                  </xsl:for-each-group>
                </xsl:variable>
                <xsl:if test="exists($list)">
                  <list>
                    <xsl:sequence select="$list"/>
                  </list>
                </xsl:if>
              </xsl:if>
            </li>
          </xsl:for-each-group>
        </xsl:variable>
        <xsl:if test="exists($list)">
          <list id="generated-document-toc">
            <xsl:sequence select="$list"/>
          </list>
          <list id="generated-volume-toc">
            <xsl:sequence select="$list"/>
          </list>
        </xsl:if>
      </xsl:if>
      <xsl:apply-templates/>
    </xsl:copy>
  </xsl:template>
  
  <xsl:template match="dtb:h1|dtb:h2|dtb:h3|dtb:h4|dtb:h5|dtb:h6">
    <xsl:copy>
      <xsl:apply-templates select="@*"/>
      <xsl:if test="not(@id|@xml:id)">
        <xsl:attribute name="xml:id" select="concat(local-name(.),'_',generate-id(.))"/>
      </xsl:if>
      <xsl:apply-templates/>
    </xsl:copy>
  </xsl:template>
  
  <xsl:function name="pxi:get-or-generate-id" as="xs:string">
    <xsl:param name="element" as="element()"/>
    <xsl:sequence select="($element/@id,
                           $element/@xml:id,
                           concat(local-name($element),'_',generate-id($element)))[1]"/>
  </xsl:function>
  
  <xsl:template match="@*|node()">
    <xsl:copy>
      <xsl:apply-templates select="@*|node()"/>
    </xsl:copy>
  </xsl:template>
  
</xsl:stylesheet>
