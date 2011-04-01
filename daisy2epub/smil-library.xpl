<?xml version="1.0" encoding="UTF-8"?>
<p:library xmlns:p="http://www.w3.org/ns/xproc" xmlns:c="http://www.w3.org/ns/xproc-step"
    xmlns:px="http://pipeline.daisy.org/ns/" version="1.0">

    <p:declare-step type="px:join-smil10">
        <p:output port="result"/>
        <p:input port="source" sequence="true"/>
        <p:wrap-sequence wrapper="smil"/>
        <p:xslt>
            <p:input port="parameters">
                <p:empty/>
            </p:input>
            <p:input port="stylesheet">
                <p:document href="join-smil10.xsl"/>
            </p:input>
        </p:xslt>
    </p:declare-step>

</p:library>
