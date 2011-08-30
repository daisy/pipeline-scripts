<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step version="1.0" name="copy-referenced-files" type="pxi:copy-referenced-files"
    xmlns:p="http://www.w3.org/ns/xproc" 
    xmlns:cx="http://xmlcalabash.com/ns/extensions"
    xmlns:pxi="http://www.daisy.org/ns/pipeline/xproc/internal"
    xmlns:z="http://www.daisy.org/ns/z3986/authoring/"
    xmlns:cxf="http://xmlcalabash.com/ns/extensions/fileutils"
    exclude-inline-prefixes="cx p cxf pxi z">

    <p:documentation>
    <p>Take an input ZedAI file and copy from the source directory to the destination directory all referenced files.  This script does not output anything.</p>    
    </p:documentation>

    <p:input port="source" primary="true"/>
    
    <p:option name="output-dir" required="true"/>
    <p:option name="dtbook-base-uri" required="true"/>
    
    <p:import href="http://xmlcalabash.com/extension/steps/library-1.0.xpl"/>
    <p:import href="http://xmlcalabash.com/extension/steps/fileutils.xpl"/>
    
    <p:variable name="out" select="if (ends-with($output-dir, '/')) then $output-dir
        else concat($output-dir, '/')"/>
    
    
    <!-- all the elements that have external file references -->
    <p:for-each name="loop">
        <p:iteration-source select="//*[@src]"/>
        <p:variable name="src" select="*/@src"/>
        
        
        <p:variable name="href-value" select="resolve-uri($src, $dtbook-base-uri)"/>
        <p:variable name="target-value" select="concat($out, $src)"/>
        
        <cx:message>
            <p:with-option name="message" select="$href-value"/>
        </cx:message>

        <cx:message>
            <p:with-option name="message" select="$target-value"/>
        </cx:message>
        
        <cxf:copy name="copy">
            <p:with-option name="href" select="$href-value"/>
            <p:with-option name="target" select="$target-value"/>
        </cxf:copy>
            
    </p:for-each>
    
</p:declare-step>
