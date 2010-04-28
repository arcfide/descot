#! /usr/bin/env scheme-script
 
(import (chezscheme))
 
(make-boot-file "descot-packager.boot"
  '("petite")
  "/home/arcfide/code/arcfide/chezweb/cheztangle.ss"
  "/home/arcfide/code/arcfide/extended-definitions.sls"
  "packager.w")
