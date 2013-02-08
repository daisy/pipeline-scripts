<?xml version="1.0" encoding="UTF-8"?>

<schema xmlns="http://purl.oclc.org/dsdl/schematron" queryBinding="xslt2"
    xmlns:dtb="http://www.daisy.org/z3986/2005/dtbook/" xmlns:m="http://www.w3.org/1998/Math/MathML"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
    
    <ns uri="http://www.daisy.org/z3986/2005/dtbook/" prefix="dtb"/>
    <ns uri="http://www.w3.org/1998/Math/MathML" prefix="m"/>
    <ns prefix="pkg" uri="http://openebook.org/namespaces/oeb-package/1.0/"/>
    
    
    <!--
        Math-specific metadata must not appear in OPF files for books with no math content.
    -->
    <pattern id="no-math-tests">
        <rule context="//pkg:package/pkg:metadata/pkg:x-metadata">
            <assert test="count(pkg:meta[@name='z39-86-extension-version']) = 0"> 
                x-metadata element with name 'z39-86-extension-version' must not be present.
            </assert>
            <assert test="count(pkg:meta[@name='DTBook-XSLTFallback']) = 0">
                x-metadata element with name 'DTBook-XSLTFallback' must not be present.
            </assert>
        </rule>
    </pattern>
</schema>