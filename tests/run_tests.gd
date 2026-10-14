extends SceneTree
## Dependency-free headless test runner.
##
## Usage (after the project has been imported once):
##   godot --headless --path . --script res://tests/run_tests.gd
##
## Loads every tests/unit/test_*.gd, runs each method whose name starts with "test_"
## on a fresh instance, prints one line per test and exits 0 when everything passed,
## 1 otherwise.

const TEST_DIR := "res://tests/unit"


func _initialize() -> void:
	var files: Array[String] = []
	for file in DirAccess.get_files_at(TEST_DIR):
		if file.begins_with("test_") and file.ends_with(".gd"):
			files.append(file)
	files.sort()

	var passed := 0
	var failed := 0
	var assertions := 0
	for file in files:
		var script: GDScript = load("%s/%s" % [TEST_DIR, file])
		if script == null:
			print("FAIL %s: could not load script" % file)
			failed += 1
			continue
		var names: Array[String] = []
		for method in script.get_script_method_list():
			var method_name: String = method.name
			if method_name.begins_with("test_") and not names.has(method_name):
				names.append(method_name)
		for method_name in names:
			var case = script.new()
			case.before_each()
			case.call(method_name)
			assertions += case.assertions
			if case.failures.is_empty():
				passed += 1
				print("PASS %s::%s" % [file, method_name])
			else:
				failed += 1
				print("FAIL %s::%s" % [file, method_name])
				for failure in case.failures:
					print("     %s" % failure)

	print("")
	print("%d tests, %d passed, %d failed, %d assertions" % [passed + failed, passed, failed, assertions])
	if passed + failed == 0:
		print("No tests found in %s" % TEST_DIR)
		failed = 1
	quit(0 if failed == 0 else 1)
