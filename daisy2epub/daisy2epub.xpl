<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step xmlns:p="http://www.w3.org/ns/xproc" xmlns:c="http://www.w3.org/ns/xproc-step"
    xmlns:d2e="http://pipeline.daisy.org/ns/daisy2epub/" xmlns:opf="http://www.idpf.org/2007/opf" version="1.0">

    <p:output port="result">
        <p:pipe port="result" step="epub-media-overlay"/>
    </p:output>

    <p:option name="nccFile" required="true"/>
    <p:option name="outDir" required="true"/>

    <p:import href="daisy2epub-library.xpl"/>

    <p:variable name="nccPath" select="p:resolve-uri($nccFile,base-uri())">
        <p:document href="daisy2epub.xpl"/>
    </p:variable>
    <p:variable name="inPath" select="replace($nccPath,'[^/]+$','')">
        <p:document href="daisy2epub.xpl"/>
    </p:variable>
    <p:variable name="outPath"
        select="replace(p:resolve-uri(concat($outDir,'/'),base-uri()),'[^/]+$','')">
        <p:document href="daisy2epub.xpl"/>
    </p:variable>

    <p:group name="daisy-ncc">
        <p:documentation><![CDATA[
            Loads and returns ncc.html as valid XHTML.
        ]]></p:documentation>
        <p:output port="result"/>
        <d2e:load-html name="result">
            <p:with-option name="href" select="$nccPath"/>
        </d2e:load-html>
    </p:group>
    <p:sink/>

    <p:group name="daisy-flow">
        <p:documentation><![CDATA[
            Returns:
            <c:body>
                <c:file href="..."/>
                <c:file href="..."/>
                <c:file href="..."/>
            </c:body>
            Depends on "daisy-ncc"
        ]]></p:documentation>
        <p:output port="result"/>
        <p:xslt>
            <p:input port="parameters">
                <p:empty/>
            </p:input>
            <p:input port="source">
                <p:pipe port="result" step="daisy-ncc"/>
            </p:input>
            <p:input port="stylesheet">
                <p:document href="daisy-ncc2flow.xsl"/>
            </p:input>
        </p:xslt>
    </p:group>
    <p:sink/>

    <p:group name="daisy-spine">
        <p:documentation><![CDATA[
            Returns:
            <c:body>
                <c:file href="..."/>
                <c:file href="..."/>
                <c:file href="..."/>
            </c:body>
            Depends on "daisy-flow"
        ]]></p:documentation>
        <p:output port="result"/>
        <p:identity>
            <p:input port="source">
                <p:pipe port="result" step="daisy-flow"/>
            </p:input>
        </p:identity>
        <p:for-each>
            <p:iteration-source select="//c:file"/>
            <p:variable name="href" select="/*/@href"/>
            <p:load>
                <p:with-option name="href" select="concat($inPath,$href)"/>
            </p:load>
            <p:xslt>
                <p:input port="parameters">
                    <p:empty/>
                </p:input>
                <p:input port="stylesheet">
                    <p:document href="smil-to-spinepart.xsl"/>
                </p:input>
            </p:xslt>
        </p:for-each>
        <p:wrap-sequence wrapper="c:result"/>
        <p:xslt>
            <p:input port="parameters">
                <p:empty/>
            </p:input>
            <p:input port="stylesheet">
                <p:document href="spineparts-to-spine.xsl"/>
            </p:input>
        </p:xslt>
    </p:group>
    <p:sink/>
    
    <p:group name="daisy-resources">
        <p:documentation><![CDATA[
            Returns:
            <c:body>
                <c:file href="..."/>
                <c:file href="..."/>
                <c:file href="..."/>
            </c:body>
            Depends on "daisy-flow" and "daisy-spine"
        ]]></p:documentation>
        <p:output port="result"/>
        <!-- TODO -->
        <p:identity>
            <p:input port="source">
                <p:pipe port="result" step="daisy-flow"/>
            </p:input>
        </p:identity>
    </p:group>
    <p:sink/>
    
    <p:group name="epub-navigation">
        <p:documentation><![CDATA[
            Makes the Navigation Document based purely on ncc.html.
            Depends on "daisy-ncc"
         ]]></p:documentation>
        <p:output port="store-complete" primary="false">
            <p:pipe port="result" step="store"/>
        </p:output>
        <p:xslt>
            <p:input port="source">
                <p:pipe port="result" step="daisy-ncc"/>
            </p:input>
            <p:input port="parameters">
                <p:empty/>
            </p:input>
            <p:input port="stylesheet">
                <p:document href="ncc-to-navigation.xsl"/>
            </p:input>
        </p:xslt>
        <p:store name="store">
            <p:with-option name="href" select="concat($outPath,'navigation.xhtml')"/>
        </p:store>
    </p:group>

    <p:group name="epub-metadata">
        <p:documentation><![CDATA[
            Depends on "daisy-flow"
        ]]></p:documentation>
        <p:output port="result"/>
        <p:xslt name="ncc-metadata">
            <p:input port="source">
                <p:pipe port="result" step="daisy-ncc"/>
            </p:input>
            <p:input port="parameters">
                <p:empty/>
            </p:input>
            <p:input port="stylesheet">
                <p:document href="ncc-to-metadata.xsl"/>
            </p:input>
        </p:xslt>
        <p:sink/>
        <p:for-each name="smil-metadata">
            <p:output port="result"/>
            <p:iteration-source select="//c:file">
                <p:pipe port="result" step="daisy-flow"/>
            </p:iteration-source>
            <p:variable name="href" select="/*/@href"/>
            <p:xslt>
                <p:input port="parameters">
                    <p:empty/>
                </p:input>
                <p:input port="stylesheet">
                    <p:document href="smil-to-metadata.xsl"/>
                </p:input>
            </p:xslt>
        </p:for-each>
        <p:sink/>
        <p:for-each name="spine-metadata">
            <p:output port="result"/>
            <p:iteration-source select="//c:file">
                <p:pipe port="result" step="daisy-spine"/>
            </p:iteration-source>
            <p:variable name="href" select="/*/@href"/>
            <p:xslt>
                <p:input port="parameters">
                    <p:empty/>
                </p:input>
                <p:input port="stylesheet">
                    <p:document href="spine-to-metadata.xsl"/>
                </p:input>
            </p:xslt>
        </p:for-each>
        <p:sink/>
        <p:identity>
            <p:input port="source">
                <p:inline>
                    <opf:metadata/>
                </p:inline>
            </p:input>
        </p:identity>
        <p:insert position="last-child" match="/*">
            <p:input port="insertion">
                <p:pipe port="result" step="ncc-metadata"/>
                <p:pipe port="result" step="smil-metadata"/>
                <p:pipe port="result" step="spine-metadata"/>
            </p:input>
        </p:insert>
        <p:unwrap match="opf:metadata[parent::opf:metadata]"/>
        <p:xslt>
            <p:input port="parameters">
                <p:empty/>
            </p:input>
            <p:input port="stylesheet">
                <p:document href="metadata-cleanup.xsl"/>
            </p:input>
        </p:xslt>
    </p:group>
    <p:sink/>

    <p:group name="epub-documents">
        <p:documentation><![CDATA[
            Depends on "daisy-spine"
        ]]></p:documentation>
        <p:output port="result"/>
        <p:identity>
            <p:input port="source">
                <p:pipe port="result" step="daisy-spine"/>
            </p:input>
        </p:identity>
        <p:viewport name="spine-metadata" match="//c:file">
            <p:output port="result">
                <p:pipe port="result" step="input"/>
            </p:output>
            <p:variable name="href" select="/*/@href"/>
            <p:identity name="input"/>
            <d2e:load-html>
                <p:with-option name="href" select="concat($inPath,$href)"/>
            </d2e:load-html>
            <p:xslt>
                <p:input port="parameters">
                    <p:empty/>
                </p:input>
                <p:input port="stylesheet">
                    <p:document href="document-cleanup.xsl"/>
                </p:input>
            </p:xslt>
            <p:store>
                <p:with-option name="href" select="concat($outPath,$href)"/>
            </p:store>
        </p:viewport>
    </p:group>
    <p:sink/>

    <p:group name="epub-media-overlay">
        <p:documentation><![CDATA[
            Depends on "daisy-flow"
            TODO: split or merge SMIL-files as necessary
        ]]></p:documentation>
        <p:output port="result"/>
        <p:identity>
            <p:input port="source">
                <p:pipe port="result" step="daisy-flow"/>
            </p:input>
        </p:identity>
        <p:viewport name="spine-metadata" match="//c:file">
            <p:output port="result">
                <p:pipe port="result" step="input"/>
            </p:output>
            <p:variable name="href" select="/*/@href"/>
            <p:identity name="input"/>
            <p:load>
                <p:with-option name="href" select="concat($inPath,$href)"/>
            </p:load>
            <p:xslt>
                <p:input port="parameters">
                    <p:empty/>
                </p:input>
                <p:input port="stylesheet">
                    <p:document href="smil-cleanup.xsl"/>
                </p:input>
            </p:xslt>
            <p:store>
                <p:with-option name="href" select="concat($outPath,$href)"/>
            </p:store>
        </p:viewport>
    </p:group>
    <p:sink/>
    
    <p:group name="epub-manifest">
        <p:documentation><![CDATA[
            Depends on "daisy-ncc" and "daisy-spine"
        ]]></p:documentation>
        <p:output port="result"/>
        <p:xslt name="resources-ncc">
            <p:input port="source">
                <p:pipe port="result" step="daisy-ncc"/>
            </p:input>
            <p:input port="parameters">
                <p:empty/>
            </p:input>
            <p:input port="stylesheet">
                <p:document href="ncc2resources.xsl"/>
            </p:input>
        </p:xslt>
        <p:sink/>
        <p:xslt name="resources-flow">
            <p:input port="source">
                <p:pipe port="result" step="daisy-flow"/>
            </p:input>
            <p:input port="parameters">
                <p:empty/>
            </p:input>
            <p:input port="stylesheet">
                <p:document href="flow2resources.xsl"/>
            </p:input>
        </p:xslt>
        <p:sink/>
        <p:xslt name="resources-documents">
            <p:input port="source">
                <p:pipe port="result" step="daisy-spine"/>
            </p:input>
            <p:input port="parameters">
                <p:empty/>
            </p:input>
            <p:input port="stylesheet">
                <p:document href="documents2resources.xsl"/>
            </p:input>
        </p:xslt>
        <p:sink/>
        <p:identity>
            <p:input port="source">
                <p:inline>
                    <c:body/>
                </p:inline>
            </p:input>
        </p:identity>
        <p:insert position="last-child">
            <p:input port="insertion">
                <p:pipe port="result" step="resources-ncc"/>
            </p:input>
        </p:insert>
        <p:insert position="last-child">
            <p:input port="insertion">
                <p:pipe port="result" step="resources-flow"/>
            </p:input>
        </p:insert>
        <p:insert position="last-child">
            <p:input port="insertion">
                <p:pipe port="result" step="resources-documents"/>
            </p:input>
        </p:insert>
        <p:unwrap match="c:body[parent::c:body]"/>
        <p:xslt>
            <p:input port="parameters">
                <p:empty/>
            </p:input>
            <p:input port="stylesheet">
                <p:document href="resources-fixup.xsl"/>
            </p:input>
        </p:xslt>
    </p:group>
    <p:sink/>

    <p:group name="epub-spine">
        <p:documentation><![CDATA[
            Depends on "daisy-flow"
        ]]></p:documentation>
        <p:output port="result"/>
        <p:identity>
            <p:input port="source">
                <p:inline>
                    <doc/>
                </p:inline>
            </p:input>
        </p:identity>
    </p:group>
    <p:sink/>

    <p:group name="epub-package">
        <p:documentation><![CDATA[
            Depends on "epub-spine", "epub-metadata" and "epub-manifest"
        ]]></p:documentation>
        <p:output port="result"/>
        <p:identity>
            <p:input port="source">
                <p:inline>
                    <doc/>
                </p:inline>
            </p:input>
        </p:identity>
    </p:group>
    <p:sink/>

</p:declare-step>
