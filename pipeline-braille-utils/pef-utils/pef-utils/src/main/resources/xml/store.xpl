<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step
    xmlns:p="http://www.w3.org/ns/xproc"
    xmlns:c="http://www.w3.org/ns/xproc-step"
    xmlns:px="http://www.daisy.org/ns/pipeline/xproc"
    xmlns:pxi="http://www.daisy.org/ns/pipeline/xproc/internal"
    xmlns:pef="http://www.daisy.org/ns/2008/pef"
    exclude-inline-prefixes="#all"
    type="pef:store" name="store" version="1.0">
    
    <p:input port="source" primary="true" px:media-type="application/x-pef+xml"/>
    
    <p:option name="output-dir" required="true"/>
    <p:option name="name" required="true"/>
    
    <p:option name="include-preview" required="false" select="'false'"/>
    <p:option name="include-brf" required="false" select="'false'"/>
    <p:option name="brf-table" required="false" select="'(id:&quot;org.daisy.braille.impl.table.DefaultTableProvider.TableType.EN_US&quot;)'"/>
    
    <p:import href="utils/normalize-uri.xpl"/>
    <p:import href="pef-to-html.convert.xpl"/>
    <p:import href="pef2text.xpl"/>
    <p:import href="http://www.daisy.org/pipeline/modules/file-utils/library.xpl"/>
    <p:import href="http://www.daisy.org/pipeline/modules/common-utils/library.xpl"/>
    
    <pxi:normalize-uri>
        <p:with-option name="href" select="$output-dir"/>
    </pxi:normalize-uri>
    
    <px:message severity="DEBUG">
        <p:with-option name="message" select="concat('Storing PEF as ''', $name, '.pef','''')"/>
    </px:message>
    <p:group>
        <p:variable name="output-dir-uri" select="string(/c:result)"/>
        
        <!-- ============ -->
        <!-- STORE AS PEF -->
        <!-- ============ -->
        
        <p:store indent="true" encoding="utf-8" omit-xml-declaration="false">
            <p:input port="source">
                <p:pipe step="store" port="source"/>
            </p:input>
            <p:with-option name="href" select="concat($output-dir-uri, $name, '.pef')"/>
        </p:store>
        
        <!-- ============ -->
        <!-- STORE AS BRF -->
        <!-- ============ -->

        <p:choose>
            <p:when test="$include-brf='true'">
                <p:identity>
                    <p:input port="source">
                        <p:pipe step="store" port="source"/>
                    </p:input>
                </p:identity>
                <px:message severity="DEBUG">
                    <p:with-option name="message" select="concat('Storing BRF as ''', $name, '.brf','''')"/>
                </px:message>
                <pef:pef2text breaks="DEFAULT" pad="BOTH">
                    <p:with-option name="href" select="concat($output-dir-uri, $name, '.brf')"/>
                    <p:with-option name="table" select="$brf-table"/>
                </pef:pef2text>
            </p:when>
            <p:otherwise>
                <p:identity>
                    <p:input port="source">
                        <p:empty/>
                    </p:input>
                </p:identity>
                <px:message severity="DEBUG" message="Not storing as BRF"/>
                <p:sink/>
            </p:otherwise>
        </p:choose>
        
        <!-- ==================== -->
        <!-- STORE AS PEF PREVIEW -->
        <!-- ==================== -->
        
        <p:choose>
            <p:when test="$include-preview='true'">
                <p:identity>
                    <p:input port="source">
                        <p:pipe step="store" port="source"/>
                    </p:input>
                </p:identity>
                <px:message severity="DEBUG">
                    <p:with-option name="message" select="concat('Converting PEF to HTML preview using the BRF table ''',$brf-table,'''')"/>
                </px:message>
                <px:pef-to-html.convert>
                    <p:with-option name="table" select="$brf-table"/>
                </px:pef-to-html.convert>
                <px:message severity="DEBUG">
                    <p:with-option name="message" select="concat('Storing HTML preview as ''', $name, '.pef.html','''')"/>
                </px:message>
                <p:store indent="false" encoding="utf-8" method="xhtml" omit-xml-declaration="false"
                    doctype-public="-//W3C//DTD XHTML 1.0 Strict//EN" doctype-system="http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">
                    <p:with-option name="href" select="concat($output-dir-uri, $name, '.pef.html')"/>
                </p:store>
                <p:identity>
                    <p:input port="source">
                        <p:inline>
                            <irrelevant/>
                        </p:inline>
                    </p:input>
                </p:identity>
                <px:message severity="DEBUG" message="Copying braille font file (odt2braille8.ttf) to HTML preview directory"/>
                <px:copy-resource fail-on-error="true">
                    <p:with-option name="href" select="resolve-uri('../odt2braille8.ttf')"/>
                    <p:with-option name="target" select="concat($output-dir-uri, 'odt2braille8.ttf')"/>
                </px:copy-resource>
                <p:sink/>
            </p:when>
            <p:otherwise>
                <p:identity>
                    <p:input port="source">
                        <p:empty/>
                    </p:input>
                </p:identity>
                <px:message severity="DEBUG" message="Not including HTML preview"/>
                <p:sink/>
            </p:otherwise>
        </p:choose>
    </p:group>
    
</p:declare-step>
