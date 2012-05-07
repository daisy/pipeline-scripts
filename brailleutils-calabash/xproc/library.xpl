<p:library
    xmlns:p="http://www.w3.org/ns/xproc"
    xmlns:px="http://www.daisy.org/ns/pipeline/xproc"
    xmlns:cxb="http://xmlcalabash.com/ns/extensions/brailleutils"
    version="1.0">
    
    <p:declare-step type="cxb:emboss-pef">
        <p:input port="source" sequence="true"/>
        <p:output port="result" sequence="true"/>
        <p:option name="message" required="true"/>
    </p:declare-step>
    
    <p:declare-step type="cxb:pef-to-text">
        <p:input port="source" sequence="true"/>
        <p:output port="result" sequence="true"/>
        <p:option name="message" required="true"/>
    </p:declare-step>
    
    <p:declare-step type="cxb:text-to-pef">
        <p:input port="source" sequence="false" primary="true"/>
        <p:output port="result" sequence="false" primary="true"/>
        <p:option name="temp-dir" required="true" px:type="anyDirURI"/>
    </p:declare-step>
    
    <p:declare-step type="cxb:validate-pef">
        <p:input port="source" sequence="true"/>
        <p:output port="result" sequence="true"/>
        <p:option name="message" required="true"/>
    </p:declare-step>
</p:library>

