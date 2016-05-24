#!/usr/bin/env python
# -*- coding: utf-8 -*-
from __future__ import absolute_import, division

from distutils.core import setup
from distutils.extension import Extension
from Cython.Build import cythonize
import os

os.environ['CC'] = 'clang-3.5'

CYTHON_EXTENSIONS = (
    Extension('rpg.sdl', ["rpg/sdl.pyx"], libraries=['SDL2', 'SDL2_image']),
    Extension('rpg.cnach', ["rpg/cnach.pyx"], libraries=['SDL2', 'SDL2_image']),
)

setup(ext_modules=cythonize(CYTHON_EXTENSIONS))
