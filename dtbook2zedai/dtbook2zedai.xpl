<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step xmlns:p="http://www.w3.org/ns/xproc" version="1.0" name="dtbook2zedai">
    <!-- 
        
        This XProc script is the main entry point for the DTBook2ZedAI module.
        The module's homepage is here: http://code.google.com/p/daisy-pipeline/wiki/DTBook2ZedAI
        
        Note that the wiki page lists more steps than what you'll find here.  That's because this script isn't complete yet.
    -->
    
    <p:input port="source" primary="true"/>
    <p:input port="parameters" kind="parameter" />
    
    
    <!-- Validate DTBook Input-->
    <p:validate-with-relax-ng assert-valid="true" name="validate-dtbook">
        <p:input port="schema">
            <p:document href="./schema/dtbook-2005-3.rng"/>
        </p:input>
    </p:validate-with-relax-ng>
    
    
    <!-- normalize dtbook -->
   <p:group name="normalize-dtbook">
       <!--<p:xslt name="normalize-inline">
           <p:input port="stylesheet">
               <p:document href="./normalize-inline.xsl"/>
           </p:input>
       </p:xslt>-->
       
        <p:xslt name="normalize-linegroups">
            <p:input port="stylesheet">
                <p:document href="./normalize-linegroup/dtbook-linegroup-flatten.xsl"/>
            </p:input>
        </p:xslt>
        
    </p:group>
    
    <!-- transform dtbook to zedai -->
    <p:xslt name="translate-dtbook2zedai"> 
        <p:input port="stylesheet">
            <p:document href="./dtbook2zedai.xsl"/>
        </p:input>
    </p:xslt>
    
    
    <!-- Validate the ZedAI output -->
    <p:validate-with-relax-ng assert-valid="false" name="validate-zedai">
        <p:input port="schema">
            <p:document href="./schema/zedai_bookprofile_v0.7/z3986a-book.rng"/>
        </p:input>
    </p:validate-with-relax-ng>
    
    
    <p:store href="out.xml"/>
    
</p:declare-step>