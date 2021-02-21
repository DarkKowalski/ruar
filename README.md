# ruar

Tar-like Archive for RIEN

[![CI Tests](https://github.com/DarkKowalski/ruar/workflows/CI%20Tests/badge.svg)](https://github.com/DarkKowalski/ruar/actions?query=workflow%3A%22CI+Tests%22)
[![Build](https://github.com/DarkKowalski/ruar/workflows/Build/badge.svg)](https://github.com/DarkKowalski/ruar/actions?query=workflow%3ABuild)

This GEM is still in development, please use the latest git dev branch

## Usage

```ruby
require 'ruar'
require 'tmpdir'

# Serialize it
# file /tmp/plain.ruar => data
archive = File.join(Dir.tmpdir, 'plain.ruar')
Ruar::Serialize.plain('./test/sample', archive)

# Setup
Ruar.setup(
  archive: archive
).activate

# Require from /tmp/plain.ruar
require 'dir/file'

# require 'your_file', from: [:both, :ruar, :local]
# require_relative 'your_file', from: [:both, :ruar, :local]
# load 'your_file', from: [:both, :ruar, :local]
#
# Notice: Currently we don't support autoload from ruar

# Here you go
```

### AEAD

Encrypt

```ruby
require 'ruar'
require 'tmpdir'

auth_data = Base64.encode64('nekomimi')
Ruar.cipher.setup(auth_data: auth_data)

archive = File.join(Dir.tmpdir, 'aead.ruar')
Ruar::Serialize.aead('./test/sample', archive)
```

Then you will get `/tmp/aead.ruar.setup`

```ruby
Ruar.cipher.setup(
  iv: 'niNGDaPcFiD8eKdb',
  key: 'I0LpzLx3GuU19F5EOwTbfZJ6pYOlH4Pbumm9SolLJv8=',
  auth_data: 'bmVrb21pbWk=',
  tag: 'nN6rCnd5SmZaoTdpmUEjtw==')
Ruar.cipher.enable
```

Decrypt

```ruby
require 'lib/ruar'
require 'tmpdir'

# Decryption Setup
Ruar.cipher.setup(
  iv: 'niNGDaPcFiD8eKdb',
  key: 'I0LpzLx3GuU19F5EOwTbfZJ6pYOlH4Pbumm9SolLJv8=',
  auth_data: 'bmVrb21pbWk=',
  tag: 'nN6rCnd5SmZaoTdpmUEjtw==')
Ruar.cipher.enable

archive = File.join(Dir.tmpdir, 'aead.ruar')
Ruar.setup(archive: archive).activate

# Setup
Ruar.setup(
  archive: archive
).activate

# Require from /tmp/aeae.ruar
require 'dir/file'
```
## Format

```
+--------+-------+--------+-----+--------+
| Header | Index | File 0 | ... | File x |
+--------+-------+--------+-----+--------+
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
|                            padding:                         |
|                           24 octets                         |
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
