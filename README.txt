Attack trees are a way of modelling security systems and how they fail.
Calculations within the attack tree determine how much effort is necessary to break the system.
The calculations operate by taking values from the leaf nodes and working upward to the root.
(In compiler construction one calls them "synthesized attributes" (has nothing to do with XML attributes)).

This XSL Transformation performs the calculations on an attack tree that you provide as XML input.
It outputs the result in HTML. You can set the natural language of the output via 
the parameter "lang". Currently German ("'de'") and English ("'en'") are supported.
The XML input can describe an attack tree in multiple natural languages.

The attack tree scheme is meant to faciliate reuse of attack trees. One can expand them for virtually 
unlimited resources of attackers and defenders. You effectively prune the attack tree for your needs
by limiting resources seperately: As additional defences are disabled by default and additional 
attacks are enabled by default, including third party updates to the attack tree becomes feasible.

Use the usual XML include features to include parts of the tree. 
Starting with the most relevant items, you will typically want to reuse:
 - properties with their types and translations (type element)
 - defences with their translations (defences element)
 - the actual attack trees or subtrees of them (attacknode element)
 - the resources of the attacker (attacker element)
 - enabled defences (defender element)

The Attack Tree Monkey project is hosted at BerliOS:
 https://developer.berlios.de/projects/a-tree-monkey/

=== Environment ===
Needs an XSLT processor for XSLT Version 1.0 with the 
extension function 'exslt:node-set' (xmlns:exslt="http://exslt.org/common"). 

Works with
 - Libxslt (xsltproc 1.1.26-7 with libxslt 1.1.26-7)
 - Saxon (libsaxonb-java 9.0.0.4+svn20080322-3)

Broken for:
 - Xalan (xalan 2.7.1)



=== Make HTML Attack Trees ===
The main XSLT file is 'attacktree.xsl' which includes the other xsl-files and 'userinterface.xml'.
The files 'attacktree_dr_dobbs_journal*.xml' provide examples taken from Bruce Schneier's article 
in Dr. Dobb's Journal December 1999.

In order to use Saxon instead of Libxslt, move the comment sign to the other line in the Makefile,
so that it looks like this:
 #xslt = $(atm_dir)/xslt_xsltproc.sh
 xslt = $(atm_dir)/xslt_saxonb.sh

Run 'make' in order to build the examples (works with GNU Make 3.81).

Define your own attack tree by adapting 'attacktree_template.xml' and a copy of the Makefile in a new 
directory. Symbolic links to the directories 'attack_tree_monkey/' and 'include/' may help.

=== Features ===
==Types==
Calculation is performed on user defined properties of the following types:
 - rationalScale: describes how much effort the attacker has to spend. (Zero means effortless.)
 - probability: describes how likely an attacker succeeds in the attack (or some aspect of it.)
 - boolean: describes, if something is positive for the attacker.
 - rationalScaleDefender: Describes effort of the defender. The effort is summed in each 
    attack node regardless, if it is an or-node or an and-node, because the attacker decides.

==Properties==
Properties can also be defined in inner nodes, and their values are treated much like, if they
would originate from another child node. However unlike values from real child nodes they are
never filtered.

==Filtering==
You can limit the resources of the attacker to filter attack nodes.
An attack nodes ignores values from filtered children, unless it is also filtered.

==== Defences ====
You can add a new defence by adding an attack node that represents breaking the defence.
So if you want to add a safe as a new defence, you will have to add an attack goal like "open safe"
to the attack tree first.
Add a property of the defender to the new attack node and add a defence attribute to the 
respective property element. The value of the defence attribute describes for what the defender 
spends resources (e. g. "Buy and install a safe"). Localization for another language can be done 
below the defences element.

Defences are disabled by default making the respective attack effortless. Enter the defence below
the enabledDefences element to enable it.

== Repeat ==
This is an experimental feature to model an attacker who repeats a certain attack until he succeeds.
Add an attribute 'repeat="chanceOfSuccess"' to the respective attack node, and define a property
'chanceOfSuccess' (which is of type probability).

The extra effort for the repetition will only be calculated for properties of type rationalScale.
It is not obvious what to do with other properties of type probability.
Leaving properties of type boolean and rationalScaleDefender untouched, is what one would expect.

== Translation ==
You can translate this software to other natural languages by adding your translation to the file
userinterface.xml.

In order to translate an attack tree to a different language, make use of the xml:lang attribute for
title elements and describtion elements. Existing titles may use a title attribute. In this case
simply add a title element child.

The defence attribute of properties and the name attribute of a defence element inside 
an enabledDefences element must be translated below the defences element.
