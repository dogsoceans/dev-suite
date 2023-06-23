/-  linedb,
    spider,
    zig=zig-ziggurat
/+  strandio,
    zig-lib=zig-ziggurat,
    ziggurat-threads=zig-ziggurat-threads,
    ziggurat-system-threads=zig-ziggurat-system-threads
::
=*  strand         strand:spider
=*  get-bowl       get-bowl:strandio
=*  get-time       get-time:strandio
=*  leave-our      leave-our:strandio
=*  poke-our       poke-our:strandio
=*  scry           scry:strandio
=*  send-raw-card  send-raw-card:strandio
=*  sleep          sleep:strandio
=*  take-fact      take-fact:strandio
=*  take-poke      take-poke:strandio
=*  watch-our      watch-our:strandio
::
=/  m  (strand ,vase)
=|  project-name=@t
=|  desk-name=@tas
=|  start=@da
=*  zig-threads
  ~(. ziggurat-threads project-name desk-name ~)
=*  zig-sys-threads
  ~(. ziggurat-system-threads project-name desk-name)
|^  ted
::
+$  arg-mold
  $:  project-name=@t
      desk-name=@tas
      request-id=(unit @t)
      file-path=path
  ==
::
++  return-error
  |=  message=tape
  =/  m  (strand ,vase)
  ^-  form:m
  (pure:m !>(`(each vase tang)`[%| [%leaf message]~]))
::
++  ted
  ^-  thread:spider
  |=  args-vase=vase
  ^-  form:m
  =/  args  !<((unit arg-mold) args-vase)
  ?~  args
    =/  message=tape
      ;:  weld
        "Usage:\0a-suite!ziggurat-build project-name=@t"
        " desk-name=@tas request-id=(unit @t) repo-host=@p"
        " branch-name=@tas commit-hash=(unit @ux)"
        " file-path=path"
      ==
    (return-error message)
  =.  project-name  project-name.u.args
  =.  desk-name     desk-name.u.args
  =*  request-id    request-id.u.args
  =*  file-path     file-path.u.args
  ?~  file-path  (return-error "file-path must be non-~")
  (build:zig-sys-threads file-path ~)
--
