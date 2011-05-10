<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step version="1.0" name="moveout-definition-contents"
    type="pxi:moveout-definition-contents"
    xmlns:p="http://www.w3.org/ns/xproc"
    xmlns:c="http://www.w3.org/ns/xproc-step" 
    xmlns:cx="http://xmlcalabash.com/ns/extensions"
    xmlns:cxo="http://xmlcalabash.com/ns/extensions/osutils"
    xmlns:pxi="http://www.daisy.org/ns/pipeline/xproc/internal"
    xmlns:xd="http://www.daisy.org/ns/pipeline/doc" 
    exclude-inline-prefixes="cx p c cxo pxi">
    
    <p:input port="source" primary="true"/>
    <p:input port="parameters" kind="parameter"/>
    <p:output port="result"/>
    
    <p:import href="http://xmlcalabash.com/extension/steps/library-1.0.xpl"/>
    
    <p:xslt name="moveout-div">
        <p:input port="stylesheet">
            <p:inline>
                <xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                    xmlns:dtb="http://www.daisy.org/z3986/2005/dtbook/"
                    exclude-result-prefixes="dtb" version="2.0">
                    <xsl:include href="moveout-generic.xsl"/>
                    <xsl:output indent="yes" method="xml"/>
                    
                    <xsl:template match="/">
                        <xsl:call-template name="main">
                            <xsl:with-param name="document" select="//dtb:dtbook[1]"/>
                        </xsl:call-template>
                    </xsl:template>
                    
                    <xsl:template name="main">
                        <xsl:param name="document"/>
                        <xsl:message>Move out div</xsl:message>
                        <xsl:call-template name="test-and-move">
                            <xsl:with-param name="root-elem" select="if ($document instance of document-node()) then $document/*[1] else $document"/>
                            <xsl:with-param name="target-elem-name" select="'div'" tunnel="yes"/>
                            <xsl:with-param name="valid-parents-list" select="tokenize('annotation-block,prodnote,sidebar,div,caption,code-block,li,note,img,blockquote,level1,level2,level3,level4,level5,level6,level,td,th,item', ',')"  tunnel="yes"/>                            
                        </xsl:call-template>
                        <xsl:message>--Done</xsl:message>
                    </xsl:template>  
                </xsl:stylesheet>
            </p:inline>
        </p:input>
    </p:xslt>
    <p:xslt name="moveout-poem">
        <p:input port="stylesheet">
            <p:inline>
                <xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                    xmlns:dtb="http://www.daisy.org/z3986/2005/dtbook/"
                    exclude-result-prefixes="dtb" version="2.0">
                    <xsl:include href="moveout-generic.xsl"/>
                    <xsl:output indent="yes" method="xml"/>
                    
                    <xsl:template match="/">
                        <xsl:call-template name="main">
                            <xsl:with-param name="document" select="//dtb:dtbook[1]"/>
                        </xsl:call-template>
                    </xsl:template>
                    
                    <xsl:template name="main">
                        <xsl:param name="document"/>
                        <xsl:message>Move out div</xsl:message>
                        <xsl:call-template name="test-and-move">
                            <xsl:with-param name="root-elem" select="if ($document instance of document-node()) then $document/*[1] else $document"/>
                            <xsl:with-param name="target-elem-name" select="'poem'" tunnel="yes"/>
                            <xsl:with-param name="valid-parents-list" select="tokenize('annotation-block,prodnote,sidebar,div,caption,code-block,li,note,img,blockquote,level1,level2,level3,level4,level5,level6,level,td,th,item', ',')"  tunnel="yes"/>                            
                        </xsl:call-template>
                        <xsl:message>--Done</xsl:message>
                    </xsl:template>  
                </xsl:stylesheet>
            </p:inline>
        </p:input>
    </p:xslt>
    <p:xslt name="moveout-linegroup">
        <p:input port="stylesheet">
            <p:inline>
                <xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                    xmlns:dtb="http://www.daisy.org/z3986/2005/dtbook/"
                    exclude-result-prefixes="dtb" version="2.0">
                    <xsl:include href="moveout-generic.xsl"/>
                    <xsl:output indent="yes" method="xml"/>
                    
                    <xsl:template match="/">
                        <xsl:call-template name="main">
                            <xsl:with-param name="document" select="//dtb:dtbook[1]"/>
                        </xsl:call-template>
                    </xsl:template>
                    
                    <xsl:template name="main">
                        <xsl:param name="document"/>
                        <xsl:message>Move out linegroup</xsl:message>
                        <xsl:call-template name="test-and-move">
                            <xsl:with-param name="root-elem" select="if ($document instance of document-node()) then $document/*[1] else $document"/>
                            <xsl:with-param name="target-elem-name" select="'linegroup'" tunnel="yes"/>
                            <xsl:with-param name="valid-parents-list" select="tokenize('annotation-block,prodnote,sidebar,div,caption,code-block,li,note,img,blockquote,level1,level2,level3,level4,level5,level6,level,td,th,item', ',')"  tunnel="yes"/>                            
                        </xsl:call-template>
                        <xsl:message>--Done</xsl:message>
                    </xsl:template>  
                </xsl:stylesheet>
            </p:inline>
        </p:input>
    </p:xslt>
    <p:xslt name="moveout-table">
        <p:input port="stylesheet">
            <p:inline>
                <xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                    xmlns:dtb="http://www.daisy.org/z3986/2005/dtbook/"
                    exclude-result-prefixes="dtb" version="2.0">
                    <xsl:include href="moveout-generic.xsl"/>
                    <xsl:output indent="yes" method="xml"/>
                    
                    <xsl:template match="/">
                        <xsl:call-template name="main">
                            <xsl:with-param name="document" select="//dtb:dtbook[1]"/>
                        </xsl:call-template>
                    </xsl:template>
                    
                    <xsl:template name="main">
                        <xsl:param name="document"/>
                        <xsl:message>Move out table</xsl:message>
                        <xsl:call-template name="test-and-move">
                            <xsl:with-param name="root-elem" select="if ($document instance of document-node()) then $document/*[1] else $document"/>
                            <xsl:with-param name="target-elem-name" select="'table'" tunnel="yes"/>
                            <xsl:with-param name="valid-parents-list" select="tokenize('annotation-block,prodnote,sidebar,div,caption,li,note,img,blockquote,level1,level2,level3,level4,level5,level6,level,td,th,item', ',')"  tunnel="yes"/>                            
                        </xsl:call-template>
                        <xsl:message>--Done</xsl:message>
                    </xsl:template>  
                </xsl:stylesheet>
            </p:inline>
        </p:input>
    </p:xslt>
    <p:xslt name="moveout-sidebar">
        <p:input port="stylesheet">
            <p:inline>
                <xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                    xmlns:dtb="http://www.daisy.org/z3986/2005/dtbook/"
                    exclude-result-prefixes="dtb" version="2.0">
                    <xsl:include href="moveout-generic.xsl"/>
                    <xsl:output indent="yes" method="xml"/>
                    
                    <xsl:template match="/">
                        <xsl:call-template name="main">
                            <xsl:with-param name="document" select="//dtb:dtbook[1]"/>
                        </xsl:call-template>
                    </xsl:template>
                    
                    <xsl:template name="main">
                        <xsl:param name="document"/>
                        <xsl:message>Move out sidebar</xsl:message>
                        <xsl:call-template name="test-and-move">
                            <xsl:with-param name="root-elem" select="if ($document instance of document-node()) then $document/*[1] else $document"/>
                            <xsl:with-param name="target-elem-name" select="'sidebar'" tunnel="yes"/>
                            <xsl:with-param name="valid-parents-list" select="tokenize('annotation-block,prodnote,sidebar,div,caption,li,note,img,blockquote,level1,level2,level3,level4,level5,level6,level,td,th,item', ',')"  tunnel="yes"/>                            
                        </xsl:call-template>
                        <xsl:message>--Done</xsl:message>
                    </xsl:template>  
                </xsl:stylesheet>
            </p:inline>
        </p:input>
    </p:xslt>
    <p:xslt name="moveout-note">
        <p:input port="stylesheet">
            <p:inline>
                <xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                    xmlns:dtb="http://www.daisy.org/z3986/2005/dtbook/"
                    exclude-result-prefixes="dtb" version="2.0">
                    <xsl:include href="moveout-generic.xsl"/>
                    <xsl:output indent="yes" method="xml"/>
                    
                    <xsl:template match="/">
                        <xsl:call-template name="main">
                            <xsl:with-param name="document" select="//dtb:dtbook[1]"/>
                        </xsl:call-template>
                    </xsl:template>
                    
                    <xsl:template name="main">
                        <xsl:param name="document"/>
                        <xsl:message>Move out note</xsl:message>
                        <xsl:call-template name="test-and-move">
                            <xsl:with-param name="root-elem" select="if ($document instance of document-node()) then $document/*[1] else $document"/>
                            <xsl:with-param name="target-elem-name" select="'note'" tunnel="yes"/>
                            <xsl:with-param name="valid-parents-list" select="tokenize('annotation-block,prodnote,sidebar,div,caption,li,note,img,blockquote,level1,level2,level3,level4,level5,level6,level,td,th,item', ',')"  tunnel="yes"/>                            
                        </xsl:call-template>
                        <xsl:message>--Done</xsl:message>
                    </xsl:template>  
                </xsl:stylesheet>
            </p:inline>
        </p:input>
    </p:xslt>
    <p:xslt name="moveout-epigraph">
        <p:input port="stylesheet">
            <p:inline>
                <xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                    xmlns:dtb="http://www.daisy.org/z3986/2005/dtbook/"
                    exclude-result-prefixes="dtb" version="2.0">
                    <xsl:include href="moveout-generic.xsl"/>
                    <xsl:output indent="yes" method="xml"/>
                    
                    <xsl:template match="/">
                        <xsl:call-template name="main">
                            <xsl:with-param name="document" select="//dtb:dtbook[1]"/>
                        </xsl:call-template>
                    </xsl:template>
                    
                    <xsl:template name="main">
                        <xsl:param name="document"/>
                        <xsl:message>Move out epigraph</xsl:message>
                        <xsl:call-template name="test-and-move">
                            <xsl:with-param name="root-elem" select="if ($document instance of document-node()) then $document/*[1] else $document"/>
                            <xsl:with-param name="target-elem-name" select="'epigraph'" tunnel="yes"/>
                            <xsl:with-param name="valid-parents-list" select="tokenize('annotation-block,prodnote,sidebar,div,caption,code-block,li,note,img,blockquote,level1,level2,level3,level4,level5,level6,level,td,th,item', ',')"  tunnel="yes"/>                            
                        </xsl:call-template>
                        <xsl:message>--Done</xsl:message>
                    </xsl:template>  
                </xsl:stylesheet>
            </p:inline>
        </p:input>
    </p:xslt>
    <p:xslt name="moveout-annotation-block">
        <p:input port="stylesheet">
            <p:inline>
                <xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                    xmlns:dtb="http://www.daisy.org/z3986/2005/dtbook/"
                    exclude-result-prefixes="dtb" version="2.0">
                    <xsl:include href="moveout-generic.xsl"/>
                    <xsl:output indent="yes" method="xml"/>
                    
                    <xsl:template match="/">
                        <xsl:call-template name="main">
                            <xsl:with-param name="document" select="//dtb:dtbook[1]"/>
                        </xsl:call-template>
                    </xsl:template>
                    
                    <xsl:template name="main">
                        <xsl:param name="document"/>
                        <xsl:message>Move out annotation-block</xsl:message>
                        <xsl:call-template name="test-and-move">
                            <xsl:with-param name="root-elem" select="if ($document instance of document-node()) then $document/*[1] else $document"/>
                            <xsl:with-param name="target-elem-name" select="'annotation-block'" tunnel="yes"/>
                            <xsl:with-param name="valid-parents-list" select="tokenize('annotation-block,prodnote,sidebar,div,caption,li,note,img,blockquote,level1,level2,level3,level4,level5,level6,level,td,th,item', ',')"  tunnel="yes"/>                            
                        </xsl:call-template>
                        <xsl:message>--Done</xsl:message>
                    </xsl:template>  
                </xsl:stylesheet>
            </p:inline>
        </p:input>
    </p:xslt>
</p:declare-step>
