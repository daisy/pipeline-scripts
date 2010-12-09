<?xml version="1.0" encoding="UTF-8"?>
<p:pipeline xmlns:p="http://www.w3.org/ns/xproc" version="1.0" name="dtbook2zedai">
    
    <!-- 
        
        This XProc script is the main entry point for the DTBook2ZedAI module.
        The module's homepage is here: http://code.google.com/p/daisy-pipeline/wiki/DTBook2ZedAI
        
        Note that the wiki page lists more steps than what you'll find here.  That's because this script isn't complete yet.
    -->
    
    
    
    <!-- validate dtbook -->
    <p:validate-with-relax-ng assert-valid="true">
        <p:input port="schema">
            <p:document href="./schema/dtbook-2005-3.rng"/>
        </p:input>
    </p:validate-with-relax-ng>
    
    <!-- normalize dtbook -->
    <!-- TODO: it would be nice to encapsulate all of the normalization steps -->
    <!-- Ideas for normalization:
       
        * Flatten nested linegroups
        * Insert required frontmatter/bodymatter if not present
        * Organize images, image groups, image-related prodnotes, image-related captions
        * Move <imggroup>s out of inline contexts.  They will be <block>s in zedai, which cannot live inline.
        * Move <br>s out of inline contexts.  They will be <separator>s in zedai, which cannot live inline.        
        
    -->
    <p:xslt>
        <p:input port="stylesheet">
            <p:document href="./normalize-linegroup/dtbook-linegroup-flatten.xsl"/>
        </p:input>
    </p:xslt>
    
    <!-- transform dtbook to zedai -->
    <p:xslt name="transform_dtbook2zedai_xsl">      
        <p:input port="stylesheet">
            <p:document href="./dtbook2zedai.xsl"/>
        </p:input>
    </p:xslt>
    
    
    <!-- validate final zedai -->
    <!--
    <p:validate-with-relax-ng assert-valid="true">
        <p:input port="schema">
            <p:document href="./schema/zedai_bookprofile_v0.7/z3986a-book.rng"/>
        </p:input>
    </p:validate-with-relax-ng>
    -->
    
    <!-- TODO: how to hook up p:store without getting errors? I either get an error that the pipeline has no output, or
    , if i give it explicit output, that there is null input -->
    <!--    
        <p:store href="out.xml"/>
    -->
    
    
</p:pipeline>