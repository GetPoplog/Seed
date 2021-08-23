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
| linux/x86_64/010-05_11_12-2021_07_07.corepop | <Container: eea33928ff> | 21.04 | :heavy_check_mark: | 0 |  |
| linux/x86_64/010-05_11_12-2021_07_07.corepop | <Container: 694840a607> | 20.04 | :heavy_check_mark: | 0 |  |
| linux/x86_64/010-05_11_12-2021_07_07.corepop | <Container: f3f8a64226> | 18.04 | :heavy_check_mark: | 0 |  |
| linux/x86_64/010-05_11_12-2021_07_07.corepop | <Container: cda9e9f1b5> | 16.04 | :heavy_check_mark: | 0 |  |
| linux/x86_64/010-05_11_12-2021_07_07.corepop | <Container: 4d5ef49eec> | latest | :heavy_check_mark: | 0 |  |
| linux/x86_64/010-05_11_12-2021_07_07.corepop | <Container: c5a8d04f50> | unstable-slim | :heavy_check_mark: | 0 |  |
| linux/x86_64/010-05_11_12-2021_07_07.corepop | <Container: dc5b460394> | testing-slim | :heavy_check_mark: | 0 |  |
| linux/x86_64/010-05_11_12-2021_07_07.corepop | <Container: 06d36b37b2> | stable-slim | :heavy_check_mark: | 0 |  |
| linux/x86_64/010-05_11_12-2021_07_07.corepop | <Container: 7c9b0900c8> | oldstable-slim | :heavy_check_mark: | 0 |  |
| linux/x86_64/010-05_11_12-2021_07_07.corepop | <Container: d0ff9f18d3> | oldoldstable | :heavy_check_mark: | 0 |  |
| linux/x86_64/010-05_11_12-2021_07_07.corepop | <Container: ab5744ba9d> | 34 | :heavy_check_mark: | 0 |  |
| linux/x86_64/010-05_11_12-2021_07_07.corepop | <Container: dfa2448f72> | 33 | :heavy_check_mark: | 0 |  |
| linux/x86_64/010-05_11_12-2021_07_07.corepop | <Container: 96d70a094f> | 32 | :heavy_check_mark: | 0 |  |
| linux/x86_64/010-05_11_12-2021_07_07.corepop | <Container: 68f0ffc59d> | 8 | :heavy_check_mark: | 0 |  |
| linux/x86_64/010-05_11_12-2021_07_07.corepop | <Container: 8143daf501> | 7 | :heavy_check_mark: | 0 |  |
| linux/x86_64/020-05_08_00-2021_06_24.corepop | <Container: f08af236f9> | 21.04 | :x: | 127 | <details><summary>details</summary><pre>/corepops/linux/x86_64/020-05_08_00-2021_06_24.corepop: error while loading shared libraries: libncurses.so.5: cannot open shared object file: No such file or directory<br></pre></details> |
| linux/x86_64/020-05_08_00-2021_06_24.corepop | <Container: 979851eac6> | 20.04 | :x: | 127 | <details><summary>details</summary><pre>/corepops/linux/x86_64/020-05_08_00-2021_06_24.corepop: error while loading shared libraries: libncurses.so.5: cannot open shared object file: No such file or directory<br></pre></details> |
| linux/x86_64/020-05_08_00-2021_06_24.corepop | <Container: c4c8306f60> | 18.04 | :x: | 1 | <details><summary>details</summary><pre>/corepops/linux/x86_64/020-05_08_00-2021_06_24.corepop: /lib/x86_64-linux-gnu/libm.so.6: version `GLIBC_2.29' not found (required by /corepops/linux/x86_64/020-05_08_00-2021_06_24.corepop)<br></pre></details> |
| linux/x86_64/020-05_08_00-2021_06_24.corepop | <Container: 3e59ee5cf1> | 16.04 | :x: | 1 | <details><summary>details</summary><pre>/corepops/linux/x86_64/020-05_08_00-2021_06_24.corepop: /lib/x86_64-linux-gnu/libm.so.6: version `GLIBC_2.29' not found (required by /corepops/linux/x86_64/020-05_08_00-2021_06_24.corepop)<br></pre></details> |
| linux/x86_64/020-05_08_00-2021_06_24.corepop | <Container: 5e810554c4> | latest | :x: | 127 | <details><summary>details</summary><pre>/corepops/linux/x86_64/020-05_08_00-2021_06_24.corepop: error while loading shared libraries: libncurses.so.5: cannot open shared object file: No such file or directory<br></pre></details> |
| linux/x86_64/020-05_08_00-2021_06_24.corepop | <Container: 6deaf99059> | unstable-slim | :x: | 127 | <details><summary>details</summary><pre>/corepops/linux/x86_64/020-05_08_00-2021_06_24.corepop: error while loading shared libraries: libncurses.so.5: cannot open shared object file: No such file or directory<br></pre></details> |
| linux/x86_64/020-05_08_00-2021_06_24.corepop | <Container: 903a306f03> | testing-slim | :x: | 127 | <details><summary>details</summary><pre>/corepops/linux/x86_64/020-05_08_00-2021_06_24.corepop: error while loading shared libraries: libncurses.so.5: cannot open shared object file: No such file or directory<br></pre></details> |
| linux/x86_64/020-05_08_00-2021_06_24.corepop | <Container: 156a8d6019> | stable-slim | :x: | 127 | <details><summary>details</summary><pre>/corepops/linux/x86_64/020-05_08_00-2021_06_24.corepop: error while loading shared libraries: libncurses.so.5: cannot open shared object file: No such file or directory<br></pre></details> |
| linux/x86_64/020-05_08_00-2021_06_24.corepop | <Container: 0ded59369d> | oldstable-slim | :x: | 127 | <details><summary>details</summary><pre>/corepops/linux/x86_64/020-05_08_00-2021_06_24.corepop: error while loading shared libraries: libncurses.so.5: cannot open shared object file: No such file or directory<br></pre></details> |
| linux/x86_64/020-05_08_00-2021_06_24.corepop | <Container: f99b458fe7> | oldoldstable | :x: | 127 | <details><summary>details</summary><pre>/corepops/linux/x86_64/020-05_08_00-2021_06_24.corepop: error while loading shared libraries: libncurses.so.5: cannot open shared object file: No such file or directory<br></pre></details> |
| linux/x86_64/020-05_08_00-2021_06_24.corepop | <Container: 41cf56e34f> | 34 | :x: | 127 | <details><summary>details</summary><pre>/corepops/linux/x86_64/020-05_08_00-2021_06_24.corepop: error while loading shared libraries: libncurses.so.5: cannot open shared object file: No such file or directory<br></pre></details> |
| linux/x86_64/020-05_08_00-2021_06_24.corepop | <Container: 94ac504481> | 33 | :x: | 127 | <details><summary>details</summary><pre>/corepops/linux/x86_64/020-05_08_00-2021_06_24.corepop: error while loading shared libraries: libncurses.so.5: cannot open shared object file: No such file or directory<br></pre></details> |
| linux/x86_64/020-05_08_00-2021_06_24.corepop | <Container: 85b2131875> | 32 | :x: | 127 | <details><summary>details</summary><pre>/corepops/linux/x86_64/020-05_08_00-2021_06_24.corepop: error while loading shared libraries: libncurses.so.5: cannot open shared object file: No such file or directory<br></pre></details> |
| linux/x86_64/020-05_08_00-2021_06_24.corepop | <Container: 954be3aca6> | 8 | :x: | 127 | <details><summary>details</summary><pre>/corepops/linux/x86_64/020-05_08_00-2021_06_24.corepop: error while loading shared libraries: libncurses.so.5: cannot open shared object file: No such file or directory<br></pre></details> |
| linux/x86_64/020-05_08_00-2021_06_24.corepop | <Container: 79f7b42303> | 7 | :x: | 1 | <details><summary>details</summary><pre>/corepops/linux/x86_64/020-05_08_00-2021_06_24.corepop: /lib64/libtinfo.so.5: no version information available (required by /corepops/linux/x86_64/020-05_08_00-2021_06_24.corepop)<br>/corepops/linux/x86_64/020-05_08_00-2021_06_24.corepop: /lib64/libm.so.6: version `GLIBC_2.29' not found (required by /corepops/linux/x86_64/020-05_08_00-2021_06_24.corepop)<br></pre></details> |
| linux/x86_64/030-05_04_00-2020_08_22.corepop | <Container: 94db7cdf5c> | 21.04 | :heavy_check_mark: | 0 |  |
| linux/x86_64/030-05_04_00-2020_08_22.corepop | <Container: 6c17ce8a25> | 20.04 | :heavy_check_mark: | 0 |  |
| linux/x86_64/030-05_04_00-2020_08_22.corepop | <Container: 925811a3d3> | 18.04 | :heavy_check_mark: | 0 |  |
| linux/x86_64/030-05_04_00-2020_08_22.corepop | <Container: d89abf7cd4> | 16.04 | :heavy_check_mark: | 0 |  |
| linux/x86_64/030-05_04_00-2020_08_22.corepop | <Container: e7e6dd93e6> | latest | :heavy_check_mark: | 0 |  |
| linux/x86_64/030-05_04_00-2020_08_22.corepop | <Container: c960a6609a> | unstable-slim | :heavy_check_mark: | 0 |  |
| linux/x86_64/030-05_04_00-2020_08_22.corepop | <Container: 75c0ee93f5> | testing-slim | :heavy_check_mark: | 0 |  |
| linux/x86_64/030-05_04_00-2020_08_22.corepop | <Container: cded777314> | stable-slim | :heavy_check_mark: | 0 |  |
| linux/x86_64/030-05_04_00-2020_08_22.corepop | <Container: 7803e28abb> | oldstable-slim | :heavy_check_mark: | 0 |  |
| linux/x86_64/030-05_04_00-2020_08_22.corepop | <Container: 713d2fc630> | oldoldstable | :heavy_check_mark: | 0 |  |
| linux/x86_64/030-05_04_00-2020_08_22.corepop | <Container: d42c3994e4> | 34 | :heavy_check_mark: | 0 |  |
| linux/x86_64/030-05_04_00-2020_08_22.corepop | <Container: 083abff746> | 33 | :heavy_check_mark: | 0 |  |
| linux/x86_64/030-05_04_00-2020_08_22.corepop | <Container: 034df24dab> | 32 | :heavy_check_mark: | 0 |  |
| linux/x86_64/030-05_04_00-2020_08_22.corepop | <Container: f4f1a92b1f> | 8 | :heavy_check_mark: | 0 |  |
| linux/x86_64/030-05_04_00-2020_08_22.corepop | <Container: 43c8999ef0> | 7 | :heavy_check_mark: | 0 |  |
| linux/x86_64/040-05_08_00-2021_07_30.corepop | <Container: d67e493a20> | 21.04 | :x: | 127 | <details><summary>details</summary><pre>/corepops/linux/x86_64/040-05_08_00-2021_07_30.corepop: error while loading shared libraries: libXt.so.6: cannot open shared object file: No such file or directory<br></pre></details> |
| linux/x86_64/040-05_08_00-2021_07_30.corepop | <Container: c1ecbe07a8> | 20.04 | :x: | 127 | <details><summary>details</summary><pre>/corepops/linux/x86_64/040-05_08_00-2021_07_30.corepop: error while loading shared libraries: libXt.so.6: cannot open shared object file: No such file or directory<br></pre></details> |
| linux/x86_64/040-05_08_00-2021_07_30.corepop | <Container: b1da724f68> | 18.04 | :x: | 127 | <details><summary>details</summary><pre>/corepops/linux/x86_64/040-05_08_00-2021_07_30.corepop: error while loading shared libraries: libXt.so.6: cannot open shared object file: No such file or directory<br></pre></details> |
| linux/x86_64/040-05_08_00-2021_07_30.corepop | <Container: cf31ce5838> | 16.04 | :x: | 127 | <details><summary>details</summary><pre>/corepops/linux/x86_64/040-05_08_00-2021_07_30.corepop: error while loading shared libraries: libXt.so.6: cannot open shared object file: No such file or directory<br></pre></details> |
| linux/x86_64/040-05_08_00-2021_07_30.corepop | <Container: 5aa0c6fd14> | latest | :x: | 127 | <details><summary>details</summary><pre>/corepops/linux/x86_64/040-05_08_00-2021_07_30.corepop: error while loading shared libraries: libXt.so.6: cannot open shared object file: No such file or directory<br></pre></details> |
| linux/x86_64/040-05_08_00-2021_07_30.corepop | <Container: 28c191f047> | unstable-slim | :x: | 127 | <details><summary>details</summary><pre>/corepops/linux/x86_64/040-05_08_00-2021_07_30.corepop: error while loading shared libraries: libXt.so.6: cannot open shared object file: No such file or directory<br></pre></details> |
| linux/x86_64/040-05_08_00-2021_07_30.corepop | <Container: fd4c4224dd> | testing-slim | :x: | 127 | <details><summary>details</summary><pre>/corepops/linux/x86_64/040-05_08_00-2021_07_30.corepop: error while loading shared libraries: libXt.so.6: cannot open shared object file: No such file or directory<br></pre></details> |
| linux/x86_64/040-05_08_00-2021_07_30.corepop | <Container: abc6109f68> | stable-slim | :x: | 127 | <details><summary>details</summary><pre>/corepops/linux/x86_64/040-05_08_00-2021_07_30.corepop: error while loading shared libraries: libXt.so.6: cannot open shared object file: No such file or directory<br></pre></details> |
| linux/x86_64/040-05_08_00-2021_07_30.corepop | <Container: 440579f7df> | oldstable-slim | :x: | 127 | <details><summary>details</summary><pre>/corepops/linux/x86_64/040-05_08_00-2021_07_30.corepop: error while loading shared libraries: libXt.so.6: cannot open shared object file: No such file or directory<br></pre></details> |
| linux/x86_64/040-05_08_00-2021_07_30.corepop | <Container: 0d66cbdfee> | oldoldstable | :x: | 127 | <details><summary>details</summary><pre>/corepops/linux/x86_64/040-05_08_00-2021_07_30.corepop: error while loading shared libraries: libXt.so.6: cannot open shared object file: No such file or directory<br></pre></details> |
| linux/x86_64/040-05_08_00-2021_07_30.corepop | <Container: 04cfe9ef59> | 34 | :x: | 127 | <details><summary>details</summary><pre>/corepops/linux/x86_64/040-05_08_00-2021_07_30.corepop: error while loading shared libraries: libXt.so.6: cannot open shared object file: No such file or directory<br></pre></details> |
| linux/x86_64/040-05_08_00-2021_07_30.corepop | <Container: 8c6f3d9110> | 33 | :x: | 127 | <details><summary>details</summary><pre>/corepops/linux/x86_64/040-05_08_00-2021_07_30.corepop: error while loading shared libraries: libXt.so.6: cannot open shared object file: No such file or directory<br></pre></details> |
| linux/x86_64/040-05_08_00-2021_07_30.corepop | <Container: e9b964ef04> | 32 | :x: | 127 | <details><summary>details</summary><pre>/corepops/linux/x86_64/040-05_08_00-2021_07_30.corepop: error while loading shared libraries: libXt.so.6: cannot open shared object file: No such file or directory<br></pre></details> |
| linux/x86_64/040-05_08_00-2021_07_30.corepop | <Container: 1e6061a376> | 8 | :x: | 127 | <details><summary>details</summary><pre>/corepops/linux/x86_64/040-05_08_00-2021_07_30.corepop: error while loading shared libraries: libXt.so.6: cannot open shared object file: No such file or directory<br></pre></details> |
| linux/x86_64/040-05_08_00-2021_07_30.corepop | <Container: 942ed7276f> | 7 | :x: | 127 | <details><summary>details</summary><pre>/corepops/linux/x86_64/040-05_08_00-2021_07_30.corepop: error while loading shared libraries: libXt.so.6: cannot open shared object file: No such file or directory<br></pre></details> |
| linux/x86_64/050-04_04_00-2020_00_00.corepop | <Container: 4ae961354e> | 21.04 | :x: | 127 | <details><summary>details</summary><pre>/corepops/linux/x86_64/050-04_04_00-2020_00_00.corepop: error while loading shared libraries: libncurses.so.5: cannot open shared object file: No such file or directory<br></pre></details> |
| linux/x86_64/050-04_04_00-2020_00_00.corepop | <Container: f9bce098f0> | 20.04 | :x: | 127 | <details><summary>details</summary><pre>/corepops/linux/x86_64/050-04_04_00-2020_00_00.corepop: error while loading shared libraries: libncurses.so.5: cannot open shared object file: No such file or directory<br></pre></details> |
| linux/x86_64/050-04_04_00-2020_00_00.corepop | <Container: 1369c09512> | 18.04 | :heavy_check_mark: | 0 |  |
| linux/x86_64/050-04_04_00-2020_00_00.corepop | <Container: 75aa5f0465> | 16.04 | :heavy_check_mark: | 0 |  |
| linux/x86_64/050-04_04_00-2020_00_00.corepop | <Container: 365c588ded> | latest | :x: | 127 | <details><summary>details</summary><pre>/corepops/linux/x86_64/050-04_04_00-2020_00_00.corepop: error while loading shared libraries: libncurses.so.5: cannot open shared object file: No such file or directory<br></pre></details> |
| linux/x86_64/050-04_04_00-2020_00_00.corepop | <Container: 71459809fc> | unstable-slim | :x: | 127 | <details><summary>details</summary><pre>/corepops/linux/x86_64/050-04_04_00-2020_00_00.corepop: error while loading shared libraries: libncurses.so.5: cannot open shared object file: No such file or directory<br></pre></details> |
| linux/x86_64/050-04_04_00-2020_00_00.corepop | <Container: 3a45e1390a> | testing-slim | :x: | 127 | <details><summary>details</summary><pre>/corepops/linux/x86_64/050-04_04_00-2020_00_00.corepop: error while loading shared libraries: libncurses.so.5: cannot open shared object file: No such file or directory<br></pre></details> |
| linux/x86_64/050-04_04_00-2020_00_00.corepop | <Container: b1ff9bf8e5> | stable-slim | :x: | 127 | <details><summary>details</summary><pre>/corepops/linux/x86_64/050-04_04_00-2020_00_00.corepop: error while loading shared libraries: libncurses.so.5: cannot open shared object file: No such file or directory<br></pre></details> |
| linux/x86_64/050-04_04_00-2020_00_00.corepop | <Container: b5c5336fc8> | oldstable-slim | :x: | 127 | <details><summary>details</summary><pre>/corepops/linux/x86_64/050-04_04_00-2020_00_00.corepop: error while loading shared libraries: libncurses.so.5: cannot open shared object file: No such file or directory<br></pre></details> |
| linux/x86_64/050-04_04_00-2020_00_00.corepop | <Container: 8eb59c4be5> | oldoldstable | :x: | 127 | <details><summary>details</summary><pre>/corepops/linux/x86_64/050-04_04_00-2020_00_00.corepop: error while loading shared libraries: libncurses.so.5: cannot open shared object file: No such file or directory<br></pre></details> |
| linux/x86_64/050-04_04_00-2020_00_00.corepop | <Container: 11b1b30618> | 34 | :x: | 127 | <details><summary>details</summary><pre>/corepops/linux/x86_64/050-04_04_00-2020_00_00.corepop: error while loading shared libraries: libncurses.so.5: cannot open shared object file: No such file or directory<br></pre></details> |
| linux/x86_64/050-04_04_00-2020_00_00.corepop | <Container: 6ec2afadbd> | 33 | :x: | 127 | <details><summary>details</summary><pre>/corepops/linux/x86_64/050-04_04_00-2020_00_00.corepop: error while loading shared libraries: libncurses.so.5: cannot open shared object file: No such file or directory<br></pre></details> |
| linux/x86_64/050-04_04_00-2020_00_00.corepop | <Container: 60939355ef> | 32 | :x: | 127 | <details><summary>details</summary><pre>/corepops/linux/x86_64/050-04_04_00-2020_00_00.corepop: error while loading shared libraries: libncurses.so.5: cannot open shared object file: No such file or directory<br></pre></details> |
| linux/x86_64/050-04_04_00-2020_00_00.corepop | <Container: e8ac5d09d0> | 8 | :x: | 127 | <details><summary>details</summary><pre>/corepops/linux/x86_64/050-04_04_00-2020_00_00.corepop: error while loading shared libraries: libncurses.so.5: cannot open shared object file: No such file or directory<br></pre></details> |
| linux/x86_64/050-04_04_00-2020_00_00.corepop | <Container: 6e48246323> | 7 | :x: | 0 | <details><summary>details</summary><pre>/corepops/linux/x86_64/050-04_04_00-2020_00_00.corepop: /lib64/libtinfo.so.5: no version information available (required by /corepops/linux/x86_64/050-04_04_00-2020_00_00.corepop)<br>/corepops/linux/x86_64/050-04_04_00-2020_00_00.corepop: /lib64/libtinfo.so.5: no version information available (required by /corepops/linux/x86_64/050-04_04_00-2020_00_00.corepop)<br></pre></details> |
<!--END COREPOP_TEST_RESULTS-->
