<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step type="louis:generate-liblouis-files" name="generate-liblouis-files"
    xmlns:p="http://www.w3.org/ns/xproc"
    xmlns:c="http://www.w3.org/ns/xproc-step"
    xmlns:px="http://www.daisy.org/ns/pipeline/xproc"
    xmlns:louis="http://liblouis.org/liblouis"
    version="1.0">
    
    <p:input port="source" sequence="true" primary="true"/>
    <p:input port="source-toc" sequence="true"/>
    <p:option name="directory" required="true"/>
    <p:output port="result" sequence="true" primary="true">
        <p:pipe step="result" port="result"/>
    </p:output>
    <p:output port="result-toc" sequence="true">
        <p:pipe step="result-toc" port="result"/>
    </p:output>
    
    <p:import href="store-file.xpl"/>
    <p:import href="http://www.daisy.org/pipeline/modules/fileset-utils/xproc/fileset-library.xpl"/>
    
    <px:fileset-create name="directory">
        <p:with-option name="base" select="$directory">
            <p:empty/>
        </p:with-option>
    </px:fileset-create>

    <louis:store-file name="styles-directory" suffix=".cfg">
        <p:input port="source">
            <p:inline><louis:config-file>style no-pagenum
    braillePageNumberFormat blank

style contentsheader
    leftMargin 0
    rightMargin 0
    firstLineIndent 0
    format leftJustified

style preformatted-line
    leftMargin 0
    rightMargin 0
    firstLineIndent 0
    format leftJustified
    skipNumberLines yes
</louis:config-file></p:inline>
        </p:input>
        <p:input port="directory">
            <p:pipe step="directory" port="result"/>
        </p:input>
    </louis:store-file>
    
    <louis:store-file name="semantics-directory" suffix=".sem">
        <p:input port="source">
            <p:inline><louis:semantic-file>skip &amp;xpath(//*[@louis:style='skip'])
no-pagenum &amp;xpath(//louis:no-pagenum)
contentsheader &amp;xpath(//louis:toc[parent::louis:no-pagenum])
none &amp;xpath(//louis:toc[not(parent::louis:no-pagenum)])
preformatted-line &amp;xpath(//louis:preformatted//louis:line)
pagenum &amp;xpath(//louis:print-page)
</louis:semantic-file></p:inline>
        </p:input>
        <p:input port="directory">
            <p:pipe step="directory" port="result"/>
        </p:input>
    </louis:store-file>
    
    <p:for-each name="styles">
        <p:iteration-source>
            <p:pipe step="generate-liblouis-files" port="source"/>
        </p:iteration-source>
        <p:output port="result" sequence="true" primary="true">
            <p:pipe step="extract-liblouis-styles" port="result"/>
        </p:output>
        <p:output port="liblouis-files" sequence="true">
            <p:pipe step="store-file" port="result"/>
        </p:output>
        <p:xslt name="extract-liblouis-styles">
            <p:input port="source" select="/*/*"/>
            <p:input port="stylesheet">
                <p:document href="../xslt/extract-liblouis-styles.xsl"/>
            </p:input>
            <p:input port="parameters">
                <p:empty/>
            </p:input>
        </p:xslt>
        <louis:store-file name="store-file" suffix=".cfg">
            <p:input port="source">
                <p:pipe step="extract-liblouis-styles" port="secondary"/>
            </p:input>
            <p:input port="directory">
                <p:pipe step="styles-directory" port="result"/>
            </p:input>
        </louis:store-file>
    </p:for-each>
    
    <p:for-each name="semantics">
        <p:output port="liblouis-files" sequence="true">
            <p:pipe step="store-file" port="result"/>
        </p:output>
        <p:xslt name="generate-liblouis-semantics">
            <p:input port="stylesheet">
                <p:document href="../xslt/generate-liblouis-semantics.xsl"/>
            </p:input>
            <p:input port="parameters">
                <p:empty/>
            </p:input>
        </p:xslt>
        <louis:store-file name="store-file" suffix=".sem">
            <p:input port="directory">
                <p:pipe step="semantics-directory" port="result"/>
            </p:input>
        </louis:store-file>
    </p:for-each>
    
    <p:for-each name="toc-styles">
        <p:iteration-source>
            <p:pipe step="generate-liblouis-files" port="source-toc"/>
        </p:iteration-source>
        <p:output port="result" sequence="true" primary="true">
            <p:pipe step="extract-liblouis-styles" port="result"/>
        </p:output>
        <p:output port="liblouis-files" sequence="true">
            <p:pipe step="store-file" port="result"/>
        </p:output>
        <p:xslt name="extract-liblouis-styles">
            <p:input port="stylesheet">
                <p:document href="../xslt/extract-liblouis-styles.xsl"/>
            </p:input>
            <p:input port="parameters">
                <p:empty/>
            </p:input>
        </p:xslt>
        <louis:store-file name="store-file" suffix=".cfg">
            <p:input port="source">
                <p:pipe step="extract-liblouis-styles" port="secondary"/>
            </p:input>
            <p:input port="directory">
                <p:pipe step="directory" port="result"/>
            </p:input>
        </louis:store-file>
    </p:for-each>
    
    <p:for-each name="toc-semantics">
        <p:output port="liblouis-files" sequence="true">
            <p:pipe step="store-file" port="result"/>
        </p:output>
        <p:xslt name="generate-liblouis-semantics">
            <p:input port="stylesheet">
                <p:document href="../xslt/generate-liblouis-semantics.xsl"/>
            </p:input>
            <p:input port="parameters">
                <p:empty/>
            </p:input>
        </p:xslt>
        <louis:store-file name="store-file" suffix=".sem">
            <p:input port="directory">
                <p:pipe step="directory" port="result"/>
            </p:input>
        </louis:store-file>
    </p:for-each>
    
    <p:group name="result">
        <p:output port="result" sequence="true" primary="true"/>
        <p:pack wrapper="wrapper">
            <p:input port="source">
                <p:pipe step="styles" port="result"/>
            </p:input>
            <p:input port="alternate">
                <p:pipe step="styles" port="liblouis-files"/>
            </p:input>
        </p:pack>
        <p:pack wrapper="wrapper">
            <p:input port="alternate">
                <p:pipe step="semantics" port="liblouis-files"/>
            </p:input>
        </p:pack>
        <p:pack wrapper="wrapper">
            <p:input port="alternate" select="/*/*[2]">
                <p:pipe step="generate-liblouis-files" port="source"/>
            </p:input>
        </p:pack>
        <p:for-each>
            <p:unwrap match="/*//wrapper"/>
        </p:for-each>
    </p:group>
    
    <p:group name="result-toc">
        <p:output port="result" sequence="true" primary="true"/>
        <p:pack wrapper="wrapper">
            <p:input port="source">
                <p:pipe step="toc-styles" port="result"/>
            </p:input>
            <p:input port="alternate">
                <p:pipe step="toc-styles" port="liblouis-files"/>
            </p:input>
        </p:pack>
        <p:pack wrapper="wrapper">
            <p:input port="alternate">
                <p:pipe step="toc-semantics" port="liblouis-files"/>
            </p:input>
        </p:pack>
        <p:for-each>
            <p:unwrap match="/*//wrapper"/>
        </p:for-each>
    </p:group>
    
</p:declare-step>
