color=`tput setaf 48`
reset=`tput setaf 7`

echo
echo "${color}:Publishing ...${reset}"

TARGET=/Users/carlson/dev/github_pages/app/editor-simple

elm make --optimize Main.elm --output=Demo.js

echo
echo "${color}:Uglifying ...${reset}"

uglifyjs Demo.js -mc 'pure_funcs="F2,F3,F4,F5,F6,F7,F8,F9"' -o Demo.min.js

echo
echo "${color}:Copying ...${reset}"

cp index-remote.html ${TARGET}/index.html
cp Demo.min.js ${TARGET}/


echo
echo "${color}cd /Users/carlson/dev/github_pages${reset}"


# cd /Users/carlson/dev/github_pages
