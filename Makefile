#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

# User-level configuration
include Makefile.config
# Contains the list of all the Coq modules
include Makefile.coq_modules

#
CP=cp

FILES = $(addprefix compiler/core/,$(MODULES:%=%.v))

## Compiler
all:
	@$(MAKE) MAKEFLAGS= ergo

# Stdlib

%.ctoj: %.cto
	./scripts/cto2ctoj.js parse $<

compiler/lib/Resources.ml: compiler/stdlib/accordproject.ctoj \
                           compiler/stdlib/stdlib.ergo \
                           compiler/stdlib/etime.ergo \
                           compiler/stdlib/template.ergo \
                           ./runtimes/javascript/ergo-runtime.js
	echo '(* generated ocaml file *)' > compiler/lib/Resources.ml
	(for i in accordproject; do \
         echo "let $$i = {xxx|"; \
         cat compiler/stdlib/$$i.ctoj; \
         echo "|xxx}"; \
         done) >> compiler/lib/Resources.ml
	(for i in stdlib etime template; do \
         echo "let $$i = {xxx|"; \
         cat compiler/stdlib/$$i.ergo; \
         echo "|xxx}"; \
         done) >> compiler/lib/Resources.ml
	(for i in runtime; do \
         echo "let ergo_$$i = {xxx|"; \
         cat ./runtimes/javascript/ergo-$$i.js; \
         echo "|xxx}"; \
         done) >> compiler/lib/Resources.ml
	(echo `date "+let builddate = {xxx|%b %d, %Y|xxx}"`) >> compiler/lib/Resources.ml

# Configure
./runtimes/javascript/ergo_runtime.ml:
	$(MAKE) -C ./runtimes/javascript

./compiler/lib/js_runtime.ml: ./runtimes/javascript/ergo_runtime.ml
	cp ./runtimes/javascript/ergo_runtime.ml ./compiler/lib/js_runtime.ml

./compiler/lib/static_config.ml:
	echo "(* This file is generated *)" > ./compiler/lib/static_config.ml
	echo "let ergo_home = \"$(CURDIR)\"" >> ./compiler/lib/static_config.ml

prepare: ./compiler/lib/js_runtime.ml ./compiler/lib/static_config.ml compiler/lib/Resources.ml Makefile.coq

configure:
	@echo "[Ergo] "
	@echo "[Ergo] Configuring Build"
	@echo "[Ergo] "
	@$(MAKE) prepare
	@$(MAKE) npm-setup

# Regenerate the npm directory
ergo:
	@$(MAKE) ergo-mechanization
	@$(MAKE) MAKEFLAGS= ergo-extraction

ergo-mechanization: _CoqProject Makefile.coq
	@echo "[Ergo] "
	@echo "[Ergo] Compiling Coq Mechanization"
	@echo "[Ergo] "
	@$(MAKE) -f Makefile.coq

ergo-extraction:
	@echo "[Ergo] "
	@echo "[Ergo] Compiling the extracted OCaml"
	@echo "[Ergo] "
	@$(MAKE) -C compiler/extraction
	dune build @install

npm-setup:
	@echo "[Ergo] "
	@echo "[Ergo] Setting up for Node.js build"
	@echo "[Ergo] "
	npm install

## Documentation
documentation:
	$(MAKE) -C compiler/core documentation

## Testing
test:
	lerna run test

## Cleanup
clean-mechanization: Makefile.coq
	- @$(MAKE) -f Makefile.coq clean

cleanall-mechanization:
	- @$(MAKE) -f Makefile.coq cleanall
	- @rm -f Makefile.coq
	- @rm -f Makefile.coq.conf
	- @rm -f _CoqProject
	- @find compiler/core \( -name '*.vo' -or -name '*.v.d' -or -name '*.glob'  -or -name '*.aux' \) -print0 | xargs -0 rm -f

clean-extraction:
	- @$(MAKE) -C compiler/extraction clean

cleanall-extraction:
	- @$(MAKE) -C compiler/extraction cleanall
	- dune clean

clean-npm:
	- @rm -f package-lock.json
	- @rm -rf dist

cleanall-npm: clean-npm
	- @node ./scripts/external/cleanExternalModels.js
	- @rm -f ergo*.tgz
	- @rm -rf node_modules
	- @rm -rf .nyc_output
	- @rm -rf coverage
	- @rm -rf log
	- @rm -f lerna-debug.log

clean: Makefile.coq
	- @$(MAKE) clean-npm
	- @$(MAKE) clean-extraction
	- @$(MAKE) -C packages/ergo-compiler clean
	- @$(MAKE) -C packages/ergo-engine clean
	- @$(MAKE) -C packages/ergo-cli clean

cleanall: Makefile.coq
	@echo "[Ergo] "
	@echo "[Ergo] Cleaning up"
	@echo "[Ergo] "
	- @$(MAKE) cleanall-npm
	- @$(MAKE) cleanall-extraction
	- @$(MAKE) cleanall-mechanization
	- @$(MAKE) -C packages/ergo-compiler cleanall
	- @$(MAKE) -C packages/ergo-engine cleanall
	- @$(MAKE) -C packages/ergo-cli cleanall

##
_CoqProject: Makefile.config
	@echo "[Ergo] "
	@echo "[Ergo] Setting up Coq"
	@echo "[Ergo] "
ifneq ($(QCERT),)
	(echo "-R compiler/core ErgoSpec -R $(QCERT)/coq Qcert";) > _CoqProject
else
	(echo "-R compiler/core ErgoSpec";) > _CoqProject
endif

Makefile.coq: _CoqProject Makefile $(FILES)
	coq_makefile -f _CoqProject $(FILES) -o Makefile.coq

.PHONY: all clean documentation npm ergo

