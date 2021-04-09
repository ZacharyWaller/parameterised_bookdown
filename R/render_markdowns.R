# name of the parameterised report rmarkdown
rmarkdown_file <- "parameterised_report"

# the parameter we're going to pass to the report
report_cyl <- c(4, 6, 8)

# Run Parameterised Reports ----------------------------------------------------
# run through the cyls and render each version of the report.
# the important part here is "run_pandoc = FALSE" which will leave us with
# a .md file for each report.
markdowns <- lapply(
  report_cyl,
  function(x, filename){
    # this folder will hold our report files - the images for plots etc.
    output_files <- paste(filename, x, sep = "_")

    # name of the underlying, parameterised report to render for each chapter
    rmd_filename <- xfun::with_ext(filename, ".Rmd")

    # render markdown
    # this will create a file called filename.knit.md but the report files will
    # be put in a folder called *output_files*_files
    rmarkdown::render(
      rmd_filename, output_file = output_files,
      params = list(cyl_num = x), run_pandoc = FALSE
    )

    # filename.knit.md will be created by the render
    knit_file <- xfun::with_ext(rmd_filename, ".knit.md")
    # to avoid saving over it each time, rename it
    new_file_name <- xfun::with_ext(output_files, ".knit.md")
    file.rename(knit_file, new_file_name)

    # return our new file name
    new_file_name

  },
  filename = rmarkdown_file
)

# Run index file ---------------------------------------------------------------
# do the same for the index file
index_file <- "index.Rmd"
rmarkdown::render(index_file, run_pandoc = FALSE)
index_file <- xfun::with_ext(index_file, ".knit.md")

# add the index file to the list of other markdowns
markdowns <- append(index_file, markdowns)

# Stitch together markdowns ----------------------------------------------------
# output file
to = "output.Rmd"

# paste the markdowns together
# this is taken from bookdown:::merge_chapters()
content = unlist(mapply(markdowns, markdowns, SIMPLIFY = FALSE, FUN = function(f, o) {
  x = xfun::read_utf8(f)
  # add a comment at the end of each file
  c(x, '', paste0('<!--chapter:end:', o, '-->'), '')
}))

# write to a new file
xfun::write_utf8(content, to)
Sys.chmod(to, '644')

# Render one big Rmarkdown -----------------------------------------------------
rmarkdown::render(to, run_pandoc = TRUE)

# Clean up ---------------------------------------------------------------------
# get rid of all of the extra markdowns we made
file.remove(to)
unlink(unlist(markdowns))
