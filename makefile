#
# makefile
# ignacio, 2016-05-25 17:30
#

clean:
	find rpg -name "*.so" -delete
	find rpg -name "*.c" -delete
	find rpg -name "*.html" -delete

build_ext:
	python setup.py build_ext --inplace

run: build_ext
	python -c 'from rpg.main import main; main()'

html:
	find rpg -name "*.pyx" -exec python scripts/make_html.py {} +
	find rpg -name "*.pyx" | python scripts/make_html_tree.py > tree.html

# vim:ft=make
#
