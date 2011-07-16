APP	= marker
SRCDIR	= coffeescript
JSDIR	= js
SRCS	:= $(shell find $(SRCDIR) -name '*.coffee')
JSS	:= $(patsubst $(SRCDIR)/%.coffee,$(JSDIR)/%.js,$(SRCS))

all: create_js_dir $(APP)
	
$(APP): $(JSS)

$(JSDIR)/%.js: $(SRCDIR)/%.coffee
	coffee -o $(JSDIR) -c $<

create_js_dir:
	mkdir -p $(JSDIR)

clean:
	rm -rf $(JSDIR)


