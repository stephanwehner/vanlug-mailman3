# Convert md file to html, using kramdown / https://kramdown.gettalong.org/
# Usage is simple:
# $ source make_installation_script_html.sh

kramdown debian-8-installation.md > debian-8-installation.html
ed -s debian-8-installation.html <<-END_TOP
0a
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<style>
  pre { border: 1px solid #aaa; padding: 5px; background: #deeff5; width: 99%}
</style>
</head>
<body>
.
$a
w
END_TOP
cat >> debian-8-installation.html <<-END_BOTTOM
</body>
</html>
END_BOTTOM

echo "Wrote file debian-8-installation.html"
