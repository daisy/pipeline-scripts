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
    <!-- Note that there is NO INPUT required for this step -->
    <!-- ***************************************************** -->
    
    <p:input port="source" primary="true">
        <p:documentation xmlns="http://www.w3.org/1999/xhtml">
            <h1 px:role="name">source</h1>
            <p px:role="desc">A valid DTBook document.</p>
        </p:documentation>
    </p:input>
    
    <!-- format of output: 
        <d:errors>
            <d:error>
                <d:desc>Image not found</d:desc>
                <d:file>file:/path/to/file.jpg</d:file>
                <d:ref>file:/path/to/dtbook.xml#ID</d:ref>
            </d:error>
        </d:errors>
    -->    
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
    
    <p:variable name="dtbook-uri" select="base-uri()"/>
    
    <!-- make a list of image paths:
        <image path="file:/full/path/to/image1.jpg/>
        <image path="file:/full/path/to/image2.jpg/>"
    -->
    <p:for-each name="list-images">
        <p:iteration-source select="//dtb:img | //m:math"/>
        <p:variable name="refid" select="*/@id"/>
        <p:choose>
            <!-- dtb:img has @src -->
            <p:when test="*/@src">
                <p:variable name="imgpath" select="*/resolve-uri(@src, base-uri(.))"/>
                <p:add-attribute match="image">
                    <p:input port="source">
                        <p:inline>
                            <image/>
                        </p:inline>
                    </p:input>
                    <p:with-option name="attribute-name" select="'path'"/>
                    <p:with-option name="attribute-value" select="$imgpath"/>
                </p:add-attribute>
            </p:when>
            <!-- m:math has @altimg -->
            <p:otherwise>
                <p:variable name="imgpath" select="*/resolve-uri(@altimg, base-uri(.))"/>
                <p:variable name="refid" select="*/@id"/>
                <p:add-attribute match="image">
                    <p:input port="source">
                        <p:inline>
                            <image/>
                        </p:inline>
                    </p:input>
                    <p:with-option name="attribute-name" select="'path'"/>
                    <p:with-option name="attribute-value" select="$imgpath"/>
                </p:add-attribute>
            </p:otherwise>
        </p:choose>
        <p:add-attribute match="image">
            <p:with-option name="attribute-name" select="'refid'"/>
            <p:with-option name="attribute-value" select="$refid"/>
        </p:add-attribute>
    </p:for-each>
    
    <p:for-each name="check-each-image">
        <p:variable name="imagepath" select="*/@path"/>
        <p:variable name="id" select="*/@refid"/>
        <p:try>
            <p:group>
                <px:info>
                    <p:with-option name="href" select="$imagepath"/>
                </px:info>
            </p:group>
            <p:catch>
                <p:identity>
                    <p:input port="source">
                        <p:empty/>
                    </p:input>
                </p:identity>
            </p:catch>
        </p:try>
        
        <p:wrap-sequence wrapper="info"/>
        
        <!-- the <info> element, generated above, will be empty if the file was not found -->
        <p:choose name="file-exists">
            <p:when test="empty(/info/*)">
                <p:output port="result"/>
                <p:string-replace match="//d:file/text()">
                    <p:with-option name="replace" select="concat('&quot;', $imagepath, '&quot;')"/>
                    <p:input port="source">
                        <p:inline>
                            <d:error>
                                <d:desc>Image not found</d:desc>
                                <d:file>@@</d:file>
                                <d:ref>@@</d:ref>
                            </d:error>
                        </p:inline>
                    </p:input>
                </p:string-replace>
                <p:choose>
                    <p:when test="string-length($id) > 0">
                        <p:string-replace match="//d:ref/text()">
                            <p:with-option name="replace" select="concat('&quot;', $dtbook-uri, '#', $id, '&quot;')"/>
                        </p:string-replace>        
                    </p:when>
                    <p:otherwise>
                        <p:string-replace match="//d:ref/text()">
                            <p:with-option name="replace" select="'&quot;&quot;'"/>
                        </p:string-replace>
                    </p:otherwise>
                </p:choose>
            </p:when>
            <p:otherwise>
                <p:output port="result"/>
                <p:identity>
                    <p:input port="source">
                        <p:empty/>
                    </p:input>
                </p:identity>
            </p:otherwise>
        </p:choose>
    </p:for-each>  
    
    <p:wrap-sequence wrapper="errors" wrapper-prefix="d" wrapper-namespace="http://www.daisy.org/ns/pipeline/data"/>
    
</p:declare-step>
