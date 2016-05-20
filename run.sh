#! /bin/bash
set -u

python setup.py build_ext --inplace && python -c 'import cnach; cnach.main()'

