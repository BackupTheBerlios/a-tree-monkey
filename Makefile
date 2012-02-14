.PHONY: all clean dobb dobb_de

atm_dir = attack_tree_monkey
include_dir = include
attacktree_dr_dobbs_journal = attacktree_dr_dobbs_journal_dir
xslt = $(atm_dir)/xslt_xsltproc.sh
#xslt = $(atm_dir)/xslt_saxonb.sh

all: dobb dobb_de

include $(atm_dir)/Makefile.include

clean:
	rm -f -- *.htm $(atm_dir)/atm $(attacktree_dr_dobbs_journal)/nodefence attacktree_dr_dobbs_journal_filter6 attacktree_dr_dobbs_journal_filter2 attacktree_dr_dobbs_journal attacktree_dr_dobbs_journal_filter6_with_rise_in_salary attacktree_exslt *~ $(include_dir)/*~ $(attacktree_dr_dobbs_journal)/*~ $(atm_dir)/*~ $(atm_dir)/lang/*~

dobb: attacktree_dr_dobbs_journal.htm attacktree_dr_dobbs_journal_filter2.htm attacktree_dr_dobbs_journal_filter6.htm attacktree_dr_dobbs_journal_filter6_with_rise_in_salary.htm 

dobb_de: attacktree_dr_dobbs_journal_de.htm attacktree_dr_dobbs_journal_filter2_de.htm attacktree_dr_dobbs_journal_filter6_de.htm attacktree_dr_dobbs_journal_filter6_with_rise_in_salary_de.htm

$(attacktree_dr_dobbs_journal)/nodefence: $(attacktree_dr_dobbs_journal)/nodefence.xml $(include_dir)/defences.xml
	touch $@

attacktree_dr_dobbs_journal_filter6: $(include_dir)/type.xml $(attacktree_dr_dobbs_journal)/nodefence $(attacktree_dr_dobbs_journal)/attacktree_only_dr_dobbs_journal.xml attacktree_dr_dobbs_journal_filter6.xml
	touch $@

attacktree_dr_dobbs_journal_filter2: $(include_dir)/type.xml $(attacktree_dr_dobbs_journal)/nodefence $(attacktree_dr_dobbs_journal)/attacktree_only_dr_dobbs_journal.xml attacktree_dr_dobbs_journal_filter2.xml
	touch $@

attacktree_dr_dobbs_journal: $(include_dir)/type.xml $(attacktree_dr_dobbs_journal)/nodefence $(attacktree_dr_dobbs_journal)/attacktree_only_dr_dobbs_journal.xml attacktree_dr_dobbs_journal.xml
	touch $@

attacktree_dr_dobbs_journal_filter6_with_rise_in_salary: $(include_dir)/type.xml $(attacktree_dr_dobbs_journal)/attacktree_only_dr_dobbs_journal.xml attacktree_dr_dobbs_journal_filter6_with_rise_in_salary.xml
	touch $@

attacktree_dr_dobbs_journal.htm attacktree_dr_dobbs_journal_filter2.htm attacktree_dr_dobbs_journal_filter6.htm attacktree_dr_dobbs_journal_filter6_with_rise_in_salary.htm: %.htm: % $(atm_dir)/atm 
	$(xslt) $@ $(atm_dir)/attacktree.xsl $<.xml "lang" "en"
	#xsltproc --param "lang" "'en'" -o $@ $(atm_dir)/attacktree.xsl $<.xml

attacktree_dr_dobbs_journal_de.htm attacktree_dr_dobbs_journal_filter2_de.htm attacktree_dr_dobbs_journal_filter6_de.htm attacktree_dr_dobbs_journal_filter6_with_rise_in_salary_de.htm: %_de.htm: % $(atm_dir)/atm 
	$(xslt) $@ $(atm_dir)/attacktree.xsl $<.xml "lang" "de"
	#xsltproc --param "lang" "'de'" -o $@ $(atm_dir)/attacktree.xsl $<.xml

empty.htm: %.htm: %.xml $(atm_dir)/atm 
	$(xslt) $@ $(atm_dir)/attacktree.xsl $< "lang" "en"
	#xsltproc --param "lang" "'en'" -o $@ $(atm_dir)/attacktree.xsl $<
