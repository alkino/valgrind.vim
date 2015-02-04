if !exists(":Valgrind")
    command -nargs=1 -complete=file Valgrind call s:Valgrind(<f-args>)
endif

function s:ExtractError(filexml, fileerr)
python << EOF
import xml.etree.ElementTree as ET
root = ET.parse(vim.eval("a:filexml")).getroot()

with open(vim.eval("a:fileerr"), "w") as h:
    for i in root.iter('error'):
        s=""
        if i.find("stack") is not None:
            frames = i.find("stack").findall("frame")[::-1]
            for n, frame in enumerate(frames):
                # Choice the last frame if frames available
                s+=str(n+1) + ":"
                if frame.find("dir") is not None:
                    s+=frame.find("dir").text+os.path.sep
                if frame.find("file") is not None:
                    s+=frame.find("file").text
                s+=":"
                if frame.find("line") is not None:
                    s+=frame.find("line").text
                else:
                    s+=":"
                s+=":"
                if i.find("what") is not None:
                    s+=i.find("what").text
                elif i.find("xwhat") is not None:
                    s+=i.find("xwhat").find("text").text
                s+="\n"
                h.write(s)
EOF
endfunction

function s:Valgrind(...)
    let tmpfilexml = tempname()
    let tmpfileerror = tempname()
    "
    " construct the commandline and execute it
    let run_valgrind='!'
    if exists("g:valgrind_command")
	let run_valgrind .= g:valgrind_command
    else
	let run_valgrind .= 'valgrind'
    endif
    if exists("g:valgrind_arguments")
	let run_valgrind .= ' ' . g:valgrind_arguments
    else
	let run_valgrind .= ' --num-callers=500'
    endif
    let run_valgrind .= ' --xml=yes --xml-file=' . tmpfilexml
    for arg_ in a:000
        let run_valgrind .= ' ' . arg_
    endfor
    execute run_valgrind
    call s:ExtractError(tmpfilexml, tmpfileerror)

    setlocal errorformat=%n:%f:%l:%m
    execute "cfile ".tmpfileerror
endfunction
