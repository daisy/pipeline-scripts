<p:library
    xmlns:p="http://www.w3.org/ns/xproc"
    xmlns:px="http://www.daisy.org/ns/pipeline/xproc"
    xmlns:pef="http://www.daisy.org/ns/2008/pef"
    version="1.0">
    
    <p:declare-step type="pef:text2pef">
        <p:input port="source" sequence="false" primary="true"/>
        <p:output port="result" sequence="false" primary="true"/>
        <p:option name="table" required="true"/>
        <p:option name="temp-dir" required="true" px:output="temp" px:sequence="false" px:type="anyDirURI"/>
        <p:option name="title" required="false"/>
        <p:option name="creator" required="false"/>
    </p:declare-step>
    
    <p:import href="merge.xpl"/>
    
</p:library>

