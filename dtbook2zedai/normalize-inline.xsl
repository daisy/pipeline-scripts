<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:dtb="http://www.daisy.org/z3986/2005/dtbook/"
    xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl" exclude-result-prefixes="xd dtb" version="2.0">
    
    <xd:doc>
        <xd:desc>This stylesheet maps elements with dtbook:inline content model to something that will translate easily into zedai.</xd:desc>
    </xd:doc>
    
    
    <!-- All of the elements processed here have dtbook:inline as their content model, and all of the elements' zedai equivalents have zedai:inline as 
        their content model (see below) 
        
        dtbook:inline
        =========
        text
        em
        strong
        dfn
        code
        samp
        kbd
        cite
        abbr
        acronym
        a
        img
        imggroup
        br
        q
        sub
        sup
        span
        bdo
        sent
        w
        pagenum
        prodnote
        annoref
        noteref
        
        
        zedai:"inline" (there is no such named group, but we will refer to this set of 44 elements as such):
        =======
        abbr
        annoref
        annotation
        char
        citation
        code
        d
        definition
        emph, emph
        expansion
        its:ruby
        ln
        m:math
        name
        noteref
        num
        object, object
        pagebreak
        quote
        ref
        s
        sel:select
        span, span
        ssml:break, ssml:phoneme, ssml:prosody, ssml:say-as, ssml:sub, ssml:token
        sub
        sup
        term
        time
        w, w
        xforms:input, xforms:range, xforms:secret, xforms:select, xforms:select1 or xforms:textarea
    -->
    
    <xsl:output indent="yes" method="xml"/>
    
    <!-- identity template -->
    <xsl:template match="@*|node()">
        <xsl:copy>
            <xsl:apply-templates select="@*|node()"/>
        </xsl:copy>
    </xsl:template>
    
    <!-- TODO: there are many dtbook elements whose content model is x + inline.  could process them here too. -->
    
    <xsl:template match="dtb:title | dtb:author | dtb:byline | dtb:dateline | dtb:em | dtb:strong | dtb:bdo | dtb:span | dtb:q | 
    dtb:doctitle | dtb:docauthor | dtb:h1 | dtb:h2 | dtb:h3 | dtb:h4 | dtb:h5 | dtb:h6 | dtb:bridgehead | dtb:hd">
        <xsl:call-template name="normalize-inline"/>
    </xsl:template>
    
   
    <!-- all of these elements have a dtbook:inline content model.  we need to move some child nodes to make it compatible with content model of the elements' zedai representation -->
    <xsl:template name="normalize-inline">
        
        <!-- extract what is not allowed in zedai:"inline": 
            samp, imggroup, br 
            move to the first parent that can have it as a child
            
            question: how to reassign parent in xslt?
            
            question: do we split the original parent of samp|imggroup|br or move samp|imggroup|br before/after?
        -->
        <xsl:copy>
            <xsl:apply-templates select="@*"/>
            <xsl:for-each select="child::node()">
                <xsl:choose>
                    
                    <xsl:when test="name() = 'samp' or name() = 'imggroup' or name() = 'br'">
                        <!-- TODO: move these elements somewhere correct instead of discarding them -->
                        <!-- how do i save this element for later?  variables are local -->
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:copy>
                            <xsl:apply-templates select="@*"/>
                            <xsl:apply-templates/>
                        </xsl:copy>
                    </xsl:otherwise>
                </xsl:choose>
                
                
            </xsl:for-each>
            
        </xsl:copy>
       
        
    </xsl:template>

    <!-- e.g. 
        
        This:
        
        <dtb:h1>
            <abbr>..</abbr>
            <acronym>..</acronym>
            <imggroup>..</imggroup>
            <span>..</span>
            some text
        </dtb:h1>
        
        Becomes this:
        <dtb:h1>
            <abbr>...</abbr>
            <acronym>..</acronym>
        </dtb:h1>
        
        <imggroup>..</imggroup>
        
        <div>
            <span>..</span>
            some text
        </div>
        
        Or this:
        
        <dtb:h1>
            <abbr>...</abbr>
            <acronym>..</acronym>
            <span>..</span>
            some text
        </dtb:h1>
        
        <imggroup>..</imggroup>
        
        In the main dtbook2zedai transformation:
            dtbook:h1 will become zedai:h
        
        And:
            dtbook:samp will become zedai:block
            dtbook:imggroup will become zedai:block
            dtbook:br will become zedai:separator
        
        The question is, though, can all possible parents of zedai:h have zedai:block and zedai:separator as children too?
        
        For zedai:h the answer is: yes, if we deal separately with poetry (section-verse and verse elements)
        
        Now just to check for all the others ... 
    -->
    


    <!-- Just a note
        dtb:covertitle and dtb:samp also have a dtbook:inline content model, but they map to zedai:block, which has a more flexible 
            content model than the zedai:"inline" model described above 
            for these elements, no content model transformation is required
    -->
    
    
</xsl:stylesheet>
