<?xml version="1.0" encoding="UTF-8"?>

<p:declare-step version="1.0" name="dtbook2zedai"  
        xmlns:p="http://www.w3.org/ns/xproc"
        xmlns:c="http://www.w3.org/ns/xproc-step"
        xmlns:cx="http://xmlcalabash.com/ns/extensions"
        xmlns:cxo="http://xmlcalabash.com/ns/extensions/osutils"
        exclude-inline-prefixes="cx">
    <p:import href="http://xmlcalabash.com/extension/steps/library-1.0.xpl"/>
    <!-- 
        
        This XProc script is the main entry point for the DTBook2ZedAI module.
        The module's homepage is here: http://code.google.com/p/daisy-pipeline/wiki/DTBook2ZedAI
        
    -->
    
    <p:input port="source" primary="true"/>
    <p:input port="parameters" kind="parameter" />
    
    
    <p:option name="output" select="''"/>
    
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
    
    <cx:message>
        <p:with-option name="message" select="$zedai-file"/>
    </cx:message>
    
    <!-- Validate DTBook Input-->
    <p:validate-with-relax-ng assert-valid="true" name="validate-dtbook">
        <p:input port="schema">
            <p:document href="./schema/dtbook-2005-3.rng"/>
        </p:input>
    </p:validate-with-relax-ng>
    
    <!-- create MODS metadata record -->
    <p:xslt name="create-mods">
        <p:input port="stylesheet">
            <p:document href="./generate-mods.xsl"/>
        </p:input>
    </p:xslt>
    <p:store>
        <p:with-option name="href" select="$mods-file"/>
    </p:store>
    
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
       
    </p:group>
    
    <!-- Translate element and attribute names from DTBook to ZedAI -->
    <p:xslt name="translate-dtbook2zedai">
        <p:with-param name="mods-filename" select="$mods-file"/>
        <p:with-param name="css-filename" select="$css-file"/>
        <p:input port="stylesheet">
            <p:document href="./dtbook2zedai.xsl"/>
        </p:input>
    </p:xslt>
    
    
    <p:xslt name="generate-css" use-when="0">
        <p:input port="stylesheet">
            <p:document href="./generate-css.xsl"/>
        </p:input>   
    </p:xslt>
    <p:store method="text" use-when="0">
        <p:with-option name="href" select="$css-file"/>
    </p:store> 
    
    <p:xslt name="remove-css-attributes">
        <p:input port="stylesheet">
            <p:document href="./remove-css-attributes.xsl"/>
        </p:input>
        <p:input port="source">
            <p:pipe step="translate-dtbook2zedai" port="result"/>
        </p:input>
    </p:xslt>
    
    
    <!-- Validate the ZedAI output -->
    <p:validate-with-relax-ng assert-valid="false" name="validate-zedai" use-when="0">
        <p:input port="schema">
            <p:document href="./schema/z3986a-book-0.8/z3986a-book.rng"/>
        </p:input>
    </p:validate-with-relax-ng>
    
    
    <p:store>
        <p:with-option name="href" select="$zedai-file"/>
    </p:store>
    
</p:declare-step>