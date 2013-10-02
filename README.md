Drive Test Shell Script (Mac/*nix)
====================

What
---------------------

I wrote this to test a few USB sticks that seemed to be malfunctioning. 

Use it as such:

	./test.sh some_big_file /Volumes/drive_to_test [times_to_test]

By giving it some big file to use, and some bad drive to test. Optionally, the number of tests you want to perform (default 10).

Make sure that times_to_test x sizeof(some_big_file) can fit in the free space of your drive.

Tested under Mac OS X 10.6 and Linux Mint 15.

How
---------------------

Very simply, this will calculate the MD5 of the testfile, copy the file to the USB drive, then calculate the MD5 of the file on the drive. If the two are different, we have either ran out of space (not currently detected) or we have integrity problems.

**The temporary files are kept on disk for the duration of the test.** After all runs are done, it will re-verify the md5s of the temp files on the disk, just in case they were corrupted while we were writing the next files.

Under certain circumstances, the script will leave the files on drive. This happens on purpose when an integrity problem was detected, or inadvertently if the script is killed/crashes before it is done.

As a bonus it also measures how long it takes for the file to be written and does a basic transfer rate calculation. If you have wildly fluctuating transfer averages that may also indicate problems with the drive. 

**To get good results, try to fill over 50% of the drive you're testing. e.g. no less than 8 test runs x 1G file for a 16G drive.**

Output - Good
---------------------

	$ ./test.sh data.mid /Volumes/qo 5
	
	Test file size: 118M (123717354)
	Test file md5: 316703fbfd1c76d84e62677b96cc604e
	About perform 5 test copies
	Test 1 (tmp filename: /Volumes/qo/84whOWbJEQ8YBO0ftuJEtSxVtyPan2fj)
	Effective Transfer Rate in KB/s: 5034 (~4 MB/s)
	Test 2 (tmp filename: /Volumes/qo/B9SzJOJ79yAr9wVUV28foykCOU5uTRzL)
	Effective Transfer Rate in KB/s: 4646 (~4 MB/s)
	Test 3 (tmp filename: /Volumes/qo/9V11sTZl4qs4lYlcuVpWBXE4L9JV8mNF)
	Effective Transfer Rate in KB/s: 4474 (~4 MB/s)
	Test 4 (tmp filename: /Volumes/qo/VXTgH6mDgdjlH97JVopyfSAEeD4xya8m)
	Effective Transfer Rate in KB/s: 5252 (~5 MB/s)
	Test 5 (tmp filename: /Volumes/qo/l1L3ZBc4q9euNL7UxINF2NtChI)
	Effective Transfer Rate in KB/s: 5491 (~5 MB/s)
	Write tests completed successfully. Re-verifying files
	Data integrity looks ok. Files were verified after their initial copy and just now.
	*** ALL FILES VERIFIED SUCCESSFULLY ***
	Removing temp files from drive...
	Removing /Volumes/qo/84whOWbJEQ8YBO0ftuJEtSxVtyPan2fj
	Removing /Volumes/qo/B9SzJOJ79yAr9wVUV28foykCOU5uTRzL
	Removing /Volumes/qo/9V11sTZl4qs4lYlcuVpWBXE4L9JV8mNF
	Removing /Volumes/qo/VXTgH6mDgdjlH97JVopyfSAEeD4xya8m
	Removing /Volumes/qo/l1L3ZBc4q9euNL7UxINF2NtChI
	Calculating average transfer rate
	Average Transfer rate: 4979 KB/s
	Average Transfer rate: 4 MB/s

Glorious.

Output - Bad
---------------------

	$ ./test.sh data.big /Volumes/qo
	
	Test file size: 1.3G (1360763578)
	Test file md5: ca2907413a0d8191c72d60fa45755c2a
	About perform 15 test copies
	Test 1 (tmp filename: /Volumes/po/NDDMUAVzf8Q96x4TmaxI)
	Effective Transfer Rate in KB/s: 22523 (~21 MB/s)
	Test 2 (tmp filename: /Volumes/po/AMaPdkm28KlIfbsj22qk7EXqs)
	Effective Transfer Rate in KB/s: 23313 (~22 MB/s)
	Test 3 (tmp filename: /Volumes/po/eNDOyI7Z4IkFc9SRLfDlNHh8zK5d1utC)
	Effective Transfer Rate in KB/s: 22147 (~21 MB/s)
	Test 4 (tmp filename: /Volumes/po/0fYYV4jmQQ0vFJ3Eu5aiGYG7Hm8YZpNa)
	Effective Transfer Rate in KB/s: 23313 (~22 MB/s)
	Test 5 (tmp filename: /Volumes/po/Iqm9NOu8ugHl474hM5n9r07GZ24dn3br)
	Effective Transfer Rate in KB/s: 22147 (~21 MB/s)
	Test 6 (tmp filename: /Volumes/po/fC2Sh8FD8tmMdCF1qcHSEAvEdNL0NNAB)
	Effective Transfer Rate in KB/s: 22911 (~22 MB/s)
	Test 7 (tmp filename: /Volumes/po/X2o5ZOXxWQunAH37QZLkRHTEwWuoRbRd)
	Effective Transfer Rate in KB/s: 23313 (~22 MB/s)
	Drive integrity compromised! Expecting /Volumes/po/X2o5ZOXxWQunAH37QZLkRHTEwWuoRbRd to have md5 ca2907413a0d8191c72d60fa45755c2a, but found with acdc6a1f594a41f6150ffae28c5cb640
	The temp files have been left on the drive as evidence

Rage time.

Why
---------------------

Because I wanted to show a seller that both the throughput speed and the integrity of some USB sticks I bought were completely fucked up. Thought I'd share the code, since it worked. 

There's probably over 100 better things than this to use out there, I highly suggest you find one and use it. 

