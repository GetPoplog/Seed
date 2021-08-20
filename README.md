# Corepops

A Poplog installation bootstraps itself from a working Poplog executable. This 
repository contains known, working Poplog corepop executables that can be used
for the bootstrapping process. This repository is used by the scripts of the 
Seed repository.

## Naming Convention for Corepop Images

The naming convention is nnn-kk_kk_kk-yyyy_mm_dd.corepop, where:

- nnn is the preference order (smaller before bigger) initially steps of 10 to allow for additions without frequent renumbering. We will need to renumber every so often.
- kk_kk_kk is a kernel number it is known to work on.
- yyyy_mm_dd is the date it was produced.
