#!/bin/bash
PARSLEY_REPO="http://svn.code.sf.net/adobe/cairngorm/code/cairngorm3/maven-repository"
PARSLEY_GROUP="org/spicefactory"
PARSLEY_ARTIFACT="parsley-flex4"
SPICELIB_ARTIFACT="spicelib-flex"
PARSLEY_VERSION="2.4.0"
PARSLEY_TYPE="swc"
#
PARSLEY=$PARSLEY_REPO"/"$PARSLEY_GROUP"/"$PARSLEY_ARTIFACT"/"$PARSLEY_VERSION"/"$PARSLEY_ARTIFACT"-"$PARSLEY_VERSION"."$PARSLEY_TYPE
SPICELIB=$PARSLEY_REPO"/"$PARSLEY_GROUP"/"$SPICELIB_ARTIFACT"/"$PARSLEY_VERSION"/"$SPICELIB_ARTIFACT"-"$PARSLEY_VERSION"."$PARSLEY_TYPE
#echo "installing "$PARSLEY" to local repo "~/.m2
#echo "installing "$SPICELIB" to local repo "~/.m2

PARSLEY_SWC=$PARSLEY_ARTIFACT"-"$PARSLEY_VERSION"."$PARSLEY_TYPE
SPICELIB_SWC=$SPICELIB_ARTIFACT"-"$PARSLEY_VERSION"."$PARSLEY_TYPE

curl $PARSLEY > $PARSLEY_SWC
curl $SPICELIB > $SPICELIB_SWC

mvn install:install-file  -Dfile=$PARSLEY_SWC \
                          -DgroupId="org.spicefactory" \
                          -DartifactId=$PARSLEY_ARTIFACT \
                          -Dversion=$PARSLEY_VERSION \
                          -Dpackaging=$PARSLEY_TYPE

mvn install:install-file  -Dfile=$SPICELIB_SWC \
                          -DgroupId="org.spicefactory" \
                          -DartifactId=$SPICELIB_ARTIFACT \
                          -Dversion=$PARSLEY_VERSION \
                          -Dpackaging=$PARSLEY_TYPE

#cleanup
rm $PARSLEY_SWC
rm $SPICELIB_SWC
