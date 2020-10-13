# Create a self-extract installer
## Table of Contents
  - [Create archive file](#create-archive-file--archivetgz)
  - [Create installation script](#create-installation-script--my_scriptbash)
  - [Create self-extract script](#create-self-extract-script--selfextractbsx)
  - [Reference](#reference)
## Create archive file : archive.tgz
```commandline
tar czf archive.tgz <dirs or files>
```
## Create installation script : my_script.bash
```commandline
#!/bin/bash

echo "Create temporary directory to extract archive"
export TMPDIR=$(mktemp -d)
    
echo "Extract archive"
ARCHIVE=$(awk '/^__ARCHIVE_BELOW__$/ {print NR + 1; exit 0; }' $0)
tail -n +${ARCHIVE} $0 | tar xzv -C ${TMPDIR}

echo "Execute post-installation"
CDIR=$(pwd)
cd $TMPDIR
./bin/postinstall.bash

echo "Remove temporary directory"
cd $CDIR
rm -rf $TMPDIR
    
echo "Installation completed"
exit 0

__ARCHIVE_BELOW__
```    
## Create self-extract script : selfextract.bsx
```commandline
cat my_script.bash archive.tgz > selfextract.bsx
```
## Reference
This guide is based on Linux Journal post writen by Jeff Parent

https://www.linuxjournal.com/node/1005818