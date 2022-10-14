#!/bin/bash

DATE=$(date +%Y%m%d)
echo $DATE 


FILE=my_file_$(date +%Y%m%d).tar.gz

tar -czf $FILE /Users/jaisoft/Documents/bashScriptProjects

ls



