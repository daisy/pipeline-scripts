<?xml version="1.0" encoding="UTF-8"?>

<p:declare-step version="1.0" name="dtbook2zedai" xmlns:p="http://www.w3.org/ns/xproc"
    xmlns:c="http://www.w3.org/ns/xproc-step" xmlns:cx="http://xmlcalabash.com/ns/extensions"
    xmlns:cxo="http://xmlcalabash.com/ns/extensions/osutils"
    xmlns:dtb="http://www.daisy.org/z3986/2005/dtbook/"
    xmlns:p2="http://code.google.com/p/daisy-pipeline/" exclude-inline-prefixes="cx">
    <!-- 
        
        This XProc script is part of the DTBook2ZedAI module.
        The module's homepage is here: http://code.google.com/p/daisy-pipeline/wiki/DTBook2ZedAI
        
        TODO: 
         * remove dupliate meta/doctitle/docauthor
         * remove empty elements        
    -->

    <p:input port="source" primary="true" sequence="true"/>
    <p:input port="parameters" kind="parameter"/>

    <p:option name="output" select="''"/>

    <p:import href="http://xmlcalabash.com/extension/steps/library-1.0.xpl"/>

    <p:for-each name="validate-input">
        <p:output port="result">
            <p:pipe step="ident" port="result"/>
        </p:output>
        
        <p:iteration-source select="/"/>
        
        <p:validate-with-relax-ng assert-valid="true">
            <p:input port="schema">
                <p:document href="./schema/dtbook-2005-3.rng"/>
            </p:input>
        </p:validate-with-relax-ng>
        
        <p:identity name="ident"/>
        
    </p:for-each>

   <p:for-each name="for-each-head">
       <p:iteration-source select="//dtb:dtbook/dtb:head/*">
           <p:pipe port="result" step="validate-input"></p:pipe>
       </p:iteration-source>
        <p:output port="result"/>
        
        <p:identity/>
    </p:for-each>

    <p:wrap-sequence name="wrap-head" wrapper="head">
        <p:input port="source">
            <p:pipe step="for-each-head" port="result"/>
        </p:input>
    </p:wrap-sequence>

    <p:for-each name="for-each-frontmatter">
        <p:output port="result"/>
        <p:iteration-source select="//dtb:dtbook/dtb:book/dtb:frontmatter/*">
            <p:pipe port="result" step="validate-input"></p:pipe>
        </p:iteration-source>
        <p:identity/>
    </p:for-each>
    
    <p:wrap-sequence name="wrap-frontmatter" wrapper="frontmatter">
        <p:input port="source">
            <p:pipe step="for-each-frontmatter" port="result"/>
        </p:input>
    </p:wrap-sequence>
    
    <p:for-each name="for-each-bodymatter">
        <p:output port="result"/>
        <p:iteration-source select="//dtb:dtbook/dtb:book/dtb:bodymatter/*">
            <p:pipe port="result" step="validate-input"></p:pipe>
        </p:iteration-source>
        <p:identity/>
    </p:for-each>
    
    <p:wrap-sequence name="wrap-bodymatter" wrapper="bodymatter">
        <p:input port="source">
            <p:pipe step="for-each-bodymatter" port="result"/>
        </p:input>
    </p:wrap-sequence>
    
    <p:for-each name="for-each-rearmatter">
        <p:output port="result"/>
        <p:iteration-source select="//dtb:dtbook/dtb:book/dtb:rearmatter/*">
            <p:pipe port="result" step="validate-input"></p:pipe>
        </p:iteration-source>
        <p:identity/>
    </p:for-each>
    
    <p:wrap-sequence name="wrap-rearmatter" wrapper="rearmatter">
        <p:input port="source">
            <p:pipe step="for-each-rearmatter" port="result"/>
        </p:input>
    </p:wrap-sequence>
    
    <p:wrap-sequence wrapper="dtbook">
        <p:input port="source">
            <p:pipe step="wrap-head" port="result"/>
            <p:pipe step="wrap-frontmatter" port="result"/>
            <p:pipe step="wrap-bodymatter" port="result"/>
            <p:pipe step="wrap-rearmatter" port="result"/>
        </p:input>
    </p:wrap-sequence>

    <p:store>
        <p:with-option name="href" select="'/Users/marisa/test.xml'"/>
    </p:store>
</p:declare-step>
