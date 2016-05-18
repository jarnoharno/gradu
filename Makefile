OUT := out
DOC := gradu

DEPS := ${DOC}.tex ${OUT}/${DOC}.bib body.tex

ZOTERO_URL := https://api.zotero.org/groups/494431/collections/WSPRTVK4/items

${OUT}/${DOC}.pdf: ${DEPS} | ${OUT}
	latexmk -outdir=${OUT} $<

# 1. download bibliography from zotero in bibtex format
${OUT}/${DOC}.raw.bib: | ${OUT}
	curl --header "Zotero-API-Version: 3" -o $@ \
		"${ZOTERO_URL}?format=bibtex&sort=creator&limit=100"

# 2. remove 'file' and 'language' fields
# 3. remove time zone from 'urldate' fields
# 4. convert citation keys from 'author_title:_YYYY' to 'authorYYtitle' for
#    compatibility with jabref and google scholar
${OUT}/${DOC}.bib: ${OUT}/${DOC}.raw.bib | ${OUT}
		sed -e '/^\t\(file\|language\) /d' $< | \
		sed -e 's/\(^\turldate.*\)TZ/\1/g' | \
		sed -e 's/\(@[^{]*{\)\([^_]*\)_\([^:_]*\):\?_..\(..\)/\1\2\4\3/g' \
		> $@

${OUT}:
	mkdir $@

.PHONY: rebib
rebib: cleanbib
	make ${OUT}/${DOC}.bib

.PHONY: retex
retex: cleantex
	make ${OUT}/${DOC}.pdf

.PHONY: cont
cont: ${DEPS} | ${OUT}
	latexmk -outdir=${OUT} -pvc -view=none $<

.PHONY: cleantex
cleantex:
	latexmk -C -outdir=${OUT} $<

.PHONY: cleanbib
cleanbib:
	rm -f ${OUT}/${DOC}.raw.bib
	rm -f ${OUT}/${DOC}.bib
	rm -f ${OUT}/${DOC}.bbl

.PHONY: clean
clean: cleantex cleanbib
	rmdir ${OUT}
