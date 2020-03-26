NAME=Elva
rm -r build $NAME.xcframework
xcodebuild clean
xcodebuild archive -scheme "$NAME.macOS" -sdk macosx OBJROOT=build/macosx
xcodebuild archive -scheme "$NAME.iOS" -sdk iphoneos OBJROOT=build/iOS
xcodebuild archive -scheme "$NAME.iOS" -sdk iphonesimulator OBJROOT=build/simulator
xcodebuild archive -scheme "$NAME.iOS" -destination 'platform=macOS,arch=x86_64,variant=Mac Catalyst'  OBJROOT=build/maccatalyst
xcodebuild -create-xcframework \
-framework build/macosx/UninstalledProducts/macosx/$NAME.framework \
-framework build/iOS/UninstalledProducts/iphoneos/$NAME.framework \
-framework build/simulator/UninstalledProducts/iphonesimulator/$NAME.framework \
-framework build/maccatalyst/UninstalledProducts/macosx/$NAME.framework \
-output build/$NAME.xcframework
mv build/$NAME.xcframework $NAME.xcframework
zip -r $NAME.xcframework.zip $NAME.xcframework