<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step version="1.0" name="dtbook-validator.check-images" type="px:dtbook-validator.check-images"
    xmlns:p="http://www.w3.org/ns/xproc" 
    xmlns:c="http://www.w3.org/ns/xproc-step"
    xmlns:cx="http://xmlcalabash.com/ns/extensions"
    xmlns:cxo="http://xmlcalabash.com/ns/extensions/osutils"
    xmlns:px="http://www.daisy.org/ns/pipeline/xproc"
    xmlns:pxi="http://www.daisy.org/ns/pipeline/xproc/internal"    
    xmlns:xhtml="http://www.w3.org/1999/xhtml" 
    xmlns:dtb="http://www.daisy.org/z3986/2005/dtbook/"
    xmlns:m="http://www.w3.org/1998/Math/MathML" 
    xmlns:tmp="http://www.daisy.org/ns/pipeline/tmp"
    xmlns:d="http://www.daisy.org/ns/pipeline/data"
    exclude-inline-prefixes="#all">
    
    <p:documentation xmlns="http://www.w3.org/1999/xhtml">
        <h1 px:role="name">Helper step for DTBook Validator</h1>
        <p px:role="desc">Checks to see if referenced images exist on disk.</p>
    </p:documentation>
    
    <!-- ***************************************************** -->
    <!-- INPUT, OUTPUT and OPTIONS -->
    <!-- ***************************************************** -->
    
    <p:input port="source" primary="true">
        <p:documentation xmlns="http://www.w3.org/1999/xhtml">
            <h1 px:role="name">source</h1>
            <p px:role="desc">A valid DTBook document.</p>
        </p:documentation>
    </p:input>
    
    <p:output port="result" sequence="true">
        <p:documentation xmlns="http://www.w3.org/1999/xhtml">
            <h1 px:role="name">result</h1>
            <p px:role="desc">List of missing images, or an empty sequence if nothing is missing.</p>
        </p:documentation>
    </p:output>
    
    <p:import href="http://xmlcalabash.com/extension/steps/library-1.0.xpl">
        <p:documentation>Calabash extension steps.</p:documentation>
    </p:import>
    
    <p:import href="http://www.daisy.org/pipeline/modules/file-utils/xproc/file-library.xpl">
        <p:documentation>For manipulating files.</p:documentation>
    </p:import>
    
    <p:import
        href="http://www.daisy.org/pipeline/modules/validation-utils/validation-utils-library.xpl">
        <p:documentation> Collection of utilities for validation and reporting. </p:documentation>
    </p:import>
    
    <p:variable name="dtbook-uri" select="base-uri()"/>
    
    <!-- make a list of image paths:
        <d:files>
            <d:file path="file:/full/path/to/image1.jpg" ref="file:/full/path/to/dtbook.xml#ID"/>
            <d:file path="file:/full/path/to/image1.jpg" ref="file:/full/path/to/dtbook.xml#ID"/>
        </d:files>
    -->
    <p:for-each name="list-images">
        <p:iteration-source select="//dtb:img | //m:math"/>
        <p:variable name="refid" select="*/@id"/>
        <p:choose>
            <!-- dtb:img has @src -->
            <p:when test="*/@src">
                <p:variable name="imgpath" select="*/resolve-uri(@src, base-uri(.))"/>
                <p:add-attribute match="d:file">
                    <p:input port="source">
                        <p:inline>
                            <d:file/>
                        </p:inline>
                    </p:input>
                    <p:with-option name="attribute-name" select="'path'"/>
                    <p:with-option name="attribute-value" select="$imgpath"/>
                </p:add-attribute>
            </p:when>
            <!-- m:math has @altimg -->
            <p:otherwise>
                <p:variable name="imgpath" select="*/resolve-uri(@altimg, base-uri(.))"/>
                <p:add-attribute match="d:file">
                    <p:input port="source">
                        <p:inline>
                            <d:file/>
                        </p:inline>
                    </p:input>
                    <p:with-option name="attribute-name" select="'path'"/>
                    <p:with-option name="attribute-value" select="$imgpath"/>
                </p:add-attribute>
            </p:otherwise>
        </p:choose>
        <p:add-attribute match="d:file">
            <p:with-option name="attribute-name" select="'ref'"/>
            <p:with-option name="attribute-value" select="concat($dtbook-uri, '#', $refid)"/>
        </p:add-attribute>
        
    </p:for-each>
    
    <p:wrap-sequence wrapper="files" wrapper-prefix="d" wrapper-namespace="http://www.daisy.org/ns/pipeline/data"/>
    
    <px:check-files-exist name="check-images-exist"/>    
</p:declare-step>
