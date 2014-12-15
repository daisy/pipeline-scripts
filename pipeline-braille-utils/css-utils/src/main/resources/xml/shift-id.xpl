<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step xmlns:p="http://www.w3.org/ns/xproc"
                xmlns:css="http://www.daisy.org/ns/pipeline/braille-css"
                type="css:shift-id"
                exclude-inline-prefixes="#all"
                version="1.0">
    
    <!--
        Move @css:id attributes from non css:box elements to the following css:box.
    -->
    
    <p:input port="source" sequence="true"/>
    <p:output port="result" sequence="true"/>
    
    <p:wrap-sequence wrapper="_"/>
    
    <p:label-elements match="css:box"
                      attribute="css:id" replace="false"
                      label="string(
                               ((preceding::*|ancestor::*)[not(self::css:box)][@css:id]
                                except (preceding::css:box|ancestor::css:box)
                                       [last()]/(preceding::*|ancestor::*)
                               )[last()]/@css:id)"/>
    <p:delete match="@css:id[.='']"/>
    
    <p:label-elements match="css:counter[@name][@target]" attribute="target"
                      label="for $target in @target return
                             //*[@css:id=$target]/(self::css:box|following::css:box|descendant::css:box)
                             [1]/@css:id"/>
    
    <p:delete match="*[not(self::css:box)]/@css:id"/>
    
    <p:filter select="/_/*"/>
    
</p:declare-step>
