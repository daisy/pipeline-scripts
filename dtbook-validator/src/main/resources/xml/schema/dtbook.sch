<?xml version="1.0" encoding="UTF-8"?>
<schema xmlns="http://purl.oclc.org/dsdl/schematron" queryBinding="xslt2"
    xmlns:dtb="http://www.daisy.org/z3986/2005/dtbook/"
    xmlns:m="http://www.w3.org/1998/Math/MathML"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
    <ns uri="http://www.daisy.org/z3986/2005/dtbook/" prefix="dtb"/>
    <ns uri="http://www.w3.org/1998/Math/MathML" prefix="m"/>
    
    <!-- TODO look at what possible datatype validation can be done
        e.g. page="front|normal|special
       -->
    
    <!-- idref targets must exist 
    TODO what about external document targets?
    check what the pipeline1 had to say about this
    
    1. check idref is nonempty and longer than just '#'
    2. check that target exists
    3. check that noterefs reference notes, prodnoterefs reference prodnotes, etc
    
    optimize id-searching by storing all the IDs
    e.g.
    <sch:key name="notes" match="dtb:note[@id]" path="@id"/>
    
    -->
    
    <xsl:key name="notes" match="dtb:note[@id]" use="@id"/>
    <xsl:key name="annotations" match="dtb:annotation[@id]" use="@id"/>
    
    <pattern id="dtbook_MetaUid">
        <!-- dtb:uid meta element exists -->
        <rule context="dtb:head">
            <assert test="count(dtb:meta[@name='dtb:uid'])=1"> 
                [sch][zedid::dtbook_MetaUid]
            </assert>        
        </rule>
        <rule context="dtb:meta[@name='dtb:uid']">
            <assert test="string-length(normalize-space(@content))!=0">
                Content of dtb:uid metadata may not be empty
            </assert>        
        </rule>
    </pattern> 
    
    <pattern id="dtbook_MetaTitle">
        <rule context="dtb:head">
            <assert test="count(dtb:meta[@name='dc:Title'])>0"> 
                [sch][zedid::dtbook_MetaTitle]
            </assert>  
        </rule>
        <rule context="dtb:meta[@name='dc:Title']">
            <assert test="string-length(normalize-space(@content))!=0">
                Content of dc:Title metadata may not be empty
            </assert>        
        </rule>
    </pattern>
    
    <pattern id="dtbook_idrefNote">
        <rule context="dtb:noteref">	  
            <assert test="contains(@idref, '#')">
                [sch][zedid::dtbook_noteFragment]
            </assert>
            <report test="contains(@idref, '#') and string-length(substring-before(@idref, '#'))=0 and count(key('notes',substring(current()/@idref,2)))!=1">
                [sch][zedid::dtbook_idrefNote]
                THE KEY IS ***<value-of select="key('notes', 'p004-n002')"/>*** 
            </report>
            <!-- Do not perform any checks on external note references
	       since you cannot set a URIResolver in Jing
	  <sch:report test="string-length(substring-before(@idref, '#'))>0 and not(document(substring-before(@idref, '#')))">External document does not exist</sch:report>
	  <sch:report test="string-length(substring-before(@idref, '#'))>0 and count(document(substring-before(@idref, '#'))//dtb:note[@id=substring-after(current()/@idref, '#')])!=1">Incorrect external fragment identifier</sch:report>
	  -->
        </rule>
    </pattern>  
    
    <pattern id="dtbook_idrefAnnotation">
        <rule context="dtb:annoref">
            <assert test="contains(@idref, '#')">
                [sch][zedid::dtbook_annotationFragment]
            </assert>
            <report test="contains(@idref, '#') and string-length(substring-before(@idref, '#'))=0 and count(key('annotations',substring(current()/@idref,2)))!=1">
                [sch][zedid::dtbook_idrefAnnotation]
            </report>
            <!-- Do not perform any checks on external note references
	       since you cannot set a URIResolver in Jing
	  <sch:report test="string-length(substring-before(@idref, '#'))>0 and not(document(substring-before(@idref, '#')))">External document does not exist</sch:report>
	  <sch:report test="string-length(substring-before(@idref, '#'))>0 and count(document(substring-before(@idref, '#'))//dtb:annotation[@id=substring-after(current()/@idref, '#')])!=1">Incorrect external fragment identifier</sch:report>
	  -->
        </rule>
    </pattern>
    
    <!-- MG20061101: added as a consequence of zedval feature request #1565049 -->
    <pattern id="dtbook_internalLinks">
        <rule context="dtb:a[starts-with(@href, '#')]">
            <assert test="count(//dtb:*[@id=substring(current()/@href, 2)])=1">
                [sch][zedid::dtbook_internalLinks]
            </assert>
        </rule>  	
    </pattern> 
    <!-- Imported from Pipeline 1 -->
    <pattern>
        <rule context="dtb:head">
            <assert test="count(dtb:meta[@name='dtb:uid'])=1"> 
                dtb:uid meta required
            </assert>        
        </rule>
        <rule context="dtb:meta[@name='dtb:uid']">
            <assert test="string-length(normalize-space(@content))!=0">
                Content of dtb:uid metadata may not be empty
            </assert>        
        </rule>
    </pattern> 
    
    <!-- Imported from Pipeline 1 -->
    <pattern>
        <rule context="dtb:head">
            <assert test="count(dtb:meta[@name='dc:Title'])>0"> 
                dc:Title meta required
            </assert>  
        </rule>
        <rule context="dtb:meta[@name='dc:Title']">
            <assert test="string-length(normalize-space(@content))!=0">
                Content of dc:Title metadata may not be empty
            </assert>        
        </rule>
    </pattern>
    
    <!-- Imported from Pipeline 1
        MG20061101: added as a consequence of zedval feature request #1565049 -->
    <pattern>
        <rule context="dtb:a[starts-with(@href, '#')]">
            <assert test="count(//dtb:*[@id=substring(current()/@href, 2)])=1">
                Internal link targets must exist 
            </assert>
        </rule>  	
    </pattern>  
    
    <!-- Imported from Pipeline 1
        MG20061101: added as a consequence of zedval feature request #1565049 -->
    <pattern>
        <rule context="dtb:list">
            <report test="@enum and @type!='ol'">
                The 'enum' attribute on lists should only be used when the 'type' attribute is 'ol'.
            </report>
        </rule>
    </pattern>
    
    <!-- Imported from Pipeline 1
        MG20061101: added as a consequence of zedval feature request #1565049 -->
    <pattern>
        <rule context="dtb:list">
            <report test="@depth and @depth!=count(ancestor-or-self::dtb:list)">
                   dtb:list depth should be equal to actual depth 
            </report>
        </rule>
    </pattern>
    
    <!-- Imported from Pipeline 1
        MG20061101: added as a consequence of zedval feature request #1565049 -->
    <pattern>
        <rule context="dtb:*[@headers and (self::dtb:th or self::dtb:td)]">
            <assert test="
                count(
                ancestor::dtb:table//dtb:th/@id[contains( concat(' ',current()/@headers,' '), concat(' ',normalize-space(),' ') )]
                ) = 
                string-length(normalize-space(@headers)) - string-length(translate(normalize-space(@headers), ' ','')) + 1
                ">
                The 'headers' attribute on the td element should only refer to th
                elements within the same table.
            </assert>
        </rule>
    </pattern>
    
    <!-- Imported from Pipeline 1
        MG20061101: added as a consequence of zedval feature request #1565049 -->
    <pattern>
        <rule context="dtb:prodnote[@imgref]">
            <assert test="
                count(
                //dtb:img/@id[contains( concat(' ',current()/@imgref,' '), concat(' ',normalize-space(),' ') )]
                ) = 
                string-length(normalize-space(@imgref)) - string-length(translate(normalize-space(@imgref), ' ','')) + 1
                ">
                'imgref' should only be allowed when the prodnote is a direct child of an
                imggroup element and the attribute should only point to img elements
                within that imggroup.
            </assert>
        </rule>
    </pattern>
    
    <!-- Imported from Pipeline 1
        MG20061101: added as a consequence of zedval feature request #1565049 -->  
    <pattern>
        <rule context="dtb:caption[@imgref]">
            <assert test="
                count(
                //dtb:img/@id[contains( concat(' ',current()/@imgref,' '), concat(' ',normalize-space(),' ') )]
                ) = 
                string-length(normalize-space(@imgref)) - string-length(translate(normalize-space(@imgref), ' ','')) + 1
                ">
                'imgref' should only be allowed when the caption is a direct child of an
                imggroup element and the attribute should only point to img elements
                within that imggroup.
            </assert>
        </rule>
    </pattern>
    
    <!-- Imported from Pipeline 1
        MG20061101: added as a consequence of zedval feature request #1565049 -->
    <pattern>
        <rule context="dtb:a">
            <report test="@accesskey and string-length(@accesskey)!=1">The string length of the 'accesskey' attibute value should be 1.</report>
            <report test="@tabindex and string-length(translate(@width,'0123456789',''))!=0">The 'tabindex' attribute should only contain numbers.</report>
            <report test="@accesskey and count(//dtb:a/@accesskey=@accesskey)!=1">The 'accesskey' attribute value should be unique.</report>
            <report test="@tabindex and count(//dtb:a/@tabindex=@tabindex)!=1">The 'tabindex' attribute value should be unique.</report>
        </rule>
    </pattern>    
    
    <!-- Imported from Pipeline 1
        MG20061101: added as a consequence of zedval feature request #1565049 -->
    <pattern>
        <rule context="dtb:*[self::dtb:col   or self::dtb:colgroup or self::dtb:tbody or self::dtb:td or 
            self::dtb:tfoot or self::dtb:th       or self::dtb:thead or self::dtb:tr]">
            <report test="@char and string-length(@char)!=1">
                The 'char' attribute on col, colgroup, tbody, td, tfoot, th, thead or tr should have a string length of 1.</report>
            <report test="@char and @align!='char'">
                The 'char' attribute on col, colgroup, tbody, td, tfoot, th, thead or tr is only allowed if the value of the 'align' attribute is "char"</report>
        </rule>
    </pattern>
    
    <!-- Imported from Pipeline 1
        MG20061101: added as a consequence of zedval feature request #1565049 -->
    <pattern>
        <rule context="dtb:img">
            <assert test="not(@width) or 
                string-length(translate(@width,'0123456789',''))=0 or
                (contains(@width,'%') and substring-after(@width,'%')='' and translate(@width,'%0123456789','')='' and string-length(@width)>=2)"
                >img 'width' attribute is not numeric or a percent value</assert>
            <assert test="not(@height) or 
                string-length(translate(@height,'0123456789',''))=0 or
                (contains(@height,'%') and substring-after(@height,'%')='' and translate(@height,'%0123456789','')='' and string-length(@height)>=2)"
                >img 'height' attribute is not numeric or a percent value</assert>
        </rule>
    </pattern>
    
    <!-- Imported from Pipeline 1
        MG20061101: added as a consequence of zedval feature request #1565049 -->
    <pattern>
        <rule context="dtb:table">
            <assert test="not(@width) or 
                string-length(translate(@width,'0123456789',''))=0 or
                (contains(@width,'%') and substring-after(@width,'%')='' and translate(@width,'%0123456789','')='' and string-length(@width)>=2)"
                >table 'width' attribute is not numeric or a percent value</assert>
            <assert test="not(@cellspacing) or 
                string-length(translate(@cellspacing,'0123456789',''))=0 or
                (contains(@cellspacing,'%') and substring-after(@cellspacing,'%')='' and translate(@cellspacing,'%0123456789','')='' and string-length(@cellspacing)>=2)"
                >table 'cellspacing' attribute is not numeric or a percent value</assert>
            <assert test="not(@cellpadding) or 
                string-length(translate(@cellpadding,'0123456789',''))=0 or
                (contains(@cellpadding,'%') and substring-after(@cellpadding,'%')='' and translate(@cellpadding,'%0123456789','')='' and string-length(@cellpadding)>=2)"
                >table 'cellpadding' attribute is not numeric or a percent value</assert>
        </rule>
    </pattern>
    
    <!-- Imported from Pipeline 1
        MG20061101: added as a consequence of zedval feature request #1565049 -->
    <pattern>
        <rule context="dtb:list">
            <report test="@start and @type!='ol'">list 'start' attribute present but list type != 'ol'</report>
            <report test="@start='' or string-length(translate(@start,'0123456789',''))!=0">list 'start' attribute should be non-negative</report>
        </rule>
    </pattern> 
    
    <!-- Imported from Pipeline 1
        MG20061101: added as a consequence of zedval feature request #1565049 -->
    <pattern>
        <rule context="dtb:meta">
            <report test="starts-with(@name, 'dc:') and not(@name='dc:Title' or @name='dc:Subject' or @name='dc:Description' or
                @name='dc:Type' or @name='dc:Source' or @name='dc:Relation' or 
                @name='dc:Coverage' or @name='dc:Creator' or @name='dc:Publisher' or 
                @name='dc:Contributor' or @name='dc:Rights' or @name='dc:Date' or 
                @name='dc:Format' or @name='dc:Identifier' or @name='dc:Language')"
                >meta 'name' attribute invalid</report>
            <report test="starts-with(@name, 'DC:') or starts-with(@name, 'Dc:') or starts-with(@name, 'dC:')">meta 'name' attribute prefix should be 'dc:'</report>
        </rule>
    </pattern>
    
    <!-- Imported from Pipeline 1
        MG20061101: added as a consequence of zedval feature request #1565049 -->
    <pattern>
        <rule context="dtb:*[self::dtb:col or self::dtb:colgroup]">
            <report test="@span and (translate(@span,'0123456789','')!='' or starts-with(@span,'0'))">col and colgroup elements' 'span' attribute should be numeric</report>
        </rule>
    </pattern>
    
    <!-- Imported from Pipeline 1
        MG20061101: added as a consequence of zedval feature request #1565049 -->  
    <pattern>
        <rule context="dtb:*[self::dtb:td or self::dtb:th]">
            <report test="@rowspan and (translate(@rowspan,'0123456789','')!='' or starts-with(@rowspan,'0'))">
                td and th elements' 'rowspan' attribute should be numeric and should not start with 0</report>
            <report test="@colspan and (translate(@colspan,'0123456789','')!='' or starts-with(@colspan,'0'))">
                td and th elements' 'colspan' attribute should be numeric and should not start with 0</report>    	
            <report test="@rowspan and number(@rowspan) > count(parent::dtb:tr/following-sibling::dtb:tr)+1">
                td and th elements' 'rowspan' attribute should correspond to the table row count</report>
        </rule>
    </pattern>  
    
    <!-- Imported from Pipeline 1 
        MG20070522: added as a consequence of zedval feature request #1593192 -->
    <pattern>
        <rule context="dtb:level[@depth]">
            <assert test="@depth=count(ancestor-or-self::dtb:level)">level elements' 'depth' attribute should be correct</assert>
        </rule>
    </pattern>
    
    
    <!-- MathML rules -->
    <pattern> 
        <rule context="//m:math">
            
            <!-- 
                The math element has optional attributes alttext and altimg. To be valid with the MathML in DAISY spec, 
                the alttext and altimg attributes must be part of the math element.
             -->
            <assert test="//node()[@alttext]">@alttext must be present</assert>
            <assert test="not(empty(//node()[@alttext]))">@alttext must be non-empty</assert>
            
            <assert test="//node()[@altimg]">@altimg must be present</assert>
            <assert test="not(empty(//node()[@altimg]))">@altimg must be non-empty</assert>
            
            <!-- 
                The math element must also include a dtbook:smilref attribute that references the corresponding element in the SMIL file. 
                Note that this attribute must be in the dtbook namespace.
                
                TODO: @smilref may be present and if so must be non-empty
             -->
            <!--<assert test="//node()[@dtb:smilref]">@smilref must be present</assert>
            <assert test="not(empty(//node()[@dtb:smilref]))">@smilref must be non-empty</assert>
            -->
        </rule>
    </pattern>
    
    <!--
        If any of the content elements listed in Chapter 4 of the MathML specification with the exception of those 
        listed in Section 4.4.11 (Semantic Mapping Elements) are used, they must appear inside of an 
        annotation-xml element inside of a semantics element.
        
        TODO: maybe can be ancestor, not strictly parent? 
        TODO: use qname instead of local
    -->
    <pattern>
        <!-- this is a list of all the mathml 2 content elements except the semantic mapping elements -->
        <!--there are actually more elements in the spec than the content elements; that's why we can't just test 
            for 'not the semantic mapping elements'-->
        <rule context="m:cn | 
            m:ci | 
            m:csymbol | 
            m:apply | 
            m:reln | 
            m:fn | 
            m:interval | 
            m:inverse | 
            m:sep | 
            m:condition | 
            m:declare | 
            m:lambda | 
            m:compose | 
            m:ident | 
            m:domain | 
            m:codomain | 
            m:image | 
            m:domainofapplication | 
            m:piecewise | 
            m:piece | 
            m:otherwise | 
            m:quotient | 
            m:factorial | 
            m:divide | 
            m:max |  
            m:min | 
            m:minus | 
            m:plus | 
            m:power | 
            m:rem | 
            m:times | 
            m:root | 
            m:gcd | 
            m:and | 
            m:or | 
            m:xor | 
            m:not | 
            m:implies | 
            m:forall | 
            m:exists | 
            m:abs | 
            m:conjugate | 
            m:arg | 
            m:real | 
            m:imaginary | 
            m:lcm | 
            m:floor | 
            m:ceiling | 
            m:eq | 
            m:neq | 
            m:gt | 
            m:lt | 
            m:geq | 
            m:leq | 
            m:equivalent | 
            m:approx | 
            m:factorof | 
            m:int | 
            m:diff | 
            m:partialdiff | 
            m:lowlimit | 
            m:uplimit | 
            m:bvar | 
            m:degree | 
            m:divergence | 
            m:grad | 
            m:curl | 
            m:laplacian | 
            m:set | 
            m:list | 
            m:union | 
            m:intersect | 
            m:in | 
            m:notin | 
            m:subset | 
            m:prsubset | 
            m:notsubset | 
            m:notprsubset | 
            m:setdiff | 
            m:card | 
            m:cartesianproduct | 
            m:sum | 
            m:product | 
            m:limit | 
            m:tendsto | 
            m:exp | 
            m:ln | 
            m:log | 
            m:sin | 
            m:cos | 
            m:tan | 
            m:sec | 
            m:csc | 
            m:cot | 
            m:sinh | 
            m:cosh | 
            m:tanh | 
            m:sech | 
            m:csch | 
            m:coth | 
            m:arcsin | 
            m:arccos | 
            m:arctan | 
            m:arccosh | 
            m:arccot | 
            m:arccoth | 
            m:arccsc | 
            m:arccsch | 
            m:arcsec | 
            m:arcsech | 
            m:arcsinh | 
            m:arctanh | 
            m:mean | 
            m:sdev | 
            m:variance | 
            m:median | 
            m:mode | 
            m:moment | 
            m:momentabout | 
            m:vector | 
            m:matrix | 
            m:matrixrow | 
            m:determinant | 
            m:transpose | 
            m:selector | 
            m:vectorproduct | 
            m:scalarproduct | 
            m:outerproduct | 
            m:integers | 
            m:reals | 
            m:rationals | 
            m:naturalnumbers | 
            m:complexes | 
            m:primes | 
            m:exponentiale | 
            m:imaginaryi | 
            m:notanumber | 
            m:true | 
            m:false | 
            m:emptyset | 
            m:pi | 
            m:eulergamma | 
            m:infinity">
            <assert test="local-name(node()/parent::node()) = 'annotation-xml'">Parent node must be &lt;annotation-xml&gt;</assert>
        </rule>
    </pattern>
</schema>