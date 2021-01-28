# ruar

Tar-like Archive for RIEN

![CI Tests](https://github.com/DarkKowalski/ruar/workflows/CI%20Tests/badge.svg)
![Build](https://github.com/DarkKowalski/ruar/workflows/Build/badge.svg)

## Format

```
+--------+-------+-------+-----+--------+
| Header | Index | File0 | ... | File x |
+--------+-------+-------+-----+--------+
```

### Header

```
+-------------------------------------------------------------+
|                            Header                           |
+-------------------------------+-----------------------------+
| major_version:      uint32_t  | minor_version:     uint32_t |
+-------------------------------+-----------------------------+
| patch_version:      uint32_t  | platform:          uint32_t |
+-------------------------------+-----------------------------+
| encryption_flags:   uint32_t  | compression_flags: uint32_t |
+-------------------------------+-----------------------------+
| index_start(octet): uint32_t  | index_size(octet): unit32_t |
+-------------------------------+-----------------------------+
| index_checksum:     uint32_t  | header_checksum:   uint32_t |
+-------------------------------+-----------------------------+
```

### Index

```json
{
   "files": {
      "tmp": {
         "files": {}
      },
      "usr" : {
         "files": {
           "bin": {
             "files": {
               "ls": {
                 "offset": "0",
                 "size": 100,
                 "executable": true
               },
               "cd": {
                 "offset": "100",
                 "size": 100,
                 "executable": true
               }
             }
           }
         }
      },
      "etc": {
         "files": {
           "hosts": {
             "offset": "200",
             "size": 32
           }
         }
      }
   }
}
```
