#!/bin/bash
#set -x
#Split header to different parts; getHeaderParts headerLine
getHeaderParts(){
	line="$1"
	HeaderAll=`echo "$line" | awk -F: '{print $1}'`
	Subject=`echo $line | awk -F: '{print $2}'`
}

#check the headerType; headerTypeChk
headerTypeChk(){
	Tflag=0
	Types="feat change fix refactor remove style docs revert"
	Header=`echo "$HeaderAll" | grep -E ".*\(.*\)"`
	if [ "z$Header" == "z" ]; then
		Type=$HeaderAll
	else
		Type=${Header%%(*}
	fi

	for i in $Types
	do
		if [ "$Type" == "$i" ]; then
			Tflag=1
			break
		fi
	done

	if [ $Tflag -eq 0 ]; then
		echo "ERROR! Header type is incorrect!"
		echo "Supported Header Types:"
		echo -e "\t$Types"
		echo "Header example: \"feat(uboot): subjetct here\""
		let EN=$EN+1
	fi
}

#blank after Header check; blankAftHdrChk Subject
blankAftHdrChk(){
	subjectBlank=`echo "$Subject"  | grep -E "^ .*$"`
	if [ "z$subjectBlank" == "z" ];then
		echo "ERROR! Blank is missing following colon(:)!"
		echo "  Header example: \"feat(uboot): subjetct here\""
		let EN=$EN+1
	fi
}

#subject length check; subjectLenChk SubjectLen
subjectLenChk(){
	if [ $1 -gt 50 -a $1 -le 100 ]; then
		echo "WARNING! Subject too long: 50 ~ 100."
		let WN=$WN+1
	else
		if [ $1 -gt 100 ]; then
			echo "ERROR! Subject too long: >100."
			let EN=$EN+1
		fi
	fi
}

#first letter of subject check; fisrtLetterChk Subject
fisrtLetterChk(){
	SubjectFst1=`echo "$Subject" | grep -E "^ [A-Z]"`
	SubjectFst2=`echo "$Subject" | grep -E "^[A-Z]"`
	if [ "z$SubjectFst1$SubjectFst2" != "z" ]; then
		echo "ERROR! First letter of Subject is up!"
		let EN=$EN+1
	fi
}

#comma(,) and period (.) in subject check; SubjectPaunChk HeaderLine
SubjectPaunChk(){
	SubjectPaun1=`echo "$1" | grep -E "[.,] "`
	SubjectPaun2=`echo "$1" | grep -E "\.$"`
	if [ "z$SubjectPaun1$SubjectPaun2" != "z" ]; then
		echo "ERROR! Comma or period exists in subject!"
		let EN=$EN+1
	fi
}

#blank line between header and body check
blankLineChk(){
	if [ "z$1" != "z" ]; then
		echo "ERROR! There is no blank line between Header and body!"
		let EN=$EN+1
	fi
}

#foterChk footerline
footerChk(){
	Footer=`echo "$1" | \
		grep -E "^[A-Z]+SWITCH+\-[0-9]*$"`
	if [ "z$Footer" == "z" ]; then
		echo "ERROR! Footer format is incorrect!"
		echo -n "  Footer example: \"FESWITCH-34\""
		let EN=$EN+1
	fi
}

#=============================================================================
cnt=0
EN=0
WN=0
HeaderAll=""
Subject=""

HasFooter=0

while read line
do
	end=`echo "$line" | grep -E "Signed-off-by: "`
	if [ "z$end" != "z" ]; then
		if [ $HasFooter -ne 1 ]; then
			echo $HasFooter
			echo "ERROR! There is no legal footer line checked!"
			echo "Footer line example: \"FESWITCH-34\""
			let EN=$EN+1
		else
			break
		fi
	fi

	#Header check
	if [ $cnt -eq 0 ]; then
		getHeaderParts "$line"
		headerTypeChk
		blankAftHdrChk
		let SubjectLen=${#line}-${#HeaderAll}
		subjectLenChk $SubjectLen
		fisrtLetterChk
		SubjectPaunChk "$line"
	fi

	#Blank line check
	if [ $cnt -eq 1 ]; then
		blankLineChk "$line"
	fi

	#Footer check
	footer=`echo "$line" | grep -E "^[A-Z]+SWITCH+\-[0-9]*$"`
	if [ "z$footer" != "z" ]; then
		footerChk "$line"
		HasFooter=1
	fi

	let cnt=$cnt+1
done

echo "total: $EN errors, $WN warnings."
