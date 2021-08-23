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

## Corepop test results

<!--BEGIN COREPOP_TEST_RESULTS-->
| Corepop | Distribution | Version | Pass | Exit code | Logs |
| ------- | ------------ | ------- | ---- | --------- | ---- |
| linux/x86_64/010-05_11_12-2021_07_07.corepop | ubuntu | 21.04 | :heavy_check_mark: | 0 |  |
| linux/x86_64/010-05_11_12-2021_07_07.corepop | ubuntu | 20.04 | :heavy_check_mark: | 0 |  |
| linux/x86_64/010-05_11_12-2021_07_07.corepop | ubuntu | 18.04 | :heavy_check_mark: | 0 |  |
| linux/x86_64/010-05_11_12-2021_07_07.corepop | ubuntu | 16.04 | :heavy_check_mark: | 0 |  |
| linux/x86_64/010-05_11_12-2021_07_07.corepop | archlinux | latest | :heavy_check_mark: | 0 |  |
| linux/x86_64/010-05_11_12-2021_07_07.corepop | debian | unstable-slim | :heavy_check_mark: | 0 |  |
| linux/x86_64/010-05_11_12-2021_07_07.corepop | debian | testing-slim | :heavy_check_mark: | 0 |  |
| linux/x86_64/010-05_11_12-2021_07_07.corepop | debian | stable-slim | :heavy_check_mark: | 0 |  |
| linux/x86_64/010-05_11_12-2021_07_07.corepop | debian | oldstable-slim | :heavy_check_mark: | 0 |  |
| linux/x86_64/010-05_11_12-2021_07_07.corepop | debian | oldoldstable | :heavy_check_mark: | 0 |  |
| linux/x86_64/010-05_11_12-2021_07_07.corepop | fedora | 34 | :heavy_check_mark: | 0 |  |
| linux/x86_64/010-05_11_12-2021_07_07.corepop | fedora | 33 | :heavy_check_mark: | 0 |  |
| linux/x86_64/010-05_11_12-2021_07_07.corepop | fedora | 32 | :heavy_check_mark: | 0 |  |
| linux/x86_64/010-05_11_12-2021_07_07.corepop | centos | 8 | :heavy_check_mark: | 0 |  |
| linux/x86_64/010-05_11_12-2021_07_07.corepop | centos | 7 | :heavy_check_mark: | 0 |  |
| linux/x86_64/020-05_08_00-2021_06_24.corepop | ubuntu | 21.04 | :x: | 127 | <details><summary>details</summary><pre>/corepops/linux/x86_64/020-05_08_00-2021_06_24.corepop: error while loading shared libraries: libncurses.so.5: cannot open shared object file: No such file or directory<br></pre></details> |
| linux/x86_64/020-05_08_00-2021_06_24.corepop | ubuntu | 20.04 | :x: | 127 | <details><summary>details</summary><pre>/corepops/linux/x86_64/020-05_08_00-2021_06_24.corepop: error while loading shared libraries: libncurses.so.5: cannot open shared object file: No such file or directory<br></pre></details> |
| linux/x86_64/020-05_08_00-2021_06_24.corepop | ubuntu | 18.04 | :x: | 1 | <details><summary>details</summary><pre>/corepops/linux/x86_64/020-05_08_00-2021_06_24.corepop: /lib/x86_64-linux-gnu/libm.so.6: version `GLIBC_2.29' not found (required by /corepops/linux/x86_64/020-05_08_00-2021_06_24.corepop)<br></pre></details> |
| linux/x86_64/020-05_08_00-2021_06_24.corepop | ubuntu | 16.04 | :x: | 1 | <details><summary>details</summary><pre>/corepops/linux/x86_64/020-05_08_00-2021_06_24.corepop: /lib/x86_64-linux-gnu/libm.so.6: version `GLIBC_2.29' not found (required by /corepops/linux/x86_64/020-05_08_00-2021_06_24.corepop)<br></pre></details> |
| linux/x86_64/020-05_08_00-2021_06_24.corepop | archlinux | latest | :x: | 127 | <details><summary>details</summary><pre>/corepops/linux/x86_64/020-05_08_00-2021_06_24.corepop: error while loading shared libraries: libncurses.so.5: cannot open shared object file: No such file or directory<br></pre></details> |
| linux/x86_64/020-05_08_00-2021_06_24.corepop | debian | unstable-slim | :x: | 127 | <details><summary>details</summary><pre>/corepops/linux/x86_64/020-05_08_00-2021_06_24.corepop: error while loading shared libraries: libncurses.so.5: cannot open shared object file: No such file or directory<br></pre></details> |
| linux/x86_64/020-05_08_00-2021_06_24.corepop | debian | testing-slim | :x: | 127 | <details><summary>details</summary><pre>/corepops/linux/x86_64/020-05_08_00-2021_06_24.corepop: error while loading shared libraries: libncurses.so.5: cannot open shared object file: No such file or directory<br></pre></details> |
| linux/x86_64/020-05_08_00-2021_06_24.corepop | debian | stable-slim | :x: | 127 | <details><summary>details</summary><pre>/corepops/linux/x86_64/020-05_08_00-2021_06_24.corepop: error while loading shared libraries: libncurses.so.5: cannot open shared object file: No such file or directory<br></pre></details> |
| linux/x86_64/020-05_08_00-2021_06_24.corepop | debian | oldstable-slim | :x: | 127 | <details><summary>details</summary><pre>/corepops/linux/x86_64/020-05_08_00-2021_06_24.corepop: error while loading shared libraries: libncurses.so.5: cannot open shared object file: No such file or directory<br></pre></details> |
| linux/x86_64/020-05_08_00-2021_06_24.corepop | debian | oldoldstable | :x: | 127 | <details><summary>details</summary><pre>/corepops/linux/x86_64/020-05_08_00-2021_06_24.corepop: error while loading shared libraries: libncurses.so.5: cannot open shared object file: No such file or directory<br></pre></details> |
| linux/x86_64/020-05_08_00-2021_06_24.corepop | fedora | 34 | :x: | 127 | <details><summary>details</summary><pre>/corepops/linux/x86_64/020-05_08_00-2021_06_24.corepop: error while loading shared libraries: libncurses.so.5: cannot open shared object file: No such file or directory<br></pre></details> |
| linux/x86_64/020-05_08_00-2021_06_24.corepop | fedora | 33 | :x: | 127 | <details><summary>details</summary><pre>/corepops/linux/x86_64/020-05_08_00-2021_06_24.corepop: error while loading shared libraries: libncurses.so.5: cannot open shared object file: No such file or directory<br></pre></details> |
| linux/x86_64/020-05_08_00-2021_06_24.corepop | fedora | 32 | :x: | 127 | <details><summary>details</summary><pre>/corepops/linux/x86_64/020-05_08_00-2021_06_24.corepop: error while loading shared libraries: libncurses.so.5: cannot open shared object file: No such file or directory<br></pre></details> |
| linux/x86_64/020-05_08_00-2021_06_24.corepop | centos | 8 | :x: | 127 | <details><summary>details</summary><pre>/corepops/linux/x86_64/020-05_08_00-2021_06_24.corepop: error while loading shared libraries: libncurses.so.5: cannot open shared object file: No such file or directory<br></pre></details> |
| linux/x86_64/020-05_08_00-2021_06_24.corepop | centos | 7 | :x: | 1 | <details><summary>details</summary><pre>/corepops/linux/x86_64/020-05_08_00-2021_06_24.corepop: /lib64/libtinfo.so.5: no version information available (required by /corepops/linux/x86_64/020-05_08_00-2021_06_24.corepop)<br>/corepops/linux/x86_64/020-05_08_00-2021_06_24.corepop: /lib64/libm.so.6: version `GLIBC_2.29' not found (required by /corepops/linux/x86_64/020-05_08_00-2021_06_24.corepop)<br></pre></details> |
| linux/x86_64/030-05_04_00-2020_08_22.corepop | ubuntu | 21.04 | :heavy_check_mark: | 0 |  |
| linux/x86_64/030-05_04_00-2020_08_22.corepop | ubuntu | 20.04 | :heavy_check_mark: | 0 |  |
| linux/x86_64/030-05_04_00-2020_08_22.corepop | ubuntu | 18.04 | :heavy_check_mark: | 0 |  |
| linux/x86_64/030-05_04_00-2020_08_22.corepop | ubuntu | 16.04 | :heavy_check_mark: | 0 |  |
| linux/x86_64/030-05_04_00-2020_08_22.corepop | archlinux | latest | :heavy_check_mark: | 0 |  |
| linux/x86_64/030-05_04_00-2020_08_22.corepop | debian | unstable-slim | :heavy_check_mark: | 0 |  |
| linux/x86_64/030-05_04_00-2020_08_22.corepop | debian | testing-slim | :heavy_check_mark: | 0 |  |
| linux/x86_64/030-05_04_00-2020_08_22.corepop | debian | stable-slim | :heavy_check_mark: | 0 |  |
| linux/x86_64/030-05_04_00-2020_08_22.corepop | debian | oldstable-slim | :heavy_check_mark: | 0 |  |
| linux/x86_64/030-05_04_00-2020_08_22.corepop | debian | oldoldstable | :heavy_check_mark: | 0 |  |
| linux/x86_64/030-05_04_00-2020_08_22.corepop | fedora | 34 | :heavy_check_mark: | 0 |  |
| linux/x86_64/030-05_04_00-2020_08_22.corepop | fedora | 33 | :heavy_check_mark: | 0 |  |
| linux/x86_64/030-05_04_00-2020_08_22.corepop | fedora | 32 | :heavy_check_mark: | 0 |  |
| linux/x86_64/030-05_04_00-2020_08_22.corepop | centos | 8 | :heavy_check_mark: | 0 |  |
| linux/x86_64/030-05_04_00-2020_08_22.corepop | centos | 7 | :heavy_check_mark: | 0 |  |
| linux/x86_64/040-05_08_00-2021_07_30.corepop | ubuntu | 21.04 | :x: | 127 | <details><summary>details</summary><pre>/corepops/linux/x86_64/040-05_08_00-2021_07_30.corepop: error while loading shared libraries: libXt.so.6: cannot open shared object file: No such file or directory<br></pre></details> |
| linux/x86_64/040-05_08_00-2021_07_30.corepop | ubuntu | 20.04 | :x: | 127 | <details><summary>details</summary><pre>/corepops/linux/x86_64/040-05_08_00-2021_07_30.corepop: error while loading shared libraries: libXt.so.6: cannot open shared object file: No such file or directory<br></pre></details> |
| linux/x86_64/040-05_08_00-2021_07_30.corepop | ubuntu | 18.04 | :x: | 127 | <details><summary>details</summary><pre>/corepops/linux/x86_64/040-05_08_00-2021_07_30.corepop: error while loading shared libraries: libXt.so.6: cannot open shared object file: No such file or directory<br></pre></details> |
| linux/x86_64/040-05_08_00-2021_07_30.corepop | ubuntu | 16.04 | :x: | 127 | <details><summary>details</summary><pre>/corepops/linux/x86_64/040-05_08_00-2021_07_30.corepop: error while loading shared libraries: libXt.so.6: cannot open shared object file: No such file or directory<br></pre></details> |
| linux/x86_64/040-05_08_00-2021_07_30.corepop | archlinux | latest | :x: | 127 | <details><summary>details</summary><pre>/corepops/linux/x86_64/040-05_08_00-2021_07_30.corepop: error while loading shared libraries: libXt.so.6: cannot open shared object file: No such file or directory<br></pre></details> |
| linux/x86_64/040-05_08_00-2021_07_30.corepop | debian | unstable-slim | :x: | 127 | <details><summary>details</summary><pre>/corepops/linux/x86_64/040-05_08_00-2021_07_30.corepop: error while loading shared libraries: libXt.so.6: cannot open shared object file: No such file or directory<br></pre></details> |
| linux/x86_64/040-05_08_00-2021_07_30.corepop | debian | testing-slim | :x: | 127 | <details><summary>details</summary><pre>/corepops/linux/x86_64/040-05_08_00-2021_07_30.corepop: error while loading shared libraries: libXt.so.6: cannot open shared object file: No such file or directory<br></pre></details> |
| linux/x86_64/040-05_08_00-2021_07_30.corepop | debian | stable-slim | :x: | 127 | <details><summary>details</summary><pre>/corepops/linux/x86_64/040-05_08_00-2021_07_30.corepop: error while loading shared libraries: libXt.so.6: cannot open shared object file: No such file or directory<br></pre></details> |
| linux/x86_64/040-05_08_00-2021_07_30.corepop | debian | oldstable-slim | :x: | 127 | <details><summary>details</summary><pre>/corepops/linux/x86_64/040-05_08_00-2021_07_30.corepop: error while loading shared libraries: libXt.so.6: cannot open shared object file: No such file or directory<br></pre></details> |
| linux/x86_64/040-05_08_00-2021_07_30.corepop | debian | oldoldstable | :x: | 127 | <details><summary>details</summary><pre>/corepops/linux/x86_64/040-05_08_00-2021_07_30.corepop: error while loading shared libraries: libXt.so.6: cannot open shared object file: No such file or directory<br></pre></details> |
| linux/x86_64/040-05_08_00-2021_07_30.corepop | fedora | 34 | :x: | 127 | <details><summary>details</summary><pre>/corepops/linux/x86_64/040-05_08_00-2021_07_30.corepop: error while loading shared libraries: libXt.so.6: cannot open shared object file: No such file or directory<br></pre></details> |
| linux/x86_64/040-05_08_00-2021_07_30.corepop | fedora | 33 | :x: | 127 | <details><summary>details</summary><pre>/corepops/linux/x86_64/040-05_08_00-2021_07_30.corepop: error while loading shared libraries: libXt.so.6: cannot open shared object file: No such file or directory<br></pre></details> |
| linux/x86_64/040-05_08_00-2021_07_30.corepop | fedora | 32 | :x: | 127 | <details><summary>details</summary><pre>/corepops/linux/x86_64/040-05_08_00-2021_07_30.corepop: error while loading shared libraries: libXt.so.6: cannot open shared object file: No such file or directory<br></pre></details> |
| linux/x86_64/040-05_08_00-2021_07_30.corepop | centos | 8 | :x: | 127 | <details><summary>details</summary><pre>/corepops/linux/x86_64/040-05_08_00-2021_07_30.corepop: error while loading shared libraries: libXt.so.6: cannot open shared object file: No such file or directory<br></pre></details> |
| linux/x86_64/040-05_08_00-2021_07_30.corepop | centos | 7 | :x: | 127 | <details><summary>details</summary><pre>/corepops/linux/x86_64/040-05_08_00-2021_07_30.corepop: error while loading shared libraries: libXt.so.6: cannot open shared object file: No such file or directory<br></pre></details> |
| linux/x86_64/050-04_04_00-2020_00_00.corepop | ubuntu | 21.04 | :x: | 127 | <details><summary>details</summary><pre>/corepops/linux/x86_64/050-04_04_00-2020_00_00.corepop: error while loading shared libraries: libncurses.so.5: cannot open shared object file: No such file or directory<br></pre></details> |
| linux/x86_64/050-04_04_00-2020_00_00.corepop | ubuntu | 20.04 | :x: | 127 | <details><summary>details</summary><pre>/corepops/linux/x86_64/050-04_04_00-2020_00_00.corepop: error while loading shared libraries: libncurses.so.5: cannot open shared object file: No such file or directory<br></pre></details> |
| linux/x86_64/050-04_04_00-2020_00_00.corepop | ubuntu | 18.04 | :heavy_check_mark: | 0 |  |
| linux/x86_64/050-04_04_00-2020_00_00.corepop | ubuntu | 16.04 | :heavy_check_mark: | 0 |  |
| linux/x86_64/050-04_04_00-2020_00_00.corepop | archlinux | latest | :x: | 127 | <details><summary>details</summary><pre>/corepops/linux/x86_64/050-04_04_00-2020_00_00.corepop: error while loading shared libraries: libncurses.so.5: cannot open shared object file: No such file or directory<br></pre></details> |
| linux/x86_64/050-04_04_00-2020_00_00.corepop | debian | unstable-slim | :x: | 127 | <details><summary>details</summary><pre>/corepops/linux/x86_64/050-04_04_00-2020_00_00.corepop: error while loading shared libraries: libncurses.so.5: cannot open shared object file: No such file or directory<br></pre></details> |
| linux/x86_64/050-04_04_00-2020_00_00.corepop | debian | testing-slim | :x: | 127 | <details><summary>details</summary><pre>/corepops/linux/x86_64/050-04_04_00-2020_00_00.corepop: error while loading shared libraries: libncurses.so.5: cannot open shared object file: No such file or directory<br></pre></details> |
| linux/x86_64/050-04_04_00-2020_00_00.corepop | debian | stable-slim | :x: | 127 | <details><summary>details</summary><pre>/corepops/linux/x86_64/050-04_04_00-2020_00_00.corepop: error while loading shared libraries: libncurses.so.5: cannot open shared object file: No such file or directory<br></pre></details> |
| linux/x86_64/050-04_04_00-2020_00_00.corepop | debian | oldstable-slim | :x: | 127 | <details><summary>details</summary><pre>/corepops/linux/x86_64/050-04_04_00-2020_00_00.corepop: error while loading shared libraries: libncurses.so.5: cannot open shared object file: No such file or directory<br></pre></details> |
| linux/x86_64/050-04_04_00-2020_00_00.corepop | debian | oldoldstable | :x: | 127 | <details><summary>details</summary><pre>/corepops/linux/x86_64/050-04_04_00-2020_00_00.corepop: error while loading shared libraries: libncurses.so.5: cannot open shared object file: No such file or directory<br></pre></details> |
| linux/x86_64/050-04_04_00-2020_00_00.corepop | fedora | 34 | :x: | 127 | <details><summary>details</summary><pre>/corepops/linux/x86_64/050-04_04_00-2020_00_00.corepop: error while loading shared libraries: libncurses.so.5: cannot open shared object file: No such file or directory<br></pre></details> |
| linux/x86_64/050-04_04_00-2020_00_00.corepop | fedora | 33 | :x: | 127 | <details><summary>details</summary><pre>/corepops/linux/x86_64/050-04_04_00-2020_00_00.corepop: error while loading shared libraries: libncurses.so.5: cannot open shared object file: No such file or directory<br></pre></details> |
| linux/x86_64/050-04_04_00-2020_00_00.corepop | fedora | 32 | :x: | 127 | <details><summary>details</summary><pre>/corepops/linux/x86_64/050-04_04_00-2020_00_00.corepop: error while loading shared libraries: libncurses.so.5: cannot open shared object file: No such file or directory<br></pre></details> |
| linux/x86_64/050-04_04_00-2020_00_00.corepop | centos | 8 | :x: | 127 | <details><summary>details</summary><pre>/corepops/linux/x86_64/050-04_04_00-2020_00_00.corepop: error while loading shared libraries: libncurses.so.5: cannot open shared object file: No such file or directory<br></pre></details> |
| linux/x86_64/050-04_04_00-2020_00_00.corepop | centos | 7 | :x: | 0 | <details><summary>details</summary><pre>/corepops/linux/x86_64/050-04_04_00-2020_00_00.corepop: /lib64/libtinfo.so.5: no version information available (required by /corepops/linux/x86_64/050-04_04_00-2020_00_00.corepop)<br>/corepops/linux/x86_64/050-04_04_00-2020_00_00.corepop: /lib64/libtinfo.so.5: no version information available (required by /corepops/linux/x86_64/050-04_04_00-2020_00_00.corepop)<br></pre></details> |
<!--END COREPOP_TEST_RESULTS-->
