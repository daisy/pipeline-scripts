<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step
    xmlns:p="http://www.w3.org/ns/xproc"
    xmlns:c="http://www.w3.org/ns/xproc-step"
    xmlns:px="http://www.daisy.org/ns/pipeline/xproc"
    xmlns:pxi="http://www.daisy.org/ns/pipeline/xproc/internal"
    xmlns:pef="http://www.daisy.org/ns/2008/pef"
    exclude-inline-prefixes="#all"
    type="px:xml-to-pef.store" name="store" version="1.0">
    
    <p:input port="source" primary="true" px:media-type="application/x-pef+xml"/>
    
    <p:option name="result" required="false" select="''"/>
    <p:option name="preview" required="false" select="''"/>
    <p:option name="brf" required="false" select="''"/>
    
    <p:option name="brf-table" required="false" select="'org.daisy.braille.table.DefaultTableProvider.TableType.EN_US'"/>
    
    <p:import href="utils/normalize-uri.xpl"/>
    <p:import href="http://www.daisy.org/pipeline/modules/braille/pef-to-html/xproc/pef-to-html.convert.xpl"/>
    <p:import href="http://www.daisy.org/pipeline/modules/braille/pef-calabash/xproc/library.xpl"/>
    
    <!-- ============ -->
    <!-- STORE AS PEF -->
    <!-- ============ -->
    
    <p:choose>
        <p:when test="string-length($result) > 0">
            <pxi:normalize-uri>
                <p:with-option name="href" select="$result"/>
            </pxi:normalize-uri>
            <p:group>
                <p:variable name="result-uri" select="string(/c:result)"/>
                <p:store indent="true" encoding="utf-8" omit-xml-declaration="false">
                    <p:input port="source">
                        <p:pipe step="store" port="source"/>
                    </p:input>
                    <p:with-option name="href" select="$result-uri"/>
                </p:store>
            </p:group>
        </p:when>
        <p:otherwise>
            <p:sink>
                <p:input port="source">
                    <p:empty/>
                </p:input>
            </p:sink>
        </p:otherwise>
    </p:choose>
    
    <!-- ============ -->
    <!-- STORE AS BRF -->
    <!-- ============ -->
    
    <p:choose>
        <p:when test="string-length($brf) > 0">
            <pxi:normalize-uri>
                <p:with-option name="href" select="$brf"/>
            </pxi:normalize-uri>
            <p:group>
                <p:variable name="brf-uri" select="string(/c:result)"/>
                <pef:pef2text breaks="DEFAULT" pad="BOTH">
                    <p:input port="source">
                        <p:pipe step="store" port="source"/>
                    </p:input>
                    <p:with-option name="href" select="$brf-uri"/>
                    <p:with-option name="table" select="$brf-table"/>
                </pef:pef2text>
            </p:group>
        </p:when>
        <p:otherwise>
            <p:sink>
                <p:input port="source">
                    <p:empty/>
                </p:input>
            </p:sink>
        </p:otherwise>
    </p:choose>
    
    <!-- ===================== -->
    <!-- STORE AS HTML PREVIEW -->
    <!-- ===================== -->
    
    <p:choose>
        <p:when test="string-length($preview) > 0">
            <pxi:normalize-uri>
                <p:with-option name="href" select="$preview"/>
            </pxi:normalize-uri>
            <p:group>
                <p:variable name="preview-uri" select="string(/c:result)"/>
                <px:pef-to-html.convert>
                    <p:input port="source">
                        <p:pipe step="store" port="source"/>
                    </p:input>
                    <p:with-option name="table" select="$brf-table"/>
                </px:pef-to-html.convert>
                <p:store indent="false" encoding="utf-8" method="xhtml" omit-xml-declaration="false"
                    doctype-public="-//W3C//DTD XHTML 1.0 Strict//EN" doctype-system="http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">
                    <p:with-option name="href" select="$preview-uri"/>
                </p:store>
            </p:group>
        </p:when>
        <p:otherwise>
            <p:sink>
                <p:input port="source">
                    <p:empty/>
                </p:input>
            </p:sink>
        </p:otherwise>
    </p:choose>
    
</p:declare-step>
