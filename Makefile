
output/mem.svg: output/bad.mem.stdout
output/mem.svg: output/good.mem.stdout
output/mem.svg: output/latest.mem.stdout
output/mem.svg: plot-mem.R
	Rscript plot-mem.R

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

output/latest.mem.stdout:
	docker build -t styler-rlang-mem:latest \
	  --build-arg CRAN=https://packagemanager.rstudio.com/cran/__linux__/focal/2023-05-12+bqFWVFWh \
	  --build-arg RLANG_COMMIT=194c085b03138edc486efecdf86ebb7604bd6bc8 \
	  .
	mkdir -p output
	docker run -v $$(pwd)/output:/scratch -it --rm styler-rlang-mem:latest latest
