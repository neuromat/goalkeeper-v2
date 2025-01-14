extends GutTest

func test_should_add_two_integers():
	# given
	var a = 1
	var b = 2
	
	# when
	var result = a + b
	
	# then
	assert_eq(result, 3)
