<p:declare-step version="1.0" name="main" type="px:daisy202-validator.validate" xmlns:p="http://www.w3.org/ns/xproc" xmlns:c="http://www.w3.org/ns/xproc-step"
    xmlns:cx="http://xmlcalabash.com/ns/extensions" xmlns:px="http://www.daisy.org/ns/pipeline/xproc" xmlns:pxi="http://www.daisy.org/ns/pipeline/xproc/internal/daisy202-validator"
    xmlns:d="http://www.daisy.org/ns/pipeline/data" xmlns:html="http://www.w3.org/1999/xhtml" exclude-inline-prefixes="#all">

    <p:input port="fileset.in" primary="true"/>
    <p:input port="in-memory.in" sequence="true"/>
    <p:input port="report.in" sequence="true">
        <p:empty/>
    </p:input>

    <p:option name="timeToleranceMs" select="500" px:type="xs:integer"/>

    <p:output port="fileset.out" primary="true">
        <p:pipe port="fileset.in" step="main"/>
    </p:output>
    <p:output port="in-memory.out" sequence="true">
        <p:pipe port="in-memory.in" step="main"/>
    </p:output>
    <p:output port="report.out" sequence="true">
        <p:pipe step="main" port="report.in"/>
        <p:pipe step="report" port="result"/>
    </p:output>

    <p:import href="http://www.daisy.org/pipeline/modules/common-utils/library.xpl"/>
    <p:import href="http://www.daisy.org/pipeline/modules/fileset-utils/library.xpl"/>

    <p:variable name="start" select="current-dateTime()"/>

    <px:message message="Validating DAISY 2.02 fileset"/>
    <px:message message="timeToleranceMs set to $1">
        <p:with-option name="param1" select="$timeToleranceMs"/>
    </px:message>
    <p:identity name="fileset.in">
        <!-- pipe fileset.in from this one so that px:message is executed first -->
    </p:identity>

    <px:fileset-load media-types="application/smil+xml">
        <p:input port="fileset">
            <p:pipe port="result" step="fileset.in"/>
        </p:input>
        <p:input port="in-memory">
            <p:pipe port="in-memory.in" step="main"/>
        </p:input>
    </px:fileset-load>
    <p:identity name="smil"/>
    <p:sink/>

    <px:fileset-load href="*/ncc.html">
        <p:input port="fileset">
            <p:pipe port="result" step="fileset.in"/>
        </p:input>
        <p:input port="in-memory">
            <p:pipe port="in-memory.in" step="main"/>
        </p:input>
    </px:fileset-load>
    <p:identity name="ncc"/>
    <p:sink/>

    <!--
    // InterDocURICheckerD202Delegate
    for referer in fileset[xml- and html-files] {
        for reference in referer.references {
            if matches(reference, regex.URI_REMOTE) and !startsWith(reference, "#") {
                path = reference.stripFragment()
                fragment = reference.getFragment()
                uri = resolve-uri(base-uri(referer), path)
                if uri is not in fileset {
                    concat('The URI ',reference,' points to a file that is not in included in the DAISY 2.02 fileset')
                } else if fragment!='' {
                    if uri is SMIL {
                        if not(smil//text[@id=$fragment] or smil//par[@id=$fragment]) {
                            concat('The URI ',reference,' does not resolve correctly')
                        }
                    } else {
                        if not(xml//@id=$fragment) then {
                            concat('The URI ',reference,' does not resolve correctly')
                        }
                    }
                }
            }
        }
    }
    -->
    <p:identity name="interdoc-urichecker-tests">
        <p:input port="source">
            <!-- not implemented -->
            <p:empty/>
        </p:input>
    </p:identity>
    <p:sink/>

    <!--
    // FilesetFileTypeRestrictionDelegate
    for file in fileset {
        if filetype not allowed in fileset {
            concat(file,' is not an allowed file type in DAISY 2.02')
                allowed file types:
                    D202Ncc
                    D202Smil
                    D202MasterSmil
                    D202TextualContent
                    Mp3
                    Mp2
                    Wav
                    Jpg
                    Gif
                    Png
                    Css
        }
    }
    -->
    <p:identity name="filetype-restriction-tests">
        <p:input port="source">
            <!-- not implemented -->
            <p:empty/>
        </p:input>
    </p:identity>
    <p:sink/>

    <!-- TODO: validate SMIL files against "-//DAISY//RNG smil v2.02//EN" (see org.daisy.util.fileset.impl.D202SmilFileImpl) -->

    <!-- TODO: validate NCC file against "-//DAISY//RNG ncc v2.02//EN" (see org.daisy.util.fileset.impl.D202NccFileImpl) -->

    <!--
    for each file, switch (file type) {
        NCC: check that the heading hierarchy is correct (i.e. no levels are skipped. assert that not(level#-1 > previousLevel#). message: "incorrect heading hierarchy"
        Content: check that the heading hierarchy is correct (i.e. no levels are skipped. assert that not(level#-1 > previousLevel#). message: "incorrect heading hierarchy"
        master SMIL: // not implemented in DP1, marked as TODO
        audio: {-->
    <!-- validate duration -->
    <!--
                compare audio duration with info from SMIL files and NCC totalTime (not implemented in DP1, but should probably have been there)
                depends on https://github.com/daisy/pipeline-mod-audio/issues/4
            -->

    <!-- validate ID3 -->
    <!--
                if (is mp3) {
                    if (has ID3v2) - info: concat(file,' has ID3 tag')
                    if (is not mono) - warning: concat(file,' is not single channel')
                    if (variable bitrate) - warning: concat(file,' file uses variable bit rate (VBR)')
                }
                depends on https://github.com/daisy/pipeline-mod-audio/issues/3 and
            -->
    <!--}
    }
    -->

    <p:for-each>
        <p:iteration-source>
            <p:pipe port="result" step="smil"/>
        </p:iteration-source>
        <p:add-attribute match="/*" attribute-name="xml:base">
            <p:with-option name="attribute-value" select="base-uri(/*)"/>
        </p:add-attribute>
    </p:for-each>
    <p:wrap-sequence wrapper="c:result"/>
    <p:xslt>
        <p:input port="parameters">
            <p:empty/>
        </p:input>
        <p:input port="stylesheet">
            <p:document href="validate.smil-times-1.xsl"/>
        </p:input>
    </p:xslt>
    <p:xslt>
        <p:with-param name="ncc-totalTime" select="/*/*[local-name()='head']/*[local-name()='meta' and @name='ncc:totalTime']/@content">
            <p:pipe port="result" step="ncc"/>
        </p:with-param>
        <p:input port="stylesheet">
            <p:document href="validate.smil-times-2.xsl"/>
        </p:input>
    </p:xslt>
    <p:identity name="smil-times"/>
    <p:for-each name="smil-times.iterate">
        <p:iteration-source select="/*/*"/>
        <p:output port="result" sequence="true">
            <p:pipe port="result" step="smil-times.iterate.totalTime"/>
            <p:pipe port="result" step="smil-times.iterate.duration"/>
        </p:output>
        <p:variable name="base-uri-xpath" select="concat('&quot;',replace(base-uri(/*),'&quot;','&quot;&quot;'),'&quot;')"/>

        <!-- test totalElapsedTime -->
        <p:choose name="smil-times.iterate.totalTime">
            <p:xpath-context>
                <p:pipe port="current" step="smil-times.iterate"/>
            </p:xpath-context>
            <p:when test="abs(/*/number(@calculated-totalTime) - /*/number(@meta-totalTime)) &gt; number($timeToleranceMs) div 1000">
                <p:output port="result" sequence="true"/>
                <p:identity>
                    <p:input port="source">
                        <p:inline exclude-inline-prefixes="#all">
                            <d:message severity="error">
                                <d:desc>DESC</d:desc>
                                <d:file>FILE</d:file>
                                <d:location>/smil/head/meta[@name='ncc:totalTime']</d:location>
                            </d:message>
                        </p:inline>
                    </p:input>
                </p:identity>
                <p:string-replace match="//d:desc/text()">
                    <p:with-option name="replace" select="concat('&quot;expected total elapsed time ',/*/@calculated-totalTime,' but found ',/*/@meta-totalTime,'&quot;')">
                        <p:pipe port="current" step="smil-times.iterate"/>
                    </p:with-option>
                </p:string-replace>
                <p:string-replace match="//d:file/text()">
                    <p:with-option name="replace" select="$base-uri-xpath"/>
                </p:string-replace>
            </p:when>
            <p:otherwise>
                <p:output port="result" sequence="true"/>
                <p:identity>
                    <p:input port="source">
                        <p:inline exclude-inline-prefixes="#all">
                            <d:message severity="info">
                                <d:desc>DESC</d:desc>
                                <d:file>FILE</d:file>
                                <d:location>/smil/head/meta[@name='ncc:totalElapsedTime']</d:location>
                            </d:message>
                        </p:inline>
                    </p:input>
                </p:identity>
                <p:string-replace match="//d:desc/text()">
                    <p:with-option name="replace" select="concat('&quot;total elapsed time ',/*/@calculated-totalTime,' is close enough to the declared ',/*/@meta-totalTime,'&quot;')">
                        <p:pipe port="current" step="smil-times.iterate"/>
                    </p:with-option>
                </p:string-replace>
                <p:string-replace match="//d:file/text()">
                    <p:with-option name="replace" select="$base-uri-xpath"/>
                </p:string-replace>
            </p:otherwise>
        </p:choose>

        <!-- test timeInThisSmil -->
        <p:choose name="smil-times.iterate.duration">
            <p:xpath-context>
                <p:pipe port="current" step="smil-times.iterate"/>
            </p:xpath-context>
            <p:when test="abs(/*/number(@calculated-duration) - /*/number(@meta-duration)) &gt; number($timeToleranceMs) div 1000">
                <p:output port="result" sequence="true"/>
                <p:identity>
                    <p:input port="source">
                        <p:inline exclude-inline-prefixes="#all">
                            <d:message severity="error">
                                <d:desc>DESC</d:desc>
                                <d:file>FILE</d:file>
                                <d:location>/smil/head/meta[@name='ncc:timeInThisSmil']</d:location>
                            </d:message>
                        </p:inline>
                    </p:input>
                </p:identity>
                <p:string-replace match="//d:desc/text()">
                    <p:with-option name="replace" select="concat('&quot;expected duration ',/*/@calculated-duration,' but found ',/*/@meta-duration,'&quot;')">
                        <p:pipe port="current" step="smil-times.iterate"/>
                    </p:with-option>
                </p:string-replace>
                <p:string-replace match="//d:file/text()">
                    <p:with-option name="replace" select="$base-uri-xpath"/>
                </p:string-replace>
            </p:when>
            <p:otherwise>
                <p:output port="result" sequence="true"/>
                <p:identity>
                    <p:input port="source">
                        <p:inline exclude-inline-prefixes="#all">
                            <d:message severity="info">
                                <d:desc>DESC</d:desc>
                                <d:file>FILE</d:file>
                                <d:location>/smil/head/meta[@name='ncc:timeInThisSmil']</d:location>
                            </d:message>
                        </p:inline>
                    </p:input>
                </p:identity>
                <p:string-replace match="//d:desc/text()">
                    <p:with-option name="replace" select="concat('&quot;duration ',/*/@calculated-duration,' is close enough to the declared ',/*/@meta-duration,'&quot;')">
                        <p:pipe port="current" step="smil-times.iterate"/>
                    </p:with-option>
                </p:string-replace>
                <p:string-replace match="//d:file/text()">
                    <p:with-option name="replace" select="$base-uri-xpath"/>
                </p:string-replace>
            </p:otherwise>
        </p:choose>
    </p:for-each>
    <p:identity name="smil-time-tests"/>
    <p:sink/>

    <p:group>
        <p:variable name="base-uri-xpath" select="concat('&quot;',replace(base-uri(/*),'&quot;','&quot;&quot;'),'&quot;')">
            <p:pipe port="result" step="ncc"/>
        </p:variable>
        <p:choose>
            <p:xpath-context>
                <p:pipe port="result" step="smil-times"/>
            </p:xpath-context>
            <p:when test="abs(/*/number(@calculated-totalTime) - /*/number(@ncc-meta-totalTime)) &gt; number($timeToleranceMs) div 1000">
                <p:identity>
                    <p:input port="source">
                        <p:inline exclude-inline-prefixes="#all">
                            <d:message severity="error">
                                <d:desc>DESC</d:desc>
                                <d:file>FILE</d:file>
                                <d:location>/html/head/meta[@name='ncc:totalTime']</d:location>
                            </d:message>
                        </p:inline>
                    </p:input>
                </p:identity>
                <p:string-replace match="//d:desc/text()">
                    <p:with-option name="replace" select="concat('&quot;expected total time ',/*/@calculated-totalTime,' but found ',/*/@ncc-meta-totalTime,'&quot;')">
                        <p:pipe port="result" step="smil-times"/>
                    </p:with-option>
                </p:string-replace>
                <p:string-replace match="//d:file/text()">
                    <p:with-option name="replace" select="$base-uri-xpath"/>
                </p:string-replace>
            </p:when>
            <p:otherwise>
                <p:identity>
                    <p:input port="source">
                        <p:inline exclude-inline-prefixes="#all">
                            <d:message severity="info">
                                <d:desc>DESC</d:desc>
                                <d:file>FILE</d:file>
                                <d:location>/html/head/meta[@name='ncc:totalTime']</d:location>
                            </d:message>
                        </p:inline>
                    </p:input>
                </p:identity>
                <p:string-replace match="//d:desc/text()">
                    <p:with-option name="replace" select="concat('&quot;total time ',/*/@calculated-totalTime,' is close enough to the declared ',/*/@ncc-meta-totalTime,'&quot;')">
                        <p:pipe port="result" step="smil-times"/>
                    </p:with-option>
                </p:string-replace>
                <p:string-replace match="//d:file/text()">
                    <p:with-option name="replace" select="$base-uri-xpath"/>
                </p:string-replace>
            </p:otherwise>
        </p:choose>
    </p:group>
    <p:identity name="ncc-time-test"/>
    <p:sink/>

    <p:identity>
        <p:input port="source">
            <p:pipe step="interdoc-urichecker-tests" port="result"/>
            <p:pipe step="filetype-restriction-tests" port="result"/>
            <p:pipe step="smil-time-tests" port="result"/>
            <p:pipe step="ncc-time-test" port="result"/>
        </p:input>
    </p:identity>
    <p:group>
        <p:variable name="end" select="current-dateTime()">
            <p:empty/>
        </p:variable>
        <px:message message="Validation completed in {end-start} seconds"/>
    </p:group>
    <p:identity name="report"/>

</p:declare-step>
