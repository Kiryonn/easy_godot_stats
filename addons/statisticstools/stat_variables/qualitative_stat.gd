@tool
class_name QualitativeStat extends StatVariable

@export var values: Array[String] = []:
	set(value):
		values = value
		for v in unique_values: if v not in values: unique_values.erase(v)
		for v in values: if v not in unique_values: unique_values.push_back(v)
		unique_values.sort()

var unique_values: Array[String]
