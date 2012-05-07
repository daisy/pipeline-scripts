<p:library
    xmlns:p="http://www.w3.org/ns/xproc"
    xmlns:px="http://www.daisy.org/ns/pipeline/xproc"
    xmlns:cxl="http://xmlcalabash.com/ns/extensions/liblouisxml"
    version="1.0">
    
    <p:declare-step type="cxl:format-braille">
        <p:input port="source" sequence="false" primary="true"/>
        <p:output port="result" sequence="false" primary="true"/>
        <p:option name="temp-dir" required="true" px:type="anyDirURI"/>
    </p:declare-step>
</p:library>

