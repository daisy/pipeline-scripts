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
    
    <p:variable name="mods-file" select="if (ends-with($zedai-file, '.xml')) then replace($zedai-file, '.xml', '-mods.xml')
                                         else concat($zedai-file, '-mods.xml')"/>
    
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
            <p:document href="./process-mods-meta.xsl"/>
        </p:input>
    </p:xslt>
    <p:store>
        <p:with-option name="href" select="$mods-file"/>
    </p:store>
    
    <!-- Normalize DTBook content model -->
   <p:group name="normalize-dtbook">
       
       <!-- sort out the linegroup content model -->
       <p:xslt name="normalize-linegroups" use-when="0">
           <p:input port="stylesheet">
               <p:document href="./normalize-linegroup/dtbook-linegroup-flatten.xsl"/>
           </p:input>
           
       </p:xslt>
       
       <!-- normalize nested samps -->
       <p:xslt name="normalize-samp">
           <p:input port="stylesheet">
               <p:document href="./normalize-samp.xsl"/>
           </p:input>
           <p:input port="source">
               <p:pipe step="validate-dtbook" port="result"/>
           </p:input>
       </p:xslt>
       
       <!-- move linegroups out from elements which must not contain them once converted to zedai -->
       <!-- TODO: review this approach; linegroups are very selectively used in ZedAI -->
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
        <p:with-param name="mods-filename" select="$mods-file"/>
        <p:input port="stylesheet">
            <p:document href="./dtbook2zedai.xsl"/>
        </p:input>
    </p:xslt>
    
    <!-- TODO: scrape the ZedAI output for CSS attributes; then remove them from the ZedAI file.
    The reason we can't do this in parallel with the main ZedAI transformation step (above) is that too much
    could potentially change wrt elements (and subsequently, their IDs) to generate an accurate CSS file.-->
    
    
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