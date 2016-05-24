#! /bin/bash
set -u

python setup.py build_ext --inplace && python -c 'import rpg.cnach; rpg.cnach.main()'

