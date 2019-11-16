import os
import json
import strutils
import tables

type database* = object
  db: JsonNode
  path*: string
  size*: int

#Misc procs
proc longestString(x: seq[string]): int =
  result = 0
  for y in x:
    if y.len() > result:
     result = y.len()

proc printAsTable(keys, values: seq[string], amount: int) =
  var longestKey = longestString(keys)
  var longestVal = longestString(values)

  if longestKey < 3: longestKey = 3
  if longestVal < 5: longestVal = 5

  let separator = "+" & repeat('-', longestKey) & "+" & repeat('-', longestVal) & "+"

  echo separator
  echo "|", alignLeft("Key", longestKey), "|", alignLeft("Value", longestVal), "|"
  echo separator

  for i in countup(0, amount):
    if i < keys.len():
      echo "|", alignLeft(keys[i], longestKey), "|", alignLeft(values[i], longestVal), "|"
    else:
      break

  echo separator

#Load/Save database
proc loadDatabase*(file_path: string): database =
  var x: database
  if fileExists(file_path):
    x.db = parseFile(file_path)
  else:
    x.db = %*{}
    echo "Database \"", file_path, "\" doesn't exist. Creating new database."

  x.path = file_path
  x.size = x.db.len()
  return x

proc saveDatabase*(database: var database) =
  writeFile(database.path, pretty(database.db))

discard """proc getObjectFields[T](obj: JsonNode): T =
  let fields = getFields(obj)
  var index = 0
  for v in fields.values:
    if v.kind == JInt:
      result[index] = v.getInt()
    if v.kind == JBool:
      result[index] = v.getBool()
    if v.kind == JString:
      result[index] = v.getStr()
    if v.kind == JFloat:
      result[index] = v.getFloat()
    if v.kind == JArray:
      let elements = v.getElems()
      var index2 = 0
      for element in elements:
        result[index][index2] = getObjectFields[typeof(result[index])](element)
        inc(index2)
    if v.kind == JObject:
      result[index] = getObjectFields[typeof(result[index])](v)
    inc(index)
"""
#Accessing the database
proc readKey*[T](database: var database, key: string) =
  if database.db.hasKey(key):
    when T is int:
      return database.db[key].getInt()
    when T is bool:
      return database.db[key].getBool()
    when T is string:
      return database.db[key].getStr()
    when T is float:
      return database.db[key].getFloat()
    else:
      let fields = getFields(database.db[key])

      var data = ()

      var index = 0
      for v in fields.values:
        data[index] = v
        inc(index)

      return data
  else:
    echo "Key \"", key ,"\" is not in the database."

proc readKeys*[T](database: var database, key: string): seq[T] =
  if database.db.hasKey(key):
    when T is int:
      result = newSeq[int]()
      let elements = getElems(database.db[key])
      for element in elements:
        result.add(element.getInt())
    when T is bool:
      result = newSeq[bool]()
      let elements = getElems(database.db[key])
      for element in elements:
        result.add(element.getBool())
    when T is string:
      result = newSeq[string]()
      let elements = getElems(database.db[key])
      for element in elements:
        result.add(element.getStr())
    when T is float:
      result = newSeq[float]()
      let elements = getElems(database.db[key])
      for element in elements:
        result.add(element.getFloat())
  else:
    echo "Key \"", key ,"\" is not in the database."

#Modifing the database
proc writeKey*[T](database: var database, key: string, input: T, overwrite: bool = true): bool =
  if database.db.hasKey(key):
    if not overwrite:
      #echo "Key \"", key, "\" already exists, overwrite is false."
      return false

  when T is int:
    database.db.add(key, newJInt(input))
  when T is bool:
    database.db.add(key, newJBool(input))
  when T is string:
    database.db.add(key, newJString(input))
  when T is float:
    database.db.add(key, newJFloat(input))
  else:
    database.db.add(key, %*input)
  
  database.size = database.db.len()
  return true
  
proc writeKeys*[T](database: var database, key: string, input: openArray[T], overwrite: bool = true): bool =
  if database.db.hasKey(key):
    if not overwrite:
      echo "Key \"", key, "\" already exists, overwrite is false."
      return false

  when T is int:
    var temp = newJArray()
    for item in input:
      add(temp, newJInt(item))
    database.db.add(key, temp)
  when T is bool:
    var temp = newJArray()
    for item in input:
      add(temp, newJBool(item))
    database.db.add(key, temp)
  when T is string:
    var temp = newJArray()
    for item in input:
      add(temp, newJString(item))
    database.db.add(key, temp)
  when T is float:
    var temp = newJArray()
    for item in input:
      add(temp, newJFloat(item))
    database.db.add(key, temp)

  database.size = database.db.len()
  return true

proc deleteKey*(database: var database, key: string): bool =
  if database.db.hasKey(key):
    database.db.delete(key)
    database.size = database.db.len()
    return true
  else:
    echo "Key \"", key, "\" doesn't exist in the database."
    return false

#Printing the database
proc printValues*(database: var database, amount: var int, start: int = 0) =
  
  var keys = newSeq[string]()
  var values = newSeq[string]()

  var index = start
  for item in pairs(database.db):
    if index < database.db.len():
      if index < start+amount:
        if item.val.kind == JArray:
          keys.add(item.key)
          values.add("Array")

          let elements = getElems(item.val)

          var index = 0
          for element in elements:
            if element.kind == JObject:
              keys.add(alignLeft("Element: " & $index, item.key.len()))
              values.add("")
              for pair in pairs(element):
                keys.add(alignLeft("->" & pair.key, item.key.len()))
                values.add($pair.val)
                inc(amount)
            else:
              keys.add(alignLeft("Element: " & $index, item.key.len()))
              values.add($element)
            inc(amount)
            inc(index)
        else:
          keys.add(item.key)
          values.add($item.val)

        inc(index)
      else:
        break
    else:
      break

  printAsTable(keys, values, amount)

proc printValuesFilteredKey*(database: var database, filter: proc(x: string): bool, amount: int, start: int = 0) =
  var keys = newSeq[string]()
  var values = newSeq[string]()

  var index = start
  for item in pairs(database.db):
    if index < database.db.len():
      if filter(item.key):
        keys.add(item.key)
        values.add($item.val)

      inc(index)
    else:
      break

  printAsTable(keys, values, amount)

proc printValuesFilteredValue*[T](database: var database, filter: proc(x: T): bool, amount: int, start: int = 0) =
  var keys = newSeq[string]()
  var values = newSeq[string]()

  var index = start
  for item in pairs(database.db):
    if index < database.db.len():
      when T is int:
        if item.val.kind == JInt:
          if filter(item.val.getInt()):
            keys.add(item.key)
            values.add($item.val)
      when T is bool:
        if item.val.kind == JBool:
          if filter(item.val.getBool()):
            keys.add(item.key)
            values.add($item.val)
      when T is string:
        if item.val.kind == JString:
          if filter(item.val.getStr()):
            keys.add(item.key)
            values.add($item.val)
      when T is float:
        if item.val.kind == JFloat:
          if filter(item.val.getFloat()):
            keys.add(item.key)
            values.add($item.val)

      inc(index)
    else:
      break

  printAsTable(keys, values, amount)

