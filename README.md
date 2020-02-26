#  XcodeSpellChecker

![LICENSE](https://img.shields.io/github/license/u5-03/XcodeSpellChecker)
![Tag](https://img.shields.io/github/v/tag/u5-03/XcodeSpellChecker)

## What's XcodeSpellChecker?
This tool for Xcode is to detect misspelling and show warnings to misspelling location.  

## Recommended environment

- Swift 5.1
- Xcode 11.3
- macOS 10.15

## Install
### Clone from github
```shellscript
git clone https://github.com/u5-03/XcodeSpellChecker.git
cd ./XcodeSpellChecker
make install
```
### Install with Mint
```shellscript：Mintfile
mint install u5-03/XcodeSpellChecker
```
Click [here](https://github.com/yonaskolb/Mint) to see how to run Mint.

## Usage

Write to your `Run script` like a below code. 

```shellscript
if ! [ -f /usr/local/bin/XcodeSpellChecker ]; then
    echo "XcodeSpellChecker not installed"
    exit 1
fi

git_path=/usr/local/bin/git
files=$($git_path diff --diff-filter=d --name-only -- "*.swift" "*.h" "*.m" "*.strings")
if (test -z $files) || (test ${#files[@]} -eq 0); then
  echo "no files changed."
  exit 0
fi

filePaths=""
for file in $files
do
  filePaths="$filePaths:$SRCROOT/$file"
done

XcodeSpellChecker --yml $SRCROOT/Xcode-spellChecker.yml --files $filePaths

```

Write to your `Run script` like a below code when using `Mint`. 

```shellscript
if mint list | [ -z `grep -p "XcodeSpellChecker"` ]; then
    echo "XcodeSpellChecker not installed"
    exit 1
fi

git_path=/usr/local/bin/git
files=$($git_path diff --diff-filter=d --name-only -- "*.swift" "*.h" "*.m" "*.strings")
if (test -z $files) || (test ${#files[@]} -eq 0); then
  echo "No files changed."
  exit 0
fi

filePaths=""
for file in $files
do
  filePaths="$filePaths:$SRCROOT/$file"
done

mint run XcodeSpellChecker XcodeSpellChecker --yml $SRCROOT/Xcode-spellChecker.yml --files $filePaths

```

### Options

If you want ignore some warnings, make YAML file to your directory and write keywords to `whiteList`.  
And if you want to restrict the scope of checking, write file path or file name to `includePath` and `excludePath`.  
For example:

```yaml
whiteList:
  - PersonName
  - CompanyName

includePath:
  - Views
  - Components
  - Assets/localizable.strings

excludePath:
  - Frameworks/
  - Generated/
```
The filters of `includePath` applied first, and those of `excludePath` applied after that.

And set `--yml` options.

```shellscript
XcodeSpellChecker --yml $SRCROOT/Xcode-spellChecker.yml --files $filePaths
```

## References
This tool was based on the following packages. Thanks!  
[SpellChecker](https://github.com/fromkk/SpellChecker)   by  [fromkk](https://github.com/fromkk)
