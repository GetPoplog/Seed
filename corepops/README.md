# Corepops

A Poplog installation bootstraps itself from a working Poplog executable. This
directory contains known, working Poplog corepop executables that can be used
for the bootstrapping process.

## Naming Convention for Corepop Images

The naming convention is `<nnn>-<kk_kk_kk>-<yyyy_mm_dd>.corepop`, where:

- `<nnn>` is the preference order (smaller before bigger) initially steps of 10 to
  allow for additions without frequent renumbering. We will need to renumber
  every so often.
- `<kk_kk_kk>` is a kernel number it is known to work on.
- `<yyyy_mm_dd>` is the date it was produced.

For example, `010-05_11_12-2021_07_07.corepop` has:
- `<nnn>` = `010`
- `<kk_kk_kk>` = `05_11_12`
- `<yyyy_mm_dd>` = `2012-07-07`
