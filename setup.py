#!/usr/bin/env python
# -*- coding: utf-8 -*-
from __future__ import absolute_import, division

import os

from distutils.core import setup
from distutils.extension import Extension
from Cython.Build import cythonize

os.environ['CC'] = 'clang-3.5'

CYTHON_EXTENSIONS = (
    Extension('*',
              ["rpg/**/*.pyx"],
              include_dirs=['rpg'],
              libraries=['SDL2', 'SDL2_image'],
#               define_macros=[('CYTHON_WITHOUT_ASSERTIONS', 1)],
              extra_compile_args=['-Wno-unused-function',
                                  '-Wno-incompatible-pointer-types',
                                 ]), )

setup(ext_modules=cythonize(
                            CYTHON_EXTENSIONS,
                            compiler_directives={'profile': True},
))
