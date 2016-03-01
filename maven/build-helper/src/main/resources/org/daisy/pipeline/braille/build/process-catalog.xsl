<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:cat="urn:oasis:names:tc:entity:xmlns:xml:catalog"
                xmlns:px="http://www.daisy.org/ns/pipeline"
                xmlns:pxd="http://www.daisy.org/ns/pipeline/xproc"
                xmlns:xd="http://www.daisy.org/ns/pipeline/doc"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns:c="http://www.w3.org/ns/xproc-step"
                xmlns:p="http://www.w3.org/ns/xproc"
                xmlns:html="http://www.w3.org/1999/xhtml"
                exclude-result-prefixes="#all" version="2.0">
    
    <xsl:param name="outputDir" required="no" select="''" as="xs:string"/>
    <xsl:param name="version" required="yes"  as="xs:string"/>
    
    <xsl:template match="/">
        <xsl:result-document href="{$outputDir}/bnd.bnd" method="text" xml:space="preserve"><c:data>
<xsl:if test="//cat:nextCatalog">Require-Bundle: <xsl:value-of select="string-join(//cat:nextCatalog/translate(@catalog,':','.'),',')"/></xsl:if>
<xsl:if test="//cat:uri[@px:script] or //cat:uri[@px:data-type]">
        Service-Component: <xsl:value-of select="string-join((//cat:uri[@px:script]/concat('OSGI-INF/',replace(document(@uri,..)/*/@type,'.*:',''),'.xml'),//cat:uri[@px:data-type]/concat('OSGI-INF/',replace(document(@uri,..)/*/@id,'.*:',''),'.xml')),',')"/></xsl:if>
<!-- my xslt skills are long forgotten, this sucks-->
<xsl:if test="//cat:uri[@px:data-type] and not(//cat:uri[@px:script])">
        Import-Package: org.daisy.pipeline.datatypes,*</xsl:if>
<xsl:if test="//cat:uri[@px:script] and not(//cat:uri[@px:data-type])">
        Import-Package: org.daisy.pipeline.script,*</xsl:if>
<xsl:if test="//cat:uri[@px:script] and //cat:uri[@px:data-type]">
        Import-Package: org.daisy.pipeline.script,org.daisy.pipeline.datatypes,*</xsl:if>
        </c:data></xsl:result-document>
        <xsl:result-document href="{$outputDir}/META-INF/catalog.xml" method="xml">
            <xsl:apply-templates select="/*" mode="ds"/>
        </xsl:result-document>
    </xsl:template>
    
    <xsl:template match="cat:uri[@px:script]" mode="ds" priority="2">
        <xsl:variable name="type" select="string(document(@uri,.)/*/@type)"/>
        <xsl:variable name="id" select="if (namespace-uri-for-prefix(substring-before($type,':'),document(@uri,.)/*)='http://www.daisy.org/ns/pipeline/xproc') then substring-after($type,':') else $type"/>
        <xsl:variable name="name" select="(document(@uri,.)//*[tokenize(@pxd:role,'\s+')='name'])[1]"/>
        <xsl:variable name="descr" select="(document(@uri,.)//*[tokenize(@pxd:role,'\s+')='desc'])[1]"/>
        <xsl:result-document href="{$outputDir}/OSGI-INF/{replace($id,'.*:','')}.xml" method="xml">
            <scr:component xmlns:scr="http://www.osgi.org/xmlns/scr/v1.1.0" immediate="true" name="{$id}">
                <scr:implementation class="org.daisy.pipeline.script.XProcScriptService"/>
                <scr:service>
                    <scr:provide interface="org.daisy.pipeline.script.XProcScriptService"/>
                </scr:service>
                <scr:property name="script.id" type="String" value="{$id}"/>
                <scr:property name="script.name" type="String" value="{$name}"/>
                <scr:property name="script.description" type="String" value="{$descr}"/>
                <scr:property name="script.url" type="String" value="{@name}"/>
                <scr:property name="script.version" type="String" value="{$version}"/>
            </scr:component>
        </xsl:result-document>
        <xsl:next-match/>
    </xsl:template>
    
    <xsl:template match="cat:uri[@px:extends]" mode="ds">
        <xsl:next-match/>
        <xsl:result-document href="{$outputDir}/generated-scripts/{replace(@uri,'^.*/([^/]+)$','$1')}" method="xml">
            <xsl:variable name="original-script" select="document((//cat:uri[current()/@px:extends=@name]/@uri, @px:extends)[1])"/>
            <xsl:if test="not($original-script)">
                <xsl:message terminate="yes" select="concat('Unable to resolve script extension: ', @px:extends)"/>
            </xsl:if>
            <xsl:apply-templates select="document(@uri,.)" mode="xproc">
                <xsl:with-param name="original-script" select="$original-script" tunnel="yes"/>
            </xsl:apply-templates>
        </xsl:result-document>
    </xsl:template>
    
    <xsl:template match="cat:uri[@px:extends]/@uri" mode="ds">
        <xsl:attribute name="uri" select="concat('../generated-scripts/',replace(.,'^.*/([^/]+)$','$1'))"/>
    </xsl:template>
    
    <xsl:template match="cat:uri[@px:data-type]" mode="ds">
        <xsl:variable name="id" select="string(document(@uri,.)/*/@id)"/>
        <xsl:result-document href="{$outputDir}/OSGI-INF/{replace($id,'.*:','')}.xml" method="xml">
            <scr:component xmlns:scr="http://www.osgi.org/xmlns/scr/v1.1.0" immediate="true" name="{$id}">
                <scr:implementation class="org.daisy.pipeline.datatypes.UrlBasedDatatypeService"/>
                <scr:service>
                    <scr:provide interface="org.daisy.pipeline.datatypes.DatatypeService"/>
                </scr:service>
                <scr:reference bind="setUriResolver" cardinality="1..1" interface="javax.xml.transform.URIResolver" name="resolver" policy="static"/>
                <scr:property name="data-type.id" type="String" value="{$id}"/>
                <scr:property name="data-type.url" type="String" value="{@name}"/>
            </scr:component>
        </xsl:result-document>
        <xsl:next-match/>
    </xsl:template>
    
    <xsl:template match="cat:uri/@px:script|
                         cat:uri/@px:extends|
                         cat:uri/@px:data-type"
                  mode="ds"/>
    
    <xsl:template match="p:input[@port] | p:option[@name]" mode="xproc">
        <xsl:param name="original-script" as="document-node()" tunnel="yes"/>
        <xsl:variable name="name" as="xs:string" select="(@port, @name)[1]"/>
        <xsl:variable name="original-input-or-option" as="element()?" select="$original-script/*/(p:input|p:option)[(@port,@name)=$name]"/>
        <xsl:variable name="new-attributes" as="xs:string*" select="@*/concat('{',namespace-uri(.),'}',name(.))"/>
        <xsl:copy>
            <xsl:apply-templates select="@*" mode="#current"/>
            <xsl:sequence select="$original-input-or-option/@*[not(concat('{',namespace-uri(.),'}',name(.))=$new-attributes or name()='select' and current()/@required = 'true')]"/>
            <xsl:if test="not(p:documentation)">
                <xsl:sequence select="$original-input-or-option/p:documentation"/>
            </xsl:if>
            <xsl:apply-templates select="node()" mode="#current">
                <xsl:with-param name="original-input-or-option" select="$original-input-or-option" tunnel="yes"/>
            </xsl:apply-templates>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="p:input/p:documentation | p:option/p:documentation" mode="xproc">
        <xsl:param name="original-input-or-option" as="element()?" tunnel="yes"/>
        <xsl:copy>
            <xsl:apply-templates select="@*"/>
            <xsl:if test="not(descendant::*[tokenize(@pxd:role,'\s+')='name'])">
                <xsl:sequence select="$original-input-or-option/p:documentation/*[tokenize(@pxd:role,'\s+')='name']"/>
            </xsl:if>
            <xsl:apply-templates select="node()" mode="#current">
                <xsl:with-param name="original-input-or-option" as="element()?" tunnel="yes"/>
            </xsl:apply-templates>
            <xsl:if test="not(descendant::*[tokenize(@pxd:role,'\s+')='desc'])">
                <xsl:sequence select="$original-input-or-option/p:documentation/*[tokenize(@pxd:role,'\s+')='desc']"/>
            </xsl:if>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="*[tokenize(@pxd:role,'\s+')=('name','desc')]" mode="xproc">
        <xsl:param name="original-input-or-option" as="element()?" tunnel="yes"/>
        <xsl:copy>
            <xsl:apply-templates select="@*" mode="#current"/>
            <xsl:if test="@pxd:inherit = 'prepend'">
                <xsl:copy-of select="$original-input-or-option//*[tokenize(@pxd:role,'\s+')=current()/tokenize(@pxd:role,'\s+')]/node()"/>
            </xsl:if>
            <xsl:copy-of select="node()"/>
            <xsl:if test="@pxd:inherit = 'append'">
                <xsl:copy-of select="$original-input-or-option//*[tokenize(@pxd:role,'\s+')=current()/tokenize(@pxd:role,'\s+')]/node()"/>
            </xsl:if>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="@*|node()" mode="ds xproc">
        <xsl:copy>
            <xsl:apply-templates select="@*|node()" mode="#current"/>
        </xsl:copy>
    </xsl:template>
    
</xsl:stylesheet>
