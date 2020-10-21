#!/bin/bash

echo "# Packages" > README.md
echo >> README.md


	for j in `ls *.Pkg 2>/dev/null`; do 
		k=`grep '^doc' $j | awk -F',' '{print $2}'`
		pkgdesc=`grep '^doc' $j | awk -F',' '{print $3}'`
		ref=`echo $j | sed -e 's/\(.*\).Pkg/\1/g'` 
		nam=`echo $ref | awk -F'/' '{print $1}'` 
		
		
		
                echo "## $nam" >> README.md
		echo "Package $pkgdesc" >> README.md
		echo >> README.md
		for l in `grep '^p,' $j | awk -F',' '{print $2}'`; do
			snam=`echo $l | sed -e 's/\(.*\).Mod/\1/g'`
			echo  >> README.md
			echo  > $snam.md
                        awk '/end-package-description/{p=0};p;/begin-package-description/{p=1}' $snam.Mod >> README.md
                        echo  >> README.md
			echo "#### [MODULE $snam](https://github.com/io-orig/System/blob/main/$snam.md) [(source)](https://github.com/io-orig/System/blob/main/$snam.Mod)" >> README.md
                        awk '/end-module-use-description/{p=0};p;/begin-module-use-description/{p=1}' $snam.Mod >> README.md
			echo "## [MODULE $snam](https://github.com/io-core/$nam/blob/main/$snam.Mod)" >> $snam.md
                        awk '/end-module-develop-description/{p=0};p;/begin-module-develop-description/{p=1}' $snam.Mod >> $snam.md
			echo  >> README.md
			echo  >> $snam.md
			awk '/^ *IMPORT/{print}' $snam.Mod | sed -e 's/IMPORT/**imports\:** `/g' | tr -d ',' | sed -e 's/;/`\n/g' >> README.md
			echo "**Procedures:**" >> README.md
                        echo '```' >> README.md
			echo "$snam.Mod" 
			for p in `grep "PROCEDURE" $snam.Mod | grep '*;\|*(\|* (' | sed -e 's/ *PROCEDURE \(.*\);/\1/g'|tr ' ' '~'`; do
				echo "  `echo $p | tr '~' ' '`" >> README.md
			        echo  >> README.md	
			done
                        echo '```' >> README.md

			awk '/^ *IMPORT/{print}' $snam.Mod | sed -e 's/IMPORT/## Imports\:\n`/g' | tr -d ',' | sed -e 's/;/`\n/g' >> $snam.md
			awk '/^ *CONST/{f=1;count=1} f{ if(/^ *TYPE/){count--; if(count==0) exit}; print}' $snam.Mod | sed -e 's/^ *CONST/## Constants\:\n```\n/g' >> $snam.md
			echo '```' >> $snam.md
			awk '/^ *TYPE/{f=1;count=1} f{if(/^ *VAR/){count--; if(count==0) exit}; print}' $snam.Mod | sed -e 's/^ *TYPE/## Types\:\n```\n/g' >> $snam.md
			echo '```' >> $snam.md
			awk '/^ *VAR/{f=1;count=1} f{ print; if(/^$/){count--; if(count==0) exit}}' $snam.Mod | sed -e 's/^ *VAR/## Variables\:\n```\n/g' >> $snam.md
                        echo '```' >> $snam.md
			
			echo "## Procedures:" >> $snam.md
                        echo "---" >> $snam.md
			echo "$snam.Mod"
			awk '/end-procedure-description/{p=0};p;/begin-procedure-description/{p=1};/end-section-description/{q=0};q;/begin-section-description/{q=1};/^ *PROCEDURE/{print "";print "`"$0"` [(source)](https://github.com/io-orig/System/blob/main/~~~snam~~~.Mod#L"NR")";print ""}' $snam.Mod | sed -e "s/~~~nam~~~/$nam/g" | sed -e "s/~~~snam~~~/$snam/g" >> $snam.md	
                        

		done
	done

