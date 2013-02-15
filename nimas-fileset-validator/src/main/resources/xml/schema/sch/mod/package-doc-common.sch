
<pattern id="package-doc-common" xmlns="http://purl.oclc.org/dsdl/schematron">
    <rule context="//pkg:package/pkg:metadata/pkg:dc-metadata">
        <assert test="count(dc:Format) >= 1">dc:Format metadata is required by NIMAS.</assert>
        <assert test="count(dc:Rights) >= 1">dc:Rights metadata is required by NIMAS.</assert>
        <assert test="count(dc:Source) >= 1">dc:Source metadata is required by NIMAS.</assert>
    </rule>
    
    <rule context="//pkg:package/pkg:metadata/pkg:x-metadata">
        <assert test="count(pkg:meta[@name = 'nimas-SourceEdition']) >= 1">nimas-SourceEdition metadata is required by NIMAS.</assert>
        <assert test="count(pkg:meta[@name = 'nimas-SourceDate']) >= 1">nimas-SourceDate metadata is required by NIMAS.</assert>
    </rule>
    
    <rule context="//pkg:package/pkg:manifest">
        <report test="count(pkg:item[@media-type = 'application/pdf']) = 0"> 
            At least one document with media-type equal to 'application/pdf' is required in the manifest.
        </report>
        <report test="count(pkg:item[@media-type = 'application/x-dtbook+xml']) = 0"> 
            At least one document with media-type equal to 'application/x-dtbook+xml' is required in the manifest.
        </report>
    </rule>
        
</pattern>
