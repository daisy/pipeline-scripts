<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step type="lblxml:format-side-border" name="format-side-border"
    xmlns:p="http://www.w3.org/ns/xproc"
    xmlns:px="http://www.daisy.org/ns/pipeline/xproc"
    xmlns:brl="http://www.daisy.org/ns/pipeline/braille"
    xmlns:lblxml="http://xmlcalabash.com/ns/extensions/liblouisxml"
    version="1.0">
    
    <p:input port="source" sequence="false" primary="true"/>
    <p:input port="config-files" sequence="false"/>
    <p:input port="semantic-files" sequence="false"/>
    <p:option name="temp-dir" required="true"/>
    <p:output port="result" sequence="false" primary="true"/>
    
    <p:import href="xml2brl.xpl"/>    
    
    <p:choose>
        <p:when test="//lblxml:side-border">
            
            <p:xslt>
                <p:input port="stylesheet">
                    <p:document href="../xslt/select-side-border.xsl"/>
                </p:input>
                <p:input port="parameters">
                    <p:empty/>
                </p:input>
            </p:xslt>
            
            <lblxml:xml2brl name="xml2brl">
                <p:input port="config-files">
                    <p:pipe step="format-side-border" port="config-files"/>
                </p:input>
                <p:input port="semantic-files">
                    <p:pipe step="format-side-border" port="semantic-files"/>
                </p:input>
                <p:with-option name="line-width" select="/descendant::lblxml:side-border[1]/@width">
                    <p:pipe step="format-side-border" port="source"/>
                </p:with-option>
                <p:with-option name="temp-dir" select="$temp-dir">
                    <p:empty/>
                </p:with-option>
            </lblxml:xml2brl>
            
            <p:xslt name="preformatted">
                <p:input port="stylesheet">
                    <p:document href="../xslt/read-xml2brl-output.xsl"/>
                </p:input>
                <p:input port="parameters">
                    <p:empty/>
                </p:input>
                <p:with-param name="width" select="/descendant::lblxml:side-border[1]/@width">
                    <p:pipe step="format-side-border" port="source"/>
                </p:with-param>
                <p:with-param name="margin-left" select="/descendant::lblxml:side-border[1]/@margin-left">
                    <p:pipe step="format-side-border" port="source"/>
                </p:with-param>
                <p:with-param name="border-left" select="/descendant::lblxml:side-border[1]/@border-left">
                    <p:pipe step="format-side-border" port="source"/>
                </p:with-param>
                <p:with-param name="border-right" select="/descendant::lblxml:side-border[1]/@border-right">
                    <p:pipe step="format-side-border" port="source"/>
                </p:with-param>
            </p:xslt>
            
            <p:replace match="lblxml:side-border[not(preceding::lblxml:side-border)]">
                <p:input port="source">
                    <p:pipe step="format-side-border" port="source"/>
                </p:input>
                <p:input port="replacement">
                    <p:pipe step="preformatted" port="result"/>
                </p:input>
            </p:replace>
            
            <lblxml:format-side-border>
                <p:input port="config-files">
                    <p:pipe step="format-side-border" port="config-files"/>
                </p:input>
                <p:input port="semantic-files">
                    <p:pipe step="format-side-border" port="semantic-files"/>
                </p:input>
                <p:with-option name="temp-dir" select="$temp-dir">
                    <p:empty/>
                </p:with-option>
            </lblxml:format-side-border>
            
        </p:when>
        
        <p:otherwise>
            <p:identity/>
        </p:otherwise>
    </p:choose>
    
</p:declare-step>
