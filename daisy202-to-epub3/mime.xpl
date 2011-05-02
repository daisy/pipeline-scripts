<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step xmlns:p="http://www.w3.org/ns/xproc" xmlns:c="http://www.w3.org/ns/xproc-step"
    xmlns:px="http://pipeline.daisy.org/ns/" xmlns:xd="http://pipeline.daisy.org/ns/sample/doc"
    version="1.0" type="px:mime">

    <p:documentation xd:target="parent">
        <xd:short>Determine the MIME-type of a file.</xd:short>
        <xd:author>
            <xd:name>Jostein Austvik Jacobsen</xd:name>
            <xd:mailto>josteinaj@gmail.com</xd:mailto>
            <xd:organization>NLB</xd:organization>
        </xd:author>
        <xd:maintainer>Jostein Austvik Jacobsen</xd:maintainer>
        <xd:option name="href">URI to the file you want to know the MIME-type of.</xd:option>
        <xd:output port="result">Returns &lt;c:file href="(href)" type="(MIME-type)"/&gt;</xd:output>
    </p:documentation>

    <p:option name="href" required="true"/>
    <p:output port="result"/>

    <p:variable name="ext" select="lower-case(replace($href,'^.+?([^/\.]+)$','$1'))"/>

    <p:add-attribute attribute-name="href" match="/*">
        <p:with-option name="attribute-value" select="$href"/>
        <p:input port="source">
            <p:inline>
                <c:file/>
            </p:inline>
        </p:input>
    </p:add-attribute>
    <p:choose>
        <p:when test="$ext = 'xhtml'">
            <p:add-attribute match="/*" attribute-name="type"
                attribute-value="application/xhtml+xml"/>
        </p:when>
        <p:when test="$ext = 'smil'">
            <p:add-attribute match="/*" attribute-name="type" attribute-value="application/smil+xml"
            />
        </p:when>
        <p:when test="$ext = 'mp3'">
            <p:add-attribute match="/*" attribute-name="type" attribute-value="audio/mpeg"/>
        </p:when>
        <p:when test="$ext = 'epub'">
            <p:add-attribute match="/*" attribute-name="type" attribute-value="application/epub+zip"
            />
        </p:when>
        <p:when test="$ext = 'xpl'">
            <p:add-attribute match="/*" attribute-name="type"
                attribute-value="application/xproc+xml"/>
        </p:when>
        <p:when test="$ext = 'xproc'">
            <p:add-attribute match="/*" attribute-name="type"
                attribute-value="application/xproc+xml"/>
        </p:when>
        <p:when test="$ext = 'xsl'">
            <p:add-attribute match="/*" attribute-name="type" attribute-value="application/xslt+xml"
            />
        </p:when>
        <p:when test="$ext = 'xslt'">
            <p:add-attribute match="/*" attribute-name="type" attribute-value="application/xslt+xml"
            />
        </p:when>
        <p:when test="$ext = 'xq'">
            <p:add-attribute match="/*" attribute-name="type"
                attribute-value="application/xquery+xml"/>
        </p:when>
        <p:when test="$ext = 'xquery'">
            <p:add-attribute match="/*" attribute-name="type"
                attribute-value="application/xquery+xml"/>
        </p:when>
        <p:when test="$ext = 'otf'">
            <p:add-attribute match="/*" attribute-name="type"
                attribute-value="application/x-font-opentype"/>
        </p:when>
        <p:when test="$ext = 'xml'">
            <p:add-attribute match="/*" attribute-name="type" attribute-value="application/xml"/>
        </p:when>
        <p:when test="$ext = 'wav'">
            <p:add-attribute match="/*" attribute-name="type" attribute-value="audio/x-wav"/>
        </p:when>
        <p:when test="$ext = 'opf'">
            <p:add-attribute match="/*" attribute-name="type"
                attribute-value="application/oebps-package+xml"/>
        </p:when>
        <p:when test="$ext = 'ncx'">
            <p:add-attribute match="/*" attribute-name="type"
                attribute-value="application/x-dtbncx+xml"/>
        </p:when>
        <p:when test="$ext = 'mp4'">
            <p:add-attribute match="/*" attribute-name="type" attribute-value="audio/mpeg4-generic"
            />
        </p:when>
        <p:when test="$ext = 'jpg'">
            <p:add-attribute match="/*" attribute-name="type" attribute-value="image/jpeg"/>
        </p:when>
        <p:when test="$ext = 'jpe'">
            <p:add-attribute match="/*" attribute-name="type" attribute-value="image/jpeg"/>
        </p:when>
        <p:when test="$ext = 'jpeg'">
            <p:add-attribute match="/*" attribute-name="type" attribute-value="image/jpeg"/>
        </p:when>
        <p:when test="$ext = 'png'">
            <p:add-attribute match="/*" attribute-name="type" attribute-value="image/png"/>
        </p:when>
        <p:when test="$ext = 'svg'">
            <p:add-attribute match="/*" attribute-name="type" attribute-value="image/svg+xml"/>
        </p:when>
        <p:when test="$ext = 'css'">
            <p:add-attribute match="/*" attribute-name="type" attribute-value="text/css"/>
        </p:when>
        <p:when test="$ext = 'dtd'">
            <p:add-attribute match="/*" attribute-name="type" attribute-value="application/xml-dtd"
            />
        </p:when>
        <p:when test="$ext = 'res'">
            <p:add-attribute match="/*" attribute-name="type"
                attribute-value="application/x-dtbresource+xml"/>
        </p:when>
        <p:when test="$ext = 'ogg'">
            <p:add-attribute match="/*" attribute-name="type" attribute-value="audio/ogg"/>
        </p:when>
        <p:when test="$ext = 'au'">
            <p:add-attribute match="/*" attribute-name="type" attribute-value="audio/basic"/>
        </p:when>
        <p:when test="$ext = 'snd'">
            <p:add-attribute match="/*" attribute-name="type" attribute-value="audio/basic"/>
        </p:when>
        <p:when test="$ext = 'mid'">
            <p:add-attribute match="/*" attribute-name="type" attribute-value="audio/mid"/>
        </p:when>
        <p:when test="$ext = 'rmi'">
            <p:add-attribute match="/*" attribute-name="type" attribute-value="audio/mid"/>
        </p:when>
        <p:when test="$ext = 'aif'">
            <p:add-attribute match="/*" attribute-name="type" attribute-value="audio/x-aiff"/>
        </p:when>
        <p:when test="$ext = 'aifc'">
            <p:add-attribute match="/*" attribute-name="type" attribute-value="audio/x-aiff"/>
        </p:when>
        <p:when test="$ext = 'aiff'">
            <p:add-attribute match="/*" attribute-name="type" attribute-value="audio/x-aiff"/>
        </p:when>
        <p:when test="$ext = 'm3u'">
            <p:add-attribute match="/*" attribute-name="type" attribute-value="audio/x-mpegurl"/>
        </p:when>
        <p:when test="$ext = 'ra'">
            <p:add-attribute match="/*" attribute-name="type" attribute-value="audio/x-pn-realaudio"
            />
        </p:when>
        <p:when test="$ext = 'ram'">
            <p:add-attribute match="/*" attribute-name="type" attribute-value="audio/x-pn-realaudio"
            />
        </p:when>
        <p:when test="$ext = 'bmp'">
            <p:add-attribute match="/*" attribute-name="type" attribute-value="image/bmp"/>
        </p:when>
        <p:when test="$ext = 'cod'">
            <p:add-attribute match="/*" attribute-name="type" attribute-value="image/cis-cod"/>
        </p:when>
        <p:when test="$ext = 'gif'">
            <p:add-attribute match="/*" attribute-name="type" attribute-value="image/gif"/>
        </p:when>
        <p:when test="$ext = 'ief'">
            <p:add-attribute match="/*" attribute-name="type" attribute-value="image/ief"/>
        </p:when>
        <p:when test="$ext = 'jfif'">
            <p:add-attribute match="/*" attribute-name="type" attribute-value="image/pipeg"/>
        </p:when>
        <p:when test="$ext = 'tif'">
            <p:add-attribute match="/*" attribute-name="type" attribute-value="image/tiff"/>
        </p:when>
        <p:when test="$ext = 'tiff'">
            <p:add-attribute match="/*" attribute-name="type" attribute-value="image/tiff"/>
        </p:when>
        <p:when test="$ext = 'ras'">
            <p:add-attribute match="/*" attribute-name="type" attribute-value="image/x-cmu-raster"/>
        </p:when>
        <p:when test="$ext = 'cmx'">
            <p:add-attribute match="/*" attribute-name="type" attribute-value="image/x-cmx"/>
        </p:when>
        <p:when test="$ext = 'ico'">
            <p:add-attribute match="/*" attribute-name="type" attribute-value="image/x-icon"/>
        </p:when>
        <p:when test="$ext = 'pnm'">
            <p:add-attribute match="/*" attribute-name="type"
                attribute-value="image/x-portable-anymap"/>
        </p:when>
        <p:when test="$ext = 'pbm'">
            <p:add-attribute match="/*" attribute-name="type"
                attribute-value="image/x-portable-bitmap"/>
        </p:when>
        <p:when test="$ext = 'pgm'">
            <p:add-attribute match="/*" attribute-name="type"
                attribute-value="image/x-portable-graymap"/>
        </p:when>
        <p:when test="$ext = 'ppm'">
            <p:add-attribute match="/*" attribute-name="type"
                attribute-value="image/x-portable-pixmap"/>
        </p:when>
        <p:when test="$ext = 'rgb'">
            <p:add-attribute match="/*" attribute-name="type" attribute-value="image/x-rgb"/>
        </p:when>
        <p:when test="$ext = 'xbm'">
            <p:add-attribute match="/*" attribute-name="type" attribute-value="image/x-xbitmap"/>
        </p:when>
        <p:when test="$ext = 'xpm'">
            <p:add-attribute match="/*" attribute-name="type" attribute-value="image/x-xpixmap"/>
        </p:when>
        <p:when test="$ext = 'xwd'">
            <p:add-attribute match="/*" attribute-name="type" attribute-value="image/x-xwindowdump"
            />
        </p:when>
        <p:when test="$ext = 'mp2'">
            <p:add-attribute match="/*" attribute-name="type" attribute-value="video/mpeg"/>
        </p:when>
        <p:when test="$ext = 'mpa'">
            <p:add-attribute match="/*" attribute-name="type" attribute-value="video/mpeg"/>
        </p:when>
        <p:when test="$ext = 'mpe'">
            <p:add-attribute match="/*" attribute-name="type" attribute-value="video/mpeg"/>
        </p:when>
        <p:when test="$ext = 'mpeg'">
            <p:add-attribute match="/*" attribute-name="type" attribute-value="video/mpeg"/>
        </p:when>
        <p:when test="$ext = 'mpg'">
            <p:add-attribute match="/*" attribute-name="type" attribute-value="video/mpeg"/>
        </p:when>
        <p:when test="$ext = 'mpv2'">
            <p:add-attribute match="/*" attribute-name="type" attribute-value="video/mpeg"/>
        </p:when>
        <p:when test="$ext = 'mov'">
            <p:add-attribute match="/*" attribute-name="type" attribute-value="video/quicktime"/>
        </p:when>
        <p:when test="$ext = 'qt'">
            <p:add-attribute match="/*" attribute-name="type" attribute-value="video/quicktime"/>
        </p:when>
        <p:when test="$ext = 'lsf'">
            <p:add-attribute match="/*" attribute-name="type" attribute-value="video/x-la-asf"/>
        </p:when>
        <p:when test="$ext = 'lsx'">
            <p:add-attribute match="/*" attribute-name="type" attribute-value="video/x-la-asf"/>
        </p:when>
        <p:when test="$ext = 'asf'">
            <p:add-attribute match="/*" attribute-name="type" attribute-value="video/x-ms-asf"/>
        </p:when>
        <p:when test="$ext = 'asr'">
            <p:add-attribute match="/*" attribute-name="type" attribute-value="video/x-ms-asf"/>
        </p:when>
        <p:when test="$ext = 'asx'">
            <p:add-attribute match="/*" attribute-name="type" attribute-value="video/x-ms-asf"/>
        </p:when>
        <p:when test="$ext = 'avi'">
            <p:add-attribute match="/*" attribute-name="type" attribute-value="video/x-msvideo"/>
        </p:when>
        <p:when test="$ext = 'movie'">
            <p:add-attribute match="/*" attribute-name="type" attribute-value="video/x-sgi-movie"/>
        </p:when>
        <p:when test="$ext = '323'">
            <p:add-attribute match="/*" attribute-name="type" attribute-value="text/h323"/>
        </p:when>
        <p:when test="$ext = 'htm'">
            <p:add-attribute match="/*" attribute-name="type" attribute-value="text/html"/>
        </p:when>
        <p:when test="$ext = 'html'">
            <p:add-attribute match="/*" attribute-name="type" attribute-value="text/html"/>
        </p:when>
        <p:when test="$ext = 'stm'">
            <p:add-attribute match="/*" attribute-name="type" attribute-value="text/html"/>
        </p:when>
        <p:when test="$ext = 'uls'">
            <p:add-attribute match="/*" attribute-name="type" attribute-value="text/iuls"/>
        </p:when>
        <p:when test="$ext = 'bas'">
            <p:add-attribute match="/*" attribute-name="type" attribute-value="text/plain"/>
        </p:when>
        <p:when test="$ext = 'c'">
            <p:add-attribute match="/*" attribute-name="type" attribute-value="text/plain"/>
        </p:when>
        <p:when test="$ext = 'h'">
            <p:add-attribute match="/*" attribute-name="type" attribute-value="text/plain"/>
        </p:when>
        <p:when test="$ext = 'txt'">
            <p:add-attribute match="/*" attribute-name="type" attribute-value="text/plain"/>
        </p:when>
        <p:when test="$ext = 'rtx'">
            <p:add-attribute match="/*" attribute-name="type" attribute-value="text/richtext"/>
        </p:when>
        <p:when test="$ext = 'sct'">
            <p:add-attribute match="/*" attribute-name="type" attribute-value="text/scriptlet"/>
        </p:when>
        <p:when test="$ext = 'tsv'">
            <p:add-attribute match="/*" attribute-name="type"
                attribute-value="text/tab-separated-values"/>
        </p:when>
        <p:when test="$ext = 'htt'">
            <p:add-attribute match="/*" attribute-name="type" attribute-value="text/webviewhtml"/>
        </p:when>
        <p:when test="$ext = 'htc'">
            <p:add-attribute match="/*" attribute-name="type" attribute-value="text/x-component"/>
        </p:when>
        <p:when test="$ext = 'etx'">
            <p:add-attribute match="/*" attribute-name="type" attribute-value="text/x-setext"/>
        </p:when>
        <p:when test="$ext = 'vcf'">
            <p:add-attribute match="/*" attribute-name="type" attribute-value="text/x-vcard"/>
        </p:when>
        <p:when test="$ext = 'mht'">
            <p:add-attribute match="/*" attribute-name="type" attribute-value="message/rfc822"/>
        </p:when>
        <p:when test="$ext = 'mhtml'">
            <p:add-attribute match="/*" attribute-name="type" attribute-value="message/rfc822"/>
        </p:when>
        <p:when test="$ext = 'nws'">
            <p:add-attribute match="/*" attribute-name="type" attribute-value="message/rfc822"/>
        </p:when>
        <p:when test="$ext = 'evy'">
            <p:add-attribute match="/*" attribute-name="type" attribute-value="application/envoy"/>
        </p:when>
        <p:when test="$ext = 'fif'">
            <p:add-attribute match="/*" attribute-name="type" attribute-value="application/fractals"
            />
        </p:when>
        <p:when test="$ext = 'spl'">
            <p:add-attribute match="/*" attribute-name="type"
                attribute-value="application/futuresplash"/>
        </p:when>
        <p:when test="$ext = 'hta'">
            <p:add-attribute match="/*" attribute-name="type" attribute-value="application/hta"/>
        </p:when>
        <p:when test="$ext = 'acx'">
            <p:add-attribute match="/*" attribute-name="type"
                attribute-value="application/internet-property-stream"/>
        </p:when>
        <p:when test="$ext = 'hqx'">
            <p:add-attribute match="/*" attribute-name="type"
                attribute-value="application/mac-binhex40"/>
        </p:when>
        <p:when test="$ext = 'doc'">
            <p:add-attribute match="/*" attribute-name="type" attribute-value="application/msword"/>
        </p:when>
        <p:when test="$ext = 'dot'">
            <p:add-attribute match="/*" attribute-name="type" attribute-value="application/msword"/>
        </p:when>
        <p:when test="$ext = '*'">
            <p:add-attribute match="/*" attribute-name="type"
                attribute-value="application/octet-stream"/>
        </p:when>
        <p:when test="$ext = 'bin'">
            <p:add-attribute match="/*" attribute-name="type"
                attribute-value="application/octet-stream"/>
        </p:when>
        <p:when test="$ext = 'class'">
            <p:add-attribute match="/*" attribute-name="type"
                attribute-value="application/octet-stream"/>
        </p:when>
        <p:when test="$ext = 'dms'">
            <p:add-attribute match="/*" attribute-name="type"
                attribute-value="application/octet-stream"/>
        </p:when>
        <p:when test="$ext = 'exe'">
            <p:add-attribute match="/*" attribute-name="type"
                attribute-value="application/octet-stream"/>
        </p:when>
        <p:when test="$ext = 'lha'">
            <p:add-attribute match="/*" attribute-name="type"
                attribute-value="application/octet-stream"/>
        </p:when>
        <p:when test="$ext = 'lzh'">
            <p:add-attribute match="/*" attribute-name="type"
                attribute-value="application/octet-stream"/>
        </p:when>
        <p:when test="$ext = 'oda'">
            <p:add-attribute match="/*" attribute-name="type" attribute-value="application/oda"/>
        </p:when>
        <p:when test="$ext = 'axs'">
            <p:add-attribute match="/*" attribute-name="type"
                attribute-value="application/olescript"/>
        </p:when>
        <p:when test="$ext = 'pdf'">
            <p:add-attribute match="/*" attribute-name="type" attribute-value="application/pdf"/>
        </p:when>
        <p:when test="$ext = 'prf'">
            <p:add-attribute match="/*" attribute-name="type"
                attribute-value="application/pics-rules"/>
        </p:when>
        <p:when test="$ext = 'p10'">
            <p:add-attribute match="/*" attribute-name="type" attribute-value="application/pkcs10"/>
        </p:when>
        <p:when test="$ext = 'crl'">
            <p:add-attribute match="/*" attribute-name="type" attribute-value="application/pkix-crl"
            />
        </p:when>
        <p:when test="$ext = 'ai'">
            <p:add-attribute match="/*" attribute-name="type"
                attribute-value="application/postscript"/>
        </p:when>
        <p:when test="$ext = 'eps'">
            <p:add-attribute match="/*" attribute-name="type"
                attribute-value="application/postscript"/>
        </p:when>
        <p:when test="$ext = 'ps'">
            <p:add-attribute match="/*" attribute-name="type"
                attribute-value="application/postscript"/>
        </p:when>
        <p:when test="$ext = 'rtf'">
            <p:add-attribute match="/*" attribute-name="type" attribute-value="application/rtf"/>
        </p:when>
        <p:when test="$ext = 'setpay'">
            <p:add-attribute match="/*" attribute-name="type"
                attribute-value="application/set-payment-initiation"/>
        </p:when>
        <p:when test="$ext = 'setreg'">
            <p:add-attribute match="/*" attribute-name="type"
                attribute-value="application/set-registration-initiation"/>
        </p:when>
        <p:when test="$ext = 'xla'">
            <p:add-attribute match="/*" attribute-name="type"
                attribute-value="application/vnd.ms-excel"/>
        </p:when>
        <p:when test="$ext = 'xlc'">
            <p:add-attribute match="/*" attribute-name="type"
                attribute-value="application/vnd.ms-excel"/>
        </p:when>
        <p:when test="$ext = 'xlm'">
            <p:add-attribute match="/*" attribute-name="type"
                attribute-value="application/vnd.ms-excel"/>
        </p:when>
        <p:when test="$ext = 'xls'">
            <p:add-attribute match="/*" attribute-name="type"
                attribute-value="application/vnd.ms-excel"/>
        </p:when>
        <p:when test="$ext = 'xlt'">
            <p:add-attribute match="/*" attribute-name="type"
                attribute-value="application/vnd.ms-excel"/>
        </p:when>
        <p:when test="$ext = 'xlw'">
            <p:add-attribute match="/*" attribute-name="type"
                attribute-value="application/vnd.ms-excel"/>
        </p:when>
        <p:when test="$ext = 'msg'">
            <p:add-attribute match="/*" attribute-name="type"
                attribute-value="application/vnd.ms-outlook"/>
        </p:when>
        <p:when test="$ext = 'sst'">
            <p:add-attribute match="/*" attribute-name="type"
                attribute-value="application/vnd.ms-pkicertstore"/>
        </p:when>
        <p:when test="$ext = 'cat'">
            <p:add-attribute match="/*" attribute-name="type"
                attribute-value="application/vnd.ms-pkiseccat"/>
        </p:when>
        <p:when test="$ext = 'stl'">
            <p:add-attribute match="/*" attribute-name="type"
                attribute-value="application/vnd.ms-pkistl"/>
        </p:when>
        <p:when test="$ext = 'pot'">
            <p:add-attribute match="/*" attribute-name="type"
                attribute-value="application/vnd.ms-powerpoint"/>
        </p:when>
        <p:when test="$ext = 'pps'">
            <p:add-attribute match="/*" attribute-name="type"
                attribute-value="application/vnd.ms-powerpoint"/>
        </p:when>
        <p:when test="$ext = 'ppt'">
            <p:add-attribute match="/*" attribute-name="type"
                attribute-value="application/vnd.ms-powerpoint"/>
        </p:when>
        <p:when test="$ext = 'mpp'">
            <p:add-attribute match="/*" attribute-name="type"
                attribute-value="application/vnd.ms-project"/>
        </p:when>
        <p:when test="$ext = 'wcm'">
            <p:add-attribute match="/*" attribute-name="type"
                attribute-value="application/vnd.ms-works"/>
        </p:when>
        <p:when test="$ext = 'wdb'">
            <p:add-attribute match="/*" attribute-name="type"
                attribute-value="application/vnd.ms-works"/>
        </p:when>
        <p:when test="$ext = 'wks'">
            <p:add-attribute match="/*" attribute-name="type"
                attribute-value="application/vnd.ms-works"/>
        </p:when>
        <p:when test="$ext = 'wps'">
            <p:add-attribute match="/*" attribute-name="type"
                attribute-value="application/vnd.ms-works"/>
        </p:when>
        <p:when test="$ext = 'hlp'">
            <p:add-attribute match="/*" attribute-name="type" attribute-value="application/winhlp"/>
        </p:when>
        <p:when test="$ext = 'bcpio'">
            <p:add-attribute match="/*" attribute-name="type" attribute-value="application/x-bcpio"
            />
        </p:when>
        <p:when test="$ext = 'cdf'">
            <p:add-attribute match="/*" attribute-name="type" attribute-value="application/x-cdf"/>
        </p:when>
        <p:when test="$ext = 'z'">
            <p:add-attribute match="/*" attribute-name="type"
                attribute-value="application/x-compress"/>
        </p:when>
        <p:when test="$ext = 'tgz'">
            <p:add-attribute match="/*" attribute-name="type"
                attribute-value="application/x-compressed"/>
        </p:when>
        <p:when test="$ext = 'cpio'">
            <p:add-attribute match="/*" attribute-name="type" attribute-value="application/x-cpio"/>
        </p:when>
        <p:when test="$ext = 'csh'">
            <p:add-attribute match="/*" attribute-name="type" attribute-value="application/x-csh"/>
        </p:when>
        <p:when test="$ext = 'dcr'">
            <p:add-attribute match="/*" attribute-name="type"
                attribute-value="application/x-director"/>
        </p:when>
        <p:when test="$ext = 'dir'">
            <p:add-attribute match="/*" attribute-name="type"
                attribute-value="application/x-director"/>
        </p:when>
        <p:when test="$ext = 'dxr'">
            <p:add-attribute match="/*" attribute-name="type"
                attribute-value="application/x-director"/>
        </p:when>
        <p:when test="$ext = 'dvi'">
            <p:add-attribute match="/*" attribute-name="type" attribute-value="application/x-dvi"/>
        </p:when>
        <p:when test="$ext = 'gtar'">
            <p:add-attribute match="/*" attribute-name="type" attribute-value="application/x-gtar"/>
        </p:when>
        <p:when test="$ext = 'gz'">
            <p:add-attribute match="/*" attribute-name="type" attribute-value="application/x-gzip"/>
        </p:when>
        <p:when test="$ext = 'hdf'">
            <p:add-attribute match="/*" attribute-name="type" attribute-value="application/x-hdf"/>
        </p:when>
        <p:when test="$ext = 'ins'">
            <p:add-attribute match="/*" attribute-name="type"
                attribute-value="application/x-internet-signup"/>
        </p:when>
        <p:when test="$ext = 'isp'">
            <p:add-attribute match="/*" attribute-name="type"
                attribute-value="application/x-internet-signup"/>
        </p:when>
        <p:when test="$ext = 'iii'">
            <p:add-attribute match="/*" attribute-name="type" attribute-value="application/x-iphone"
            />
        </p:when>
        <p:when test="$ext = 'js'">
            <p:add-attribute match="/*" attribute-name="type"
                attribute-value="application/x-javascript"/>
        </p:when>
        <p:when test="$ext = 'latex'">
            <p:add-attribute match="/*" attribute-name="type" attribute-value="application/x-latex"
            />
        </p:when>
        <p:when test="$ext = 'mdb'">
            <p:add-attribute match="/*" attribute-name="type"
                attribute-value="application/x-msaccess"/>
        </p:when>
        <p:when test="$ext = 'crd'">
            <p:add-attribute match="/*" attribute-name="type"
                attribute-value="application/x-mscardfile"/>
        </p:when>
        <p:when test="$ext = 'clp'">
            <p:add-attribute match="/*" attribute-name="type" attribute-value="application/x-msclip"
            />
        </p:when>
        <p:when test="$ext = 'dll'">
            <p:add-attribute match="/*" attribute-name="type"
                attribute-value="application/x-msdownload"/>
        </p:when>
        <p:when test="$ext = 'm13'">
            <p:add-attribute match="/*" attribute-name="type"
                attribute-value="application/x-msmediaview"/>
        </p:when>
        <p:when test="$ext = 'm14'">
            <p:add-attribute match="/*" attribute-name="type"
                attribute-value="application/x-msmediaview"/>
        </p:when>
        <p:when test="$ext = 'mvb'">
            <p:add-attribute match="/*" attribute-name="type"
                attribute-value="application/x-msmediaview"/>
        </p:when>
        <p:when test="$ext = 'wmf'">
            <p:add-attribute match="/*" attribute-name="type"
                attribute-value="application/x-msmetafile"/>
        </p:when>
        <p:when test="$ext = 'mny'">
            <p:add-attribute match="/*" attribute-name="type"
                attribute-value="application/x-msmoney"/>
        </p:when>
        <p:when test="$ext = 'pub'">
            <p:add-attribute match="/*" attribute-name="type"
                attribute-value="application/x-mspublisher"/>
        </p:when>
        <p:when test="$ext = 'scd'">
            <p:add-attribute match="/*" attribute-name="type"
                attribute-value="application/x-msschedule"/>
        </p:when>
        <p:when test="$ext = 'trm'">
            <p:add-attribute match="/*" attribute-name="type"
                attribute-value="application/x-msterminal"/>
        </p:when>
        <p:when test="$ext = 'wri'">
            <p:add-attribute match="/*" attribute-name="type"
                attribute-value="application/x-mswrite"/>
        </p:when>
        <p:when test="$ext = 'cdf'">
            <p:add-attribute match="/*" attribute-name="type" attribute-value="application/x-netcdf"
            />
        </p:when>
        <p:when test="$ext = 'nc'">
            <p:add-attribute match="/*" attribute-name="type" attribute-value="application/x-netcdf"
            />
        </p:when>
        <p:when test="$ext = 'pma'">
            <p:add-attribute match="/*" attribute-name="type"
                attribute-value="application/x-perfmon"/>
        </p:when>
        <p:when test="$ext = 'pmc'">
            <p:add-attribute match="/*" attribute-name="type"
                attribute-value="application/x-perfmon"/>
        </p:when>
        <p:when test="$ext = 'pml'">
            <p:add-attribute match="/*" attribute-name="type"
                attribute-value="application/x-perfmon"/>
        </p:when>
        <p:when test="$ext = 'pmr'">
            <p:add-attribute match="/*" attribute-name="type"
                attribute-value="application/x-perfmon"/>
        </p:when>
        <p:when test="$ext = 'pmw'">
            <p:add-attribute match="/*" attribute-name="type"
                attribute-value="application/x-perfmon"/>
        </p:when>
        <p:when test="$ext = 'p12'">
            <p:add-attribute match="/*" attribute-name="type" attribute-value="application/x-pkcs12"
            />
        </p:when>
        <p:when test="$ext = 'pfx'">
            <p:add-attribute match="/*" attribute-name="type" attribute-value="application/x-pkcs12"
            />
        </p:when>
        <p:when test="$ext = 'p7b'">
            <p:add-attribute match="/*" attribute-name="type"
                attribute-value="application/x-pkcs7-certificates"/>
        </p:when>
        <p:when test="$ext = 'spc'">
            <p:add-attribute match="/*" attribute-name="type"
                attribute-value="application/x-pkcs7-certificates"/>
        </p:when>
        <p:when test="$ext = 'p7r'">
            <p:add-attribute match="/*" attribute-name="type"
                attribute-value="application/x-pkcs7-certreqresp"/>
        </p:when>
        <p:when test="$ext = 'p7c'">
            <p:add-attribute match="/*" attribute-name="type"
                attribute-value="application/x-pkcs7-mime"/>
        </p:when>
        <p:when test="$ext = 'p7m'">
            <p:add-attribute match="/*" attribute-name="type"
                attribute-value="application/x-pkcs7-mime"/>
        </p:when>
        <p:when test="$ext = 'p7s'">
            <p:add-attribute match="/*" attribute-name="type"
                attribute-value="application/x-pkcs7-signature"/>
        </p:when>
        <p:when test="$ext = 'sh'">
            <p:add-attribute match="/*" attribute-name="type" attribute-value="application/x-sh"/>
        </p:when>
        <p:when test="$ext = 'shar'">
            <p:add-attribute match="/*" attribute-name="type" attribute-value="application/x-shar"/>
        </p:when>
        <p:when test="$ext = 'swf'">
            <p:add-attribute match="/*" attribute-name="type"
                attribute-value="application/x-shockwave-flash"/>
        </p:when>
        <p:when test="$ext = 'sit'">
            <p:add-attribute match="/*" attribute-name="type"
                attribute-value="application/x-stuffit"/>
        </p:when>
        <p:when test="$ext = 'sv4cpio'">
            <p:add-attribute match="/*" attribute-name="type"
                attribute-value="application/x-sv4cpio"/>
        </p:when>
        <p:when test="$ext = 'sv4crc'">
            <p:add-attribute match="/*" attribute-name="type" attribute-value="application/x-sv4crc"
            />
        </p:when>
        <p:when test="$ext = 'tar'">
            <p:add-attribute match="/*" attribute-name="type" attribute-value="application/x-tar"/>
        </p:when>
        <p:when test="$ext = 'tcl'">
            <p:add-attribute match="/*" attribute-name="type" attribute-value="application/x-tcl"/>
        </p:when>
        <p:when test="$ext = 'tex'">
            <p:add-attribute match="/*" attribute-name="type" attribute-value="application/x-tex"/>
        </p:when>
        <p:when test="$ext = 'texi'">
            <p:add-attribute match="/*" attribute-name="type"
                attribute-value="application/x-texinfo"/>
        </p:when>
        <p:when test="$ext = 'texinfo'">
            <p:add-attribute match="/*" attribute-name="type"
                attribute-value="application/x-texinfo"/>
        </p:when>
        <p:when test="$ext = 'roff'">
            <p:add-attribute match="/*" attribute-name="type" attribute-value="application/x-troff"
            />
        </p:when>
        <p:when test="$ext = 't'">
            <p:add-attribute match="/*" attribute-name="type" attribute-value="application/x-troff"
            />
        </p:when>
        <p:when test="$ext = 'tr'">
            <p:add-attribute match="/*" attribute-name="type" attribute-value="application/x-troff"
            />
        </p:when>
        <p:when test="$ext = 'man'">
            <p:add-attribute match="/*" attribute-name="type"
                attribute-value="application/x-troff-man"/>
        </p:when>
        <p:when test="$ext = 'me'">
            <p:add-attribute match="/*" attribute-name="type"
                attribute-value="application/x-troff-me"/>
        </p:when>
        <p:when test="$ext = 'ms'">
            <p:add-attribute match="/*" attribute-name="type"
                attribute-value="application/x-troff-ms"/>
        </p:when>
        <p:when test="$ext = 'ustar'">
            <p:add-attribute match="/*" attribute-name="type" attribute-value="application/x-ustar"
            />
        </p:when>
        <p:when test="$ext = 'src'">
            <p:add-attribute match="/*" attribute-name="type"
                attribute-value="application/x-wais-source"/>
        </p:when>
        <p:when test="$ext = 'cer'">
            <p:add-attribute match="/*" attribute-name="type"
                attribute-value="application/x-x509-ca-cert"/>
        </p:when>
        <p:when test="$ext = 'crt'">
            <p:add-attribute match="/*" attribute-name="type"
                attribute-value="application/x-x509-ca-cert"/>
        </p:when>
        <p:when test="$ext = 'der'">
            <p:add-attribute match="/*" attribute-name="type"
                attribute-value="application/x-x509-ca-cert"/>
        </p:when>
        <p:when test="$ext = 'pko'">
            <p:add-attribute match="/*" attribute-name="type"
                attribute-value="application/ynd.ms-pkipko"/>
        </p:when>
        <p:when test="$ext = 'zip'">
            <p:add-attribute match="/*" attribute-name="type" attribute-value="application/zip"/>
        </p:when>
        <p:when test="$ext = 'flr'">
            <p:add-attribute match="/*" attribute-name="type" attribute-value="x-world/x-vrml"/>
        </p:when>
        <p:when test="$ext = 'vrml'">
            <p:add-attribute match="/*" attribute-name="type" attribute-value="x-world/x-vrml"/>
        </p:when>
        <p:when test="$ext = 'wrl'">
            <p:add-attribute match="/*" attribute-name="type" attribute-value="x-world/x-vrml"/>
        </p:when>
        <p:when test="$ext = 'wrz'">
            <p:add-attribute match="/*" attribute-name="type" attribute-value="x-world/x-vrml"/>
        </p:when>
        <p:when test="$ext = 'xaf'">
            <p:add-attribute match="/*" attribute-name="type" attribute-value="x-world/x-vrml"/>
        </p:when>
        <p:when test="$ext = 'xof'">
            <p:add-attribute match="/*" attribute-name="type" attribute-value="x-world/x-vrml"/>
        </p:when>
        <p:otherwise>
            <!-- Binary? -->
            <p:add-attribute match="/*" attribute-name="type"
                attribute-value="application/octet-stream"/>
        </p:otherwise>
    </p:choose>

</p:declare-step>
