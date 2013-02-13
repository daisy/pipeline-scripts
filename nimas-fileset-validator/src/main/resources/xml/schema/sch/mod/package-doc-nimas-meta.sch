
<pattern id="meta-test" xmlns="http://purl.oclc.org/dsdl/schematron">
    <rule context="//pkg:package/pkg:metadata/pkg:dc-metadata">
        <assert test="count(dc:Format) >= 1">dc:Format metadata is required by NIMAS.</assert>
        <assert test="count(dc:Rights) >= 1">dc:Rights metadata is required by NIMAS.</assert>
        <assert test="count(dc:Source) >= 1">dc:Source metadata is required by NIMAS.</assert>
    </rule>
    
    <rule context="//pkg:package/pkg:metadata/pkg:x-metadata">
        <assert test="count(pkg:meta[@name = 'nimas-SourceEdition']) >= 1">nimas-SourceEdition metadata is required by NIMAS.</assert>
        <assert test="count(pkg:meta[@name = 'nimas-SourceDate']) >= 1">nimas-SourceDate metadata is required by NIMAS.</assert>
    </rule>
    
</pattern>
