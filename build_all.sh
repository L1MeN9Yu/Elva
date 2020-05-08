NAME=Elva
rm -r build $NAME.xcframework
xcodebuild clean
xcodebuild archive -scheme "$NAME-Package" -sdk macosx \
OBJROOT=build/macosx BUILD_LIBRARY_FOR_DISTRIBUTION=YES SWIFT_INSTALL_OBJC_HEADER=NO
xcodebuild archive -scheme "$NAME-Package" -sdk iphoneos \
OBJROOT=build/iOS BUILD_LIBRARY_FOR_DISTRIBUTION=YES SWIFT_INSTALL_OBJC_HEADER=NO
xcodebuild archive -scheme "$NAME-Package" -sdk iphonesimulator \
OBJROOT=build/simulator  BUILD_LIBRARY_FOR_DISTRIBUTION=YES SWIFT_INSTALL_OBJC_HEADER=NO
xcodebuild archive -scheme "$NAME-Package" -destination 'platform=macOS,arch=x86_64,variant=Mac Catalyst' \
OBJROOT=build/maccatalyst  BUILD_LIBRARY_FOR_DISTRIBUTION=YES SWIFT_INSTALL_OBJC_HEADER=NO

xcodebuild -create-xcframework \
-framework build/macosx/UninstalledProducts/macosx/$NAME.framework \
-framework build/iOS/UninstalledProducts/iphoneos/$NAME.framework \
-framework build/simulator/UninstalledProducts/iphonesimulator/$NAME.framework \
-framework build/maccatalyst/UninstalledProducts/macosx/$NAME.framework \
-output build/$NAME.xcframework
mv build/$NAME.xcframework $NAME.xcframework
zip -r $NAME.xcframework.zip $NAME.xcframework