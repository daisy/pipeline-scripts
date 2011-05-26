<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step version="1.0" name="dtbook2005-3-to-zedai" type="pxi:dtbook2005-3-to-zedai"
    xmlns:p="http://www.w3.org/ns/xproc" xmlns:c="http://www.w3.org/ns/xproc-step"
    xmlns:cx="http://xmlcalabash.com/ns/extensions"
    xmlns:cxo="http://xmlcalabash.com/ns/extensions/osutils"
    xmlns:pxi="http://www.daisy.org/ns/pipeline/xproc/internal"
    xmlns:xd="http://www.daisy.org/ns/pipeline/doc"
    exclude-inline-prefixes="cx cxo pxi p c xd">

    <p:documentation>
        <xd:short>Transforms DTBook 2005-3 XML into ZedAI XML. Part of the DTBook-to-ZedAI
            module.</xd:short>
        <xd:author>
            <xd:name>Marisa DeMeglio</xd:name>
            <xd:mailto>marisa.demeglio@gmail.com</xd:mailto>
            <xd:organization>DAISY</xd:organization>
        </xd:author>
        <xd:maintainer>Marisa DeMeglio</xd:maintainer>
        <xd:input port="source">DTBook 2005-3 document.</xd:input>
        <xd:output port="result">ZedAI document with temporary style attributes (prefixed by
            tmp:).</xd:output>
        <xd:option name="css-filename">URI of the CSS file that will go with this
            document.</xd:option>
        <xd:option name="mods-filename">URI of the MODS file that will go with this
            document.</xd:option>
    </p:documentation>

    <p:input port="source" primary="true"/>

    <p:input port="parameters" kind="parameter"/>

    <!-- output is ZedAI, not valid -->
    <p:output port="result" primary="true">
        <p:pipe port="result" step="anchor-floating-annotations"/>
    </p:output>

    <p:option name="css-filename" required="true"/>
    <p:option name="mods-filename" required="true"/>

    <p:import href="http://xmlcalabash.com/extension/steps/library-1.0.xpl"/>

    <p:documentation>Preprocess certain inline elements by making them into spans. This streamlines
        the number of transformation cases that need to be dealt with later.</p:documentation>
    <p:xslt name="rename-to-span">
        <p:input port="stylesheet">
            <p:document href="rename-to-span.xsl"/>
        </p:input>
    </p:xslt>

    <p:documentation>Identify block-level code/kbd elements vs phrase-level</p:documentation>
    <p:xslt name="rename-code-kbd">
        <p:input port="stylesheet">
            <p:document href="rename-code-kbd.xsl"/>
        </p:input>
    </p:xslt>

    <p:documentation>Identify block-level annotation elements vs phrase-level</p:documentation>
    <p:xslt name="rename-annotation">
        <p:input port="stylesheet">
            <p:document href="rename-annotation.xsl"/>
        </p:input>
    </p:xslt>

    <p:documentation>Convert br to ln</p:documentation>
    <p:xslt name="convert-linebreaks">
        <p:input port="stylesheet">
            <p:document href="convert-linebreaks.xsl"/>
        </p:input>
    </p:xslt>

    <p:documentation>Group items in definition lists</p:documentation>
    <p:xslt name="convert-deflist-contents">
        <p:input port="stylesheet">
            <p:document href="group-deflist-contents.xsl"/>
        </p:input>
    </p:xslt>

    <p:documentation>Normalize imggroup element placement to suit ZedAI's content
        model.</p:documentation>
    <p:xslt name="moveout-imggroup">
        <p:input port="stylesheet">
            <p:document href="moveout-imggroup.xsl"/>
        </p:input>
    </p:xslt>

    <p:documentation>Normalize list element placement to suit ZedAI's content
        model.</p:documentation>
    <p:xslt name="moveout-list">
        <p:input port="stylesheet">
            <p:document href="moveout-list.xsl"/>
        </p:input>
    </p:xslt>

    <p:documentation>Normalize definition list element placement to suit ZedAI's content
        model.</p:documentation>
    <p:xslt name="moveout-deflist">
        <p:input port="stylesheet">
            <p:document href="moveout-deflist.xsl"/>
        </p:input>
    </p:xslt>

    <p:documentation>Normalize prodnote element placement to suit ZedAI's content
        model.</p:documentation>
    <p:xslt name="moveout-prodnote">
        <p:input port="stylesheet">
            <p:document href="moveout-prodnote.xsl"/>
        </p:input>
    </p:xslt>

    <p:documentation>Normalize div element placement to suit ZedAI's content
        model.</p:documentation>
    <p:xslt name="moveout-div">
        <p:input port="stylesheet">
            <p:document href="moveout-div.xsl"/>
        </p:input>
    </p:xslt>

    <p:documentation>Normalize poem element placement to suit ZedAI's content
        model.</p:documentation>
    <p:xslt name="moveout-poem">
        <p:input port="stylesheet">
            <p:document href="moveout-poem.xsl"/>
        </p:input>
    </p:xslt>

    <p:documentation>Normalize linegroup element placement to suit ZedAI's content
        model.</p:documentation>
    <p:xslt name="moveout-linegroup">
        <p:input port="stylesheet">
            <p:document href="moveout-linegroup.xsl"/>
        </p:input>
    </p:xslt>

    <p:documentation>Normalize table element placement to suit ZedAI's content
        model.</p:documentation>
    <p:xslt name="moveout-table">
        <p:input port="stylesheet">
            <p:document href="moveout-table.xsl"/>
        </p:input>
    </p:xslt>

    <p:documentation>Normalize sidebar element placement to suit ZedAI's content
        model.</p:documentation>
    <p:xslt name="moveout-sidebar">
        <p:input port="stylesheet">
            <p:document href="moveout-sidebar.xsl"/>
        </p:input>
    </p:xslt>

    <p:documentation>Normalize note element placement to suit ZedAI's content
        model.</p:documentation>
    <p:xslt name="moveout-note">
        <p:input port="stylesheet">
            <p:document href="moveout-note.xsl"/>
        </p:input>
    </p:xslt>

    <p:documentation>Normalize epigraph element placement to suit ZedAI's content
        model.</p:documentation>
    <p:xslt name="moveout-epigraph">
        <p:input port="stylesheet">
            <p:document href="moveout-epigraph.xsl"/>
        </p:input>
    </p:xslt>

    <p:documentation>Normalize block-level annotation element placement to suit ZedAI's content
        model.</p:documentation>
    <p:xslt name="moveout-annotation-block">
        <p:input port="stylesheet">
            <p:document href="moveout-annotation.xsl"/>
        </p:input>
    </p:xslt>

    <p:documentation>Normalize block-level code element placement to suit ZedAI's content
        model.</p:documentation>
    <p:xslt name="moveout-code">
        <p:input port="stylesheet">
            <p:document href="moveout-code.xsl"/>
        </p:input>
    </p:xslt>

    <p:documentation>Normalize mixed block/inline content models by ensuring the content consists of
        all block or all inline elements.</p:documentation>
    <p:xslt name="normalize-block-inline">
        <p:input port="stylesheet">
            <p:document href="normalize-block-inline.xsl"/>
        </p:input>
    </p:xslt>

    <p:documentation>Normalize mixed section/block content models by ensuring the content consists
        of all section or all block elements.</p:documentation>
    <p:xslt name="normalize-section-block">
        <p:input port="stylesheet">
            <p:document href="normalize-section-block.xsl"/>
        </p:input>
    </p:xslt>

    <p:documentation>Translate element and attribute names from DTBook to ZedAI</p:documentation>
    <p:xslt name="translate-to-zedai">
        <p:with-param name="mods-filename" select="$mods-filename"/>
        <p:with-param name="css-filename" select="$css-filename"/>
        <p:input port="stylesheet">
            <p:document href="./translate-elems-attrs-to-zedai.xsl"/>
        </p:input>
    </p:xslt>

    <!-- TODO: can I do this with p:add-attribute instead of the XSLT below? -->
    <p:documentation>Anchor any floating anotations</p:documentation>
    <!--<p:add-attribute name="anchor-floating-annotations">
        <p:with-option name="match" select="//z:annotation[not(@ref)]"/>
        <p:with-option name="attribute-name" select="ref"/>
        <p:with-option name="attribute-value" select="ancestor::z:section/@ref"/>
        <p:with-option name="attribute-namespace" select="http://www.daisy.org/ns/z3986/authoring/"/>
    </p:add-attribute>
    -->
    <p:xslt name="anchor-floating-annotations">
        <p:input port="stylesheet">
            <p:document href="add-ref-to-annotations.xsl"/>
        </p:input>
    </p:xslt>

</p:declare-step>
