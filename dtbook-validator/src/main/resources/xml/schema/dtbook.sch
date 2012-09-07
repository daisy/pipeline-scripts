<?xml version="1.0" encoding="UTF-8"?>
<schema xmlns="http://purl.oclc.org/dsdl/schematron" queryBinding="xslt2"
    xmlns:dtb="http://www.daisy.org/z3986/2005/dtbook/">
    <pattern>
        <rule context="//node()[@idref]">
            <let name="idref" 
                value="if (starts-with(@idref, '#')) 
                    then substring(@idref, 2) 
                    else @idref"/>
            <assert test="//node()[@id=$idref]">@idref targets must exist but 
                a node with id=<value-of select="$idref"/> was not found.</assert>
        </rule>
    </pattern>
</schema>