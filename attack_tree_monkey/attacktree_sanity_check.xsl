<?xml version="1.0"?>
<xsl:stylesheet version="1.0" 
     xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
     xmlns:all-subgoals-needed-func="all-subgoals-needed-func"
     xmlns:some-subgoal-needed-func="some-subgoal-needed-func"
     xmlns:exslt="http://exslt.org/common"
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

<xsl:template match="at:attacktree" mode="sanityCheck" >
  <xsl:variable name = "complaints">
    <xsl:for-each select=".//at:attacknode">
      <!-- loop through names of properties: -->
      <xsl:for-each select="//at:property[generate-id(.)=generate-id(key('mapPropertyNamesToPropertyNodes',attribute::name))]">
	<xsl:variable name = "propertyName" select="./attribute::name"/>
	<xsl:if test = "1 &lt; count(./child::at:property[@name = $propertyName])" >
	  <li xmlns='http://www.w3.org/1999/xhtml'><xsl:apply-templates select="$localizer/atm:duplicate_property_name" mode="translate" />: '<xsl:value-of select="./attribute::name" />' <xsl:apply-templates select="$localizer/atm:at_attacknode" mode="translate" /> '<xsl:value-of select="./parent::at:attacknode/attribute::title" />'</li>
	</xsl:if>
      </xsl:for-each>
      <xsl:choose>
	<xsl:when test = "not(not(child::at:attacknode) and attribute::type='') and attribute::type!='and' and attribute::type!='or'">
	  <li xmlns='http://www.w3.org/1999/xhtml'><xsl:apply-templates select="$localizer/atm:unknown_attacknode_type" mode="translate" /><xsl:text> </xsl:text><xsl:apply-templates select="$localizer/atm:at_attacknode" mode="translate" /> '<xsl:value-of select="attribute::title" />'</li>
	</xsl:when>
      </xsl:choose>
      <xsl:if test = "attribute::repeat" >
	<xsl:variable name = "valueType" select = "local-name(key('mapPropertyNamesToTypeDeclaration',attribute::repeat)[1]/parent::*)" />
	<xsl:if test = "$valueType!='probability'" >
	  <li xmlns='http://www.w3.org/1999/xhtml'>
	   <xsl:apply-templates select="$localizer/atm:repeat_with_wrong_type" mode="translate" /><xsl:text> '</xsl:text><xsl:value-of select="$valueType" /><xsl:text>' </xsl:text><xsl:apply-templates select="$localizer/atm:at_attacknode" mode="translate" />
	   </li>
	</xsl:if>
      </xsl:if>
    </xsl:for-each>

    <xsl:for-each select=".//at:type/child::*">
      <xsl:if test = "namespace-uri() != 'urn:attacktree.org:schemas:attacktree:1.0' or (local-name() !='rationalScale' and local-name() !='rationalScaleDefender' and local-name() !='probability' and local-name() !='boolean')" >
	<li xmlns='http://www.w3.org/1999/xhtml'><xsl:apply-templates select="$localizer/atm:unknown_type" mode="translate" />: '<xsl:copy-of select="name()" />'</li>
      </xsl:if>
    </xsl:for-each>

    <xsl:if test = "key('mapPropertyNamesToPropertyNodes','effortlessAttack')" >
      <li xmlns='http://www.w3.org/1999/xhtml'><xsl:apply-templates select="$localizer/atm:reserved_property" mode="translate" />: 'effortlessAttack'</li>
    </xsl:if>
    <xsl:if test = "key('mapPropertyNamesToPropertyNodes','includedAttack')" >
      <li xmlns='http://www.w3.org/1999/xhtml'><xsl:apply-templates select="$localizer/atm:reserved_property" mode="translate" />: 'includedAttack'</li>
    </xsl:if>
    <xsl:if test = "local-name(key('mapPropertyNamesToTypeDeclaration','effortlessAttack')[1]/parent::*)!='boolean'" >
      <li xmlns='http://www.w3.org/1999/xhtml'><xsl:apply-templates select="$localizer/atm:reserved_property_type" mode="translate" />: 'effortlessAttack'</li>
    </xsl:if>
    <xsl:if test = "local-name(key('mapPropertyNamesToTypeDeclaration','includedAttack')[1]/parent::*)!='boolean'" >
      <li xmlns='http://www.w3.org/1999/xhtml'><xsl:apply-templates select="$localizer/atm:reserved_property_type" mode="translate" />: 'includedAttack'</li>
    </xsl:if>
    <!-- loop through names of properties: -->
    <xsl:for-each select="//at:property[generate-id(.)=generate-id(key('mapPropertyNamesToPropertyNodes',attribute::name))]">
      <xsl:variable name = "propertyName" select="attribute::name"/>

      <xsl:if test = "1 &lt; count(key('mapPropertyNamesToFilterDeclaration',$propertyName))" >
	<li xmlns='http://www.w3.org/1999/xhtml'>
	  <xsl:apply-templates select="$localizer/atm:duplicate_filter" mode="translate" />
	  <xsl:text> '</xsl:text>
	  <xsl:value-of select="$propertyName" />
	  <xsl:text>'</xsl:text> 
	</li>
      </xsl:if>

      <xsl:variable name = "valueType" select = "local-name(key('mapPropertyNamesToTypeDeclaration',$propertyName)[1]/parent::*)" />
      <xsl:if test = "key('mapPropertyNamesToFilterDeclaration',$propertyName) and $valueType='rationalScaleDefender'" >
	<li xmlns='http://www.w3.org/1999/xhtml'>
	  <xsl:apply-templates select="$localizer/atm:filter_with_wrong_type" mode="translate" />
	  <xsl:text> '</xsl:text>
	  <xsl:value-of select="$propertyName" />'.
	</li>
      </xsl:if>
      <xsl:if test = "$valueType='boolean' and key('mapPropertyNamesToFilterDeclaration',$propertyName)[1]/child::text()!=''" >
	<li xmlns='http://www.w3.org/1999/xhtml'>
	  <xsl:apply-templates select="$localizer/atm:filter_with_ignored_value" mode="translate" /> '<xsl:value-of select="$propertyName" />'.
	</li>
      </xsl:if>

      <xsl:if test = "1 &lt; count(key('mapPropertyNamesToTypeDeclaration',$propertyName))" >
	<li xmlns='http://www.w3.org/1999/xhtml'>
	  <xsl:apply-templates select="$localizer/atm:duplicate_type_declaration" mode="translate" />
	  <xsl:text> '</xsl:text> 
	  <xsl:value-of select="$propertyName" />
	  <xsl:text>'</xsl:text> 
	</li>
      </xsl:if>

      <xsl:if test = "not(key('mapPropertyNamesToTypeDeclaration',$propertyName))" >
	<li xmlns='http://www.w3.org/1999/xhtml'>
	  <xsl:apply-templates select="$localizer/atm:missing_type_declaration" mode="translate" />
	  <xsl:text> '</xsl:text> 
	  <xsl:value-of select="$propertyName" />
	  <xsl:text>'</xsl:text> 
	</li>
      </xsl:if>
    </xsl:for-each>
  </xsl:variable>

  <xsl:if test = "string($complaints)" >
    <div xmlns='http://www.w3.org/1999/xhtml' class="sanityCheck">
      <b><xsl:apply-templates select="$localizer/atm:faulty_input" mode="translate" /></b>
      <ul>
	<xsl:copy-of select="$complaints" />
      </ul>
    </div>
  </xsl:if>
</xsl:template>
</xsl:stylesheet>
