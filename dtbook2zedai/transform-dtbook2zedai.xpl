<?xml version="1.0" encoding="UTF-8"?>

<p:declare-step version="1.0" name="transform-dtbook2zedai"
    type="p2:transform-dtbook2zedai"
    xmlns:p="http://www.w3.org/ns/xproc"
    xmlns:c="http://www.w3.org/ns/xproc-step"
    xmlns:cx="http://xmlcalabash.com/ns/extensions"
    xmlns:cxo="http://xmlcalabash.com/ns/extensions/osutils"
    xmlns:p2="http://code.google.com/p/daisy-pipeline/"
    exclude-inline-prefixes="cx">
    
    
    <p:input port="source" primary="true"/>
    <p:input port="parameters" kind="parameter" />
    <!-- output the ZedAI document and the CSS file -->
    <p:output port="result" primary="true">
        <p:pipe port="result" step="validate-zedai"/>
    </p:output>
    <p:output port="css">
        <p:pipe port="result" step="generate-css"/>
    </p:output>
    
    <p:option name="css-filename" required="true"/>
    <p:option name="mods-filename" required="true"/>
    
    <p:import href="http://xmlcalabash.com/extension/steps/library-1.0.xpl"/>
    
    <!-- Validate DTBook Input-->
    <p:validate-with-relax-ng assert-valid="true" name="validate-dtbook">
        <p:input port="schema">
            <p:document href="./schema/dtbook-2005-3.rng"/>
        </p:input>
    </p:validate-with-relax-ng>
    
    
    <!-- Normalize DTBook content model -->
    <p:group name="normalize-dtbook">
        
        <!-- normalize nested samps -->
        <p:xslt name="normalize-samp">
            <p:input port="stylesheet">
                <p:document href="./normalize-samp.xsl"/>
            </p:input>
            <p:input port="source">
                <p:pipe step="validate-dtbook" port="result"/>
            </p:input>
        </p:xslt>
        
        <!-- preprocess certain nested elements by making them into spans -->
        <p:xslt name="normalize-inline-special">
            <p:input port="stylesheet">
                <p:document href="./normalize-inline-special.xsl"/>
            </p:input>
        </p:xslt>
        
        
        <!-- move imggroups out from elements which must not contain them once converted to zedai -->
        <p:xslt name="normalize-imggroup">
            <p:input port="stylesheet">
                <p:document href="./normalize-imggroup.xsl"/>
            </p:input>
        </p:xslt>
        
        <!-- move lists out of paragraphs -->
        <p:xslt name="normalize-list-in-para">
            <p:input port="stylesheet">
                <p:document href="./normalize-list-in-para.xsl"/>
            </p:input>
        </p:xslt>
        
        <!-- move definition lists out of paragraphs -->
        <p:xslt name="normalize-deflist-in-para">
            <p:input port="stylesheet">
                <p:document href="./normalize-deflist-in-para.xsl"/>
            </p:input>
        </p:xslt>
        
        <!-- move producer notes out of inline elements -->
        <p:xslt name="normalize-prodnote">
            <p:input port="stylesheet">
                <p:document href="./normalize-prodnote.xsl"/>
            </p:input>
        </p:xslt>
        
        <!-- normalize mixed block/inline content models -->
        <p:xslt name="normalize-block-inline">
            <p:input port="stylesheet">
                <p:document href="./normalize-block-inline.xsl"/>
            </p:input>
        </p:xslt>
        
        <!-- convert br to ln -->
        <p:xslt name="normalize-br-to-ln">
            <p:input port="stylesheet">
                <p:document href="./normalize-br-to-ln.xsl"/>
            </p:input>
        </p:xslt>
        
        <!-- normalize definition lists by organizing into groups of items -->
        <p:xslt name="normalize-deflist-1">
            <p:input port="stylesheet">
                <p:document href="./normalize-deflist-1.xsl"/>
            </p:input>
        </p:xslt>
        
        <!-- normalize definition lists by relocating illegal elements from definitions -->
        <p:xslt name="normalize-deflist-2">
            <p:input port="stylesheet">
                <p:document href="./normalize-deflist-2.xsl"/>
            </p:input>
        </p:xslt>
    </p:group>
    
    <!-- Translate element and attribute names from DTBook to ZedAI -->
    <p:xslt name="translate-dtbook2zedai">
        <p:with-param name="mods-filename" select="$mods-filename"/>
        <p:with-param name="css-filename" select="$css-filename"/>
        <p:input port="stylesheet">
            <p:document href="./translate-dtbook2zedai.xsl"/>
        </p:input>
    </p:xslt>
    
    <!-- this step has to go after the transformation steps -->
    <p:xslt name="generate-css">
        <p:input port="stylesheet">
            <p:document href="./generate-css.xsl"/>
        </p:input>   
    </p:xslt>
    
    <p:xslt name="remove-css-attributes">
        <p:input port="stylesheet">
            <p:document href="./remove-css-attributes.xsl"/>
        </p:input>
        <p:input port="source">
            <p:pipe step="translate-dtbook2zedai" port="result"/>
        </p:input>
    </p:xslt>
    
    <!-- Validate the ZedAI output -->
    <p:validate-with-relax-ng name="validate-zedai">
        <p:input port="schema">
            <p:document href="./schema/z3986a-book-0.8/z3986a-book.rng"/>
        </p:input>
    </p:validate-with-relax-ng>
    
    
</p:declare-step>