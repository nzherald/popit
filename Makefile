
# note - this needs to be default so that the nodeunit process will exit with
# error if tests fail. Otherwise make will not abort.
REPORTER = default 

LINT    = ./node_modules/.bin/jslint --indent 2 --white --nomen
FOREVER = ./node_modules/.bin/forever

WAIT_FOR_SERVER   = sleep 5 # FIXME - use something more elegant
START_TEST_SERVER = NODE_ENV=testing $(FOREVER) start server.js && $(WAIT_FOR_SERVER)
STOP_TEST_SERVER  = $(FOREVER) stop server.js


all: npm-install


npm-install:
	npm install

npm-update:
	rm npm-shrinkwrap.json
	npm update
	npm shrinkwrap


lint:
	find lib          -name '*.js' | xargs -n 1 $(LINT) --node --
	find instance-app -name '*.js' | xargs -n 1 $(LINT) --node --
	find hosting-app  -name '*.js' | xargs -n 1 $(LINT) --node --
	find public/js    -name '*.js' | xargs -n 1 $(LINT) --browser --


scss:
	compass compile

minify:
	rm -rf public-minified
	node_modules/.bin/r.js -o public/js/app.build.js
	rm    public-minified/build.txt
	rm    public-minified/js/app.build.js 
	rm -r public-minified/sass/


tidy:
	# this should tidy, but not implemented yet
	# The output is not as nice as I'd like
	# sass-convert --recursive --in-place --from scss --to scss public/sass/


test: npm-install test-unit test-api test-browser

test-unit:
	@NODE_ENV=testing ./node_modules/.bin/nodeunit \
		--reporter $(REPORTER) \
		tests/unit


test-browser: scss minify
	$(START_TEST_SERVER)
	@NODE_ENV=testing ruby tests/browser_based/run_tests.rb
	$(STOP_TEST_SERVER)
	echo "ALL TESTS PASSED"


test-api:
	@NODE_ENV=testing ./node_modules/.bin/nodeunit \
		--reporter $(REPORTER) \
		tests/api

clean:
	rm -rfv .sass-cache


.PHONY: test test-unit test-browser test-api scss minify clean tidy npm-install npm-update

