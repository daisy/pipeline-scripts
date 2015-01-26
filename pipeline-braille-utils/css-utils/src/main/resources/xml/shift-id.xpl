<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step xmlns:p="http://www.w3.org/ns/xproc"
                xmlns:css="http://www.daisy.org/ns/pipeline/braille-css"
                type="css:shift-id"
                exclude-inline-prefixes="#all"
                version="1.0">
    
    <p:documentation>
        Move css:id attributes to boxes.
    </p:documentation>
    
    <p:input port="source" sequence="true">
        <p:documentation>
            Boxes must be represented by css:box elements. target-counter() values must be
            represented by css:counter elements.
        </p:documentation>
    </p:input>
    
    <p:output port="result" sequence="true">
        <p:documentation>
            For each non css:box element in the input with a css:id attribute, that attribute is
            moved to the first following css:box element. If this css:box element already has a
            css:id attribute in the input, the attribute is not overwritten. Instead, any
            target-counter() values that reference the non css:box element are altered to reference
            the following css:box element.
        </p:documentation>
    </p:output>
    
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
