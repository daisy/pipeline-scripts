<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step type="pxi:generate-liblouis-files" name="generate-liblouis-files"
    xmlns:p="http://www.w3.org/ns/xproc"
    xmlns:c="http://www.w3.org/ns/xproc-step"
    xmlns:px="http://www.daisy.org/ns/pipeline/xproc"
    xmlns:pxi="http://www.daisy.org/ns/pipeline/xproc/internal"
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
    <p:import href="utils/copy-text-file.xpl"/>
    <p:import href="http://www.daisy.org/pipeline/modules/fileset-utils/xproc/fileset-library.xpl"/>
    <p:import href="http://www.daisy.org/pipeline/modules/file-utils/xproc/file-library.xpl"/>
    
    <px:fileset-create name="directory">
        <p:with-option name="base" select="$directory">
            <p:empty/>
        </p:with-option>
    </px:fileset-create>
    
    <p:group name="liblouis-ini-file">
        <p:output port="result" primary="true"/>
        <pxi:copy-text-file>
            <p:with-option name="href" select="resolve-uri('../../lbx_files/liblouisutdml.ini')">
                <p:document href="attach-liblouis-config.xpl"/>
            </p:with-option>
            <p:with-option name="target" select="resolve-uri('liblouisutdml.ini', $directory)"/>
        </pxi:copy-text-file>
        <pxi:copy-text-file>
            <p:with-option name="href" select="resolve-uri('../../lbx_files/braille-patterns.cti')">
                <p:document href="attach-liblouis-config.xpl"/>
            </p:with-option>
            <p:with-option name="target" select="resolve-uri('braille-patterns.cti', $directory)"/>
        </pxi:copy-text-file>
        <pxi:copy-text-file>
            <p:with-option name="href" select="resolve-uri('../../lbx_files/nabcc.dis')">
                <p:document href="attach-liblouis-config.xpl"/>
            </p:with-option>
            <p:with-option name="target" select="resolve-uri('nabcc.dis', $directory)"/>
        </pxi:copy-text-file>
        <pxi:copy-text-file>
            <p:with-option name="href" select="resolve-uri('../../lbx_files/pagenum.cti')">
                <p:document href="attach-liblouis-config.xpl"/>
            </p:with-option>
            <p:with-option name="target" select="resolve-uri('pagenum.cti', $directory)"/>
        </pxi:copy-text-file>
        <px:fileset-add-entry href="liblouisutdml.ini">
            <p:input port="source">
                <p:pipe step="directory" port="result"/>
            </p:input>
        </px:fileset-add-entry>
    </p:group>
    <p:sink/>
    
    <pxi:store-file name="styles-directory" suffix=".cfg">
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
            <p:pipe step="liblouis-ini-file" port="result"/>
        </p:input>
    </pxi:store-file>
    
    <pxi:store-file name="semantics-directory" suffix=".sem">
        <p:input port="source">
            <p:inline><louis:semantic-file>skip              &amp;xpath(//*[@louis:style='skip'])
no-pagenum        &amp;xpath(//louis:no-pagenum)
contentsheader    &amp;xpath(//louis:toc)
none              &amp;xpath(//louis:include)
none              &amp;xpath(//louis:box)
preformatted-line &amp;xpath(//louis:line)
preformatted-line &amp;xpath(//louis:border)
pagenum           &amp;xpath(//louis:print-page)
</louis:semantic-file></p:inline>
        </p:input>
        <p:input port="directory">
            <p:pipe step="directory" port="result"/>
        </p:input>
    </pxi:store-file>
    
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
        <pxi:store-file name="store-file" suffix=".cfg">
            <p:input port="source">
                <p:pipe step="extract-liblouis-styles" port="secondary"/>
            </p:input>
            <p:input port="directory">
                <p:pipe step="styles-directory" port="result"/>
            </p:input>
        </pxi:store-file>
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
        <pxi:store-file name="store-file" suffix=".sem">
            <p:input port="directory">
                <p:pipe step="semantics-directory" port="result"/>
            </p:input>
        </pxi:store-file>
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
        <pxi:store-file name="store-file" suffix=".cfg">
            <p:input port="source">
                <p:pipe step="extract-liblouis-styles" port="secondary"/>
            </p:input>
            <p:input port="directory">
                <p:pipe step="directory" port="result"/>
            </p:input>
        </pxi:store-file>
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
        <pxi:store-file name="store-file" suffix=".sem">
            <p:input port="directory">
                <p:pipe step="directory" port="result"/>
            </p:input>
        </pxi:store-file>
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
