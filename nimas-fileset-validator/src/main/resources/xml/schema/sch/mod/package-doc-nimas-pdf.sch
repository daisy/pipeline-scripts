
<pattern id="pdf-test" xmlns="http://purl.oclc.org/dsdl/schematron">
    <rule context="//pkg:package/pkg:manifest">
        <report test="count(pkg:item[@media-type = 'application/pdf']) = 0"> 
            At least one PDF document is required to be included.
        </report>
    </rule>
</pattern>
