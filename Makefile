ERL=erl
ERLC=erlc
APP=http
REBAR=./rebar

all: compile

get-deps:
	@$(REBAR) get-deps

compile: get-deps
	@$(REBAR) compile

clean:
	@echo "removing:"
	@$(REBAR) clean

docs:
	@$(ERL) -noshell -run edoc_run application '$(APP)' '"."' '[]'

clean-docs:
	@echo "removing:"
	@rm -fv doc/edoc-info doc/*.html doc/*.css doc/*.png

run: compile
	@$(ERL) -pa ebin deps/*/ebin -s $(APP)

test: compile
	@$(REBAR) eunit

