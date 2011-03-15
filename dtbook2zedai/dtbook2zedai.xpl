<?xml version="1.0" encoding="UTF-8"?>

<p:declare-step version="1.0" name="dtbook2zedai" xmlns:p="http://www.w3.org/ns/xproc"
    xmlns:c="http://www.w3.org/ns/xproc-step" xmlns:cx="http://xmlcalabash.com/ns/extensions"
    xmlns:cxo="http://xmlcalabash.com/ns/extensions/osutils"
    xmlns:p2="http://code.google.com/p/daisy-pipeline/" exclude-inline-prefixes="cx">

    <!-- 
        
        This XProc script is the main entry point for the DTBook2ZedAI module.
        The module's homepage is here: http://code.google.com/p/daisy-pipeline/wiki/DTBook2ZedAI
        
    -->

    <p:input port="source" primary="true" sequence="true"/>
    <p:input port="parameters" kind="parameter"/>

    <p:option name="output" select="''"/>

    <p:import href="http://xmlcalabash.com/extension/steps/library-1.0.xpl"/>
    <p:import href="./transform-dtbook2zedai.xpl"/>
    <p:import href="./dtbook-merger.xpl"/>
    
    <p:variable name="zedai-file"
        select="resolve-uri(
                    if ($output='') then concat(
                        if (matches(base-uri(/),'[^/]+\..+$'))
                        then replace(tokenize(base-uri(/),'/')[last()],'\..+$','')
                        else tokenize(base-uri(/),'/')[last()],'-zedai.xml')
                    else if (ends-with($output,'.xml')) then $output 
                    else concat($output,'.xml'), base-uri(/))">
        <p:pipe step="dtbook2zedai" port="source"/>

    </p:variable>

    <p:variable name="mods-file" select="replace($zedai-file, '.xml', '-mods.xml')"/>

    <p:variable name="css-file" select="replace($zedai-file, '.xml', '.css')"/>

    <!-- Validate DTBook Input-->
    <p:validate-with-relax-ng assert-valid="true" name="validate-dtbook">
        <p:input port="schema">
            <p:document href="./schema/dtbook-2005-3.rng"/>
        </p:input>
    </p:validate-with-relax-ng>


    <p:count name="num-input-documents" limit="2"/>

    <p:choose>
        <p:when test=".//c:result[. > 1]">
            <p2:dtbook-merger/>
        </p:when>
        <p:otherwise>
            <cx:message>
                <p:with-option name="message" select="'single'"/>
            </cx:message>
            <!--<p:sink/>-->
        </p:otherwise>
    </p:choose>



    <!-- create MODS metadata record -->
    <p:xslt name="create-mods">
        <!--<p:input port="source">
            <p:pipe step="validate-dtbook" port="result"/>
        </p:input>-->
        <p:input port="stylesheet">
            <p:document href="./generate-mods.xsl"/>
        </p:input>
    </p:xslt>

    <!-- normalize and transform; also generate css -->
    <p2:transform-dtbook2zedai name="transform-dtbook2zedai">
        <p:input port="source">
            <p:pipe port="result" step="validate-dtbook"/>
        </p:input>
        <p:with-option name="css-filename" select="$css-file"/>
        <p:with-option name="mods-filename" select="$mods-file"/>
    </p2:transform-dtbook2zedai>

    <!-- Validate the ZedAI output -->
    <p:validate-with-relax-ng name="validate-zedai">
        <p:input port="schema">
            <p:document href="./schema/z3986a-book-0.8/z3986a-book.rng"/>
        </p:input>
        <p:input port="source">
            <p:pipe port="result" step="transform-dtbook2zedai"/>
        </p:input>
    </p:validate-with-relax-ng>


    <!-- write files-->
    <p:store>
        <p:input port="source">
            <p:pipe step="validate-zedai" port="result"/>
        </p:input>
        <p:with-option name="href" select="$zedai-file"/>
    </p:store>
    <p:store>
        <p:input port="source">
            <p:pipe step="create-mods" port="result"/>
        </p:input>
        <p:with-option name="href" select="$mods-file"/>
    </p:store>
    <p:store>
        <p:input port="source">
            <p:pipe step="transform-dtbook2zedai" port="css"/>
        </p:input>
        <p:with-option name="href" select="$css-file"/>
    </p:store>
</p:declare-step>
