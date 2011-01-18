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
                    else concat($output,'.xml'))">
            <p:pipe step="dtbook2zedai" port="source"/>
            </p:variable>
    
    <cx:message>
        <p:with-option name="message" select="$zedai-file"/>
    </cx:message>
    
    <!-- Validate DTBook Input-->
    <p:validate-with-relax-ng assert-valid="true" name="validate-dtbook">
        <p:input port="schema">
            <p:document href="./schema/dtbook-2005-3.rng"/>
        </p:input>
    </p:validate-with-relax-ng>
    
    
    
    <!-- Normalize DTBook content model -->
   <p:group name="normalize-dtbook">
       
       <!-- sort out the linegroup content model -->
       <p:xslt name="normalize-linegroups" use-when="0">
           <p:input port="stylesheet">
               <p:document href="./normalize-linegroup/dtbook-linegroup-flatten.xsl"/>
           </p:input>
           
       </p:xslt>
       
       <!-- move linegroups out from elements which must not contain them once converted to zedai -->
       <!-- This XSL needs to be written; will base it on move-out-imggroup when that's working -->
       <p:xslt name="move-out-linegroup" use-when="0">
           <p:input port="stylesheet">
               <p:document href="./move-out-linegroup.xsl"/>
           </p:input>
       </p:xslt>
        
       <!-- move imggroups out from elements which must not contain them once converted to zedai -->
       <p:xslt name="move-out-imggroup">
           <p:input port="stylesheet">
               <p:document href="./move-out-imggroup.xsl"/>
           </p:input>
       </p:xslt>
       
       <!-- normalize mixed block/inline content models -->
       <p:xslt name="normalize-block-inline">
           <p:input port="stylesheet">
               <p:document href="./normalize-block-inline.xsl"/>
           </p:input>
       </p:xslt>
       
       <!-- convert br to ln -->
       <p:xslt name="convert-br-to-ln">
           <p:input port="stylesheet">
               <p:document href="./convert-br-to-ln.xsl"/>
           </p:input>
       </p:xslt>
       
    </p:group>
   
    
    <!-- Translate element and attribute names from DTBook to ZedAI -->
    <p:xslt name="translate-dtbook2zedai"> 
        <p:input port="stylesheet">
            <p:document href="./dtbook2zedai.xsl"/>
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