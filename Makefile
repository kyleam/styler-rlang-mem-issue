
.PHONY: all
all: output/bad.mem.stdout output/good.mem.stdout

output/bad.mem.stdout:
	docker build -t styler-rlang-mem:bad .
	mkdir -p output
	docker run -v $$(pwd)/output:/scratch -it --rm styler-rlang-mem:bad bad

output/good.mem.stdout:
	docker build -t styler-rlang-mem:good \
	  --build-arg RLANG_COMMIT=35e87908418619f70917e191a2d9721c709527d0^ \
	  .
	mkdir -p output
	docker run -v $$(pwd)/output:/scratch -it --rm styler-rlang-mem:good good
