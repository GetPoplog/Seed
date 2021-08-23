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
| linux/x86_64/010-05_11_12-2021_07_07.corepop | <Container: 7591b6aa46> | 21.04 | :heavy_check_mark: | 0 |  |
| linux/x86_64/010-05_11_12-2021_07_07.corepop | <Container: 1feaf436e9> | 20.04 | :heavy_check_mark: | 0 |  |
| linux/x86_64/010-05_11_12-2021_07_07.corepop | <Container: 4c762e8a69> | 18.04 | :heavy_check_mark: | 0 |  |
| linux/x86_64/010-05_11_12-2021_07_07.corepop | <Container: a3493c2012> | 16.04 | :heavy_check_mark: | 0 |  |
| linux/x86_64/010-05_11_12-2021_07_07.corepop | <Container: 4fbb7dcb80> | latest | :heavy_check_mark: | 0 |  |
| linux/x86_64/010-05_11_12-2021_07_07.corepop | <Container: dcb94f0a20> | unstable-slim | :heavy_check_mark: | 0 |  |
| linux/x86_64/010-05_11_12-2021_07_07.corepop | <Container: 5ac32e134c> | testing-slim | :heavy_check_mark: | 0 |  |
| linux/x86_64/010-05_11_12-2021_07_07.corepop | <Container: 66cc04b2ba> | stable-slim | :heavy_check_mark: | 0 |  |
| linux/x86_64/010-05_11_12-2021_07_07.corepop | <Container: 9c727d4266> | oldstable-slim | :heavy_check_mark: | 0 |  |
| linux/x86_64/010-05_11_12-2021_07_07.corepop | <Container: de9285e2a6> | oldoldstable | :heavy_check_mark: | 0 |  |
| linux/x86_64/010-05_11_12-2021_07_07.corepop | <Container: 8834fb0318> | 34 | :heavy_check_mark: | 0 |  |
| linux/x86_64/010-05_11_12-2021_07_07.corepop | <Container: fe79954087> | 33 | :heavy_check_mark: | 0 |  |
| linux/x86_64/010-05_11_12-2021_07_07.corepop | <Container: c55b269410> | 32 | :heavy_check_mark: | 0 |  |
| linux/x86_64/010-05_11_12-2021_07_07.corepop | <Container: 612a2f34e2> | 8 | :heavy_check_mark: | 0 |  |
| linux/x86_64/010-05_11_12-2021_07_07.corepop | <Container: 4e10243044> | 7 | :heavy_check_mark: | 0 |  |
| linux/x86_64/020-05_08_00-2021_06_24.corepop | <Container: 50070ff527> | 21.04 | :x: | 127 | <details><summary>details</summary><pre>/corepops/linux/x86_64/020-05_08_00-2021_06_24.corepop: error while loading shared libraries: libncurses.so.5: cannot open shared object file: No such file or directory<br></pre></details> |
| linux/x86_64/020-05_08_00-2021_06_24.corepop | <Container: e500df7874> | 20.04 | :x: | 127 | <details><summary>details</summary><pre>/corepops/linux/x86_64/020-05_08_00-2021_06_24.corepop: error while loading shared libraries: libncurses.so.5: cannot open shared object file: No such file or directory<br></pre></details> |
| linux/x86_64/020-05_08_00-2021_06_24.corepop | <Container: 46468ef408> | 18.04 | :x: | 1 | <details><summary>details</summary><pre>/corepops/linux/x86_64/020-05_08_00-2021_06_24.corepop: /lib/x86_64-linux-gnu/libm.so.6: version `GLIBC_2.29' not found (required by /corepops/linux/x86_64/020-05_08_00-2021_06_24.corepop)<br></pre></details> |
| linux/x86_64/020-05_08_00-2021_06_24.corepop | <Container: 58638f35da> | 16.04 | :x: | 1 | <details><summary>details</summary><pre>/corepops/linux/x86_64/020-05_08_00-2021_06_24.corepop: /lib/x86_64-linux-gnu/libm.so.6: version `GLIBC_2.29' not found (required by /corepops/linux/x86_64/020-05_08_00-2021_06_24.corepop)<br></pre></details> |
| linux/x86_64/020-05_08_00-2021_06_24.corepop | <Container: 57f4327656> | latest | :x: | 127 | <details><summary>details</summary><pre>/corepops/linux/x86_64/020-05_08_00-2021_06_24.corepop: error while loading shared libraries: libncurses.so.5: cannot open shared object file: No such file or directory<br></pre></details> |
| linux/x86_64/020-05_08_00-2021_06_24.corepop | <Container: 39553d9679> | unstable-slim | :x: | 127 | <details><summary>details</summary><pre>/corepops/linux/x86_64/020-05_08_00-2021_06_24.corepop: error while loading shared libraries: libncurses.so.5: cannot open shared object file: No such file or directory<br></pre></details> |
| linux/x86_64/020-05_08_00-2021_06_24.corepop | <Container: a3da63fa08> | testing-slim | :x: | 127 | <details><summary>details</summary><pre>/corepops/linux/x86_64/020-05_08_00-2021_06_24.corepop: error while loading shared libraries: libncurses.so.5: cannot open shared object file: No such file or directory<br></pre></details> |
| linux/x86_64/020-05_08_00-2021_06_24.corepop | <Container: 9afb4f4bca> | stable-slim | :x: | 127 | <details><summary>details</summary><pre>/corepops/linux/x86_64/020-05_08_00-2021_06_24.corepop: error while loading shared libraries: libncurses.so.5: cannot open shared object file: No such file or directory<br></pre></details> |
| linux/x86_64/020-05_08_00-2021_06_24.corepop | <Container: 7bd4db09d7> | oldstable-slim | :x: | 127 | <details><summary>details</summary><pre>/corepops/linux/x86_64/020-05_08_00-2021_06_24.corepop: error while loading shared libraries: libncurses.so.5: cannot open shared object file: No such file or directory<br></pre></details> |
| linux/x86_64/020-05_08_00-2021_06_24.corepop | <Container: 768010f23c> | oldoldstable | :x: | 127 | <details><summary>details</summary><pre>/corepops/linux/x86_64/020-05_08_00-2021_06_24.corepop: error while loading shared libraries: libncurses.so.5: cannot open shared object file: No such file or directory<br></pre></details> |
| linux/x86_64/020-05_08_00-2021_06_24.corepop | <Container: 370e6d7b72> | 34 | :x: | 127 | <details><summary>details</summary><pre>/corepops/linux/x86_64/020-05_08_00-2021_06_24.corepop: error while loading shared libraries: libncurses.so.5: cannot open shared object file: No such file or directory<br></pre></details> |
| linux/x86_64/020-05_08_00-2021_06_24.corepop | <Container: 7a170ff071> | 33 | :x: | 127 | <details><summary>details</summary><pre>/corepops/linux/x86_64/020-05_08_00-2021_06_24.corepop: error while loading shared libraries: libncurses.so.5: cannot open shared object file: No such file or directory<br></pre></details> |
| linux/x86_64/020-05_08_00-2021_06_24.corepop | <Container: 5b8df57642> | 32 | :x: | 127 | <details><summary>details</summary><pre>/corepops/linux/x86_64/020-05_08_00-2021_06_24.corepop: error while loading shared libraries: libncurses.so.5: cannot open shared object file: No such file or directory<br></pre></details> |
| linux/x86_64/020-05_08_00-2021_06_24.corepop | <Container: db9a1892ca> | 8 | :x: | 127 | <details><summary>details</summary><pre>/corepops/linux/x86_64/020-05_08_00-2021_06_24.corepop: error while loading shared libraries: libncurses.so.5: cannot open shared object file: No such file or directory<br></pre></details> |
| linux/x86_64/020-05_08_00-2021_06_24.corepop | <Container: 74a50d277d> | 7 | :x: | 1 | <details><summary>details</summary><pre>/corepops/linux/x86_64/020-05_08_00-2021_06_24.corepop: /lib64/libtinfo.so.5: no version information available (required by /corepops/linux/x86_64/020-05_08_00-2021_06_24.corepop)<br>/corepops/linux/x86_64/020-05_08_00-2021_06_24.corepop: /lib64/libm.so.6: version `GLIBC_2.29' not found (required by /corepops/linux/x86_64/020-05_08_00-2021_06_24.corepop)<br></pre></details> |
| linux/x86_64/030-05_04_00-2020_08_22.corepop | <Container: 5c4b48043b> | 21.04 | :heavy_check_mark: | 0 |  |
| linux/x86_64/030-05_04_00-2020_08_22.corepop | <Container: 5c9bff4d12> | 20.04 | :heavy_check_mark: | 0 |  |
| linux/x86_64/030-05_04_00-2020_08_22.corepop | <Container: 0e509dd862> | 18.04 | :heavy_check_mark: | 0 |  |
| linux/x86_64/030-05_04_00-2020_08_22.corepop | <Container: eaed016263> | 16.04 | :heavy_check_mark: | 0 |  |
| linux/x86_64/030-05_04_00-2020_08_22.corepop | <Container: 1d442a3cfc> | latest | :heavy_check_mark: | 0 |  |
| linux/x86_64/030-05_04_00-2020_08_22.corepop | <Container: 0a90fcafe4> | unstable-slim | :heavy_check_mark: | 0 |  |
| linux/x86_64/030-05_04_00-2020_08_22.corepop | <Container: 3a4f7f4030> | testing-slim | :heavy_check_mark: | 0 |  |
| linux/x86_64/030-05_04_00-2020_08_22.corepop | <Container: 9a361bffdb> | stable-slim | :heavy_check_mark: | 0 |  |
| linux/x86_64/030-05_04_00-2020_08_22.corepop | <Container: 6d927be8ef> | oldstable-slim | :heavy_check_mark: | 0 |  |
| linux/x86_64/030-05_04_00-2020_08_22.corepop | <Container: eb2247ad77> | oldoldstable | :heavy_check_mark: | 0 |  |
| linux/x86_64/030-05_04_00-2020_08_22.corepop | <Container: b08f270f6f> | 34 | :heavy_check_mark: | 0 |  |
| linux/x86_64/030-05_04_00-2020_08_22.corepop | <Container: 01252a603a> | 33 | :heavy_check_mark: | 0 |  |
| linux/x86_64/030-05_04_00-2020_08_22.corepop | <Container: 6911fd20d4> | 32 | :heavy_check_mark: | 0 |  |
| linux/x86_64/030-05_04_00-2020_08_22.corepop | <Container: aac6542fa7> | 8 | :heavy_check_mark: | 0 |  |
| linux/x86_64/030-05_04_00-2020_08_22.corepop | <Container: 5a25a7075a> | 7 | :heavy_check_mark: | 0 |  |
| linux/x86_64/040-05_08_00-2021_07_30.corepop | <Container: 1465fbe960> | 21.04 | :x: | 127 | <details><summary>details</summary><pre>/corepops/linux/x86_64/040-05_08_00-2021_07_30.corepop: error while loading shared libraries: libXt.so.6: cannot open shared object file: No such file or directory<br></pre></details> |
| linux/x86_64/040-05_08_00-2021_07_30.corepop | <Container: 5598cf1035> | 20.04 | :x: | 127 | <details><summary>details</summary><pre>/corepops/linux/x86_64/040-05_08_00-2021_07_30.corepop: error while loading shared libraries: libXt.so.6: cannot open shared object file: No such file or directory<br></pre></details> |
| linux/x86_64/040-05_08_00-2021_07_30.corepop | <Container: a45b2017a7> | 18.04 | :x: | 127 | <details><summary>details</summary><pre>/corepops/linux/x86_64/040-05_08_00-2021_07_30.corepop: error while loading shared libraries: libXt.so.6: cannot open shared object file: No such file or directory<br></pre></details> |
| linux/x86_64/040-05_08_00-2021_07_30.corepop | <Container: 089be59dbf> | 16.04 | :x: | 127 | <details><summary>details</summary><pre>/corepops/linux/x86_64/040-05_08_00-2021_07_30.corepop: error while loading shared libraries: libXt.so.6: cannot open shared object file: No such file or directory<br></pre></details> |
| linux/x86_64/040-05_08_00-2021_07_30.corepop | <Container: 6ae7f8160e> | latest | :x: | 127 | <details><summary>details</summary><pre>/corepops/linux/x86_64/040-05_08_00-2021_07_30.corepop: error while loading shared libraries: libXt.so.6: cannot open shared object file: No such file or directory<br></pre></details> |
| linux/x86_64/040-05_08_00-2021_07_30.corepop | <Container: 8904557e44> | unstable-slim | :x: | 127 | <details><summary>details</summary><pre>/corepops/linux/x86_64/040-05_08_00-2021_07_30.corepop: error while loading shared libraries: libXt.so.6: cannot open shared object file: No such file or directory<br></pre></details> |
| linux/x86_64/040-05_08_00-2021_07_30.corepop | <Container: 9b346d3978> | testing-slim | :x: | 127 | <details><summary>details</summary><pre>/corepops/linux/x86_64/040-05_08_00-2021_07_30.corepop: error while loading shared libraries: libXt.so.6: cannot open shared object file: No such file or directory<br></pre></details> |
| linux/x86_64/040-05_08_00-2021_07_30.corepop | <Container: dff795257c> | stable-slim | :x: | 127 | <details><summary>details</summary><pre>/corepops/linux/x86_64/040-05_08_00-2021_07_30.corepop: error while loading shared libraries: libXt.so.6: cannot open shared object file: No such file or directory<br></pre></details> |
| linux/x86_64/040-05_08_00-2021_07_30.corepop | <Container: 27c6884e97> | oldstable-slim | :x: | 127 | <details><summary>details</summary><pre>/corepops/linux/x86_64/040-05_08_00-2021_07_30.corepop: error while loading shared libraries: libXt.so.6: cannot open shared object file: No such file or directory<br></pre></details> |
| linux/x86_64/040-05_08_00-2021_07_30.corepop | <Container: 0bfae249c7> | oldoldstable | :x: | 127 | <details><summary>details</summary><pre>/corepops/linux/x86_64/040-05_08_00-2021_07_30.corepop: error while loading shared libraries: libXt.so.6: cannot open shared object file: No such file or directory<br></pre></details> |
| linux/x86_64/040-05_08_00-2021_07_30.corepop | <Container: c08ee04dce> | 34 | :x: | 127 | <details><summary>details</summary><pre>/corepops/linux/x86_64/040-05_08_00-2021_07_30.corepop: error while loading shared libraries: libXt.so.6: cannot open shared object file: No such file or directory<br></pre></details> |
| linux/x86_64/040-05_08_00-2021_07_30.corepop | <Container: 3d2dba3293> | 33 | :x: | 127 | <details><summary>details</summary><pre>/corepops/linux/x86_64/040-05_08_00-2021_07_30.corepop: error while loading shared libraries: libXt.so.6: cannot open shared object file: No such file or directory<br></pre></details> |
| linux/x86_64/040-05_08_00-2021_07_30.corepop | <Container: 8dd4fb90a9> | 32 | :x: | 127 | <details><summary>details</summary><pre>/corepops/linux/x86_64/040-05_08_00-2021_07_30.corepop: error while loading shared libraries: libXt.so.6: cannot open shared object file: No such file or directory<br></pre></details> |
| linux/x86_64/040-05_08_00-2021_07_30.corepop | <Container: 00e9c8194b> | 8 | :x: | 127 | <details><summary>details</summary><pre>/corepops/linux/x86_64/040-05_08_00-2021_07_30.corepop: error while loading shared libraries: libXt.so.6: cannot open shared object file: No such file or directory<br></pre></details> |
| linux/x86_64/040-05_08_00-2021_07_30.corepop | <Container: 127fa8ba1a> | 7 | :x: | 127 | <details><summary>details</summary><pre>/corepops/linux/x86_64/040-05_08_00-2021_07_30.corepop: error while loading shared libraries: libXt.so.6: cannot open shared object file: No such file or directory<br></pre></details> |
| linux/x86_64/050-04_04_00-2020_00_00.corepop | <Container: 0edf6dd192> | 21.04 | :x: | 127 | <details><summary>details</summary><pre>/corepops/linux/x86_64/050-04_04_00-2020_00_00.corepop: error while loading shared libraries: libncurses.so.5: cannot open shared object file: No such file or directory<br></pre></details> |
| linux/x86_64/050-04_04_00-2020_00_00.corepop | <Container: 85037fb632> | 20.04 | :x: | 127 | <details><summary>details</summary><pre>/corepops/linux/x86_64/050-04_04_00-2020_00_00.corepop: error while loading shared libraries: libncurses.so.5: cannot open shared object file: No such file or directory<br></pre></details> |
| linux/x86_64/050-04_04_00-2020_00_00.corepop | <Container: 03b84f8b0d> | 18.04 | :heavy_check_mark: | 0 |  |
| linux/x86_64/050-04_04_00-2020_00_00.corepop | <Container: f76aba8d8a> | 16.04 | :heavy_check_mark: | 0 |  |
| linux/x86_64/050-04_04_00-2020_00_00.corepop | <Container: 34cb2fe53d> | latest | :x: | 127 | <details><summary>details</summary><pre>/corepops/linux/x86_64/050-04_04_00-2020_00_00.corepop: error while loading shared libraries: libncurses.so.5: cannot open shared object file: No such file or directory<br></pre></details> |
| linux/x86_64/050-04_04_00-2020_00_00.corepop | <Container: bca6d0971f> | unstable-slim | :x: | 127 | <details><summary>details</summary><pre>/corepops/linux/x86_64/050-04_04_00-2020_00_00.corepop: error while loading shared libraries: libncurses.so.5: cannot open shared object file: No such file or directory<br></pre></details> |
| linux/x86_64/050-04_04_00-2020_00_00.corepop | <Container: 6515756a1d> | testing-slim | :x: | 127 | <details><summary>details</summary><pre>/corepops/linux/x86_64/050-04_04_00-2020_00_00.corepop: error while loading shared libraries: libncurses.so.5: cannot open shared object file: No such file or directory<br></pre></details> |
| linux/x86_64/050-04_04_00-2020_00_00.corepop | <Container: 805bfa5926> | stable-slim | :x: | 127 | <details><summary>details</summary><pre>/corepops/linux/x86_64/050-04_04_00-2020_00_00.corepop: error while loading shared libraries: libncurses.so.5: cannot open shared object file: No such file or directory<br></pre></details> |
| linux/x86_64/050-04_04_00-2020_00_00.corepop | <Container: 044da99f7f> | oldstable-slim | :x: | 127 | <details><summary>details</summary><pre>/corepops/linux/x86_64/050-04_04_00-2020_00_00.corepop: error while loading shared libraries: libncurses.so.5: cannot open shared object file: No such file or directory<br></pre></details> |
| linux/x86_64/050-04_04_00-2020_00_00.corepop | <Container: 024b9e34a2> | oldoldstable | :x: | 127 | <details><summary>details</summary><pre>/corepops/linux/x86_64/050-04_04_00-2020_00_00.corepop: error while loading shared libraries: libncurses.so.5: cannot open shared object file: No such file or directory<br></pre></details> |
| linux/x86_64/050-04_04_00-2020_00_00.corepop | <Container: 0fa61a11b7> | 34 | :x: | 127 | <details><summary>details</summary><pre>/corepops/linux/x86_64/050-04_04_00-2020_00_00.corepop: error while loading shared libraries: libncurses.so.5: cannot open shared object file: No such file or directory<br></pre></details> |
| linux/x86_64/050-04_04_00-2020_00_00.corepop | <Container: cf6bafbcd5> | 33 | :x: | 127 | <details><summary>details</summary><pre>/corepops/linux/x86_64/050-04_04_00-2020_00_00.corepop: error while loading shared libraries: libncurses.so.5: cannot open shared object file: No such file or directory<br></pre></details> |
| linux/x86_64/050-04_04_00-2020_00_00.corepop | <Container: da55b5f38b> | 32 | :x: | 127 | <details><summary>details</summary><pre>/corepops/linux/x86_64/050-04_04_00-2020_00_00.corepop: error while loading shared libraries: libncurses.so.5: cannot open shared object file: No such file or directory<br></pre></details> |
| linux/x86_64/050-04_04_00-2020_00_00.corepop | <Container: da21943e63> | 8 | :x: | 127 | <details><summary>details</summary><pre>/corepops/linux/x86_64/050-04_04_00-2020_00_00.corepop: error while loading shared libraries: libncurses.so.5: cannot open shared object file: No such file or directory<br></pre></details> |
| linux/x86_64/050-04_04_00-2020_00_00.corepop | <Container: 0253685a81> | 7 | :x: | 0 | <details><summary>details</summary><pre>/corepops/linux/x86_64/050-04_04_00-2020_00_00.corepop: /lib64/libtinfo.so.5: no version information available (required by /corepops/linux/x86_64/050-04_04_00-2020_00_00.corepop)<br>/corepops/linux/x86_64/050-04_04_00-2020_00_00.corepop: /lib64/libtinfo.so.5: no version information available (required by /corepops/linux/x86_64/050-04_04_00-2020_00_00.corepop)<br></pre></details> |
<!--END COREPOP_TEST_RESULTS-->
