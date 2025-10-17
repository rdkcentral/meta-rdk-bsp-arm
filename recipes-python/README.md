# Pinned jinja2 and markupsafe versions

These are required to build `systemd-boot` (see log of build failure below).
The jinja2 version bundled with OpenEmbedded did not lock the
MarkupSafe version, leading to [import errors](https://github.com/pallets/jinja/issues/1587)
from Jinja2 when newer versions of MarkupSafe are installed.

If `meta-rdk-opensync` is present, that layer also provides pinned versions
of Jinja2 and MarkupSafe.

```
| ../git/meson.build:651:8: ERROR: Problem encountered: python3 jinja2 missing
|
| A full log can be found at build-ten64-rdk-broadband/tmp/work/cortexa53-rdk-linux/systemd-boot/250.5-r0/build/meson-logs/meson-log.txt
| ERROR: meson failed
| WARNING: exit code 1 from a shell command.
ERROR: Task (openembedded-core/meta/recipes-core/systemd/systemd-boot_250.5.bb:do_configure) failed with exit code '1'

$ cat build-ten64-rdk-broadband/tmp/work/cortexa53-rdk-linux/systemd-boot/250.5-r0/build/meson-logs/meson-log.txt
Running command: build-ten64-rdk-broadband/tmp/work/cortexa53-rdk-linux/systemd-boot/250.5-r0/recipe-sysroot-native/usr/bin/python3-native/python3 -c import jinja2
Traceback (most recent call last):
  File "<string>", line 1, in <module>
  File "build-ten64-rdk-broadband/tmp/work/cortexa53-rdk-linux/systemd-boot/250.5-r0/recipe-sysroot-native/usr/lib/python3.10/site-packages/jinja2/__init__.py", line 12, in <module>
    from .environment import Environment
  File "build-ten64-rdk-broadband/tmp/work/cortexa53-rdk-linux/systemd-boot/250.5-r0/recipe-sysroot-native/usr/lib/python3.10/site-packages/jinja2/environment.py", line 25, in <module>
    from .defaults import BLOCK_END_STRING
  File "build-ten64-rdk-broadband/tmp/work/cortexa53-rdk-linux/systemd-boot/250.5-r0/recipe-sysroot-native/usr/lib/python3.10/site-packages/jinja2/defaults.py", line 3, in <module>
    from .filters import FILTERS as DEFAULT_FILTERS  # noqa: F401
  File "build-ten64-rdk-broadband/tmp/work/cortexa53-rdk-linux/systemd-boot/250.5-r0/recipe-sysroot-native/usr/lib/python3.10/site-packages/jinja2/filters.py", line 13, in <module>
    from markupsafe import soft_unicode
ImportError: cannot import name 'soft_unicode' from 'markupsafe' (build-ten64-rdk-broadband/tmp/work/cortexa53-rdk-linux/systemd-boot/250.5-r0/recipe-sysroot-native/usr/lib/python3.10/site-packages/markupsafe/__init__.py)
```

