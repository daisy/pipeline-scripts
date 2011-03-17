<?xml version="1.0" encoding="UTF-8"?>
<p:library xmlns:p="http://www.w3.org/ns/xproc" xmlns:c="http://www.w3.org/ns/xproc-step"
    xmlns:d2e="http://pipeline.daisy.org/ns/daisy2epub/" version="1.0">

    <p:declare-step type="d2e:load-html">
        <p:documentation><![CDATA[
            Tries first to p:load the HTML-file. An exception will be thrown
            if the file is not well formed XML, in which case the file will
            be loaded using p:http-request and p:unescape-markup.
        ]]></p:documentation>
        <p:output port="result"/>
        <p:option name="href" required="true"/>
        <p:try>
            <p:group>
                <p:load>
                    <p:with-option name="href" select="$href"/>
                </p:load>
                <p:add-xml-base/>
            </p:group>
            <p:catch>
                <p:identity>
                    <p:input port="source">
                        <p:inline>
                            <c:request method="GET"
                                override-content-type="text/plain; charset=utf-8"/>
                        </p:inline>
                    </p:input>
                </p:identity>
                <p:add-attribute match="c:request" attribute-name="href">
                    <p:with-option name="attribute-value" select="$href"/>
                </p:add-attribute>
                <p:http-request/>
                <p:unescape-markup content-type="text/html"/>
                <p:unwrap match="c:body"/>
                <p:add-attribute match="/*" attribute-name="xml:base">
                    <p:with-option name="attribute-value" select="p:resolve-uri($href)">
                        <p:inline>
                            <irrelevant/>
                        </p:inline>
                    </p:with-option>
                </p:add-attribute>
            </p:catch>
        </p:try>
    </p:declare-step>

</p:library>
