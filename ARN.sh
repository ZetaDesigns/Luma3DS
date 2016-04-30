cd /home/alex/AuReiNand #Switching to the repo's directory
mkdir source #Creates the source directory in case it's not present
cd source/ #Switches to the source directory
git clone --recursive https://github.com/AuroraWright/Luma3DS.git #Clones ARN repo
cd ./Luma3DS #Switch to ARN repo
oldCommit=$(cat ../../lastCommit)
commitFull=$(git rev-parse HEAD)
commit=$(git rev-parse --short HEAD) #Get latest commit hash
message=$(git log -1 --pretty=%B | head -n1)
ver=$(git describe --tags)
newTag=false
skipCheck=false
lastVer=$(cat ../../lastVer)
echo $ver
echo $lastVer
if [ $ver == $lastVer ]
then
	newTag=true
fi
echo $newTag
if [ "$commit" = "$(cat ../../lastCommit)" ] && [ "$message" = "$(cat ../../lastMessage)" ] && [ newTag=false ]
then
	skipCheck=true
fi
echo $skipCheck
echo $ver > ../../lastVer
if [ $commit = $(cat ../../lastCommit) ] && [ $skipCheck = false ] #Check to see if there's a new commit
then #If there is...
	cd ../ #Clean the directory
	rm -rf Luma3DS #Clean the directory
	echo No updates found! #Echo debug message (The results of crontabs are mailed to you)
	exit #Quit
fi #Will only continue if there's a new commit
if [ "$message" = "$(cat ../../lastMessage)" ]
then
	tail -n +2 "../../current.html" > "../../current.html.tmp" && mv "../../current.html.tmp" "../../current.html"
	rm -f ../../builds/Luma-$oldCommit.zip
fi
echo $message > ../../lastMessage
if [ ${#message} -ge 75 ]
then
	message="$(echo $message | head -c 75)"
	message="$message..."
fi
echo $commit > ../../lastCommit
make #Build Luma3DS
zip -r "Luma-${commit}.zip" ./out #Zip the release with the current date
rm -rf ./out #Delete the release folder
cp Luma*.zip ../../latest.zip
if [ newTag = true ]
then
 cp Luma*.zip ../../release.zip
fi
mv Luma*.zip ../../builds #Move the zipped release to the builds directory
cd /home/alex/AuReiNand/ #switch to the root of the directory
cat current.html > /tmp/tmpcur #Copy the current list of table elements
echo "<tr><td><p><a href="/Luma3DS/builds/Luma-${commit}.zip">Luma-${commit}.zip</a></p></td><td><a href=https://github.com/AuroraWright/Luma3DS/commit/${commitFull}>${commit}</a></td><td>$(date +"%Y-%m-%d")</td><td>${message}</td></tr>" > current.html #Add a new table data element to the top of the list
cat /tmp/tmpcur >> current.html #Add the old table elements to the bottom of the list
cat top.html > index.html #Copy the top half of the webpage to index
cat current.html >> index.html #Copy the list of table elements to the index
cat bottom.html >> index.html #Copy the bottom half of the webpage to index
rm -rf /home/alex/AuReiNand/source/
git add /home/alex/AuReiNand/latest.zip
git add /home/alex/AuReiNand/builds/* #Add all new build files
git add /home/alex/AuReiNand/release.zip

git commit -a -m "Updated builds - Automated Commit Message" #Commit the new build and index
git push #Push to repo
