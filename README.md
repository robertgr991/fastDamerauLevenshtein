# fastDamerauLevenshtein

[![Build Status](https://travis-ci.com/robertgr991/fastDamerauLevenshtein.svg?branch=master)](https://travis-ci.com/robertgr991/fastDamerauLevenshtein)
[![Wheel Status](https://pypip.in/wheel/fastDamerauLevenshtein/badge.svg)](https://pypi.python.org/pypi/fastDamerauLevenshtein/)

Cython implementation of true Damerau-Levenshtein edit distance which allows one item to be edited more than once.
More information from [Wikipedia](http://en.wikipedia.org/wiki/Damerau%E2%80%93Levenshtein_distance):

> In information theory and computer science, the Damerau-Levenshtein distance (named after Frederick J. Damerau and Vladimir I. Levenshtein) is a string metric for measuring the edit distance between two sequences. Informally, the Damerau-Levenshtein distance between two words is the minimum number of operations (consisting of insertions, deletions or substitutions of a single character, or transposition of two adjacent characters) required to change one word into the other.<br/>
The Damerau-Levenshtein distance differs from the classical Levenshtein distance by including transpositions among its allowable operations in addition to the three classical single-character edit operations (insertions, deletions and substitutions).

The implementation is based on [James M. Jensen II](https://www.lemoda.net/text-fuzzy/damerau-levenshtein/index.html) explanation and it allows specifying the cost of every operation.

## Requirements
This code requires Python 2.7 or 3.4+ and a C compiler such as GCC.

## Install
fastDamerauLevenshtein is available on PyPI at https://pypi.python.org/pypi/fastDamerauLevenshtein.

Install using [pip](https://pypi.org/project/pip/):

    pip install fastDamerauLevenshtein

Install from source:

    python setup.py install

or

    pip install .

## Usage
The available method it's called `damerauLevenshtein` and can compute the distance on two objects that are hashable(strings, list of strings etc.). The method provides the following parameters:

* **firstObject**

* **secondObject**

* **similarity**
    * If this parameter value is `False`, it will return the total cost of edit, otherwise it will return a score from 0.0 to 1.0 denoting how similar the two objects are. It is `True` by default.

* **deleteWeight**
    * Cost of delete operation.

* **insertWeight**
    * Cost of insert operation.

* **replaceWeight**
    * Cost of replace operation.

* **swapWeight**
    * Cost of swap operation.

The provided weights of operations must be `int` values. All these values are `1` by default.

Basic use:

```python
from fastDamerauLevenshtein import damerauLevenshtein
damerauLevenshtein('ca', 'abc', similarity=False)  # expected result: 2.0
damerauLevenshtein('car', 'cars', similarity=True)  # expected result: 0.75
damerauLevenshtein(['ab', 'bc'], ['ab'], similarity=False)  # expected result: 1.0
damerauLevenshtein(['ab', 'bc'], ['ab'], similarity=True)  # expected result: 0.5
```

## Benchmark
Other Python Damerau-Levenshtein and OSA implementations:

* [pyxDamerauLevenshtein](https://github.com/gfairchild/pyxDamerauLevenshtein) (restricted edit distance and no custom weights)
* [jellyfish](https://github.com/sunlightlabs/jellyfish) (true Damerau-Levenshtein but no custom weights)
* [editdistance](https://github.com/aflc/editdistance) (restricted edit distance and no custom weights)
* [textdistance](https://github.com/orsinium/textdistance) (true Damerau-Levenshtein but no custom weights)

Python 3.7 (on Intel i5 6500):

    >>> import timeit
    >>> #fastDamerauLevenshtein:
    ... timeit.timeit(setup="import fastDamerauLevenshtein; text1='afwafghfdowbihgp'; text2='goagumkphfwifawpte'", stmt="fastDamerauLevenshtein.damerauLevenshtein(text1, text2)", number=100000)
    0.43
    >>> #pyxDamerauLevenshtein:
    ... timeit.timeit(setup="from pyxdameraulevenshtein import normalized_damerau_levenshtein_distance; text1='afwafghfdowbihgp'; text2='goagumkphfwifawpte'", stmt="normalized_damerau_levenshtein_distance(text1, text2)", number=100000)
    2.44
    >>> #jellyfish
    ... timeit.timeit(setup="import jellyfish; text1='afwafghfdowbihgp'; text2='goagumkphfwifawpte'", stmt="jellyfish.damerau_levenshtein_distance(text1, text2)", number=100000)
    0.20
    >>> #editdistance
    ... timeit.timeit(setup="import editdistance; text1='afwafghfdowbihgp'; text2='goagumkphfwifawpte'", stmt="editdistance.eval(text1, text2)", number=100000)
    0.22
    >>> #textdistance
    ... timeit.timeit(setup="import textdistance; text1='afwafghfdowbihgp'; text2='goagumkphfwifawpte'", stmt="textdistance.damerau_levenshtein.distance(text1, text2)", number=100000)
    0.70

-------
License
-------

It is released under the MIT license.

    Copyright (c) 2019 Robert Grigoroiu

    Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

    The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

    THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
