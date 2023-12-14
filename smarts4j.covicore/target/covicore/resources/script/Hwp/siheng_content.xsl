<?xml version="1.0" encoding="euc-kr"?>
<!--=========================-->
<!--          시행문         -->
<!--=========================-->
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">		
<xsl:template match="/">
	 <DIV STYLE="width:175mm">
	<!-- 본문 -->
	<table border="0" width="100%" cellspacing="0" cellpadding="0">
		<tr><td height="450" valign="top" >		
	      		<xsl:apply-templates select="pubdoc/body/content"/> 	
       	</td></tr>
	</table>
</DIV>
</xsl:template>

  <!-- pubdoc Body -->
  <xsl:template match="pubdoc/body/content">
     <DIV STYLE="padding-top:20px; margin-bottom:2em; color:black; width:100%;">
      <xsl:apply-templates/>
     </DIV>
  </xsl:template>
  
  <xsl:template match="p">
    <P>
      <xsl:attribute name="id"><xsl:value-of select="./@id"/></xsl:attribute>
      <xsl:attribute name="class"><xsl:value-of select="./@class"/></xsl:attribute>
      <xsl:attribute name="align"><xsl:value-of select="./@align"/></xsl:attribute>
      <xsl:attribute name="style">margin:0cm;<xsl:value-of select="./@style"/></xsl:attribute>
      <xsl:apply-templates/>
    </P>
  </xsl:template>

  <xsl:template match="b">
    <B>
      <xsl:attribute name="id"><xsl:value-of select="./@id"/></xsl:attribute>
      <xsl:attribute name="class"><xsl:value-of select="./@class"/></xsl:attribute>      
      <xsl:apply-templates/>
    </B>
  </xsl:template>

  
  <xsl:template match="i">
    <I>
      <xsl:attribute name="id"><xsl:value-of select="./@id"/></xsl:attribute>
      <xsl:attribute name="class"><xsl:value-of select="./@class"/></xsl:attribute>      
      <xsl:apply-templates/>
    </I>
  </xsl:template>
  
  <xsl:template match="u">
    <U>
      <xsl:attribute name="id"><xsl:value-of select="./@id"/></xsl:attribute>
      <xsl:attribute name="class"><xsl:value-of select="./@class"/></xsl:attribute>      
      <xsl:apply-templates/>
    </U>
  </xsl:template>


  <xsl:template match="sub">
    <SUB>
      <xsl:attribute name="id"><xsl:value-of select="./@id"/></xsl:attribute>
      <xsl:attribute name="class"><xsl:value-of select="./@class"/></xsl:attribute>          
      <xsl:apply-templates/>
    </SUB>
  </xsl:template>
  

  <xsl:template match="sup">
    <SUP>
      <xsl:apply-templates/>
    </SUP>
  </xsl:template>
  

  <xsl:template match="ol">
    <DIV STYLE="font-size:14pt; font-family:바탕체">
      <OL>
        <xsl:attribute name="id"><xsl:value-of select="./@id"/></xsl:attribute>
        <xsl:attribute name="class"><xsl:value-of select="./@class"/></xsl:attribute>
        <xsl:for-each select="li">
          <LI>
            <xsl:attribute name="id"><xsl:value-of select="./@id"/></xsl:attribute>
            <xsl:attribute name="class"><xsl:value-of select="./@class"/></xsl:attribute>      
            <xsl:apply-templates/>
          </LI>
        </xsl:for-each>
      </OL>
    </DIV>
  </xsl:template>


  <xsl:template match="ul">
    <DIV STYLE="font-size:14pt; font-family:바탕체">
      <UL>
        <xsl:attribute name="id"><xsl:value-of select="./@id"/></xsl:attribute>
        <xsl:attribute name="class"><xsl:value-of select="./@class"/></xsl:attribute>
        <xsl:for-each select="li">
          <LI>
            <xsl:attribute name="id"><xsl:value-of select="./@id"/></xsl:attribute>
            <xsl:attribute name="class"><xsl:value-of select="./@class"/></xsl:attribute>      
            <xsl:apply-templates/>
          </LI>
        </xsl:for-each>
      </UL>
    </DIV>
  </xsl:template>

  <!-- Image -->
  <xsl:template match="img">
    <DIV STYLE="margin-top:1em; margin-bottom:1em;">
        <IMG>
         <xsl:attribute name="id"><xsl:value-of select="./@id"/></xsl:attribute>
         <xsl:attribute name="class"><xsl:value-of select="./@class"/></xsl:attribute>      
          <xsl:attribute name="src"><xsl:value-of select="./@src"/></xsl:attribute>
          <xsl:attribute name="alt"><xsl:value-of select="./@alt"/></xsl:attribute>
          <xsl:attribute name="name"><xsl:value-of select="./@name"/></xsl:attribute>
          <xsl:attribute name="longdesc"><xsl:value-of select="./@longdesc"/></xsl:attribute>
          <xsl:attribute name="style">width:<xsl:value-of select="./@width"/>;height:<xsl:value-of select="./@height"/>;</xsl:attribute>
          <xsl:attribute name="align"><xsl:value-of select="./@align"/></xsl:attribute>
          <xsl:attribute name="border"><xsl:value-of select="./@border"/></xsl:attribute>
          <xsl:attribute name="hspace"><xsl:value-of select="./@hspace"/></xsl:attribute>
          <xsl:attribute name="vspace"><xsl:value-of select="./@vspace"/></xsl:attribute>
        </IMG>
    </DIV>
  </xsl:template>

  <!-- HTML Table -->
  <xsl:template match="table">
    <TABLE>
      <xsl:attribute name="style">width:<xsl:value-of select="./@width"/>;height:<xsl:value-of select="./@height"/>;margin-top:1em; margin-bottom:1em; color:black; font-size:14pt; font-family:바탕체;</xsl:attribute>
      <xsl:attribute name="id"><xsl:value-of select="./@id"/></xsl:attribute>
      <xsl:attribute name="class"><xsl:value-of select="./@class"/></xsl:attribute>
      <xsl:attribute name="summary"><xsl:value-of select="./@summary"/></xsl:attribute>
      <xsl:attribute name="border"><xsl:value-of select="./@border"/></xsl:attribute>
      <xsl:attribute name="cellspacing"><xsl:value-of select="./@cellspacing"/></xsl:attribute>
      <xsl:attribute name="cellpadding"><xsl:value-of select="./@cellpadding"/></xsl:attribute>
      <xsl:attribute name="align"><xsl:value-of select="./@align"/></xsl:attribute>
      <xsl:for-each select="caption">
        <CAPTION>
          <xsl:attribute name="id"><xsl:value-of select="./@id"/></xsl:attribute>
          <xsl:attribute name="class"><xsl:value-of select="./@class"/></xsl:attribute>
          <xsl:apply-templates/>
        </CAPTION>
      </xsl:for-each>
      <xsl:for-each select="col">
        <COL>
          <xsl:attribute name="style">width:<xsl:value-of select="./@width"/>;</xsl:attribute>
          <xsl:attribute name="id"><xsl:value-of select="./@id"/></xsl:attribute>
          <xsl:attribute name="class"><xsl:value-of select="./@class"/></xsl:attribute>
          <xsl:attribute name="span"><xsl:value-of select="./@span"/></xsl:attribute>
          <xsl:attribute name="align"><xsl:value-of select="./@align"/></xsl:attribute>
          <xsl:attribute name="char"><xsl:value-of select="./@char"/></xsl:attribute>
          <xsl:attribute name="charoff"><xsl:value-of select="./@charoff"/></xsl:attribute>
          <xsl:attribute name="valign"><xsl:value-of select="./@valign"/></xsl:attribute>
        </COL>
      </xsl:for-each>
      <xsl:for-each select="colgroup">
        <COLGROUP>
          <xsl:attribute name="style">width:<xsl:value-of select="./@width"/>;</xsl:attribute>
          <xsl:attribute name="id"><xsl:value-of select="./@id"/></xsl:attribute>
          <xsl:attribute name="class"><xsl:value-of select="./@class"/></xsl:attribute>
          <xsl:attribute name="span"><xsl:value-of select="./@span"/></xsl:attribute>
          <xsl:attribute name="align"><xsl:value-of select="./@align"/></xsl:attribute>
          <xsl:attribute name="char"><xsl:value-of select="./@char"/></xsl:attribute>
          <xsl:attribute name="charoff"><xsl:value-of select="./@charoff"/></xsl:attribute>
          <xsl:attribute name="valign"><xsl:value-of select="./@valign"/></xsl:attribute>
        </COLGROUP>
      </xsl:for-each>
      <xsl:for-each select="thead">
        <THEAD>
          <xsl:attribute name="id"><xsl:value-of select="./@id"/></xsl:attribute>
          <xsl:attribute name="class"><xsl:value-of select="./@class"/></xsl:attribute>
          <xsl:attribute name="align"><xsl:value-of select="./@align"/></xsl:attribute>
          <xsl:attribute name="char"><xsl:value-of select="./@char"/></xsl:attribute>
          <xsl:attribute name="charoff"><xsl:value-of select="./@charoff"/></xsl:attribute>
          <xsl:attribute name="valign"><xsl:value-of select="./@valign"/></xsl:attribute>
          <xsl:for-each select="tr">
            <TR>
              <xsl:attribute name="id"><xsl:value-of select="./@id"/></xsl:attribute>
              <xsl:attribute name="class"><xsl:value-of select="./@class"/></xsl:attribute>
              <xsl:attribute name="align"><xsl:value-of select="./@align"/></xsl:attribute>
              <xsl:attribute name="char"><xsl:value-of select="./@char"/></xsl:attribute>
              <xsl:attribute name="charoff"><xsl:value-of select="./@charoff"/></xsl:attribute>
              <xsl:attribute name="valign"><xsl:value-of select="./@valign"/></xsl:attribute>
                       
              <xsl:apply-templates/>
              
            </TR>
          </xsl:for-each>
        </THEAD>
      </xsl:for-each>
      <xsl:for-each select="tfoot">
        <TFOOT>
          <xsl:attribute name="id"><xsl:value-of select="./@id"/></xsl:attribute>
          <xsl:attribute name="class"><xsl:value-of select="./@class"/></xsl:attribute>
          <xsl:attribute name="align"><xsl:value-of select="./@align"/></xsl:attribute>
          <xsl:attribute name="char"><xsl:value-of select="./@char"/></xsl:attribute>
          <xsl:attribute name="charoff"><xsl:value-of select="./@charoff"/></xsl:attribute>
          <xsl:attribute name="valign"><xsl:value-of select="./@valign"/></xsl:attribute>
          <xsl:for-each select="tr">
            <TR>
              <xsl:attribute name="id"><xsl:value-of select="./@id"/></xsl:attribute>
              <xsl:attribute name="class"><xsl:value-of select="./@class"/></xsl:attribute>
              <xsl:attribute name="align"><xsl:value-of select="./@align"/></xsl:attribute>
              <xsl:attribute name="char"><xsl:value-of select="./@char"/></xsl:attribute>
              <xsl:attribute name="charoff"><xsl:value-of select="./@charoff"/></xsl:attribute>
              <xsl:attribute name="valign"><xsl:value-of select="./@valign"/></xsl:attribute>
              
              <xsl:apply-templates/>
              
            </TR>
          </xsl:for-each>
        </TFOOT>
      </xsl:for-each>
      <xsl:for-each select="tbody">
        <TBODY>
          <xsl:attribute name="id"><xsl:value-of select="./@id"/></xsl:attribute>
          <xsl:attribute name="class"><xsl:value-of select="./@class"/></xsl:attribute>
          <xsl:attribute name="align"><xsl:value-of select="./@align"/></xsl:attribute>
          <xsl:attribute name="char"><xsl:value-of select="./@char"/></xsl:attribute>
          <xsl:attribute name="charoff"><xsl:value-of select="./@charoff"/></xsl:attribute>
          <xsl:attribute name="valign"><xsl:value-of select="./@valign"/></xsl:attribute>
          <xsl:for-each select="tr">
            <TR>
              <xsl:attribute name="id"><xsl:value-of select="./@id"/></xsl:attribute>
              <xsl:attribute name="class"><xsl:value-of select="./@class"/></xsl:attribute>
              <xsl:attribute name="align"><xsl:value-of select="./@align"/></xsl:attribute>
              <xsl:attribute name="char"><xsl:value-of select="./@char"/></xsl:attribute>
              <xsl:attribute name="charoff"><xsl:value-of select="./@charoff"/></xsl:attribute>
              <xsl:attribute name="valign"><xsl:value-of select="./@valign"/></xsl:attribute>
              
              <xsl:apply-templates/>
              
            </TR>
          </xsl:for-each>
        </TBODY>
      </xsl:for-each>
    </TABLE>
  </xsl:template>
  
  <xsl:template match="td">
    <TD>
      <xsl:attribute name="style">width:<xsl:value-of select="./@width"/>;height:<xsl:value-of select="./@height"/>;padding:0cm;</xsl:attribute>
      <xsl:attribute name="id"><xsl:value-of select="./@id"/></xsl:attribute>
      <xsl:attribute name="class"><xsl:value-of select="./@class"/></xsl:attribute>      
      <xsl:attribute name="abbr"><xsl:value-of select="./@abbr"/></xsl:attribute>
      <xsl:attribute name="axis"><xsl:value-of select="./@axis"/></xsl:attribute>
      <xsl:attribute name="headers"><xsl:value-of select="./@headers"/></xsl:attribute>
      <xsl:attribute name="scope"><xsl:value-of select="./@scope"/></xsl:attribute>
      <xsl:attribute name="rowspan"><xsl:value-of select="./@rowspan"/></xsl:attribute>      
      <xsl:attribute name="colspan"><xsl:value-of select="./@colspan"/></xsl:attribute>
      <xsl:attribute name="align"><xsl:value-of select="./@align"/></xsl:attribute>
      <xsl:attribute name="char"><xsl:value-of select="./@char"/></xsl:attribute>
      <xsl:attribute name="charoff"><xsl:value-of select="./@charoff"/></xsl:attribute>
      <xsl:attribute name="valign"><xsl:value-of select="./@valign"/></xsl:attribute>
      <xsl:attribute name="nowrap"><xsl:value-of select="./@nowrap"/></xsl:attribute>
      <xsl:apply-templates/>
    </TD>    
  </xsl:template>  
  <xsl:template match="th">
    <TH>
      <xsl:attribute name="style">width:<xsl:value-of select="./@width"/>;height:<xsl:value-of select="./@height"/>;</xsl:attribute>
      <xsl:attribute name="id"><xsl:value-of select="./@id"/></xsl:attribute>
      <xsl:attribute name="class"><xsl:value-of select="./@class"/></xsl:attribute>      
      <xsl:attribute name="abbr"><xsl:value-of select="./@abbr"/></xsl:attribute>
      <xsl:attribute name="axis"><xsl:value-of select="./@axis"/></xsl:attribute>
      <xsl:attribute name="headers"><xsl:value-of select="./@headers"/></xsl:attribute>
      <xsl:attribute name="scope"><xsl:value-of select="./@scope"/></xsl:attribute>
      <xsl:attribute name="rowspan"><xsl:value-of select="./@rowspan"/></xsl:attribute>      
      <xsl:attribute name="colspan"><xsl:value-of select="./@colspan"/></xsl:attribute>
      <xsl:attribute name="align"><xsl:value-of select="./@align"/></xsl:attribute>
      <xsl:attribute name="char"><xsl:value-of select="./@char"/></xsl:attribute>
      <xsl:attribute name="charoff"><xsl:value-of select="./@charoff"/></xsl:attribute>
      <xsl:attribute name="valign"><xsl:value-of select="./@valign"/></xsl:attribute>
      <xsl:attribute name="nowrap"><xsl:value-of select="./@nowrap"/></xsl:attribute>
      <xsl:apply-templates/>
    </TH>    
  </xsl:template>  


</xsl:stylesheet>
