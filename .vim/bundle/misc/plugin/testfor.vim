" TODO(benkraft): put this in khan-dotfiles
function TestFor(cmd)
  let filenames = system(expand("~/khan/webapp/tools/test_for.py") . " -f " . bufname("%"))
  for filename in split(filenames, "\n")
      execute a:cmd . " " . filename
    endfor
endfunction
command VSplitTest call TestFor("vsplit")
command VSPT VSplitTest
command SplitTest call TestFor("split")
command SPT SplitTest
command EditTest call TestFor("edit")
command ET EditTest
