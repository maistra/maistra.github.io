# Build the guide

# This script builds 2 versions of the guide:
# * An Asciidoctor version
# * A ccutil version
# Links to each build file are provided when the build completes.

# Find the directory name and full path
CURRENT_GUIDE=${PWD##*/}
CURRENT_DIRECTORY=$(pwd)
RED='\033[0;31m'
BLACK='\033[0;30m'

# Check for an argument, which indicates request for usage information
if [ "$#" -ne "0" ]; then
  echo ""
  echo "Run this script from the root directory of this guide as follows: "
  echo "     cd $CURRENT_GUIDE "
  echo "     ./buildGuide.sh"
  echo ""
  exit;
fi

# Remove the html and build directories and then recreate the html/images/ directory
if [ -d html ]; then
   rm -r html/
fi
if [ -d build ]; then
   rm -r build/
fi

mkdir -p html
cp -r ../../docs/topics/images/ html/

echo ""
echo "********************************************"
echo " Building $CURRENT_GUIDE                "
echo "********************************************"
echo ""
echo "Building an asciidoctor version of the $CURRENT_GUIDE"
asciidoctor -t -dbook -a toc -o html/$CURRENT_GUIDE.html master.adoc
echo ""
echo "Building the ccutil version of the $CURRENT_GUIDE"
ccutil compile --lang en_US --main-file master.adoc

cd ..

echo "$CURRENT_GUIDE (AsciiDoctor) is located at: " file://$CURRENT_DIRECTORY/html/$CURRENT_GUIDE.html

if [ -d  $CURRENT_DIRECTORY/build/tmp/en-US/html-single/ ]; then
  echo "$CURRENT_GUIDE (ccutil) is located at: " file://$CURRENT_DIRECTORY/build/tmp/en-US/html-single/index.html
  exit 0
else
  echo -e "${RED}Build of $CURRENT_GUIDE failed!"
  echo -e "${BLACK}See the log above for details."
  exit 1
fi
