## Media Testing ##
---
#### Sonivox Unit Test
The Sonivox Unit Test Suite validates the Sonivox library available in external/sonivox/

Run the following steps to build the test suite:
```
m SonivoxTest
```

The 32-bit binaries will be created in the following path : ${OUT}/data/nativetest/

The 64-bit binaries will be created in the following path : ${OUT}/data/nativetest64/

To test 64-bit binary push binaries from nativetest64.
```
adb push ${OUT}/data/nativetest64/SonivoxTest/SonivoxTest /data/local/tmp/
```

To test 32-bit binary push binaries from nativetest.
```
adb push ${OUT}/data/nativetest/SonivoxTest/SonivoxTest /data/local/tmp/
```

The resource file for the tests is taken from [here](https://storage.googleapis.com/android_media/external/sonivox/test/SonivoxTestRes-1.0.zip). Download, unzip and push these files into device for testing.

```
adb push SonivoxTestRes-1.0/. /data/local/tmp/SonivoxTestRes/
```

usage: SonivoxTest -P \<path_to_res_folder\> -C <remove_output_file>
```
adb shell /data/local/tmp/SonivoxTest -P /data/local/tmp/SonivoxTestRes/ -C true
```
Alternatively, the test can also be run using atest command.

```
atest SonivoxTest -- --enable-module-dynamic-download=true
```
