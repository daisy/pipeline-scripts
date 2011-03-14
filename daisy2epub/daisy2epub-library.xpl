<?xml version="1.0" encoding="UTF-8"?>
<p:library xmlns:p="http://www.w3.org/ns/xproc"
    xmlns:c="http://www.w3.org/ns/xproc-step" xmlns:d2e="http://pipeline.daisy.org/ns/daisy2epub/" version="1.0">
    
    <p:declare-step type="d2e:load-html">
        <p:output port="result"/>
        <p:option name="href" required="true"/>
        <p:identity>
            <p:input port="source">
                <p:inline>
                    <c:request method="GET" override-content-type="text/plain; charset=utf-8"/>
                </p:inline>
            </p:input>
        </p:identity>
        <p:add-attribute match="c:request" attribute-name="href">
            <p:with-option name="attribute-value" select="$href"/>
        </p:add-attribute>
        <p:http-request/>
        <p:unescape-markup content-type="text/html"/>
        <p:unwrap match="c:body"/>
    </p:declare-step>
    
</p:library>