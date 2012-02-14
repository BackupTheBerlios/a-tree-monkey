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

<xsl:template match="at:attacktree" mode="getValueType" >
  <xsl:param name = "propertyName" />

  <xsl:value-of select = "local-name(key('mapPropertyNamesToTypeDeclaration',$propertyName)[1]/parent::*)" />
</xsl:template>

<xsl:template match="at:attacktree" mode="shouldValueBeFiltered" >
  <xsl:param name = "value" />
  <xsl:param name = "propertyName" />

  <xsl:call-template name = "shouldValueBeFiltered" >
    <xsl:with-param name = "value" select = "$value" />
    <xsl:with-param name = "propertyName" select = "$propertyName" />
  </xsl:call-template>
</xsl:template>

<xsl:template name = "shouldValueBeFiltered" >
  <xsl:param name = "value" />
  <xsl:param name = "propertyName" />

  <xsl:variable name = "valueType">
    <xsl:apply-templates select="$theAttackTree" mode="getValueType">
      <xsl:with-param name = "propertyName" select = "$propertyName" />
    </xsl:apply-templates>
  </xsl:variable>

  <xsl:choose>
    <xsl:when test = "$value='Infinity'" >
      <xsl:text>true</xsl:text>
    </xsl:when>
    <xsl:when test = "$value" >
      <xsl:variable name = "limit" select = "key('mapPropertyNamesToFilterDeclaration',$propertyName)[1]" />
      <xsl:if test = "$limit" >
	<xsl:choose>
	  <xsl:when test = "$valueType='rationalScale'" >
	    <xsl:if test="string($limit) &lt;= $value">
	      <xsl:text>true</xsl:text>
	    </xsl:if>
	  </xsl:when>
	  <xsl:when test = "$valueType='probability'" >
	    <xsl:if test="$value &lt;= string($limit)">
	      <xsl:text>true</xsl:text>
	    </xsl:if>
	  </xsl:when>
	  <xsl:when test = "$valueType='boolean'" >
	    <xsl:if test="$value = 'false'">
	      <xsl:text>true</xsl:text>
	    </xsl:if>
	  </xsl:when>
	  <xsl:when test = "$valueType='rationalScaleDefender'" >
	    <!-- never filter the defenders values -->
	  </xsl:when>
	  <xsl:otherwise>
	    <xsl:call-template name = "MissingTypeErrorMessage" >
	      <xsl:with-param name = "valueType" select = "$valueType" />
	    </xsl:call-template>
	  </xsl:otherwise>
	</xsl:choose>
      </xsl:if>
    </xsl:when>
    <xsl:otherwise>
      <!-- We tolerate missing values, and so we return: false -->
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>

<xsl:template name = "applyAttributeFilter" >
  <xsl:param name = "properties" />
  <xsl:param name = "nodetype" />

  <xsl:variable name="filteredProperties" select = "exslt:node-set($properties)/at:property[@name = 'includedAttack' and text() = 'false']" />
  <xsl:choose>
    <xsl:when test = "$filteredProperties and $nodetype != 'and'" ><!-- And-nodes will get filtered again anyways: Show meaningful results in that case. -->
      <!-- <xsl:copy-of select="exslt:node-set($properties)/attacknodePointer" /> -->
      <xsl:if test="exslt:node-set($properties)/attacknodePointer">
	<attacknodePointer />
      </xsl:if>
      <xsl:for-each select="exslt:node-set($properties)/at:property">
	<xsl:variable name = "propertyName" select="attribute::name"/>
	<xsl:variable name = "property" select="."/>
	<at:property name="{attribute::name}">
	  <xsl:if test="$property/attribute::mentioned">
	    <xsl:attribute name="mentioned"></xsl:attribute>
	  </xsl:if>
	  <xsl:if test="$property/attribute::mentionedInAllSubgoals">
	    <xsl:attribute name="mentionedInAllSubgoals"></xsl:attribute>
	  </xsl:if>
	  <xsl:variable name="valueType">
	    <xsl:apply-templates select="$theAttackTree" mode="getValueType">
	      <xsl:with-param name = "propertyName" select = "attribute::name" />
	    </xsl:apply-templates>
	  </xsl:variable>
	  <xsl:choose>
	    <xsl:when test = "$valueType='rationalScaleDefender'" >
	      <xsl:value-of select="$property" />
	    </xsl:when>
	    <xsl:when test = "$valueType='rationalScale'" >
	      <xsl:text>Infinity</xsl:text>
	    </xsl:when>
	    <xsl:when test = "$valueType='probability'" >
	      <xsl:text>0</xsl:text>
	    </xsl:when>
	    <xsl:when test = "$valueType='boolean'" >
	      <xsl:text>false</xsl:text>
	    </xsl:when>
	    <xsl:otherwise>
	      <xsl:call-template name = "MissingTypeErrorMessage" >
		<xsl:with-param name = "valueType" select = "$valueType" />
	      </xsl:call-template>
	    </xsl:otherwise>
	  </xsl:choose>
	</at:property>
      </xsl:for-each>
    </xsl:when>
    <xsl:otherwise>
      <xsl:copy-of select="$properties" />
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>

<xsl:template name = "applyAttributeNoDefence" >
  <xsl:param name = "properties" />
  <xsl:param name = "nodetype" />
  
  <xsl:variable name="noDefenceProperties" select = "exslt:node-set($properties)/at:property[@name = 'effortlessAttack' and text() = 'true']" />

  <xsl:choose>
    <xsl:when test = "$noDefenceProperties" >
      <xsl:copy-of select="exslt:node-set($properties)/attacknodePointer" />
      <xsl:for-each select="exslt:node-set($properties)/at:property">
	<xsl:variable name = "property" select="."/>
	<at:property name="{attribute::name}">
	  <xsl:if test="attribute::mentioned">
	    <xsl:attribute name="mentioned"></xsl:attribute>
	  </xsl:if>
	  <xsl:if test="attribute::mentionedInAllSubgoals">
	    <xsl:attribute name="mentionedInAllSubgoals"></xsl:attribute>
	  </xsl:if>
	  <xsl:variable name="valueType">
	    <xsl:apply-templates select="$theAttackTree" mode="getValueType">
	      <xsl:with-param name = "propertyName" select = "attribute::name" />
	    </xsl:apply-templates>
	  </xsl:variable>
	  <xsl:choose>
	    <xsl:when test = "$valueType='rationalScale' or $valueType='rationalScaleDefender'" >
	      <xsl:text>0</xsl:text>
	    </xsl:when>
	    <xsl:when test = "$valueType='probability'" >
	      <xsl:text>1</xsl:text>
	    </xsl:when>
	    <xsl:when test = "$valueType='boolean'" >
	      <xsl:text>true</xsl:text>
	    </xsl:when>
	    <xsl:otherwise>
	      <xsl:call-template name = "MissingTypeErrorMessage" >
		<xsl:with-param name = "valueType" select = "$valueType" />
	      </xsl:call-template>
	    </xsl:otherwise>
	  </xsl:choose>
	  <xsl:copy-of select="child::origin" />
	  <xsl:copy-of select="child::missing_value_from_subgoal" />
	</at:property>
      </xsl:for-each>
    </xsl:when>
    <xsl:otherwise>
      <xsl:copy-of select="$properties" />
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>

<xsl:template name = "propertyOperator" >
  <xsl:param name = "pFunc" />
  <xsl:param name = "propertiesArg1" />
  <xsl:param name = "propertiesArg2" />
  <xsl:param name = "attacknode" />

  <xsl:for-each select="exslt:node-set($propertiesArg1)/at:property">
    <xsl:variable name = "propertyName" select="attribute::name"/>
    <xsl:variable name = "arg1" select = "." />
    <xsl:variable name = "arg2" select = "exslt:node-set($propertiesArg2)/at:property[@name = $propertyName]" />

    <xsl:if test = "string($arg1/child::text())!='' or string($arg2/child::text())!=''" >
      <xsl:variable name = "value">
	<xsl:apply-templates select = "$pFunc[1]" >
	  <xsl:with-param name = "arg1" select = "$arg1/child::text()" />
	  <xsl:with-param name = "arg2" select = "$arg2/child::text()" />
	  <xsl:with-param name = "valueType">
	    <xsl:apply-templates select="$theAttackTree" mode="getValueType">
	      <xsl:with-param name = "propertyName" select = "$propertyName" />
	    </xsl:apply-templates>
	  </xsl:with-param>
	</xsl:apply-templates>
      </xsl:variable>
      <at:property source="calculation" name="{attribute::name}">
	<xsl:if test="$arg1/attribute::mentioned or $arg2/attribute::mentioned">
	  <xsl:attribute name="mentioned"></xsl:attribute>
	</xsl:if>
	<xsl:if test="$arg1/attribute::mentionedInAllSubgoals and $arg2/attribute::mentioned">
	  <xsl:attribute name="mentionedInAllSubgoals"></xsl:attribute>
	</xsl:if>
	<xsl:value-of select="$value" />
	<xsl:choose>
	  <xsl:when test="$attacknode/attribute::type = 'or'">
	    <xsl:variable name = "originsTmp" >
	      <xsl:if test="$arg1/attribute::mentioned and string($value) = $arg1/child::text()">
		<xsl:for-each select="$arg1/origin[@ref != generate-id($attacknode)]">
		  <origin ref="{attribute::ref}" />
		</xsl:for-each>
	      </xsl:if>
	      <xsl:if test="$arg2/attribute::mentioned and string($value) = $arg2/child::text()">
		<xsl:for-each select="$arg2/origin[@ref != generate-id($attacknode)]">
		  <origin ref="{attribute::ref}" />
		</xsl:for-each>
	      </xsl:if>	
	    </xsl:variable>
	    <xsl:choose>
	      <xsl:when test="not($originsTmp)">
		<origin ref="{generate-id($attacknode)}" self="true" />	
	      </xsl:when>	
	      <xsl:otherwise>
		<xsl:copy-of select="$originsTmp" />
	      </xsl:otherwise>
	    </xsl:choose>
	  </xsl:when>
	  <xsl:otherwise>
	    <origin ref="{generate-id($attacknode)}" self="true" />
	  </xsl:otherwise>
	</xsl:choose>

	<xsl:variable name="attacknodePointer1" select="exslt:node-set($propertiesArg1)/attacknodePointer" />
	<xsl:choose> 
	  <xsl:when test="$attacknodePointer1">
	    <xsl:if test="not($arg1/attribute::mentioned) and $attacknodePointer1/attribute::ref">
	      <missing_value_from_subgoal ref="{$attacknodePointer1/attribute::ref}" />
	    </xsl:if>	    
	  </xsl:when>
	  <xsl:otherwise>
	    <xsl:copy-of select="$arg1/missing_value_from_subgoal" />
	  </xsl:otherwise>
	</xsl:choose>

	<xsl:variable name="attacknodePointer2" select="exslt:node-set($propertiesArg2)/attacknodePointer" />
	<xsl:choose> 
	  <xsl:when test="$attacknodePointer2">
	    <xsl:if test="not($arg2/attribute::mentioned) and $attacknodePointer2/attribute::ref">
	      <missing_value_from_subgoal ref="{$attacknodePointer2/attribute::ref}" />
	    </xsl:if>	    
	  </xsl:when>
	  <xsl:otherwise>
	    <xsl:copy-of select="$arg2/missing_value_from_subgoal" />
	  </xsl:otherwise>
	</xsl:choose>

      </at:property>
    </xsl:if>
  </xsl:for-each>  
</xsl:template>

<xsl:template name = "foldlValuesOf" >
  <xsl:param name = "pFunc" />
  <xsl:param name = "pA0" />
  <xsl:param name = "pList" />
  <xsl:param name = "attacknode" />

  <xsl:choose>
    <xsl:when test = "not($pList)" >
      <xsl:copy-of select = "$pA0" /> <!-- Do not use '$pA0prep', in order to show meaningful results in the user interface!  -->
    </xsl:when>    
    <xsl:otherwise>
      <xsl:variable name = "pList1ValueTmp" >
	<xsl:call-template name="applyAttributeNoDefence">
	  <xsl:with-param name = "properties">
	    <xsl:apply-templates select = "$pList[1]" mode="getValues" />
	  </xsl:with-param>
	  <xsl:with-param name = "nodetype" select = "$attacknode/attribute::type" />
	</xsl:call-template>
      </xsl:variable>

      <xsl:variable name = "pA0prepTmp" >
	<xsl:call-template name="applyAttributeNoDefence">
	  <xsl:with-param name = "properties" select = "$pA0" />
	  <xsl:with-param name = "nodetype" select = "$attacknode/attribute::type" />
	</xsl:call-template>	  
      </xsl:variable>

      <xsl:variable name = "differentFilterStatusInOrNode" >
	<xsl:if test="$attacknode/attribute::type='or' and exslt:node-set($pList1ValueTmp)/at:property[@name = 'includedAttack'] != exslt:node-set($pA0prepTmp)/at:property[@name = 'includedAttack']">
	  <xsl:text>true</xsl:text>
	</xsl:if>
      </xsl:variable>

      <xsl:call-template name = "foldlValuesOf" >
	<xsl:with-param name = "pFunc" select = "$pFunc" />
	<xsl:with-param name = "pList" select = "$pList[position() &gt; 1]" />
	<xsl:with-param name = "pA0">
	  <xsl:call-template name="propertyOperator">
	    <xsl:with-param name = "pFunc" select="$pFunc" />
	    <xsl:with-param name = "propertiesArg1">
	      <xsl:choose>
		<xsl:when test="$differentFilterStatusInOrNode='true'">
		  <xsl:call-template name="applyAttributeFilter">
		    <xsl:with-param name = "properties">
		      <xsl:copy-of select="$pA0prepTmp" />
		    </xsl:with-param>
		    <xsl:with-param name = "nodetype" select = "$attacknode/attribute::type" />
		  </xsl:call-template>	    
		</xsl:when>
		<xsl:otherwise>
		  <xsl:copy-of select="$pA0prepTmp" />
		</xsl:otherwise>
	      </xsl:choose>	      
	    </xsl:with-param>
	    <xsl:with-param name = "propertiesArg2">
	      <xsl:choose>
		<xsl:when test="$differentFilterStatusInOrNode='true'">
		  <xsl:call-template name="applyAttributeFilter">
		    <xsl:with-param name = "properties">
		      <xsl:copy-of select="$pList1ValueTmp" />
		    </xsl:with-param>
		    <xsl:with-param name = "nodetype" select = "$attacknode/attribute::type" />
		  </xsl:call-template>
		</xsl:when>
		<xsl:otherwise>
		  <xsl:copy-of select="$pList1ValueTmp" />
		</xsl:otherwise>
	      </xsl:choose>
	    </xsl:with-param>
	    <xsl:with-param name = "attacknode" select = "$attacknode" />
	  </xsl:call-template>
	</xsl:with-param>
	<xsl:with-param name = "attacknode" select = "$attacknode" />
      </xsl:call-template>
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>

<some-subgoal-needed-func:some-subgoal-needed-func/>
<xsl:template name = "min" match = "*[namespace-uri() = 'some-subgoal-needed-func']" >
  <xsl:param name = "arg1" />
  <xsl:param name = "arg2" />
  <xsl:param name = "valueType" />

  <xsl:variable name = "a1" select="string($arg1)" />
  <xsl:variable name = "a2" select="string($arg2)" />

  <xsl:choose>
    <xsl:when test = "$a2='' or $a2='Infinity'" ><xsl:copy-of select = "$a1" /></xsl:when>
    <xsl:when test = "$a1='' or $a1='Infinity'" ><xsl:copy-of select = "$a2" /></xsl:when>
    <xsl:otherwise>
      <xsl:choose>
	<xsl:when test = "$valueType='rationalScale'" >
	  <xsl:choose>
	    <xsl:when test = "$a1 &lt; $a2" ><xsl:copy-of select = "$a1" /></xsl:when>
	    <xsl:otherwise><xsl:copy-of select = "$a2" /></xsl:otherwise>
	  </xsl:choose>   
	</xsl:when>
	<xsl:when test = "$valueType='rationalScaleDefender'" >
	  <xsl:value-of select = "$a1 + $a2" />
	</xsl:when>
	<xsl:when test = "$valueType='probability'" >
	  <xsl:choose>
	    <xsl:when test = "$a1 &lt; $a2" ><xsl:copy-of select = "$a2" /></xsl:when>
	    <xsl:otherwise><xsl:copy-of select = "$a1" /></xsl:otherwise>
	  </xsl:choose>   
	</xsl:when>
	<xsl:when test = "$valueType='boolean'" >
	  <xsl:choose>
	    <xsl:when test = "$a1='false'" ><xsl:copy-of select = "$a2" /></xsl:when>
	    <xsl:otherwise><xsl:text>true</xsl:text></xsl:otherwise>
	  </xsl:choose>   
	</xsl:when>
	<xsl:otherwise>
	  <xsl:call-template name = "MissingTypeErrorMessage" >
	    <xsl:with-param name = "valueType" select = "$valueType" />
	  </xsl:call-template>
	</xsl:otherwise>
      </xsl:choose>   
    </xsl:otherwise>
  </xsl:choose>   
</xsl:template>

<all-subgoals-needed-func:all-subgoals-needed-func/>
<xsl:template name = "add" match = "*[namespace-uri() = 'all-subgoals-needed-func']" >
  <xsl:param name = "arg1" />
  <xsl:param name = "arg2" />
  <xsl:param name = "valueType" />

  <xsl:variable name = "a1" select="string($arg1)" />
  <xsl:variable name = "a2" select="string($arg2)" />

  <xsl:choose>
    <xsl:when test = "$a1='' or $a2=''" >
      <xsl:choose>
	<xsl:when test = "$valueType='rationalScale' or $valueType='rationalScaleDefender'" >
	  <xsl:text>Infinity</xsl:text>
	</xsl:when>
	<xsl:when test = "$valueType='probability'" >
	  <xsl:text>0</xsl:text>
	</xsl:when>
	<xsl:when test = "$valueType='boolean'" >
	  <xsl:text>false</xsl:text>
	</xsl:when>
	<xsl:otherwise>
	  <xsl:call-template name = "MissingTypeErrorMessage" >
	    <xsl:with-param name = "valueType" select = "$valueType" />
	  </xsl:call-template>
	</xsl:otherwise>
      </xsl:choose>
    </xsl:when>
    <xsl:otherwise>
      <xsl:variable name = "result" >
	<xsl:choose>
	  <xsl:when test = "$valueType='rationalScale' or $valueType='rationalScaleDefender'" >
	    <xsl:choose>
	      <xsl:when test = "$a1='Infinity' or $a2='Infinity'" >
		<xsl:text>Infinity</xsl:text>
	      </xsl:when>
	      <xsl:otherwise>
		<xsl:value-of select = "$a1 + $a2" />
	      </xsl:otherwise>
	    </xsl:choose>
	  </xsl:when>
	  <xsl:when test = "$valueType='probability'" >
	    <xsl:value-of select = "$a1 * $a2" />
	  </xsl:when>
	  <xsl:when test = "$valueType='boolean'" >
	    <xsl:choose>
	      <xsl:when test = "$a1='false' or $a2='false'" >
		<xsl:text>false</xsl:text>
	      </xsl:when>
	      <xsl:otherwise>
		<xsl:text>true</xsl:text>
	      </xsl:otherwise>
	    </xsl:choose>
	  </xsl:when>
	  <xsl:otherwise>
	    <xsl:call-template name = "MissingTypeErrorMessage" >
	      <xsl:with-param name = "valueType" select = "$valueType" />
	    </xsl:call-template>
	  </xsl:otherwise>
	</xsl:choose>   
      </xsl:variable>
      <xsl:if test="string($result)!='NaN'">
	<xsl:copy-of select = "$result" />
      </xsl:if>
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>

<xsl:template name="MissingTypeErrorMessage">
  <xsl:param name = "valueType" />
  <xsl:apply-templates select="$localizer/atm:unknown_type" mode="translate" />
  <xsl:text> '</xsl:text>
  <xsl:value-of select = "$valueType" />
  <xsl:text>' </xsl:text>
</xsl:template>

<xsl:template match="at:attacknode" mode="getValues">
  <attacknodePointer ref="{generate-id()}" />
  <xsl:variable name = "attacknode" select="." />
  <xsl:variable name = "properties">
    <xsl:apply-templates select = "." mode="getValuesNoRepeat" />
  </xsl:variable>
  <xsl:variable name = "repeater" select="attribute::repeat" />
  <xsl:choose>
    <xsl:when test = "$repeater">
      <xsl:variable name = "divident" select = "exslt:node-set($properties)/at:property[@name = $repeater]/child::text()" />
      <xsl:choose>
	<xsl:when test="$divident = '0'">
	  <!-- repetition could not help -->
	  <xsl:copy-of select="$properties" />
	</xsl:when>
	<xsl:otherwise>
	  <xsl:variable name = "resultTmp">
	    <!-- loop through names of properties: --> 
	    <xsl:for-each select="exslt:node-set($properties)/at:property">
	      <xsl:if test="attribute::name!='includedAttack'">
		<xsl:variable name = "value">
		  <xsl:variable name="valueType">
		    <xsl:apply-templates select="$theAttackTree" mode="getValueType">
		      <xsl:with-param name = "propertyName" select = "attribute::name" />
		    </xsl:apply-templates>
		  </xsl:variable>
		  <xsl:choose>
		    <xsl:when test="attribute::name = $repeater">
		      <xsl:text>1</xsl:text>
		    </xsl:when>
		    <xsl:when test="$valueType='rationalScaleDefender' or $valueType='probability' or $valueType='boolean' or child::text()='Infinity'">
		      <xsl:value-of select="child::text()" />
		    </xsl:when>
		    <xsl:otherwise>
		      <xsl:value-of select="child::text() div $divident" />
		    </xsl:otherwise>
		  </xsl:choose>	      
		</xsl:variable>
		<xsl:variable name = "shouldFilter">
		  <xsl:call-template name = "shouldValueBeFiltered" >
		    <xsl:with-param name = "value" select = "$value" />
		    <xsl:with-param name = "propertyName" select = "attribute::name" />
		  </xsl:call-template>
		</xsl:variable>
		<at:property source="calculation" name="{attribute::name}">
		  <xsl:if test="string($shouldFilter)">
		    <xsl:attribute name="filter">true</xsl:attribute>
		  </xsl:if>
		  <xsl:if test="attribute::name = $repeater">
		    <xsl:attribute name="previous_value"><xsl:value-of select="$divident" /></xsl:attribute>
		  </xsl:if>
		  <xsl:if test="attribute::mentioned">
		    <xsl:attribute name="mentioned"></xsl:attribute>
		  </xsl:if>
		  <xsl:if test="attribute::mentionedInAllSubgoals">
		    <xsl:attribute name="mentionedInAllSubgoals"></xsl:attribute>
		  </xsl:if>
		  <xsl:value-of select="$value" />
		  <xsl:copy-of select="origin" />
		</at:property>
	      </xsl:if>
	    </xsl:for-each>
	  </xsl:variable>
	  <xsl:copy-of select="$resultTmp" />
	  <at:property source="buildIn" name="includedAttack">
	    <xsl:choose>
	      <xsl:when test = "not(exslt:node-set($properties)/at:property[@name = 'includedAttack'] = 'false') and not(exslt:node-set($resultTmp)/at:property[@filter])">
		<xsl:text>true</xsl:text>
	      </xsl:when>
	      <xsl:otherwise>
		<xsl:text>false</xsl:text>
	      </xsl:otherwise>
	    </xsl:choose>
	  </at:property>
	</xsl:otherwise>
      </xsl:choose>
    </xsl:when>
    <xsl:otherwise>
      <xsl:copy-of select="$properties" />
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>

<xsl:template match="at:attacknode" mode="getValuesNoRepeat">
  <xsl:variable name = "propertiesTmp">
    <xsl:variable name = "attacknode" select="." />
    <!-- loop through names of properties: -->
    <xsl:for-each select="//at:property[generate-id(.)=generate-id(key('mapPropertyNamesToPropertyNodes',attribute::name))]">
      <xsl:variable name = "propertyName" select="attribute::name"/>
      <xsl:variable name = "valueType">
	<xsl:apply-templates select="$theAttackTree" mode="getValueType">
	  <xsl:with-param name = "propertyName" select = "$propertyName" />
	</xsl:apply-templates>
      </xsl:variable>
      <!-- skip properties of unknown type -->
      <xsl:if test = "$valueType='rationalScale' or $valueType='rationalScaleDefender' or $valueType='probability' or $valueType ='boolean'" >
	<xsl:variable name = "property" select="$attacknode/child::at:property[@name=$propertyName]"/>
	<xsl:variable name = "value">
	  <xsl:choose>
	    <xsl:when test="string($property/child::text())=''">
	      <xsl:choose>
		<xsl:when test = "$valueType='rationalScale'" >
		  <xsl:choose>
		    <xsl:when test = "$attacknode/attribute::type = 'or'">
		      <xsl:text>Infinity</xsl:text>
		    </xsl:when>
		    <xsl:otherwise>
		      <xsl:text>0</xsl:text>
		    </xsl:otherwise>
		  </xsl:choose>
		</xsl:when>
		<xsl:when test = "$valueType='rationalScaleDefender'" >
		  <xsl:text>0</xsl:text>
		</xsl:when>
		<xsl:when test = "$valueType='probability'" >
		  <xsl:choose>
		    <xsl:when test = "$attacknode/attribute::type = 'or'">
		      <xsl:text>0</xsl:text>
		    </xsl:when>
		    <xsl:otherwise>
		      <xsl:text>1</xsl:text>
		    </xsl:otherwise>
		  </xsl:choose>
		</xsl:when>
		<xsl:when test = "$valueType='boolean'" >
		  <xsl:choose>
		    <xsl:when test = "$attacknode/attribute::type = 'or'">
		      <xsl:text>false</xsl:text>
		    </xsl:when>
		    <xsl:otherwise>
		      <xsl:text>true</xsl:text>
		    </xsl:otherwise>
		  </xsl:choose>
		</xsl:when>
		<xsl:otherwise>
		  <xsl:call-template name = "MissingTypeErrorMessage" >
		    <xsl:with-param name = "valueType" select = "$valueType" />
		  </xsl:call-template>
		</xsl:otherwise>
	      </xsl:choose>   	      
	    </xsl:when>
	    <xsl:otherwise>
	      <xsl:copy-of select="$property/child::text()" />
	    </xsl:otherwise>
	  </xsl:choose>
	</xsl:variable>

	<xsl:variable name = "shouldFilter">
	  <xsl:call-template name = "shouldValueBeFiltered" >
	    <xsl:with-param name = "value" select = "$value" />
	    <xsl:with-param name = "propertyName" select = "$propertyName" />
	  </xsl:call-template>
	</xsl:variable>
	<at:property source="literal" name="{$propertyName}" valuetype="{$valueType}" mentionedInAllSubgoals="">
	  <xsl:if test="string($shouldFilter)">
	    <xsl:attribute name="filter"><xsl:value-of select="$shouldFilter" /></xsl:attribute>
	  </xsl:if>
	  <xsl:if test="$property/attribute::defence">
	    <xsl:attribute name="defence"><xsl:value-of select="$property/attribute::defence" /></xsl:attribute>
	  </xsl:if>
	  <xsl:if test="string($property/child::text())!=''">
	    <xsl:attribute name="mentioned"></xsl:attribute>
	  </xsl:if>
	  <xsl:choose>
	    <xsl:when test = "string($property/child::text())=''">
	      <xsl:attribute name="filled_in_default"></xsl:attribute>
	    </xsl:when>
	    <xsl:otherwise>
	      <xsl:if test="$valueType='rationalScaleDefender' and not(key('mapDefenceNamesToEnableDeclaration',$property/attribute::defence))">
		<xsl:attribute name="no_defence"></xsl:attribute>
	      </xsl:if>
	    </xsl:otherwise>
	  </xsl:choose>
	  <xsl:copy-of select="$value" />
	  <xsl:if test="string($property/child::text())!=''"><!-- mentioned -->
	    <origin ref="{generate-id($attacknode)}" self="true" />	
	  </xsl:if>
	</at:property>
      </xsl:if>
    </xsl:for-each>   
  </xsl:variable>
  <xsl:variable name = "properties">
    <xsl:copy-of select="$propertiesTmp" />
    <at:property source="buildIn" name="effortlessAttack">
      <xsl:choose>
	<xsl:when test = "exslt:node-set($propertiesTmp)/at:property[@no_defence] or not(exslt:node-set($propertiesTmp)/at:property[(@valuetype = 'rationalScale' and text()!='0') or (@valuetype = 'probability' and text()!='1') or (@valuetype = 'boolean' and text()='false')])">
	  <xsl:text>true</xsl:text>
	</xsl:when>
	<xsl:otherwise>
	  <xsl:text>false</xsl:text>
	</xsl:otherwise>
      </xsl:choose>
    </at:property>
  </xsl:variable>

  <xsl:choose>
    <xsl:when test = "attribute::type = 'and'">
      <xsl:call-template name = "foldlValuesOf" >
	<xsl:with-param name = "pFunc" select = "document('')/*/all-subgoals-needed-func:all-subgoals-needed-func[1]" />
	<xsl:with-param name = "pList" select = "child::at:attacknode" />
	<xsl:with-param name = "pA0">
	  <xsl:copy-of select = "$properties" />
	  <at:property source="buildIn" name="includedAttack">
	    <xsl:choose>
	      <xsl:when test = "not(exslt:node-set($propertiesTmp)/at:property[@filter])">
		<xsl:text>true</xsl:text>
	      </xsl:when>
	      <xsl:otherwise>
		<xsl:text>false</xsl:text>
	      </xsl:otherwise>
	    </xsl:choose>
	  </at:property>
	</xsl:with-param>
	<xsl:with-param name = "attacknode" select = "." />
      </xsl:call-template>	  
    </xsl:when>
    <xsl:when test = "attribute::type = 'or'">
      <!-- apply 'pa0' as the last argument, so that it won't be filtered away. -->
      <xsl:choose>
	<xsl:when test = "child::at:attacknode">
	  <xsl:variable name="resultFromSubgoals">
	    <xsl:variable name="pA0">
	      <xsl:apply-templates select = "child::at:attacknode[1]" mode="getValues" />
	    </xsl:variable>
	    <xsl:call-template name = "foldlValuesOf" >
	      <xsl:with-param name = "pFunc" select = "document('')/*/some-subgoal-needed-func:some-subgoal-needed-func[1]" />
	      <xsl:with-param name = "pList" select = "child::at:attacknode[position() &gt; 1]" />
	      <xsl:with-param name = "pA0" select = "$pA0" />
	      <xsl:with-param name = "attacknode" select = "." />
	    </xsl:call-template>
	  </xsl:variable>
	  <xsl:call-template name="propertyOperator">
	    <xsl:with-param name = "pFunc" select="document('')/*/some-subgoal-needed-func:some-subgoal-needed-func[1]" />
	    <xsl:with-param name = "propertiesArg1">
	      <xsl:copy-of select = "$properties" />
	      <at:property source="buildIn" name="includedAttack"><!-- Do not influence filtering of the resulting node -->
		<xsl:choose>
		  <xsl:when test = "exslt:node-set($resultFromSubgoals)/at:property[@name = 'includedAttack' and text() != 'false']">
		    <xsl:text>true</xsl:text>
		  </xsl:when>
		  <xsl:otherwise>
		    <xsl:text>false</xsl:text>
		  </xsl:otherwise>
		</xsl:choose>
	      </at:property>
	    </xsl:with-param>
	    <xsl:with-param name = "propertiesArg2" select="$resultFromSubgoals" />
	    <xsl:with-param name = "attacknode" select = "." />
	  </xsl:call-template>
	</xsl:when>
	<xsl:otherwise>
	  <xsl:call-template name = "foldlValuesOf" >
	    <xsl:with-param name = "pFunc" select = "document('')/*/some-subgoal-needed-func:some-subgoal-needed-func[1]" />
	    <xsl:with-param name = "pList" select = "child::at:attacknode" />
	    <xsl:with-param name = "pA0">
	      <xsl:copy-of select = "$properties" />
	      <at:property source="buildIn" name="includedAttack">
		<xsl:choose>
		  <xsl:when test = "not(exslt:node-set($propertiesTmp)/at:property[@filter])">
		    <xsl:text>true</xsl:text>
		  </xsl:when>
		  <xsl:otherwise>
		    <xsl:text>false</xsl:text>
		  </xsl:otherwise>
		</xsl:choose>
	      </at:property>
	    </xsl:with-param>
	    <xsl:with-param name = "attacknode" select = "." />
	  </xsl:call-template>
	</xsl:otherwise>
      </xsl:choose>
    </xsl:when>
    <xsl:otherwise>
      <xsl:copy-of select = "$properties" />
      <at:property source="buildIn" name="includedAttack">
	<xsl:choose>
	  <xsl:when test = "not(exslt:node-set($propertiesTmp)/at:property[@filter])">
	    <xsl:text>true</xsl:text>
	  </xsl:when>
	  <xsl:otherwise>
	    <xsl:text>false</xsl:text>
	  </xsl:otherwise>
	</xsl:choose>
      </at:property>
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>

  
</xsl:stylesheet>