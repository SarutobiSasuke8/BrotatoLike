extends RefCounted
## Minimal assertion base for the headless test runner (tests/run_tests.gd).
## Test scripts extend this file and define methods whose names start with "test_".

var failures: Array[String] = []
var assertions := 0


func before_each() -> void:
	pass


func _fail(message: String) -> void:
	failures.append(message)


func assert_true(value: bool, message: String = "") -> void:
	assertions += 1
	if not value:
		_fail("expected true. %s" % message)


func assert_false(value: bool, message: String = "") -> void:
	assertions += 1
	if value:
		_fail("expected false. %s" % message)


func assert_eq(actual, expected, message: String = "") -> void:
	assertions += 1
	if typeof(actual) != typeof(expected) and not (_is_number(actual) and _is_number(expected)):
		_fail("expected %s (%s), got %s (%s). %s" % [expected, type_string(typeof(expected)), actual, type_string(typeof(actual)), message])
	elif actual != expected:
		_fail("expected %s, got %s. %s" % [expected, actual, message])


func assert_almost_eq(actual: float, expected: float, tolerance: float = 0.0001, message: String = "") -> void:
	assertions += 1
	if absf(actual - expected) > tolerance:
		_fail("expected %s +/- %s, got %s. %s" % [expected, tolerance, actual, message])


func _is_number(value) -> bool:
	return typeof(value) == TYPE_INT or typeof(value) == TYPE_FLOAT
