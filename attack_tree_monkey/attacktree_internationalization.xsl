<?xml version="1.0"?>
<xsl:stylesheet version="1.0" 
     xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
     xmlns:at="urn:attacktree.org:schemas:attacktree:1.0"
     xmlns:atm="urn:attacktree.org:schemas:attack-tree-monkey:1.0">

<!--
    This file is part of Attack Tree Monkey.

    Attack Tree Monkey is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    Attack Tree Monkey is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with Attack Tree Monkey.  If not, see <http://www.gnu.org/licenses/>.

    (C) Copyright 2011 Thomas Leske
-->

<xsl:template match="*" mode="childCopy" >
  <xsl:copy-of select = "child::*|child::text()" />
</xsl:template>

<xsl:template match="*" mode="translate" >
  <xsl:variable name = "nodename" select="name()"/>
  <xsl:choose>
    <xsl:when test="$esperantoReplacement != $lang and parent::atm:translation/parent::atm:userinterface/child::atm:translation[@xml:lang = $lang]/child::*[name() = $nodename]">
      <xsl:apply-templates select="parent::atm:translation/parent::atm:userinterface/child::atm:translation[@xml:lang = $lang]/child::*[name() = $nodename]" mode="childCopy" />
    </xsl:when>
    <xsl:when test="$esperantoReplacement != $lang and $esperantoReplacement != $fallback_lang and parent::atm:translation/parent::atm:userinterface/child::atm:translation[@xml:lang = $fallback_lang]/child::*[name() = $nodename]">
      <xsl:apply-templates select="parent::atm:translation/parent::atm:userinterface/child::atm:translation[@xml:lang = $fallback_lang]/child::*[name() = $nodename]" mode="childCopy" />
    </xsl:when>
    <xsl:otherwise>
      <xsl:apply-templates select="." mode="childCopy" />
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>

<xsl:template match="*" mode="printLocalizedDescription">
  <xsl:param name = "targetLang" select="$lang" />

  <xsl:variable name="localizedDescription" select="./child::at:description[@xml:lang = $targetLang and child::text() != '']" /> 
  <xsl:choose>
    <xsl:when test = "$localizedDescription" >
      <xsl:apply-templates select="$localizedDescription" mode="childCopy" />
    </xsl:when>
    <xsl:when test = "$targetLang != $fallback_lang">
      <xsl:apply-templates select="." mode="printLocalizedDescription">
	<xsl:with-param name = "targetLang" select="$fallback_lang" />
      </xsl:apply-templates>      
    </xsl:when>
    <xsl:when test = "child::at:description[not(@xml:lang)]">
      <xsl:apply-templates select="child::at:description[not(@xml:lang)]" mode="childCopy" />
    </xsl:when>
    <xsl:otherwise>
      <xsl:apply-templates select="child::at:description" mode="childCopy" />
    </xsl:otherwise>      
  </xsl:choose>
</xsl:template>

<xsl:template match="at:attacktree" mode="getLocalizedDefence" >
  <xsl:param name = "defenceName" />
  <xsl:param name = "targetLang" select="$lang" />
  
  <xsl:variable name="translation">
    <xsl:value-of select = "/at:attacktree/at:defender/at:defences/at:translation[@xml:lang = $targetLang]/child::at:defence[@name = $defenceName]" />
  </xsl:variable>
  <xsl:choose>
    <xsl:when test = "string($translation)!=''">
      <xsl:value-of select="$translation" />
    </xsl:when>
    <xsl:when test = "$targetLang != $fallback_lang">
      <xsl:apply-templates select="." mode="getLocalizedDefence">
	<xsl:with-param name = "defenceName" select="$defenceName" />
	<xsl:with-param name = "targetLang" select="$fallback_lang" />
      </xsl:apply-templates>      
    </xsl:when>
    <xsl:otherwise>
      <xsl:value-of select="$defenceName" />
    </xsl:otherwise>
  </xsl:choose>  
</xsl:template>

<xsl:template match="at:attacktree" mode="getLocalizedNameSpec" >
  <xsl:param name = "propertyName" />
  <xsl:param name = "targetLang" select="$lang" />

  <xsl:variable name = "localizedName">
    <xsl:copy-of select = "key('mapPropertyNamesToTypeDeclaration',$propertyName)[1]/child::at:translation[@xml:lang = $targetLang]" />
  </xsl:variable>
  <xsl:choose>
    <xsl:when test = "string($localizedName)">
      <xsl:copy-of select = "$localizedName" />
    </xsl:when>
    <xsl:when test = "$targetLang != $fallback_lang">
      <xsl:apply-templates select="." mode="getLocalizedNameSpec">
	<xsl:with-param name = "propertyName" select="$propertyName" />
	<xsl:with-param name = "targetLang" select="$fallback_lang" />
      </xsl:apply-templates>      
    </xsl:when>
    <xsl:otherwise>
      <dummy>
	<xsl:value-of select="$propertyName"/>
      </dummy>
    </xsl:otherwise>
  </xsl:choose>       
</xsl:template>

<xsl:template match="at:attacknode" mode="showLocalizedTitleText">
  <xsl:variable name="localizedTitle" select="child::at:title[@xml:lang = $lang]/child::text()" />
  <xsl:choose>
    <xsl:when test = "string($localizedTitle)" >
      <xsl:value-of select="$localizedTitle" />
    </xsl:when>
    <xsl:otherwise>
      <xsl:variable name="localizedTitle2" select="child::title[@xml:lang = $fallback_lang]/child::text()" />
      <xsl:choose>
	<xsl:when test = "$localizedTitle2" >
	  <xsl:value-of select="$localizedTitle2" />
	</xsl:when>
	<xsl:otherwise>
	  <xsl:value-of select="attribute::title" />
	</xsl:otherwise>      
      </xsl:choose>
    </xsl:otherwise>      
  </xsl:choose>
</xsl:template>

<xsl:decimal-format name="de"
  decimal-separator = ","
  grouping-separator = "."
  infinity = "&#8734;"
  NaN = "keine_Zahl"
  />
<xsl:decimal-format name="en"
  infinity = "&#8734;"
  NaN = "not_a_number"
 />

<xsl:template name="printLocalizedNumber">
  <xsl:param name = "number" />

  <xsl:choose>
    <xsl:when test="$lang='de'">
      <xsl:value-of select="format-number($number, '###.###.###.##0,####', 'de')" />
    </xsl:when>
    <xsl:otherwise>
      <xsl:value-of select="format-number($number, '###,###,###,##0.####', 'en')" />
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>

</xsl:stylesheet>
