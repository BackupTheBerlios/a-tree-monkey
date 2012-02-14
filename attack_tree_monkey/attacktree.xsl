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

<xsl:output method="html"/>

<xsl:key name="mapPropertyNamesToPropertyNodes" match="at:property" use="attribute::name"/>
<xsl:key name="mapPropertyNamesToTypeDeclaration" match="at:type/*/*" use="local-name()"/>
<xsl:key name="mapPropertyNamesToFilterDeclaration" match="at:filter/*" use="local-name()"/>
<xsl:key name="mapDefenceNamesToEnableDeclaration" match="at:enabledDefences/at:defence" use="attribute::name"/>
<xsl:key name="mapDefenceNamesToProperties" match="at:property" use="attribute::defence"/>
<xsl:key name="mapIdsToAttacknodes" match="at:attacknode" use="generate-id()"/>

<xsl:param name = "lang" select="'de'"/>
<xsl:variable name = "fallback_lang" select="'de'"/>

<!-- Links to an Impressum are a legal requirement for web sites in Germany. 
     Set the value to '' to disable this feature. -->
<xsl:param name = "impressum" select="'/impressum.txt'"/>

<xsl:variable name = "esperantoReplacement" select="'de'"/><!-- make sure all nodes below 'userinterface' are present for that language. (It does not matter, if the nodes lack text.) -->
<xsl:variable name = "localizer" select="document('userinterface.xml')/atm:userinterface/atm:translation[@xml:lang = $esperantoReplacement]"/>
<xsl:variable name = "theAttackTree" select="/at:attacktree"/>

<xsl:include href = "attacktree_sanity_check.xsl" />
<xsl:include href = "attacktree_internationalization.xsl" />
<xsl:include href = "attacktree_calculation.xsl" />

<xsl:template match="/at:attacktree">
  <xsl:text disable-output-escaping="yes"><![CDATA[<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.1//EN" "http://www.w3.org/TR/xhtml11/DTD/xhtml11.dtd">]]></xsl:text>
  <html xmlns="http://www.w3.org/1999/xhtml">
   <xsl:comment>*** This file is automatically generated by 'attacktree.xsl'. Do not edit! ***</xsl:comment>
   <head>
     <meta http-equiv="content-type" content="text/html; charset=UTF-8" />
     <style type="text/css">
       .attacksubtreeAnd {border-left-width:5px;border-left-style:solid;border-left-color:black;margin-bottom:20px;}
       .attacksubtreeOr  {border-left-width:5px;border-left-style:solid;border-left-color:grey;margin-bottom:20px;}

       .attacknode {padding:5px;background-color:#FFFFE0;border-width:thin;border-style:solid;border-color:grey;}
       .attacknodeWithoutChildren {padding:5px;background-color:#FFFFE0;margin-bottom:10px;border-width:thin;border-style:solid;border-color:grey;}

       .attackheadline {font-weight:bold;}
       .attacktitle {}
       .attacktitleFiltered {color:green;text-decoration:line-through;}
       .attacktitleUndefended {color:red;}
       .valueItem {}
       .valueItemFiltered {color:green;}
       .valueItemUndefended {color:red;text-decoration:line-through;}
       .valueItemDropDefence {text-decoration:line-through;}
       .repeatPartOfValueItem {color:brown;}

       .attackdescription    {}
       .propertyTitle {font-size:small;}
       .relatedgoals   {font-weight:bold;font-size:small;}
       .goalset {font-size:small;float:right;}
       .goalsetMissingValues {font-size:small;}

       .subgoallist   {position:relative;width:98%;padding-left:2%;}
       .rubber {position:relative;left:-5px;border-left-width:5px;border-left-style:solid;border-left-color:white;}
       .rubberReadjust {position:relative;left:5px;}
       .innersubgoallist   {padding-top:10px;}
       .attributelist {}
       .sanityCheck {background-color:red;}
       .defencePresent {}
       .defenceAbsent {text-decoration:line-through;}
       .attackheadline a {}
       a {color:blue;}
     </style>
    <title>
     <xsl:apply-templates select="$localizer/atm:attack_tree" mode="translate" />
     <xsl:text>: </xsl:text>
     <xsl:apply-templates select = "./at:attacknode" mode="showLocalizedTitleText" />
    </title>
   </head>
   <body>
     <xsl:apply-templates select="." mode="sanityCheck" /><hr />
     <xsl:apply-templates select="." mode="printLocalizedDescription" />
     <h1><xsl:apply-templates select="$localizer/atm:constraints" mode="translate" /></h1>
     <h2><xsl:apply-templates select="$localizer/atm:attacker" mode="translate" /></h2>
     <xsl:apply-templates select="./at:attacker" />
     <h2><xsl:apply-templates select="$localizer/atm:defender" mode="translate" /></h2>
     <xsl:apply-templates select="./at:defender" />
     <hr />
     <h1><xsl:apply-templates select="$localizer/atm:attack_tree" mode="translate" /></h1>
     <h2><xsl:apply-templates select="$localizer/atm:overview" mode="translate" /></h2>
     <xsl:apply-templates select="./at:attacknode" mode="overview" />
     <h2><xsl:apply-templates select="$localizer/atm:details" mode="translate" /></h2>
     <xsl:apply-templates select="./at:attacknode" />
     <xsl:if test="string($impressum)!=''">
       <div style="text-align:center;">
	 <a href="{$impressum}">Impressum</a>
       </div>
     </xsl:if>
   </body>
  </html>
</xsl:template>

<xsl:template match="at:defence" >
  <li xmlns='http://www.w3.org/1999/xhtml'>
    <xsl:apply-templates select="$theAttackTree" mode="getLocalizedDefence">
      <xsl:with-param name = "defenceName" select = "attribute::name" />
    </xsl:apply-templates>	  
  </li>
</xsl:template>

<xsl:template match="at:defender" >
  <p xmlns='http://www.w3.org/1999/xhtml'>
    <xsl:apply-templates select="." mode="printLocalizedDescription" />
  </p>
  <p xmlns='http://www.w3.org/1999/xhtml'>
    <xsl:apply-templates select="$localizer/atm:defences_not_applicable" mode="translate" />:
    <xsl:variable name = "defenceItems">
      <xsl:apply-templates select="./at:enabledDefences/at:defence[not(key('mapDefenceNamesToProperties', attribute::name))]">
	<xsl:sort select="child::text()" />
      </xsl:apply-templates>
    </xsl:variable>

    <xsl:choose>
      <xsl:when test = "string($defenceItems)" >
	<ul>
	  <xsl:copy-of select="$defenceItems"/>
	</ul>
      </xsl:when>
      <xsl:otherwise>
	<span style="font-style:italic;"><xsl:apply-templates select="$localizer/atm:none" mode="translate" /></span>
      </xsl:otherwise>
    </xsl:choose>
  </p>
  <p xmlns='http://www.w3.org/1999/xhtml'>
    <xsl:apply-templates select="$localizer/atm:attack_tree_of_defences" mode="translate" />:
    <xsl:variable name = "tree">
      <xsl:apply-templates select="$theAttackTree/at:attacknode" mode="defences" />
    </xsl:variable>
    <xsl:choose>
      <xsl:when test = "string($tree)" >
	<ul>
	  <xsl:copy-of select="$tree"/>
	</ul>
	(<xsl:apply-templates select="$localizer/atm:skip_defences" mode="translate" />)
      </xsl:when>
      <xsl:otherwise>
	<span style="font-style:italic;"><xsl:apply-templates select="$localizer/atm:none" mode="translate" /></span>
      </xsl:otherwise>
    </xsl:choose>
  </p>
</xsl:template>

<xsl:template match="at:filter" >
  <xsl:for-each select="./*">
    <xsl:sort select="local-name()" />
    <li xmlns='http://www.w3.org/1999/xhtml'>
      <xsl:variable name = "propertyNameSpec">
	<xsl:apply-templates select="$theAttackTree" mode="getLocalizedNameSpec">
	  <xsl:with-param name = "propertyName" select = "local-name()" />
	</xsl:apply-templates>	  
      </xsl:variable>

      <xsl:value-of select = "exslt:node-set($propertyNameSpec)/*/child::text()" />
      <xsl:text> </xsl:text>
      <xsl:variable name = "valueType" select = "local-name(key('mapPropertyNamesToTypeDeclaration',local-name())[1]/parent::*)" />
      <xsl:choose>
	<xsl:when test = "$valueType='rationalScale'" >
	    <xsl:text>&#8805;</xsl:text><!-- greater -->
	</xsl:when>
	<xsl:when test = "$valueType='probability'" >
	    <xsl:text>&#8804;</xsl:text><!-- less -->
	</xsl:when>
	<xsl:when test = "$valueType='boolean'" >
	  <xsl:apply-templates select="$localizer/atm:is_false" mode="translate" />
	</xsl:when>
	<xsl:when test = "$valueType='rationalScaleDefender'" >
	  <xsl:apply-templates select="$localizer/atm:wrong_application_of_filter" mode="translate" />
	</xsl:when>
	<xsl:otherwise>
	  <xsl:call-template name = "MissingTypeErrorMessage" >
	    <xsl:with-param name = "valueType" select = "$valueType" />
	  </xsl:call-template>
	</xsl:otherwise>
      </xsl:choose>
      <xsl:text> </xsl:text>

      <xsl:if test="$valueType!='boolean'">
	<xsl:value-of select = "exslt:node-set($propertyNameSpec)/*/prefix" />
	<xsl:call-template name = "printValue" >
	  <xsl:with-param name = "value" select = "." />
	  <xsl:with-param name = "valueType" select = "$valueType" />
	</xsl:call-template>
	<xsl:text> </xsl:text>
	<xsl:value-of select = "exslt:node-set($propertyNameSpec)/*/suffix" />
      </xsl:if>
    </li>
  </xsl:for-each>
</xsl:template>

<xsl:template match="at:attacker" >
  <p xmlns='http://www.w3.org/1999/xhtml'>
    <xsl:apply-templates select="." mode="printLocalizedDescription" />
  </p>
  <p xmlns='http://www.w3.org/1999/xhtml'>
    <span class="valueItemFiltered" style="font-style:italic;">
      <xsl:apply-templates select="$localizer/atm:excluded_attacks" mode="translate" />
    </span>
    <xsl:text>: </xsl:text>
    <xsl:variable name = "filterItems">
      <xsl:apply-templates select="./at:filter" />
    </xsl:variable>
    <xsl:choose>
      <xsl:when test = "string($filterItems)" >
	<ul>
	  <xsl:copy-of select="$filterItems"/>
	</ul>
      </xsl:when>
      <xsl:otherwise>
	<span style="font-style:italic;"><xsl:apply-templates select="$localizer/atm:none" mode="translate" /></span>
      </xsl:otherwise>
    </xsl:choose>
  </p>
</xsl:template>

<xsl:template match="at:attacktree" mode="showTitleProxy" >
  <xsl:param name = "attacknodeid" />

  <xsl:apply-templates select="key('mapIdsToAttacknodes',$attacknodeid)" mode="showTitle" />
</xsl:template>

<xsl:template match="at:attacktree" mode="getEnableDeclaration" >
  <xsl:param name = "defence" />

  <xsl:value-of select = "key('mapDefenceNamesToEnableDeclaration', $defence)" />
</xsl:template>

<xsl:template match="at:attacknode" mode="showAncestorTitleText">
  <xsl:if test="parent::at:attacknode">
    <xsl:apply-templates select="parent::at:attacknode" mode="showAncestorTitleText" />
    <xsl:text>  -  </xsl:text>
  </xsl:if>
  <xsl:apply-templates select="." mode="showLocalizedTitleText" />
</xsl:template>

<xsl:template match="at:attacknode" mode="showTitle">
  <span xmlns='http://www.w3.org/1999/xhtml'>
    <xsl:variable name = "values" >
      <xsl:apply-templates select = "." mode="getValues" />
    </xsl:variable>

    <xsl:choose>
      <xsl:when test = "exslt:node-set($values)/at:property[@name = 'effortlessAttack' and text() = 'true']" >
	<xsl:attribute name="class">attacktitleUndefended</xsl:attribute>
	<xsl:attribute name="title"><xsl:apply-templates select="$localizer/atm:effortless_attack" mode="translate" /></xsl:attribute>
      </xsl:when>
      <xsl:when test = "exslt:node-set($values)/at:property[@name = 'includedAttack' and text() = 'false']" >
	<xsl:attribute name="class">attacktitleFiltered</xsl:attribute>
	<xsl:attribute name="title"><xsl:apply-templates select="$localizer/atm:excluded_attack" mode="translate" /></xsl:attribute>
      </xsl:when>
      <xsl:otherwise>
	<xsl:attribute name="class">attacktitle</xsl:attribute>
      </xsl:otherwise>
    </xsl:choose>

    <xsl:apply-templates select = "." mode="showLocalizedTitleText" />
  </span>  
</xsl:template>

<xsl:template name="printValue">
  <xsl:param name = "value" />
  <xsl:param name = "valueType" />

  <xsl:choose>
    <!-- TODO: remove after testing that there is no need to handle this in a special case.
    <xsl:when test = "$value='Infinity'">
      <xsl:text>&#8734;</xsl:text>
    </xsl:when>
    -->
    <xsl:when test = "$valueType='probability'">
      <xsl:variable name = "valueInPercent" select = "$value * 100" />
      <xsl:choose>
	<xsl:when test = "string($valueInPercent)='NaN'">
	  <xsl:call-template name="printLocalizedNumber">
	    <xsl:with-param name="number" select="$value" />
	  </xsl:call-template>
	</xsl:when>
	<xsl:otherwise>
	  <xsl:call-template name="printLocalizedNumber">
	    <xsl:with-param name="number" select="$valueInPercent" />
	  </xsl:call-template>%
	</xsl:otherwise>
      </xsl:choose>   
      <xsl:if test="1 &lt; $value">	
	<xsl:text> </xsl:text><xsl:apply-templates select="$localizer/atm:greater_than_one" mode="translate" />
      </xsl:if>
    </xsl:when>
    <xsl:when test = "$valueType='boolean'">
      <xsl:choose>
	<xsl:when test = "$value='false'">
	  <xsl:apply-templates select="$localizer/atm:false" mode="translate" />
	</xsl:when>
	<xsl:otherwise>
	  <xsl:apply-templates select="$localizer/atm:true" mode="translate" />
	</xsl:otherwise>
      </xsl:choose>   
    </xsl:when>
    <xsl:otherwise>
      <xsl:call-template name="printLocalizedNumber">
	<xsl:with-param name="number" select="$value" />
      </xsl:call-template>
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>

<xsl:template match="at:property">
  <xsl:param name = "effortless" select = "'false'" />

  <li xmlns='http://www.w3.org/1999/xhtml'>
  <xsl:variable name = "shouldFilter">
    <xsl:apply-templates select="$theAttackTree" mode="shouldValueBeFiltered">
      <xsl:with-param name = "value" select = "child::text()" />
      <xsl:with-param name = "propertyName" select = "attribute::name" />
    </xsl:apply-templates>
  </xsl:variable>

  <xsl:variable name = "valueType">
    <xsl:apply-templates select="$theAttackTree" mode="getValueType">
      <xsl:with-param name = "propertyName" select = "attribute::name" />
    </xsl:apply-templates>
  </xsl:variable>
  
  <xsl:variable name = "enableDeclaration">
    <xsl:apply-templates select="$theAttackTree" mode="getEnableDeclaration">
      <xsl:with-param name = "defence" select = "attribute::defence" />
    </xsl:apply-templates>
  </xsl:variable>
  <xsl:choose>    
    <xsl:when test = "attribute::no_defence or ($valueType ='rationalScaleDefender' and string($enableDeclaration))" >
      <xsl:attribute name="class">valueItemUndefended</xsl:attribute>
      <xsl:attribute name="title"><xsl:apply-templates select="$localizer/atm:no_defence" mode="translate" />
      <xsl:if test="not(attribute::defence)">
	<xsl:text> </xsl:text><xsl:apply-templates select="$localizer/atm:no_defence_create_attribute" mode="translate" />
      </xsl:if>
      </xsl:attribute>
    </xsl:when>
    <xsl:when test = "$valueType ='rationalScaleDefender' and $effortless = 'true'" >
      <xsl:attribute name="class">valueItemDropDefence</xsl:attribute>
      <xsl:attribute name="title"><xsl:apply-templates select="$localizer/atm:defence_would_be_in_vain" mode="translate" />
      </xsl:attribute>
    </xsl:when>
    <xsl:when test = "$shouldFilter = 'true'" >
      <xsl:attribute name="class">valueItemFiltered</xsl:attribute>
      <xsl:attribute name="title"><xsl:apply-templates select="$localizer/atm:deterrence" mode="translate" />
      <xsl:text> </xsl:text>
      <xsl:if test="child::text() != 'Infinity'">
	<xsl:apply-templates select="$localizer/atm:deterrence_hint" mode="translate" />
      </xsl:if>
      </xsl:attribute>
    </xsl:when>
    <xsl:otherwise>
      <xsl:attribute name="class">valueItem</xsl:attribute>
    </xsl:otherwise>
  </xsl:choose>
  <xsl:variable name = "propertyNameSpec">
    <xsl:apply-templates select="$theAttackTree" mode="getLocalizedNameSpec">
      <xsl:with-param name = "propertyName" select = "attribute::name" />
    </xsl:apply-templates>	  
  </xsl:variable>
  <xsl:value-of select = "exslt:node-set($propertyNameSpec)/*/child::text()" />
  <xsl:text>: </xsl:text>
  <xsl:value-of select = "exslt:node-set($propertyNameSpec)/*/prefix" />
  <xsl:call-template name = "printValue" >
    <xsl:with-param name = "value" select = "text()" />
    <xsl:with-param name = "valueType" select = "$valueType" />
  </xsl:call-template>
  <xsl:text> </xsl:text>
  <xsl:value-of select = "exslt:node-set($propertyNameSpec)/*/suffix" />

  <xsl:if test = "attribute::previous_value" >
    <span class="repeatPartOfValueItem">
      <xsl:text> (</xsl:text>
      <xsl:apply-templates select="$localizer/atm:repetition" mode="translate" />
      <xsl:text> </xsl:text>
      <xsl:value-of select = "exslt:node-set($propertyNameSpec)/*/prefix" />
      <xsl:call-template name = "printValue" >
	<xsl:with-param name = "value" select = "attribute::previous_value" />
	<xsl:with-param name = "valueType" select = "'probability'" />
      </xsl:call-template>
      <xsl:text> </xsl:text>
      <xsl:value-of select = "exslt:node-set($propertyNameSpec)/*/suffix" />      
      <xsl:text>)</xsl:text>
    </span>
  </xsl:if>
  
  <xsl:if test="attribute::filled_in_default">
    <xsl:text> </xsl:text><i><xsl:apply-templates select="$localizer/atm:warn_default" mode="translate" /></i>
  </xsl:if>
  <xsl:if test="attribute::defence">
    <xsl:text> </xsl:text><xsl:apply-templates select="$localizer/atm:for_defence" mode="translate" /><xsl:text>: </xsl:text>
    <xsl:apply-templates select="$theAttackTree" mode="getLocalizedDefence">
      <xsl:with-param name = "defenceName" select = "attribute::defence" />
    </xsl:apply-templates>	  
  </xsl:if>
  <span class="goalset">
    <xsl:apply-templates select="child::origin[not(@self)]" />
  </span>  
  <xsl:if test="$valueType != 'rationalScaleDefender' and child::missing_value_from_subgoal">
    <span class="goalsetMissingValues">
      <xsl:apply-templates select="child::missing_value_from_subgoal" />
    </span>
  </xsl:if>
</li>
</xsl:template>

<xsl:template match="missing_value_from_subgoal">
  <xsl:if test="position() = 1">
    <xsl:text> (</xsl:text>
    <span xmlns='http://www.w3.org/1999/xhtml'>
      <xsl:attribute name="title"><xsl:apply-templates select="$localizer/atm:missing_value_hint" mode="translate" /></xsl:attribute>
      <xsl:apply-templates select="$localizer/atm:missing_value" mode="translate" />
    </span>
    <xsl:text> </xsl:text>
  </xsl:if>
  <a xmlns='http://www.w3.org/1999/xhtml' href="#{attribute::ref}">
    <xsl:apply-templates select="$theAttackTree" mode="showTitleProxy">
      <xsl:with-param name = "attacknodeid" select="attribute::ref" />
    </xsl:apply-templates>
  </a>
  <xsl:choose>
    <xsl:when test ="position() = last()">
      <xsl:text>)</xsl:text>
    </xsl:when>
    <xsl:otherwise>
      <xsl:text>, </xsl:text>
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>

<xsl:template match="origin">
  <xsl:if test="position() = 1">
    <xsl:text> (</xsl:text>
    <span xmlns='http://www.w3.org/1999/xhtml'>
      <xsl:attribute name="title"><xsl:apply-templates select="$localizer/atm:by_hint" mode="translate" /></xsl:attribute>
      <xsl:apply-templates select="$localizer/atm:by" mode="translate" />
    </span>
    <xsl:text> </xsl:text>
  </xsl:if>
  <a xmlns='http://www.w3.org/1999/xhtml' href="#{attribute::ref}">
    <xsl:apply-templates select="$theAttackTree" mode="showTitleProxy">
      <xsl:with-param name = "attacknodeid" select="attribute::ref" />
    </xsl:apply-templates>
  </a>
  <xsl:choose>
    <xsl:when test ="position() = last()">
      <xsl:text>)</xsl:text>
    </xsl:when>
    <xsl:otherwise>
      <xsl:text>, </xsl:text>
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>

<xsl:template match="at:attacknode" mode="defences">
  <xsl:variable name = "defencesRecursive">
    <xsl:variable name = "defences">
      <xsl:for-each select="./at:property[@defence]">
	<xsl:variable name = "valueType">
	  <xsl:apply-templates select="$theAttackTree" mode="getValueType">
	    <xsl:with-param name = "propertyName" select = "attribute::name" />
	  </xsl:apply-templates>
	</xsl:variable>
	<xsl:if test="$valueType='rationalScaleDefender'">
	  <span xmlns='http://www.w3.org/1999/xhtml'>
	    <xsl:attribute name="class">
	      <xsl:choose>
		<xsl:when test = "key('mapDefenceNamesToEnableDeclaration', attribute::defence)" >
		  <xsl:text>defencePresent</xsl:text>
		</xsl:when>
		<xsl:otherwise>
		  <xsl:text>defenceAbsent</xsl:text>
		</xsl:otherwise>	
	      </xsl:choose>
	    </xsl:attribute>
	    <xsl:apply-templates select="$theAttackTree" mode="getLocalizedDefence">
	      <xsl:with-param name = "defenceName" select = "attribute::defence" />
	    </xsl:apply-templates>	  
	  </span>
	  <xsl:if test="position()!=last()">
	    <xsl:text>; </xsl:text>
	  </xsl:if>
	</xsl:if>
      </xsl:for-each>
    </xsl:variable>
    <xsl:choose>
      <xsl:when test="string($defences)!=''">
	<li xmlns='http://www.w3.org/1999/xhtml'>
	  <xsl:copy-of select="$defences" />
	  <ul>
	    <xsl:apply-templates select="child::at:attacknode" mode="defences" />
	  </ul>
	</li>
      </xsl:when>
      <xsl:otherwise>
	<xsl:apply-templates select="child::at:attacknode" mode="defences" />      
      </xsl:otherwise>
    </xsl:choose>
  </xsl:variable>

  <xsl:variable name = "values" >
    <xsl:apply-templates select = "." mode="getValues" />
  </xsl:variable>
  <xsl:choose>
    <xsl:when test = "exslt:node-set($values)/at:property[@name = 'effortlessAttack' and text() = 'true']" >
      <li xmlns='http://www.w3.org/1999/xhtml'>
	<a href="#{generate-id()}">
	  <xsl:apply-templates select = "." mode="showTitle" />
	</a>
	<ul>
	  <xsl:copy-of select="$defencesRecursive" />
	</ul>
      </li>
    </xsl:when>
    <xsl:otherwise>
      <xsl:copy-of select="$defencesRecursive" />
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>

<xsl:template match="at:attacknode" mode="getClass">
  <xsl:choose>
    <xsl:when test = "attribute::type = 'or'" >
      <xsl:text>attacksubtreeOr</xsl:text>
    </xsl:when>
    <xsl:otherwise>
      <xsl:text>attacksubtreeAnd</xsl:text>
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>

<xsl:template match="at:attacknode" mode="overview">
  <xsl:variable name="class">
    <xsl:apply-templates select="." mode="getClass" />
  </xsl:variable>
  <xsl:variable name="titleText">
    <xsl:apply-templates select="." mode="showAncestorTitleText" />
  </xsl:variable>
  <div xmlns='http://www.w3.org/1999/xhtml'>
    <div id="overview_{generate-id()}" title=" ">
      <xsl:choose>	    
	<xsl:when test = "child::at:attacknode" >
	  <xsl:attribute name="class">attacknode</xsl:attribute>
	</xsl:when>
	<xsl:otherwise>
	  <xsl:attribute name="class">attacknodeWithoutChildren</xsl:attribute>
	</xsl:otherwise>
      </xsl:choose>
      <div class="attackheadline">
	<a href="#{generate-id()}">
	  <xsl:apply-templates select="." mode="showTitle" />
	</a>
	<xsl:if test="attribute::type='or' and not(child::at:attacknode)">
	  <xsl:text> </xsl:text><xsl:apply-templates select="$localizer/atm:or_node_leaf" mode="translate" />
	</xsl:if>
      </div>
    </div>
    <xsl:if test="child::at:attacknode">
      <div>
	<xsl:if test="position() = last()">
	  <xsl:attribute name="class">rubber</xsl:attribute>
	</xsl:if>
	<div>
	  <xsl:if test="position() = last()">
	    <xsl:attribute name="class">rubberReadjust</xsl:attribute>
	  </xsl:if>	  
	  <div>
	    <xsl:if test="parent::at:attacknode">
	      <xsl:attribute name="class">subgoallist</xsl:attribute>
	    </xsl:if>
	    <div class="{$class}" title="{$titleText}">
	      <div class="innersubgoallist">
		<xsl:apply-templates select="child::at:attacknode" mode="overview"/>
	      </div>
	    </div>
	  </div>
	</div>
      </div>
    </xsl:if>      
  </div>
</xsl:template>

<xsl:template match="at:attacknode">
  <xsl:variable name="class">
    <xsl:apply-templates select="." mode="getClass" />
  </xsl:variable>
  <xsl:variable name="titleText">
    <xsl:apply-templates select="." mode="showAncestorTitleText" />
  </xsl:variable>
  <div xmlns='http://www.w3.org/1999/xhtml'>
    <div id="{generate-id()}" title=" ">
      <xsl:choose>	    
	<xsl:when test = "child::at:attacknode" >
	  <xsl:attribute name="class">attacknode</xsl:attribute>
	</xsl:when>
	<xsl:otherwise>
	  <xsl:attribute name="class">attacknodeWithoutChildren</xsl:attribute>
	</xsl:otherwise>
      </xsl:choose>      
      <div class="attackheadline">
	<a href="#overview_{generate-id()}">
	  <xsl:apply-templates select="." mode="showTitle" />
	</a>
	<xsl:if test="attribute::type='or' and not(child::at:attacknode)">
	  <xsl:text> </xsl:text><xsl:apply-templates select="$localizer/atm:or_node_leaf" mode="translate" />
	</xsl:if>
	<div class="relatedgoals" style="float:right;">
	  <xsl:if test="parent::at:attacknode">
	    <xsl:choose>	    
	      <xsl:when test = "parent::at:attacknode[@type = 'or']" ><xsl:apply-templates select="$localizer/atm:sufficient" mode="translate" /></xsl:when>
	      <xsl:when test = "parent::at:attacknode[@type = 'and']" ><xsl:apply-templates select="$localizer/atm:necessary" mode="translate" /></xsl:when>
	      <xsl:otherwise><xsl:apply-templates select="$localizer/atm:attacknode_without_type" mode="translate" /></xsl:otherwise>
	    </xsl:choose>   
	    <xsl:text> </xsl:text>
	    <xsl:apply-templates select="$localizer/atm:for_end" mode="translate" />:
	    <xsl:text> </xsl:text><a href="#{generate-id(parent::at:attacknode)}">
	    <xsl:apply-templates select="parent::at:attacknode" mode="showTitle" />
	  </a>
	  </xsl:if>
	</div>	
      </div>
      <xsl:variable name = "localizedDescription">
	<xsl:apply-templates select="." mode="printLocalizedDescription" />
      </xsl:variable>
      <xsl:if test="string($localizedDescription)">
	<div class="attackdescription">
	  <p>
	    <xsl:value-of select="$localizedDescription" />
	  </p>
	</div>
      </xsl:if>
      <div class="attributelist">
	<span class="propertyTitle">
	  <xsl:apply-templates select="$localizer/atm:properties" mode="translate" />:
	</span>
	<xsl:variable name = "values" >
	  <xsl:apply-templates select = "." mode="getValues" />
	</xsl:variable>  

	<!-- <xsl:copy-of select = "$values" /> -->

	<ul>
	  <xsl:variable name = "currentAttackNode" select="." />

	  <xsl:apply-templates select = "exslt:node-set($values)/at:property[@mentioned]"><!-- -->
	    <xsl:with-param name = "effortless" select = "exslt:node-set($values)/at:property[@name = 'effortlessAttack']/child::text()" />
	    <xsl:sort select="attribute::name" />
	  </xsl:apply-templates>
	</ul>
	<xsl:if test="child::at:attacknode and child::at:property">
	  <span class="propertyTitle">
	    <xsl:apply-templates select="$localizer/atm:direct_properties" mode="translate" />:
	  </span>
	  <ul>
	    <xsl:apply-templates select = "child::at:property" >
	      <xsl:sort select="attribute::name" />
	    </xsl:apply-templates>
	  </ul>
	</xsl:if>
      </div>
      <xsl:if test="child::at:attacknode">
	  <div class="relatedgoals">
	  <xsl:apply-templates select="$localizer/atm:means" mode="translate" />:<xsl:text> </xsl:text>
	  <xsl:variable name = "nodeType" select = "attribute::type" />
	  <xsl:for-each select="child::at:attacknode">
	      <xsl:choose>
		<xsl:when test="position()=last()">
		  <xsl:text> </xsl:text>
		  <xsl:choose>
		    <xsl:when test="$nodeType='or'"><xsl:apply-templates select="$localizer/atm:or" mode="translate" /></xsl:when>
		    <xsl:when test="$nodeType='and'"><xsl:apply-templates select="$localizer/atm:and" mode="translate" /></xsl:when>
		    <xsl:otherwise><xsl:value-of select="$nodeType" /></xsl:otherwise>
		  </xsl:choose>   
		  <xsl:text> </xsl:text>
		</xsl:when>
		<xsl:otherwise>
		  <xsl:if test="not(position()=1)">
		    <xsl:text>, </xsl:text>
		  </xsl:if>
		</xsl:otherwise>
	      </xsl:choose>
	    <a href="#{generate-id()}">
	      <xsl:apply-templates select="." mode="showTitle" />
	    </a>
	  </xsl:for-each>
	  </div>
      </xsl:if>
    </div>
    <xsl:if test="child::at:attacknode">
      <div>
	<xsl:if test="position() = last()">
	  <xsl:attribute name="class">rubber</xsl:attribute>
	</xsl:if>
	<div>
	  <xsl:if test="position() = last()">
	    <xsl:attribute name="class">rubberReadjust</xsl:attribute>
	  </xsl:if>	  
	  <div>	  
	    <xsl:if test="parent::at:attacknode">
	      <xsl:attribute name="class">subgoallist</xsl:attribute>
	    </xsl:if>
	    <div class="{$class}" title="{$titleText}">
	      <div class="innersubgoallist">
		<xsl:apply-templates select="child::at:attacknode"/>
	      </div>
	    </div>
	  </div>
	</div>
      </div>
    </xsl:if>
    </div>
</xsl:template>
</xsl:stylesheet>
