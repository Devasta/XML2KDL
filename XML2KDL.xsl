<?xml version="1.0" encoding="UTF-8" ?>
<xsl:transform xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">
    <xsl:output method="text" encoding="UTF-8" />

    <xsl:strip-space elements="*"/>

    <!--
        This XSL Transform is intended to convert any XML 1.0 document to a KDL file.

        The full KDL specification can be found at https://kdl.dev/

        The spec for XML-in-KDL can be found at https://github.com/kdl-org/kdl/blob/main/XML-IN-KDL.md
    -->

    <xsl:template match="comment()">
        <!-- KDL comments take the for /* multi-line-comment */ -->
        <xsl:text>/* </xsl:text>
        <xsl:value-of select="normalize-space(.)"/>
        <xsl:text> */</xsl:text>
        <xsl:text>&#xa;</xsl:text>
    </xsl:template>
    
    <xsl:template match="processing-instruction()">
        <!-- 
            The contents of a PI are technically completely unstructured. 
            However, in practice most PIs' contents look like start-tag attributes.
            If this is the case, they should be encoded as properties on the node, with string values.

            If the contents of a PI do not look like attributes, then instead the entire contents 
            (from the end of the whitespace following the PI name, to the closing ?> characters)
            are encoded as a single unnamed string value.

            I need to put more intelligent logic in here to determine this, but for now we put raw string.
        -->
        <xsl:text>?</xsl:text>
        <xsl:value-of select="name()"/>
        <xsl:text> r#</xsl:text>
        <xsl:value-of select="normalize-space(.)"/>
        <xsl:text>#;</xsl:text>
        <xsl:text>&#xa;</xsl:text>
    </xsl:template>

    <xsl:template match="*">
        <xsl:value-of select = "name(.)"/>
        <xsl:text> </xsl:text>
        <xsl:if test="count(*) = 0">
            <xsl:value-of select="concat('&quot;',.,'&quot;')"/>
        </xsl:if>
        <xsl:for-each select="./@*">
            <xsl:text> </xsl:text>
            <xsl:value-of select="name()"/>
            <xsl:text>=</xsl:text>
            <xsl:value-of select="concat('&quot;',.,'&quot;')"/>
        </xsl:for-each>
        <xsl:choose>
            <!-- End line if no child nodes -->
            <xsl:when test="not(count(*) &gt; 0)">
                <xsl:text>;</xsl:text>
                <xsl:text>&#xa;</xsl:text>
            </xsl:when>
            <!-- Mixed Content, split into list and reapply templates. -->
            <xsl:when test="count(*) &gt; 0 and count(text()) &gt; 1">
                <xsl:text>{ </xsl:text>
                <xsl:text>&#xa;</xsl:text>
                <xsl:for-each select="node()">
                    <xsl:choose>
                        <xsl:when test="self::text()">
                            <xsl:text> - "</xsl:text>
                                <xsl:value-of select="normalize-space(.)"/>
                            <xsl:text>";</xsl:text>
                            <xsl:text>&#xa;</xsl:text> 
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:apply-templates select="."/>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:for-each>
                <xsl:text>};</xsl:text>
                <xsl:text>&#xa;</xsl:text>
            </xsl:when>
            <!-- Brackets and reapply templates if there are children -->
            <xsl:when test="count(*) &gt; 0">
                <xsl:text>{</xsl:text>
                <xsl:text>&#xa;</xsl:text>
                <xsl:apply-templates/>
                <xsl:text>}</xsl:text>
                <xsl:text>&#xa;</xsl:text>
            </xsl:when>
        </xsl:choose>
    </xsl:template>
</xsl:transform>