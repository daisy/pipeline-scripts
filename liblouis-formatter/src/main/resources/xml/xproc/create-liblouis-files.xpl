<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step type="louis:create-liblouis-files" name="create-liblouis-files"
    xmlns:p="http://www.w3.org/ns/xproc"
    xmlns:px="http://www.daisy.org/ns/pipeline/xproc"
    xmlns:louis="http://liblouis.org/liblouis"
    version="1.0">
    
    <p:input port="source" sequence="false" primary="true"/>
    <p:input port="styles" sequence="true"/>
    <p:input port="directory" sequence="false"/>
    
    <p:output port="config" sequence="false">
        <p:pipe step="config-files" port="result"/>
    </p:output>
    
    <p:output port="semantic" sequence="false">
        <p:pipe step="semantic-files" port="result"/>
    </p:output>
    
    <p:import href="store-files.xpl"/>
    
    <p:xslt name="default-sem">
        <p:input port="stylesheet">
            <p:document href="../xslt/create-default-sem-file.xsl"/>
        </p:input>
        <p:input port="parameters">
            <p:empty/>
        </p:input>
    </p:xslt>
    
    <p:xslt name="styles-cfg">
        <p:input port="source">
            <p:pipe step="create-liblouis-files" port="styles"/>
        </p:input>
        <p:input port="stylesheet">
            <p:document href="../xslt/create-styles-cfg-file.xsl"/>
        </p:input>
        <p:input port="parameters">
            <p:empty/>
        </p:input>
    </p:xslt>

    <p:xslt name="styles-sem">
        <p:input port="source">
            <p:pipe step="create-liblouis-files" port="styles"/>
        </p:input>
        <p:input port="stylesheet">
            <p:document href="../xslt/create-styles-sem-file.xsl"/>
        </p:input>
        <p:input port="parameters">
            <p:empty/>
        </p:input>
    </p:xslt>
    
    <p:xslt name="borders-sem">
        <p:input port="source">
            <p:pipe step="create-liblouis-files" port="source"/>
        </p:input>
        <p:input port="stylesheet">
            <p:document href="../xslt/create-borders-sem-file.xsl"/>
        </p:input>
        <p:input port="parameters">
            <p:empty/>
        </p:input>
    </p:xslt>
    
    <p:identity name="misc-cfg">
        <p:input port="source">
            <p:inline><louis:config-file>
style no-pagenum
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
    </p:identity>

    <p:identity name="misc-sem">
        <p:input port="source">
            <p:inline><louis:semantic-file>
no-pagenum &amp;xpath(//louis:no-pagenum)
contentsheader &amp;xpath(//louis:toc[parent::louis:no-pagenum])
skip &amp;xpath(//louis:toc[not(parent::louis:no-pagenum)])
preformatted-line &amp;xpath(//louis:preformatted//louis:line)
pagenum &amp;xpath(//louis:print-page)
            </louis:semantic-file></p:inline>
        </p:input>
    </p:identity>
    
    <louis:store-files name="config-files">
        <p:input port="source">
            <p:pipe step="styles-cfg" port="result"/>
            <p:pipe step="misc-cfg" port="result"/>
        </p:input>
        <p:input port="directory">
            <p:pipe step="create-liblouis-files" port="directory"/>
        </p:input>
    </louis:store-files>
    
    <louis:store-files name="semantic-files">
        <p:input port="source">
            <p:pipe step="default-sem" port="result"/>
            <p:pipe step="styles-sem" port="result"/>
            <p:pipe step="borders-sem" port="result"/>
            <p:pipe step="misc-sem" port="result"/>
        </p:input>
        <p:input port="directory">
            <p:pipe step="create-liblouis-files" port="directory"/>
        </p:input>
    </louis:store-files>
    
</p:declare-step>
