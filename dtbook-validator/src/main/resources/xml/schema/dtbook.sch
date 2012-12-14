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
    
    <!-- TODO beautify this file. it's a mix of older and newer schematron patterns. -->
    
    <xsl:key name="notes" match="dtb:note[@id]" use="@id"/>
    <xsl:key name="annotations" match="dtb:annotation[@id]" use="@id"/>
    
    <!-- because we override the ID datatype with NMTOKEN in the dtbook-mathml-integration schema,
        we need to double check that all @id values are unique
    -->
    <let name="id-set" value="//*[@id]"/>
    <pattern id="id-unique">
        <rule context="*[@id]">
            <assert test="count($id-set[@id = current()/@id]) = 1">Duplicate ID '<value-of
                select="current()/@id"/>'</assert>
        </rule>
    </pattern>
    
    <!-- ****************************************************** -->
    <!-- Patterns in this section were imported from Pipeline 1 -->
    <!-- ****************************************************** -->
    <pattern id="dtbook_MetaUid">
        <!-- dtb:uid meta element exists -->
        <rule context="dtb:head">
            <assert test="count(dtb:meta[@name='dtb:uid'])=1"> 
                There must be one and only one dtb:uid metadata item.
            </assert>        
        </rule>
        <rule context="dtb:meta[@name='dtb:uid']">
            <assert test="string-length(normalize-space(@content))!=0">
                Content of dtb:uid metadata may not be empty.
            </assert>        
        </rule>
    </pattern> 
    
    <pattern id="dtbook_MetaTitle">
        <rule context="dtb:head">
            <assert test="count(dtb:meta[@name='dc:Title'])>0"> 
                There must be at least one dc:Title metadata item.
            </assert>  
        </rule>
        <rule context="dtb:meta[@name='dc:Title']">
            <assert test="string-length(normalize-space(@content))!=0">
                Content of dc:Title metadata may not be empty.
            </assert>        
        </rule>
    </pattern>
    
    <pattern id="dtbook_idrefNote">
        <rule context="dtb:noteref">	  
            <assert test="contains(@idref, '#')">
                noteref URI value does not contain a fragment identifier.
            </assert>
            <report test="contains(@idref, '#') and string-length(substring-before(@idref, '#'))=0 and count(key('notes',substring(current()/@idref,2)))!=1">
                noteref URI value does not resolve to a note element.
            </report>
            <!-- Do not perform any checks on external note references since you cannot set a URIResolver in Jing
	       <sch:report test="string-length(substring-before(@idref, '#'))>0 and not(document(substring-before(@idref, '#')))">External document does not exist</sch:report>
	       <sch:report test="string-length(substring-before(@idref, '#'))>0 and count(document(substring-before(@idref, '#'))//dtb:note[@id=substring-after(current()/@idref, '#')])!=1">Incorrect external fragment identifier</sch:report>
	        -->
        </rule>
    </pattern>  
    
    <pattern id="dtbook_idrefAnnotation">
        <rule context="dtb:annoref">
            <assert test="contains(@idref, '#')">
                annoref URI value does not contain a fragment identifier.
            </assert>
            <report test="contains(@idref, '#') and string-length(substring-before(@idref, '#'))=0 and count(key('annotations',substring(current()/@idref,2)))!=1">
                annoref URI value does not resolve to a annotation element.
            </report>
            <!-- Do not perform any checks on external note references since you cannot set a URIResolver in Jing
	        <sch:report test="string-length(substring-before(@idref, '#'))>0 and not(document(substring-before(@idref, '#')))">External document does not exist</sch:report>
	        <sch:report test="string-length(substring-before(@idref, '#'))>0 and count(document(substring-before(@idref, '#'))//dtb:annotation[@id=substring-after(current()/@idref, '#')])!=1">Incorrect external fragment identifier</sch:report>
	        -->
        </rule>
    </pattern>
    
    <pattern id="dtbook_internalLinks">
        <rule context="dtb:a[starts-with(@href, '#')]">
            <assert test="count(//dtb:*[@id=substring(current()/@href, 2)])=1">
                Interal link does not resolve.
            </assert>
        </rule>  	
    </pattern> 
    
    <!-- MG20061101: added as a consequence of zedval feature request #1565049 -->
    <pattern id="dtbook_enumAttrInList">
        <rule context="dtb:list">
            <report test="@enum and @type!='ol'">
                The enum attribute is only allowed in numbered lists.
            </report>
        </rule>
    </pattern>
    
    <!-- MG20061101: added as a consequence of zedval feature request #1565049 -->
    <pattern id="dtbook_depthList">
        <rule context="dtb:list">
            <report test="@depth and @depth!=count(ancestor-or-self::dtb:list)">
                The depth attribute on list element does not contain the list wrapping level.  
            </report>
        </rule>
    </pattern>
    
    <!-- MG20061101: added as a consequence of zedval feature request #1565049 -->
    <pattern id="dtbook_headersThTd">
        <rule context="dtb:*[@headers and (self::dtb:th or self::dtb:td)]">
            <assert test="
                count(
                ancestor::dtb:table//dtb:th/@id[contains( concat(' ',current()/@headers,' '), concat(' ',normalize-space(),' ') )]
                ) = 
                string-length(normalize-space(@headers)) - string-length(translate(normalize-space(@headers), ' ','')) + 1
                ">
                Not all the tokens in the headers attribute match the id attributes of 'th' elements in this or a parent table.
            </assert>
        </rule>
    </pattern>
    
    <!-- MG20061101: added as a consequence of zedval feature request #1565049 -->
    <pattern id="dtbook_imgrefProdnote">
        <rule context="dtb:prodnote[@imgref]">
            <assert test="
                count(
                //dtb:img/@id[contains( concat(' ',current()/@imgref,' '), concat(' ',normalize-space(),' ') )]
                ) = 
                string-length(normalize-space(@imgref)) - string-length(translate(normalize-space(@imgref), ' ','')) + 1
                ">
                Not all the tokens in the imgref attribute match the id attributes of 'img' elements.
            </assert>
        </rule>
    </pattern>
    
    <!-- MG20061101: added as a consequence of zedval feature request #1565049 -->  
    <pattern id="dtbook_imgrefCaption">
        <rule context="dtb:caption[@imgref]">
            <assert test="
                count(
                //dtb:img/@id[contains( concat(' ',current()/@imgref,' '), concat(' ',normalize-space(),' ') )]
                ) = 
                string-length(normalize-space(@imgref)) - string-length(translate(normalize-space(@imgref), ' ','')) + 1
                ">
                Not all the tokens in the imgref attribute match the id attributes of 'img' elements.
            </assert>
        </rule>
    </pattern>
    
    <!-- MG20061101: added as a consequence of zedval feature request #1565049 -->
    <pattern id="dtbook_accesskeyTabindex">
        <rule context="dtb:a">
            <report test="@accesskey and string-length(@accesskey)!=1">The accesskey attribute value is not 1 character long.</report>
            <report test="@tabindex and string-length(translate(@width,'0123456789',''))!=0">The tabindex attribute value is not expressed in numbers.</report>
            <report test="@accesskey and count(//dtb:a/@accesskey=@accesskey)!=1">The accesskey attribute value is not unique within the document.</report>
            <report test="@tabindex and count(//dtb:a/@tabindex=@tabindex)!=1">The tabindex attribute value is not unique within the document.</report>
        </rule>
    </pattern>    
    
    <!-- MG20061101: added as a consequence of zedval feature request #1565049 -->
    <pattern id="dtbook_charAttribute">
        <rule context="dtb:*[self::dtb:col   or self::dtb:colgroup or self::dtb:tbody or self::dtb:td or 
            self::dtb:tfoot or self::dtb:th       or self::dtb:thead or self::dtb:tr]">
            <report test="@char and string-length(@char)!=1">The char attribute value is not 1 character long.</report>
            <report test="@char and @align!='char'">char attribute may only occur when align attribute value is 'char'.</report>
        </rule>
    </pattern>
    
    <!-- MG20061101: added as a consequence of zedval feature request #1565049 -->
    <pattern id="dtbook_imgWidthHeight">
        <rule context="dtb:img">
            <assert test="not(@width) or 
                string-length(translate(@width,'0123456789',''))=0 or
                (contains(@width,'%') and substring-after(@width,'%')='' and translate(@width,'%0123456789','')='' and string-length(@width)>=2)"
                >The image width is not expressed in pixels or percentage.</assert>
            <assert test="not(@height) or 
                string-length(translate(@height,'0123456789',''))=0 or
                (contains(@height,'%') and substring-after(@height,'%')='' and translate(@height,'%0123456789','')='' and string-length(@height)>=2)"
                >The image height is not expressed in pixels or percentage.</assert>
        </rule>
    </pattern>
    
    <!-- MG20061101: added as a consequence of zedval feature request #1565049 -->
    <pattern id="dtbook_tableAttributes">
        <rule context="dtb:table">
            <assert test="not(@width) or 
                string-length(translate(@width,'0123456789',''))=0 or
                (contains(@width,'%') and substring-after(@width,'%')='' and translate(@width,'%0123456789','')='' and string-length(@width)>=2)"
                >Table width is not expressed in pixels or percentage.</assert>
            <assert test="not(@cellspacing) or 
                string-length(translate(@cellspacing,'0123456789',''))=0 or
                (contains(@cellspacing,'%') and substring-after(@cellspacing,'%')='' and translate(@cellspacing,'%0123456789','')='' and string-length(@cellspacing)>=2)"
                >Table cellspacing is not expressed in pixels or percentage.</assert>
            <assert test="not(@cellpadding) or 
                string-length(translate(@cellpadding,'0123456789',''))=0 or
                (contains(@cellpadding,'%') and substring-after(@cellpadding,'%')='' and translate(@cellpadding,'%0123456789','')='' and string-length(@cellpadding)>=2)"
                >Table cellpadding is not expressed in pixels or percentage.</assert>
        </rule>
    </pattern>
    
    <!-- MG20061101: added as a consequence of zedval feature request #1565049 -->
    <pattern id="dtbook_startAttrInList">
        <rule context="dtb:list">
            <report test="@start and @type!='ol'">The start attribute occurs in a non-numbered list.</report>
            <report test="@start='' or string-length(translate(@start,'0123456789',''))!=0">The start attribute is not a non negative number.</report>
        </rule>
    </pattern> 
    
    <!-- MG20061101: added as a consequence of zedval feature request #1565049 -->
    <pattern id="dtbook_dcMetadata">
        <rule context="dtb:meta">
            <report test="starts-with(@name, 'dc:') and not(@name='dc:Title' or @name='dc:Subject' or @name='dc:Description' or
                @name='dc:Type' or @name='dc:Source' or @name='dc:Relation' or 
                @name='dc:Coverage' or @name='dc:Creator' or @name='dc:Publisher' or 
                @name='dc:Contributor' or @name='dc:Rights' or @name='dc:Date' or 
                @name='dc:Format' or @name='dc:Identifier' or @name='dc:Language')"
                >Unrecognized Dublin Core metadata name.</report>
            <report test="starts-with(@name, 'DC:') or starts-with(@name, 'Dc:') or starts-with(@name, 'dC:')">Unrecognized Dublin Core metadata prefix.</report>
        </rule>
    </pattern>
    
    <!-- MG20061101: added as a consequence of zedval feature request #1565049 -->
    <pattern id="dtbook_spanColColgroup">
        <rule context="dtb:*[self::dtb:col or self::dtb:colgroup]">
            <report test="@span and (translate(@span,'0123456789','')!='' or starts-with(@span,'0'))">span attribute is not a positive integer.</report>
        </rule>
    </pattern>
    
    <!-- MG20061101: added as a consequence of zedval feature request #1565049 -->  
    <pattern>
        <rule context="dtb:*[self::dtb:td or self::dtb:th]">
            <report test="@rowspan and (translate(@rowspan,'0123456789','')!='' or starts-with(@rowspan,'0'))">
                The rowspan attribute value is not a positive integer.</report>
            <report test="@colspan and (translate(@colspan,'0123456789','')!='' or starts-with(@colspan,'0'))">
                The colspan attribute value is not a positive integer.</report>    	
            <report test="@rowspan and number(@rowspan) > count(parent::dtb:tr/following-sibling::dtb:tr)+1">
                The rowspan attribute value is larger than the number of rows left in the table.</report>
        </rule>
    </pattern>  
    
    <!-- MG20070522: added as a consequence of zedval feature request #1593192 -->
    <pattern id="dtbook_levelDepth">
        <rule context="dtb:level[@depth]">
            <assert test="@depth=count(ancestor-or-self::dtb:level)">The value of the depth attribute on the level element does not correspond to actual nesting level.</assert>
        </rule>
    </pattern>
    
    <!-- ****************************************************** -->
    <!-- end Pipeline 1 pattern imports -->
    <!-- ****************************************************** -->
    
    <!-- ****************************************************** -->
    <!-- MathML rules -->
    <!-- ****************************************************** -->
    <pattern> 
        <rule context="//m:math">
            
            <!-- 
                The math element has optional attributes alttext and altimg. To be valid with the MathML in DAISY spec, 
                the alttext and altimg attributes must be part of the math element.
             -->
            <assert test="//node()[@alttext]">alttext attribute must be present</assert>
            <assert test="not(empty(//node()[@alttext]))">alttext attribute must be non-empty</assert>
            
            <assert test="//node()[@altimg]">altimg attribute must be present</assert>
            <assert test="not(empty(//node()[@altimg]))">altimg attribute must be non-empty</assert>
            
            <!-- Note that there is not a test for the rule 
                "@smilref may be present and if so must be non-empty"
                because this is designed to be used with standalone DTBook files
            -->
        </rule>
    </pattern>
    
    <!-- because we override the IDREF datatype with NMTOKEN in the dtbook-mathml-integration schema,
        we need to double check MathML @xref values (which were originally of type IDREF)
        
        Note that we don't need to perform these checks on DTBook elements because of the 
        Pipeline 1 patterns here that look at annoref and noteref already, which are the only 2 elements
        to use an attribute originally of the type IDREF.
    -->
    <pattern id="xref">        
        <rule context="m:*[@xref]">    
            <assert test="some $elem in //* satisfies ($elem/@id eq @xref)">
                xref attribute does not resolve.</assert>            
        </rule>
    </pattern> 
    
    <!-- these beautiful patterns don't work in XProc/Calabash, I suspect due to the $@ syntax in the last one
        see http://code.google.com/p/epub-revision/issues/detail?id=194 ; we pulled these patterns from EPUB
    -->
    <!--<pattern id="idref-mathml-xref" is-a="idref-any">
        <param name="element" value="m:*"/>
        <param name="idref-attr-name" value="xref"/>
    </pattern>
    
    <!-\- get ready for MathML 3 by including this pattern -\->
    <pattern id="idref-mathml-indenttarget" is-a="idref-any">
        <param name="element" value="m:*"/>
        <param name="idref-attr-name" value="indenttarget"/>
    </pattern>
    
    <pattern abstract="true" id="idref-any">
        <rule context="$element[@$idref-attr-name]">
            <assert test="some $elem in $id-set satisfies $elem/@id eq current()/@$idref-attr-name"
                >The <name path="@$idref-attr-name"/> attribute must refer to an element in the same document (the ID '<value-of 
                    select="current()/@$idref-attr-name"/>' does not exist).</assert>
        </rule>
    </pattern>
    
    -->
    
    
    <!--
        If any of the content elements listed in Chapter 4 of the MathML specification with the exception of those 
        listed in Section 4.4.11 (Semantic Mapping Elements) are used, they must appear inside of an 
        annotation-xml element inside of a semantics element.
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
            <assert test="node()/ancestor::m:annotation-xml">Math content elements must have 'annotation-xml' as ancestors.</assert>
            <assert test="node()/ancestor::m:annotation-xml/ancestor::m:semantics">'annotation-xml' must have 'semantics' as an ancestor.</assert>
        </rule>
    </pattern>
    <!-- ****************************************************** -->
    <!-- end MathML rules -->
    <!-- ****************************************************** -->
    
</schema>