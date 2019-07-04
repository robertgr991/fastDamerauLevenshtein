from cython cimport cdivision, boundscheck
from libc.stdlib cimport malloc, free, realloc
from libc.limits cimport LONG_MAX
from libc.stdint cimport int64_t


cdef struct Map:
  int64_t key
  long  value


@cdivision
@boundscheck(False)
cpdef double damerauLevenshtein(firstObject, secondObject, bint similarity=True, int deleteWeight=1, int insertWeight=1, int replaceWeight=1, int swapWeight=1):
    """
        Computes the true Damerau Levenshtein distance which allows items to be modified more the once.
        The algorithm is described on Wikipedia:
        https://en.wikipedia.org/wiki/Damerau%E2%80%93Levenshtein_distance#Distance_with_adjacent_transpositions

        The implementation is based on this tutorial:
        https://www.lemoda.net/text-fuzzy/damerau-levenshtein/index.html

        Weights for every operation can be set with the respective parameters.

        If 'similarity' parameter is False, it will simply return the total cost of the edit.
        If 'similarity' parameter is True, it will return a value from 0.0 to 1.0, denoting how similar the two objects are, with 1.0 being identical and 0.0 being total opposite.

        Example:

        damerauLevenshtein('ca', 'abc', False) = 2.0 , the optimal string alignment distance(OSA) would have returned 3.0
        damerauLevenshtein('a cat', 'a abct', False) = 2.0 , an item is modified more then once
    """

    if firstObject == secondObject:
     if similarity == True:
       return 1.0
     else:
       return 0.0

    cdef size_t len1 = len(firstObject)
    cdef size_t len2 = len(secondObject)

    if len1 == 0 and similarity == True:
      return 0.0
    elif len1 == 0 and similarity == False:
      return len2

    if len2 == 0 and similarity == True:
      return 0.0
    elif len2 == 0 and similarity == False:
      return len1

    cdef size_t i, j
    cdef int64_t* object1 = <int64_t*> malloc(len1 * sizeof(int64_t))
    cdef int64_t* object2 = <int64_t*> malloc(len2 * sizeof(int64_t))

    if not object1 and not object2:
      raise MemoryError()
    elif not object1:
      free(object2)
      raise MemoryError()
    elif not object2:
      free(object1)
      raise MemoryError()

    for i from 0 <= i < len1 by 1:
      object1[i] = hash(firstObject[i])

    for j from 0 <= j < len2 by 1:
      object2[j] = hash(secondObject[j])

    cdef size_t maxLen = len1 if len1 >= len2 else len2
    cdef long** table
    cdef size_t k

    table = <long**> malloc(len1 * sizeof(long*))

    if not table:
      free(object1)
      free(object2)
      raise MemoryError()

    for i from 0 <= i < len1 by 1:
      table[i] = <long*> malloc(len2 * sizeof(long))
      if not table[i]:
        free(object1)
        free(object2)
        for j from 0 <= j < i by 1:
          free(table[j])
        free(table)
        raise MemoryError()

    for i from 0 <= i < len1 by 1:
      for j from 0 <= j < len2 by 1:
        table[i][j] = 0

    if object1[0] != object2[0]:
        table[0][0] = swapWeight

    cdef Map* lastSeenCharacter = <Map*> malloc(sizeof(Map))

    if not lastSeenCharacter:
      free(object1)
      free(object2)
      for i from 0 <= i < len1 by 1:
        free(table[i])
      free(table)
      raise MemoryError()

    lastSeenCharacter[0].key = object1[0]
    lastSeenCharacter[0].value = 0
    cdef size_t countMap = 1

    cdef bint sw
    cdef long deleteDistance, insertDistance, matchDistance

    for i from 1 <= i < len1 by 1:
        deleteDistance = table[i - 1][0] + deleteWeight
        insertDistance = (i + 1) * deleteWeight + insertWeight
        matchDistance = i * deleteWeight + (0 if object1[i] == object2[0] else replaceWeight)
        table[i][0] = min(deleteDistance, insertDistance, matchDistance)

    for j from 1 <= j < len2 by 1:
        deleteDistance = (j + 1) * insertWeight + deleteWeight
        insertDistance = table[0][j - 1] + insertWeight
        matchDistance = j * insertWeight + (0 if object1[0] == object2[j] else replaceWeight)
        table[0][j] = min(deleteDistance, insertDistance, matchDistance)

    cdef long indexItemMatchMax, indexSwapCandidate, jSwap, swapDistance, iSwap, preSwapCost, distance
    cdef double similarityScore

    try:
      for i from 1 <= i < len1 by 1:
          indexItemMatchMax = 0 if object1[i] == object2[0] else -1
          for j from 1 <= j < len2 by 1:
              indexSwapCandidate = -1
              for k from 0 <= k < countMap by 1:
                if lastSeenCharacter[k].key == object2[j]:
                  indexSwapCandidate = lastSeenCharacter[k].value
                  break
              jSwap = indexItemMatchMax
              deleteDistance = table[i - 1][j] + deleteWeight
              insertDistance = table[i][j - 1] + insertWeight
              matchDistance = table[i - 1][j - 1]
              if object1[i] != object2[j]:
                  matchDistance += replaceWeight
              else:
                  indexItemMatchMax = j
              swapDistance = -1
              if indexSwapCandidate != -1:
                if jSwap != -1:
                    iSwap = indexSwapCandidate
                    if iSwap == 0 and jSwap == 0:
                        preSwapCost = 0
                    else:
                        preSwapCost = table[max(0, iSwap - 1)][max(0, jSwap - 1)]
                    swapDistance = preSwapCost + (i - iSwap - 1) * deleteWeight + (j - jSwap - 1) * insertWeight + swapWeight
              else:
                swapDistance = LONG_MAX
              if swapDistance == -1:
                table[i][j] = min(deleteDistance, insertDistance, matchDistance)
              else:
                table[i][j] = min(deleteDistance, insertDistance, matchDistance, swapDistance)
          sw = True
          for k from 0 <= k < countMap by 1:
            if lastSeenCharacter[k].key == object1[i]:
              lastSeenCharacter[k].value = i
              sw = False
              break
          if sw == True:
            lastSeenCharacter = <Map*> realloc(lastSeenCharacter, (countMap + 1) * sizeof(Map))

            if not lastSeenCharacter:
              raise MemoryError()

            lastSeenCharacter[countMap].key = object1[i]
            lastSeenCharacter[countMap].value = i
            countMap += 1

      distance = table[len1 - 1][len2 - 1]
      similarityScore = (<double>(maxLen - distance) / maxLen)

      if similarity == True:
        return similarityScore
      else:
        return distance
    finally:
      free(object1)
      free(object2)
      for i from 0 <= i < len1 by 1:
        free(table[i])
      free(table)
      free(lastSeenCharacter)
