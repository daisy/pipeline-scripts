<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:html="http://www.w3.org/1999/xhtml" xmlns:epub="http://www.idpf.org/2007/ops" version="2.0">
    <!-- TODO: is the pagebreak *before* or *after* the epub:type="pagebreak"-element?
        "A (sometimes valued) separator denoting the position before which a break
        between two contiguous pages occurs in a statically paginated media."  -->
    <xsl:param name="doc-href" required="yes"/>
    <xsl:template match="@*|node()">
        <xsl:copy>
            <xsl:apply-templates select="@*"/>
            <xsl:if test="@id and concat($doc-href,'#',@id)=/*/*[1]/descendant::html:nav[@epub:type='page-list']/descendant::html:a/@href">
                <xsl:attribute name="epub:type" select="'pagebreak'"/>
            </xsl:if>
            <xsl:apply-templates select="node()"/>
        </xsl:copy>
    </xsl:template>
    <xsl:template match="/*/*[1]"/>
</xsl:stylesheet>
