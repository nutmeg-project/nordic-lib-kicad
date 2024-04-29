#!/bin/sh

# adapted verson taken from https://github.com/Bouni/kicad-jlcpcb-tools/blob/main/PCM/create_pcm_archive.sh
# heavily inspired by https://github.com/4ms/4ms-kicad-lib/blob/master/PCM/make_archive.sh

TAG=$1
VERSION=${TAG##*/}
ARCHIVE=KiCAD-PCM-$VERSION.zip

echo "Clean up old files"
rm -f PCM/*.zip
rm -rf PCM/archive

echo "Create folder structure for ZIP"
mkdir -p PCM/archive/resources

echo "Copy files to destination"
cp -r footprints PCM/archive
cp -r symbols PCM/archive
cp -r 3dmodels PCM/archive
cp PCM/icon.png PCM/archive/resources
cp PCM/metadata.template.json PCM/archive/metadata.json

echo "Write version info to file"
echo $VERSION > PCM/archive/VERSION

echo "Modify archive metadata.json"
sed -i "s/VERSION_HERE/$VERSION/g" PCM/archive/metadata.json
sed -i "s/\"kicad_version\": \"8.0\",/\"kicad_version\": \"8.0\"/g" PCM/archive/metadata.json
sed -i "/SHA256_HERE/d" PCM/archive/metadata.json
sed -i "/DOWNLOAD_SIZE_HERE/d" PCM/archive/metadata.json
sed -i "/DOWNLOAD_URL_HERE/d" PCM/archive/metadata.json
sed -i "/INSTALL_SIZE_HERE/d" PCM/archive/metadata.json

echo "Zip PCM archive $ARCHIVE"
cd PCM/archive
zip -r ../$ARCHIVE .
cd ../..

echo "Gather data for repo rebuild"
echo PACKAGE="com.github.nutmeg-project.nordic-lib-kicad" >> $GITHUB_ENV
echo VERSION=$VERSION >> $GITHUB_ENV
echo DOWNLOAD_SHA256=$(shasum --algorithm 256 PCM/$ARCHIVE | xargs | cut -d' ' -f1) >> $GITHUB_ENV
echo DOWNLOAD_SIZE=$(ls -l PCM/$ARCHIVE | xargs | cut -d' ' -f5) >> $GITHUB_ENV
echo DOWNLOAD_URL="https://github.com/nutmeg-project/nordic-lib-kicad/releases/download/$TAG/KiCAD-PCM-$VERSION.zip" >> $GITHUB_ENV
echo INSTALL_SIZE=$(unzip -l PCM/$ARCHIVE | tail -1 | xargs | cut -d' ' -f1) >> $GITHUB_ENV
