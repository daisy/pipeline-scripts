<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step xmlns:p="http://www.w3.org/ns/xproc" xmlns:c="http://www.w3.org/ns/xproc-step"
    version="1.0" name="main">

    <p:input port="source" primary="true"/>
    <p:output port="result"/>

    <p:for-each>
        <p:iteration-source select="//file"/>
        <p:variable name="expath" select="."/>
        <p:load>
            <p:with-option name="href" select="$expath"/>
        </p:load>
        <p:xslt>
            <p:input port="stylesheet">
                <p:inline>
                    <xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                        xmlns:pkg="http://expath.org/ns/pkg"
                        xmlns="urn:oasis:names:tc:entity:xmlns:xml:catalog" version="1.0"
                        exclude-result-prefixes="#all">
                        <xsl:template match="pkg:package">
                            <catalog>
                                <xsl:apply-templates select="//pkg:import-uri"/>
                            </catalog>
                        </xsl:template>

                        <xsl:template match="pkg:import-uri">
                            <uri name="{.}" uri="{concat('../',//pkg:module/@name,'/',following-sibling::pkg:file)}"/>
                        </xsl:template>
                    </xsl:stylesheet>
                </p:inline>
            </p:input>
            <p:input port="parameters">
                <p:empty/>
            </p:input>
        </p:xslt>
        <p:store doctype-public="-//OASIS/DTD Entity Resolution XML Catalog V1.0//EN"
            doctype-system="http://www.oasis-open.org/committees/entity/release/1.0/catalog.dtd"
            omit-xml-declaration="false" indent="true">
            <p:with-option name="href"
                select="replace($expath,'expath-pkg.xml','META-INF/catalog.xml')"/>
        </p:store>
    </p:for-each>
    
    
    <p:xslt>
        <p:input port="source">
            <p:pipe port="source" step="main"/>
        </p:input>
        <p:input port="stylesheet">
            <p:inline>
                <xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                    xmlns:pkg="http://expath.org/ns/pkg"
                    xmlns="urn:oasis:names:tc:entity:xmlns:xml:catalog" version="1.0"
                    exclude-result-prefixes="#all">
                    <xsl:template match="doc">
                        <catalog>
                            <xsl:apply-templates select="//file"/>
                        </catalog>
                    </xsl:template>
                    
                    <xsl:template match="file">
                        <nextCatalog catalog="{replace(.,'expath-pkg.xml','META-INF/catalog.xml')}"/>
                    </xsl:template>
                </xsl:stylesheet>
            </p:inline>
        </p:input>
        <p:input port="parameters">
            <p:empty/>
        </p:input>
    </p:xslt>
    <!--<p:store doctype-public="-//OASIS/DTD Entity Resolution XML Catalog V1.0//EN"
        doctype-system="http://www.oasis-open.org/committees/entity/release/1.0/catalog.dtd"
        omit-xml-declaration="false" indent="true" href="catalog.xml"/>-->
    
</p:declare-step>
